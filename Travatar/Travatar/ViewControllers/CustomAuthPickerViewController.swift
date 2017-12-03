//
//  CustomAuthPickerViewController.swift
//  Travatar
//
//  Created by Nikolay Derkach on 12/1/17.
//  Copyright © 2017 Nikolay Derkach. All rights reserved.
//

import FirebaseAuthUI

class CustomAuthPickerViewController: FUIAuthPickerViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.isTranslucent = false
        title = "Travatar"
        self.navigationItem.leftBarButtonItem = nil
    }
}
