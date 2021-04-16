//
//  BaseViewController.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 18/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, SWRevealViewControllerDelegate {

    @IBOutlet weak var btnMenu:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if revealViewController() != nil {
            btnMenu.addTarget("revealViewController", action: #selector(SWRevealViewController.revealToggle(_:)), for: UIControl.Event.touchUpInside)
            revealViewController().delegate = self
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
