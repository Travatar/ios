//
//  UINavigationController+Custom.swift
//  Travatar
//
//  Created by Nikolay Derkach on 12/2/17.
//  Copyright © 2017 Nikolay Derkach. All rights reserved.
//

import UIKit

extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.topViewController?.preferredStatusBarStyle ?? .default
    }
}

