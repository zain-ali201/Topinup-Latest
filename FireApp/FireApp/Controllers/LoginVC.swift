//
//  LoginVC.swift
//  Topinup
//
//  Created by Zain Ali on 11/26/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseUI
import RxSwift
import Permission


class LoginVC: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()


        view.backgroundColor = .white

    }

    private func login() {
        FUIAuth.defaultAuthUI()?.delegate = self

        let phoneProvider = FUIPhoneAuth.init(authUI: FUIAuth.defaultAuthUI()!)
        FUIAuth.defaultAuthUI()?.providers = [phoneProvider]
        phoneProvider.signIn(withPresenting: self, phoneNumber: "")
    }
    
    fileprivate func goToRoot() {


        let storyBoard: UIStoryboard = UIStoryboard(name: "Chat", bundle: nil)

        if UserDefaultsManager.isUserInfoSaved() {

            let newViewController = storyBoard.instantiateViewController(withIdentifier: "RootVC") as! RootNavController
            self.dismiss(animated: false) {
                self.view.window?.rootViewController = newViewController
            }
        } else {

            let newViewController = storyBoard.instantiateViewController(withIdentifier: "SetupUserNavVC") as! UINavigationController

            self.view.window?.rootViewController = newViewController

        }
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        login()
    }

}









extension LoginVC: FUIAuthDelegate {

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
                
                goToRoot()
            }

        }
    }
}

