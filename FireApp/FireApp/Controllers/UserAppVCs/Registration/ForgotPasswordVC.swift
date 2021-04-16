//
//  ForgotPasswordVC.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 19/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    
    var params : [String : Any]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewInitializer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func viewInitializer() {
        
        self.btnSend.layer.cornerRadius = self.btnSend.frame.height/2
        
        NotificationCenter.default.addObserver(self, selector: #selector(ForgotPasswordVC.keyboardWasShown(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ForgotPasswordVC.keyboardWillBeHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSendAction(_ sender: Any) {
        
        self.view.endEditing(true)
        self.scrollView.setContentOffset(.zero, animated: true)
        let email = txtEmail.text?.trimmed()
        if email?.length() == 0
        {
            self.showInfoAlertWith(title: "Info Required", message: "Please enter an email")
        }
        else if email?.isValidEmail() == false
        {
            self.showInfoAlertWith(title: "Validation Failed", message: "Please enter a valid email address")
        }
        else
        {
            if !Connection.isInternetAvailable()
            {
                print("FIXXXXXXXX Internet not connected")
                Connection.showNetworkErrorView()
                return;
            }
            
           showProgressHud(viewController: self)
            
            Api.userApi.forgotPasswordOf(email: email!) { (isSuccessful, message) in
                
                hideProgressHud(viewController: self)
                
                self.showInfoAlertWith(title: "", message: message)
            }
        }
        
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
    
    
    
    
}
