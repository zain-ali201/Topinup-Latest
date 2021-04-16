//
//  ChangePasswordVC.swift
//  Neighboorhood-iOS-Services-User
//
//  Created by Zain ul Abideen on 07/01/2018.
//  Copyright © 2018 yamsol. All rights reserved.
//

import UIKit

class ChangePasswordVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtOldPassword: UITextField!
    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var btnEyeCurrentPassword: UIButton!
    @IBOutlet weak var btnEyeNewPassword: UIButton!
    @IBOutlet weak var btnEyeConfirmNewPassword: UIButton!
    
    var isbtnEyeCurrentPasswordEnable :Bool!
    var isbtnEyeNewPasswordEnable :Bool!
    var isbtnEyeConfirmNewPasswordEnable :Bool!
    
    @IBAction func btnEyeCurrentPasswordAction(_ sender: Any) {
        
        if isbtnEyeCurrentPasswordEnable == true
        {
            isbtnEyeCurrentPasswordEnable = false
            txtOldPassword.isSecureTextEntry = true
            btnEyeCurrentPassword.setImage(UIImage(named:"eyeDisable"), for: .normal)
        }
        else
        {
            isbtnEyeCurrentPasswordEnable = true
            txtOldPassword.isSecureTextEntry = false
            btnEyeCurrentPassword.setImage(UIImage(named:"eyeEnable"), for: .normal)
        }
    }
    
    @IBAction func btnEyeNewPasswordAction(_ sender: Any) {
        
        if isbtnEyeNewPasswordEnable == true
        {
            isbtnEyeNewPasswordEnable = false
            txtNewPassword.isSecureTextEntry = true
            btnEyeNewPassword.setImage(UIImage(named:"eyeDisable"), for: .normal)
        }
        else
        {
            isbtnEyeNewPasswordEnable = true
            txtNewPassword.isSecureTextEntry = false
            btnEyeNewPassword.setImage(UIImage(named:"eyeEnable"), for: .normal)
        }
    }
    
    @IBAction func btnEyeConfirmNewPasswordAction(_ sender: Any) {
        
        if isbtnEyeConfirmNewPasswordEnable == true
        {
            isbtnEyeConfirmNewPasswordEnable = false
            txtConfirmPassword.isSecureTextEntry = true
            btnEyeConfirmNewPassword.setImage(UIImage(named:"eyeDisable"), for: .normal)
        }
        else
        {
            isbtnEyeConfirmNewPasswordEnable = true
            txtConfirmPassword.isSecureTextEntry = false
            btnEyeConfirmNewPassword.setImage(UIImage(named:"eyeEnable"), for: .normal)
        }
    }
    
    
    
    
    
    
    var params : NSMutableDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnSend.layer.cornerRadius = self.btnSend.frame.height/2
        
        isbtnEyeCurrentPasswordEnable = false
        isbtnEyeNewPasswordEnable = false
        isbtnEyeConfirmNewPasswordEnable = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpMainVC.keyboardWasShown(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpMainVC.keyboardWillBeHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    func callApiForChangePassword() {
        
        self.view.endEditing(true)
        self.scrollView.setContentOffset(.zero, animated: true)
        let validationResult = validateFields()
        if (validationResult == kResultIsValid)
        {
            if !Connection.isInternetAvailable()
            {
                print("FIXXXXXXXX Internet not connected")
                Connection.showNetworkErrorView()
                return;
            }
            
            showProgressHud(viewController: self)
            Api.userApi.changePassword(params: (self.params)! as! [String : Any], completion: { (successful, msg) in
                hideProgressHud(viewController: self)
                
                if successful
                {
                    self.showInfoAlert(title: "Success", message: msg, handler: {
                        let _ = self.navigationController?.popViewController(animated: true)
                    })
                }
                else
                {
                    self.showInfoAlertWith(title: "Alert", message: msg)
                }
            })
            
        }
        else
        {
            self.showInfoAlertWith(title: "Info Required", message: validationResult)
        }
    }
    
    
    @IBAction func btnSendAction(_ sender: Any) {
        self.callApiForChangePassword()
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
    
    func validateFields() -> String
    {
        var result = kResultIsValid
        
        let oldPassword = txtOldPassword.text?.trimmed()
        let newPassword = txtNewPassword.text?.trimmed()
        let verifyPassword = txtConfirmPassword.text?.trimmed()
        
        if (oldPassword?.length())! < 6 || (oldPassword?.length())! > 20 {
            result = "Please enter an old password between 6 to 20 characters"
            return result
        } else if (newPassword?.length())! < 6 || (newPassword?.length())! > 20 {
            result = "Please enter a new password between 6 to 20 characters"
            return result
        } else if (verifyPassword?.length())! < 6 || (verifyPassword?.length())! > 20 {
            result = "Please enter a confirm password between 6 to 20 characters"
            return result
        }
        
        self.params = [
            "currentPassword" : oldPassword!,
            "newPassword" : newPassword!,
            "verifyPassword" : verifyPassword!
            ]
        return result
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
