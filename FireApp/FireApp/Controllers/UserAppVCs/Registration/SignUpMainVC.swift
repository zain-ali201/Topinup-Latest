//
//  SignUpMainVC.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 18/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class SignUpMainVC: UIViewController, UITextFieldDelegate,  UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewFirstName: UIView!
    @IBOutlet weak var viewLastName: UIView!
    @IBOutlet weak var viewEmailAddress: UIView!
    @IBOutlet weak var viewPassword: UIView!
    @IBOutlet weak var viewPhone: UIView!
    @IBOutlet weak var viewTermsAndCondition: UIView!
    
    @IBOutlet weak var imgProfile: UIImageView!
    
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtEmailAddress: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    
    @IBOutlet weak var btnEyePassword: UIButton!
    
    @IBOutlet weak var btnAgree: UIButton!
    @IBOutlet weak var btnTermsOfService: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var btnSignInScreen: UIButton!
    @IBOutlet weak var viewBackgroundImage: UIView!
    
    var profileImageArray = [UIImage]()
    var isPasswordEyeEnable :Bool!
    var params : NSMutableDictionary!
    var isTermsEnable = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.shared.enable = true
        self.viewInitializer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func viewInitializer()
    {
        self.viewFirstName.layer.cornerRadius = self.viewFirstName.frame.height/2
        self.viewLastName.layer.cornerRadius = self.viewLastName.frame.height/2
        self.viewEmailAddress.layer.cornerRadius = self.viewEmailAddress.frame.height/2
        self.viewPassword.layer.cornerRadius = self.viewPassword.frame.height/2
        self.viewPhone.layer.cornerRadius = self.viewPhone.frame.height/2
        self.btnSignUp.layer.cornerRadius = self.btnSignUp.frame.height/2
        self.imgProfile.layer.cornerRadius = self.imgProfile.frame.height/2
        isPasswordEyeEnable = false
        txtPassword.isSecureTextEntry = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpMainVC.keyboardWasShown(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpMainVC.keyboardWillBeHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpMainVC.tappedImageView
            ))
        
        viewBackgroundImage.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func btnSignInScreenAction(_ sender: Any) {
        
        if let vcs = self.navigationController?.viewControllers {
            
            for previousVC in vcs {
                if previousVC is UserLoginVC {
                    self.navigationController!.popToViewController(previousVC, animated: true)
                    return
                }
            }
        }
        self.performSegue(withIdentifier: "signupToLoginSegue", sender: nil)
    }
    
    @IBAction func btnSignUpAction(_ sender: Any) {
        
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

            Api.userApi.isEmailAlreadyUsed(userEmail: txtEmailAddress.text!, completion: { (emailAvailable, message) in

                hideProgressHud(viewController: self)

                if (!emailAvailable)
                {
                    self.showInfoAlertWith(title: "Alert", message: "Email already exist")
                }
                else
                {
                    self.callApiForSignUp()
                    
                }
            })
        }
        else
        {
            self.showInfoAlertWith(title: "Info Required", message: validationResult)
        }

    }
    
    func callApiForSignUp() {
        
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
            params["countryCode"] = Locale.getCountryCode()
            
            showProgressHud(viewController: self)
            
            Api.userApi.signUpUser(with: (self.params as! [String : Any]), profileImage: self.profileImageArray, completion: { (successful, msg , user) in
                hideProgressHud(viewController: self)
                
                if successful
                {
                    print(user!)
                    AppUser.setUser(user: user!)
                    UserApi().updateFirebaseToken(params: ["deviceToken": UserDefaults.standard.string(forKey: AppUser.KEY_DEVICE_TOKEN) ?? "", "deviceType":"ios", "role":"provider"]) { (success, message) in
                    }
                    let storyboardId = "Dashboard_ID"
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let initViewController = storyboard.instantiateViewController(withIdentifier: storyboardId)
                    UIApplication.shared.keyWindow?.rootViewController = initViewController
                }
                else
                {
                    self.showInfoAlertWith(title: "Oooppppsss", message: msg)
                }
            })
        }
        else
        {
            self.showInfoAlertWith(title: "Info Required", message: validationResult)
        }
    }
    
    @IBAction func btnAgreeAction(_ sender: Any) {
        
        if isTermsEnable
        {
            isTermsEnable = false
            btnAgree.setImage(UIImage(named: "iconcheckboxunselected"), for: .normal)
        }
        else
        {
            isTermsEnable = true
            btnAgree.setImage(UIImage(named: "iconcheckboxselected"), for: .normal)
        }
    }
    
    @IBAction func btnTermsOfServiceAction(_ sender: Any) {
        
    }
    
    @IBAction func btnEyePasswordAction(_ sender: Any) {
        
        if isPasswordEyeEnable == true
        {
            isPasswordEyeEnable = false
            txtPassword.isSecureTextEntry = true
            btnEyePassword.setImage(UIImage(named:"eyeDisable"), for: .normal)
        }
        else
        {
            isPasswordEyeEnable = true
            txtPassword.isSecureTextEntry = false
            btnEyePassword.setImage(UIImage(named:"eyeEnable"), for: .normal)
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
    
    func validateFields() -> String
    {
        var result = kResultIsValid
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        
        let firstName = txtFirstName.text?.trimmed()
        let lastName = txtLastName.text?.trimmed()
        let email = txtEmailAddress.text?.trimmed()
        let password = txtPassword.text?.trimmed()
        let phone = txtPhone.text?.trimmed()
        let defaultImage = UIImage(named: "imagePlaceholder")
        
        
//        if (self.imgProfile.image?.isEqualToImage(image: defaultImage!))!
//        {
//            result = "Please select a profile image"
//            return result
//        }
        
        if (firstName?.length())! < 1
        {
            result = "Please enter your first name"
            return result
        }
        else if firstName?.rangeOfCharacter(from: characterset.inverted) != nil {
            result = "Please enter a valid firstname"
            return result
        }
        else if (lastName?.length())! < 1 {
            result = "Please enter your last name"
            return result
        }
        else if lastName?.rangeOfCharacter(from: characterset.inverted) != nil {
            result = "Please enter a valid lastname"
            return result
        }
        else if email?.isValidEmail() == false
        {
            result = "Please enter a valid email address"
            return result
        }
        else if (password?.length())! < 6 || (password?.length())! > 20
        {
            result = "Please enter a password between 6 to 20 characters"
            return result
        }
//        else if (phone?.length())! < 3 {
//            result = "Please enter a phone number"
//            return result
//        }
        
        else if !isTermsEnable {
            result = "Please Agree with Terms of Services"
            return result
        }else if profileImageArray.isEmpty
        {
            result = "Please choose profile picture"
            return result
        }else if (phone?.length())! < 1 {
            result = "Please enter your phone number"
            return result
        }
        
        self.params = [
            "firstName" : firstName!,
            "lastName" : lastName!,
            "email" : email!,
            "password" : password!,
            "phone": phone!]
        
        return result
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
    }
    
    @objc func tappedImageView()
    {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        
        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            let actionSheetController: UIAlertController = UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
            let cancelActionButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
                print("Cancel")
            }
            actionSheetController.addAction(cancelActionButton)
            
            let cameraActionButton: UIAlertAction = UIAlertAction(title: "Use Camera", style: .default) { action -> Void in
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
            
            actionSheetController.addAction(cameraActionButton)
            
            let galleryActionButton: UIAlertAction = UIAlertAction(title: "Choose From Gallery", style: .default) { action -> Void in
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }
            
            actionSheetController.addAction(galleryActionButton)
            self.present(actionSheetController, animated: true, completion: nil)
        } else {
            // If on Simulator, open the gallery straight away
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImage: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        // Save image
        
        profileImageArray.removeAll()
        imgProfile.image = selectedImage
        profileImageArray.append(selectedImage!)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let maxLength = 25
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    
}
