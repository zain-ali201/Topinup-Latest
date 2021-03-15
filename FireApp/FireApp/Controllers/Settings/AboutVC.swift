//
//  AboutVC.swift
//  Topinup
//
//  Created by Zain Ali on 11/16/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import UIKit

class AboutVC: BaseVC {

    @IBOutlet weak var btnWebsite: UIButton!
//    @IBOutlet weak var btnTwitter: UIButton!
    @IBOutlet weak var btnEmail: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnWebsite.addTarget(self, action: #selector(websiteTapped), for: .touchUpInside)
//        btnTwitter.addTarget(self, action: #selector(twitterTapped), for: .touchUpInside)
        btnEmail.addTarget(self, action: #selector(emailTapped), for: .touchUpInside)

    }

    @objc private func websiteTapped() {
        if let url = URL(string: Config.website) {
            UIApplication.shared.open(url)
        }
    }

    @objc private func twitterTapped() {
        if let url = URL(string: Config.twitter) {
            UIApplication.shared.open(url)
        }
    }

    @objc private func emailTapped() {
        if let url = URL(string: "mailto:\(Config.email)") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }

}
