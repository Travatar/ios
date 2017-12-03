//
//  UserManager.swift
//  Travatar
//
//  Created by Nikolay Derkach on 11/30/17.
//  Copyright © 2017 Nikolay Derkach. All rights reserved.
//

import Foundation
import Firebase
import TwitterKit
import CoreLocation
import SwiftLocation

let UserManager = _UserManager()

class _UserManager {

    var ref: DatabaseReference!

    init() {
        self.ref = Database.database().reference()
    }

    func updateTwitterToken() {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }

        let authToken = Twitter.sharedInstance().sessionStore.session()?.authToken
        let authSecret = Twitter.sharedInstance().sessionStore.session()?.authTokenSecret

        self.ref.child("users/\(currentUser.uid)/twitter/token").setValue(authToken)
        self.ref.child("users/\(currentUser.uid)/twitter/token_secret").setValue(authSecret)
    }

    func clearTwitterToken() {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }

        self.ref.child("users/\(currentUser.uid)/twitter").removeValue()
    }

    func updateLocation(_ location: CLLocation) {
        if let uid = Auth.auth().currentUser?.uid {
            let latitude = location.coordinate.latitude + (Double(arc4random()) / Double(UINT32_MAX) / 10 - 0.05)
            let longitude = location.coordinate.longitude + (Double(arc4random()) / Double(UINT32_MAX) / 10 - 0.05)
            self.ref.child("users/\(uid)/location").setValue(["lat": latitude, "lon": longitude])
        }
    }

    func subscribeForLocationUpdates() {
        if Auth.auth().currentUser != nil && CLLocationManager.authorizationStatus() == .authorizedAlways {
            Locator.subscribeSignificantLocations(onUpdate: { newLocation in
                print("New location: \(newLocation)")
                UserManager.updateLocation(newLocation)
            }) { (err, lastLocation) -> (Void) in
                print("Failed with err: \(err)")
            }
        }
    }
}
