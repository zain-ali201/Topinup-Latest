//
//  MainVC.swift
//  Topinup
//
//  Created by Zain Ali on 1/28/20.
//  Copyright © 2020 Devlomi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseUI
import RxSwift
import Permission

class MainVC: UIViewController
{
    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var continueBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func privacyBtnTapped(_ sender: AnyObject)
    {
        if let url = URL(string: Config.privacyPolicyLink) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func checkBtnAction(_ sender: AnyObject)
    {
        checkBtn.setImage(UIImage(named: "checkbox"), for: .normal)
        continueBtn.isEnabled = true
    }

    @IBAction func continueBtnTapped(_ sender: AnyObject)
    {
        self.login()
    }
    
    fileprivate func goToRoot()
    {
        UserDefaultsManager.setAgreedToPolicy(bool: true)
        let storyBoard: UIStoryboard = UIStoryboard(name: "Chat", bundle: nil)

        if UserDefaultsManager.isUserInfoSaved()
        {
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "RootVC") as! RootNavController
            self.dismiss(animated: false) {
                self.view.window?.rootViewController = newViewController
            }
        }
        else
        {
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "SetupUserNavVC") as! UINavigationController
            self.view.window?.rootViewController = newViewController
        }
    }
    
    private func login()
    {
        FUIAuth.defaultAuthUI()?.delegate = self
        let phoneProvider = FUIPhoneAuth.init(authUI: FUIAuth.defaultAuthUI()!)
        FUIAuth.defaultAuthUI()?.providers = [phoneProvider]
        phoneProvider.signIn(withPresenting: self, phoneNumber: "")
    }
}

extension MainVC: FUIAuthDelegate {

    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let error = error as? NSError {
            login()
        } else {
            //save temp user to fetch the groups if existe and avoid nulls
            if let authResult = authDataResult, let phoneNumber = authResult.user.phoneNumber {
                
                let uid = authResult.user.uid
                
                let user = User()
                user.phone = phoneNumber
                user.uid = uid

                RealmHelper.getInstance(appRealm).saveObjectToRealm(object: user, update: true)
                print(phoneNumber)
                UserDefaults.standard.set(phoneNumber, forKey: "phoneNumber")
                goToRoot()
            }
        }
    }
}
