//
//  ViewController.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 15/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import UIKit

class MainRegistrationVC: UIViewController
{
    @IBOutlet weak var crossBtn: UIButton!
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var imgSplash: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewInitializers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func viewInitializers()
    {
        crossBtn.setShadow()
        self.btnSignIn.layer.cornerRadius = self.btnSignIn.frame.height/2
        self.btnSignUp.layer.cornerRadius = self.btnSignUp.frame.height/2
    }
    
    @IBAction func crossAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSignInAction(_ sender: Any) {
        self.performSegue(withIdentifier: "toLoginVCSegue", sender: nil)
    }
    
    @IBAction func btnSignUpAction(_ sender: Any) {
        self.performSegue(withIdentifier: "MainToSignUpSegue", sender: nil)
    }
}

