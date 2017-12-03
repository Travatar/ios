//
//  AppDelegate.swift
//  Travatar
//
//  Created by Nikolay Derkach on 11/29/17.
//  Copyright © 2017 Nikolay Derkach. All rights reserved.
//

import Firebase
import SwiftLocation
import TwitterKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        UIApplication.shared.setMinimumBackgroundFetchInterval(86400)

        FirebaseApp.configure()
        Twitter.sharedInstance().start(withConsumerKey:"1a4fFMADfBOgrjtFtlBzePNWP", consumerSecret:"WPZ5V9BORBknk7iBHz3FeJOIVPNHfDDaxmp6j9jK39XRi9kObQ")

        /// If you start monitoring significant location changes and your app is subsequently terminated,
        /// the system automatically relaunches the app into the background if a new event arrives.
        // Upon relaunch, you must still subscribe to significant location changes to continue receiving location events.
        if let _ = launchOptions?[UIApplicationLaunchOptionsKey.location] {
            Locator.subscribeSignificantLocations(onUpdate: { newLocation in
                // This block will be executed with the details of the significant location change that triggered the background app launch,
                // and will continue to execute for any future significant location change events as well (unless canceled).
            }, onFail: { (err, lastLocation) in
                // Something bad has occurred
            })
        }
        // the rest of the init...
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return Twitter.sharedInstance().application(app, open: url, options: options)
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            Locator.currentPosition(usingIP: .freeGeoIP, onSuccess: { loc in
                print("IP location \(loc)")
                UserManager.updateLocation(loc)
                completionHandler(.newData)
            }) { err, _ in
                completionHandler(.failed)
            }
        }
    }
}

