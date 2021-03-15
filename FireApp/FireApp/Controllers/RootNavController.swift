//
//  RootNavController.swift
//  Topinup
//
//  Created by Zain Ali on 9/22/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import UIKit

class RootNavController: UINavigationController, UIGestureRecognizerDelegate {

/// Custom back buttons disable the interactive pop animation
/// To enable it back we set the recognizer to `self`
    override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1

    }




}
