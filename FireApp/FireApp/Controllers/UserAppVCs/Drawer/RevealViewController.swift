//
//  RevealViewController.swift
//  Neighboorhood-iOS-Services
//
//  Created by Sarim Ashfaq on 10/08/2019.
//  Copyright © 2019 yamsol. All rights reserved.
//

import UIKit

class RevealViewController: SWRevealViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    

    override func transition(from fromViewController: UIViewController, to toViewController: UIViewController, duration: TimeInterval, options: UIView.AnimationOptions = [], animations: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        super.transition(from: fromViewController, to: toViewController, duration: duration, options: options, animations: animations, completion: completion)
    }
}
