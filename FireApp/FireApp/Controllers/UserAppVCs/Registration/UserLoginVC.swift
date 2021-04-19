//
//  LoginVC.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 15/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import UIKit

class UserLoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var btnEye: UIButton!
    @IBOutlet weak var crossBtn: UIButton!
    
    var isEyeEnable :Bool!
    var params : [String : Any]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewInitializer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(UserLoginVC.keyboardWasShown(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(UserLoginVC.keyboardWillBeHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func viewInitializer() {
        
        crossBtn.setDarkShadow()
        self.btnSignIn.layer.cornerRadius = self.btnSignIn.frame.height/2
        
        isEyeEnable = false
        txtPassword.isSecureTextEntry = true
    }
    
    @IBAction func crossAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnEyeAction(_ sender: Any)
    {
        if isEyeEnable == true
        {
            isEyeEnable = false
            txtPassword.isSecureTextEntry = true
            btnEye.setImage(UIImage(named:"eyeDisable"), for: .normal)
        }
        else
        {
            isEyeEnable = true
            txtPassword.isSecureTextEntry = false
            btnEye.setImage(UIImage(named:"eyeEnable"), for: .normal)
        }
    }
    
    @IBAction func btnForgotPasswordAction(_ sender: Any) {
        self.view.endEditing(true)
        self.scrollView.setContentOffset(.zero, animated: true)
        
        self.performSegue(withIdentifier: "forgotPasswordSegue", sender: self)
    }
    
    @IBAction func navBtnSignUpAction(_ sender: Any) {
        self.view.endEditing(true)
        self.scrollView.setContentOffset(.zero, animated: true)
        
        if let vcs = self.navigationController?.viewControllers {
            
            for previousVC in vcs {
                if previousVC is SignUpMainVC {
                    self.navigationController!.popToViewController(previousVC, animated: true)
                    return
                }
            }
        }
        
        self.performSegue(withIdentifier: "LoginToSignUpSegue", sender: nil)
    }
    
    @objc func keyboardWasShown(notification:NSNotification)
    {
        let info = notification.userInfo!
        var keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.scrollView.convert(keyboardFrame, to: nil)
        var contentInset1:UIEdgeInsets = self.scrollView.contentInset
        contentInset1.bottom = (keyboardFrame.size.height)
        self.scrollView.contentInset = contentInset1
    }
    
    @objc func keyboardWillBeHidden()
    {
        let contentInset1:UIEdgeInsets = .zero
        self.scrollView.contentInset = contentInset1
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        return true
    }
    
    @IBAction func btnSignInAction(_ sender: Any) {
        self.view.endEditing(true)
        self.scrollView.setContentOffset(.zero, animated: true)
        let validationResult = validateFields()
        if (validationResult == kResultIsValid)
        {
            print("All data is valid")
            
            if !Connection.isInternetAvailable()
            {
                print("FIXXXXXXXX Internet not connected")
                Connection.showNetworkErrorView()
                return;
            }
            
            showProgressHud(viewController: self)
            
            Api.userApi.loginUserWith(params: self.params, completion: { (success:Bool, message : String, user : UserVO?) in
                
                hideProgressHud(viewController: self)
                
                if success
                {
                    if user != nil
                    {
                        AppUser.setUser(user: user!)
                        
                        let storyboardId = "Dashboard_ID"
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let initViewController = storyboard.instantiateViewController(withIdentifier: storyboardId)
                        UIApplication.shared.keyWindow?.rootViewController = initViewController
                    }
                    else
                    {
                        self.showInfoAlertWith(title: "Internal Error", message: "Logged In but user object not returned")
                    }
                }
                else
                {
                    self.showInfoAlertWith(title: "Error", message: message)
                }
            })
        }
        else
        {
            self.showInfoAlertWith(title: "Info Required", message: validationResult)
        }
    }
    
    func validateFields() -> String
    {
        var result = kResultIsValid
        
       
        
        let email = txtEmail.text?.trimmed()
        let password = txtPassword.text?.trimmed()
        
        if email?.isValidEmail() == false
        {
            result = "Please enter a valid email address"
            return result
        }
        else if (password?.length())! < 1
        {
            result = "Please enter a password"
            return result
        }
        
        self.params = ["usernameOrEmail" : email!,
                       "password" : password!
                       ]
        
        return result
    }
    

}
