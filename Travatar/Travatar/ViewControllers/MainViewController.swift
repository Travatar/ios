//
//  MainViewController.swift
//  Travatar
//
//  Created by Nikolay Derkach on 11/29/17.
//  Copyright © 2017 Nikolay Derkach. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftLocation
import Firebase
import FirebaseTwitterAuthUI
import TwitterKit

class MainViewController: UIViewController {

    var ref: DatabaseReference!
    fileprivate(set) var auth: Auth?

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()

        auth = Auth.auth()
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.providers = [FUITwitterAuth()]
        authUI?.delegate = self

        auth?.addStateDidChangeListener { (auth, user) in
            guard user != nil else {
                let authViewController = authUI?.authViewController();
                self.present(authViewController!, animated: true, completion: nil)
                return
            }
        }

        UserManager.subscribeForLocationUpdates()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            Locator.currentPosition(usingIP: .freeGeoIP, onSuccess: { loc in
                print("IP location \(loc)")
                UserManager.updateLocation(loc)
            }) { err, _ in
                print("\(err)")
            }
        }
    }

    // MARK: - IBAction

    @IBAction func logoutTapped(_ sender: Any) {
        let store = Twitter.sharedInstance().sessionStore
        if let userID = store.session()?.userID {
            store.logOutUserID(userID)
        }

        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

extension MainViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {

        UserManager.updateTwitterToken()
        NotificationCenter.default.post(name: NSNotification.Name("UpdateTwitterSwitch"), object: nil)

        UserManager.subscribeForLocationUpdates()
    }

    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        let vc = CustomAuthPickerViewController(nibName: "LoginScreen", bundle: nil, authUI: FUIAuth.defaultAuthUI()!)
        return vc
    }
}
