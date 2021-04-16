//
//  HelpdeskVC.swift
//  SwiftPopup_Example
//
//  Created by CatchZeng on 2018/1/10.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import SwiftPopup

class HelpdeskVC: SwiftPopup {

    @IBOutlet var pupView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pupView.layer.cornerRadius = 5.0
    }
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        dismiss()

    }
    
    @IBAction func dialPhone(_ sender: UIButton) {
            
            guard let number = URL(string: "tel://+921234567") else { return }
            UIApplication.shared.open(number)
        //dismiss()
        }
        
        @IBAction func sendEmail(_ sender: Any) {
            
            
            let url = NSURL(string: "mailto:volgo@mail.com")
            UIApplication.shared.openURL(url as! URL)
            
            //dismiss()
        }
    
    
}
