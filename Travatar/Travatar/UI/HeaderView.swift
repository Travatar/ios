//
//  HeaderView.swift
//  Travatar
//
//  Created by Nikolay Derkach on 12/2/17.
//  Copyright © 2017 Nikolay Derkach. All rights reserved.
//

import UIKit
import SwiftLocation
import CoreLocation

class HeaderView: UIView {
    class func instanceFromNib() -> HeaderView {
        return UINib(nibName: "HeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! HeaderView
    }
    @IBAction func authTapped(_ sender: Any) {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            Locator.requestAuthorizationIfNeeded(.always)
        } else {
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
}
