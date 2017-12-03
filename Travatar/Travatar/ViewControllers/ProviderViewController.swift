//
//  ProviderViewController.swift
//  Travatar
//
//  Created by Nikolay Derkach on 11/30/17.
//  Copyright © 2017 Nikolay Derkach. All rights reserved.
//

import UIKit
import FirebaseAuth
import TwitterKit
import SwiftLocation
import CoreLocation

class ProviderViewController: UITableViewController {

    let kTwitter = "twitter.com"

    @IBOutlet weak var twitterSwitch: UISwitch!
    lazy var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.allowsSelection = false

        configureTwitterSwitch()

        twitterSwitch.addTarget(self, action: #selector(self.switchChanged), for: UIControlEvents.valueChanged)

        NotificationCenter.default.addObserver(self, selector: #selector(self.configureTwitterSwitch), name: NSNotification.Name("UpdateTwitterSwitch"), object: nil)

        locationManager.delegate = self
    }

    // MARK: - Selectors

    @objc func configureTwitterSwitch() {
        if let providerData = Auth.auth().currentUser?.providerData {
            for data in providerData {
                if data.providerID == kTwitter {
                    twitterSwitch.setOn(true, animated: true)
                    return
                }
            }
            twitterSwitch.setOn(false, animated: true)
        }
    }

    @objc func switchChanged(mySwitch: UISwitch) {
        if mySwitch === twitterSwitch {
            if !mySwitch.isOn {
                // trying to unlink
                guard let currentUser = Auth.auth().currentUser else {
                    self.twitterSwitch.setOn(true, animated: true)
                    return
                }

                currentUser.unlink(fromProvider: kTwitter) { (user, error) in
                    if error != nil {
                        self.twitterSwitch.setOn(true, animated: true)
                    } else {
                        UserManager.clearTwitterToken()
                    }
                }
            } else {
                // trying to link
                guard let currentUser = Auth.auth().currentUser else {
                    self.twitterSwitch.setOn(false, animated: true)
                    return
                }

                Twitter.sharedInstance().logIn(completion: { (session, error) in
                    if let session = session {
                        let credential = TwitterAuthProvider.credential(withToken: session.authToken, secret: session.authTokenSecret)

                        currentUser.link(with: credential) { (user, error) in
                            if error != nil {
                                self.twitterSwitch.setOn(false, animated: true)
                            } else {
                                UserManager.updateTwitterToken()
                            }
                        }
                    }
                })
            }
        }
    }
}

extension ProviderViewController: UITabBarDelegate {
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            return nil
        } else {
            return HeaderView.instanceFromNib()
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            return 0.0
        } else {
            return 84.0
        }
    }
}

extension ProviderViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            UserManager.subscribeForLocationUpdates()
        }

        tableView.reloadData()
    }
}

