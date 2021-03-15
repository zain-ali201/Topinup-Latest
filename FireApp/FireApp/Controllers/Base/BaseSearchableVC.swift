//
//  BaseSearchableVC.swift
//  Topinup
//
//  Created by Zain Ali on 1/2/20.
//  Copyright © 2020 Devlomi. All rights reserved.
//

import UIKit

class BaseSearchableVC: BaseVC, Searchable {
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    private var initialTableViewBottomConstraint: CGFloat = 0
    var tableViewPadding: CGFloat = 20
    var enableAds = false

    fileprivate func loadAd() {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        listenForKeyboard = true
    }

    override func keyboardWillShow(keyboardFrame: CGRect?) {
        if let frame = keyboardFrame {
            let percent:CGFloat = enableAds ? 1.6 : 1.3
            tableViewBottomConstraint.constant = (frame.height / percent)
        }
    }

    override func keyBoardWillHide() {
        tableViewBottomConstraint.constant = initialTableViewBottomConstraint
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if initialTableViewBottomConstraint == 0 {
            initialTableViewBottomConstraint = tableViewBottomConstraint.constant
        }
    }

}
