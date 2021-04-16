//
//  ProfileVC.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 18/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import UIKit
import UserNotifications

class ProfileVC: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SetLocationViewControllerDelegate {

    @IBOutlet weak var viewBackgroundCredentials: UIView!
    @IBOutlet weak var viewBackgroundAddress: UIView!
    @IBOutlet weak var viewBackgroundChangePassword: UIView!
    @IBOutlet weak var viewBackgroundImageProfile: UIView!
    @IBOutlet weak var viewBackgroundFirstLastName: UIView!
    @IBOutlet weak var viewBackgroundDisplayName: UIView!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    
    @IBOutlet weak var notificationBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    var isEditMode = false
    var user = AppUser.getUser()
    var params : NSMutableDictionary!
    
    var selectedLocation : LocationVO?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(user!)
        
        //self.btnEdit.isHidden = true
        
        self.viewBackgroundCredentials = self.shadowViewForBorder(backgroundView: self.viewBackgroundCredentials)
        self.viewBackgroundAddress = self.shadowViewForBorder(backgroundView: self.viewBackgroundAddress)
        self.viewBackgroundChangePassword = self.shadowViewForBorder(backgroundView: self.viewBackgroundChangePassword)
        
        let tapChangePassword = UITapGestureRecognizer(target: self, action: #selector(ProfileVC.gotoChangePassword))
        viewBackgroundChangePassword.addGestureRecognizer(tapChangePassword)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ProfileVC.updateImage))
        self.viewBackgroundImageProfile.addGestureRecognizer(tap)
        
        let tapLocation = UITapGestureRecognizer(target: self, action: #selector(ProfileVC.openMap))
        self.viewBackgroundAddress.addGestureRecognizer(tapLocation)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpMainVC.keyboardWasShown(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpMainVC.keyboardWillBeHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.setupSideMenu()
        notificationBtn.setTitle("Turn \(self.isRegisteredForRemoteNotifications() ? "Off":"On") Notifications", for: .normal)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.editModeChanges()
        notificationBtn.setTitle("Turn \(self.isRegisteredForRemoteNotifications() ? "Off":"On") Notifications", for: .normal)
    }
    
    func isRegisteredForRemoteNotifications() -> Bool {
        if #available(iOS 10.0, *) {
            var isRegistered = false
            let semaphore = DispatchSemaphore(value: 0)
            let current = UNUserNotificationCenter.current()
            current.getNotificationSettings(completionHandler: { settings in
                if settings.authorizationStatus != .authorized {
                    isRegistered = false
                } else {
                    isRegistered = true
                }
                semaphore.signal()
            })
            _ = semaphore.wait(timeout: .now() + 5)
            return isRegistered
        } else {
            return UIApplication.shared.isRegisteredForRemoteNotifications
        }
    }
    
    func editModeChanges() {
        
        if AppUser.getUser() != nil {
            
            user = AppUser.getUser()
            
            self.lblEmail.text = user?.email!
            self.txtName.text = user?.displayName!
            self.txtPhoneNumber.text = user?.phone!
            self.lblAddress.text = user?.address!
            
            if user?.latitude != nil && user?.longitude != nil && user?.address != nil
            {
                selectedLocation = LocationVO(lat: (user?.latitude)!, long: (user?.longitude)!, addr: (user?.address)!)
                
                if selectedLocation?.address == "" && selectedLocation?.latitude == 0.0 && selectedLocation?.longitude == 0.0
                {
                    self.lblAddress.text = "Please choose location"
                }
                else
                {
                    self.lblAddress.text = selectedLocation?.address!
                }
            }
            else
            {
                self.lblAddress.text = "Please choose location"
            }
            
            var newStr = user?.profileImageURL! as! String
            newStr.remove(at: (newStr.startIndex))
            let imageUrl = URLConfiguration.ServerUrl + newStr
            
            if let url = URL(string: imageUrl) {
                self.imgProfile.kf.setImage(with: url)
            }
            
            self.imgProfile.layer.cornerRadius = self.imgProfile.frame.height/2
        }
        
        if isEditMode
        {
            self.btnEdit.setTitle("Done", for: .normal)
            self.txtName.isEnabled = true
            self.txtPhoneNumber.isEnabled = true
            self.viewBackgroundFirstLastName.isHidden = false
            self.viewBackgroundDisplayName.isHidden = true
            
            self.txtFirstName.text = user?.firstname
            self.txtLastName.text = user?.lastname
            self.lblEmail.textColor = UIColor.lightGray
            self.lblAddress.textColor = UIColor.lightGray
            self.viewBackgroundAddress.isUserInteractionEnabled = false
            self.viewBackgroundImageProfile.isUserInteractionEnabled = true
        }
        else
        {
            self.btnEdit.setTitle("Edit", for: .normal)
            self.txtName.isEnabled = false
            self.txtPhoneNumber.isEnabled = false
            self.viewBackgroundFirstLastName.isHidden = true
            self.viewBackgroundDisplayName.isHidden = false
            
            self.lblEmail.textColor = UIColor.black
            self.lblAddress.textColor = UIColor.black
            self.viewBackgroundAddress.isUserInteractionEnabled = true
            self.viewBackgroundImageProfile.isUserInteractionEnabled = false
        }
    }
    
    @objc func openMap()
    {
        self.performSegue(withIdentifier: "profileToSetLocationSegue", sender: nil)
    }
    
    func locationSelected(location : LocationVO)
    {
        self.selectedLocation = location
        
        if isEditMode == false
        {
            self.updateProfileLocation()
        }
    }
    
    @objc func gotoChangePassword() {
        self.performSegue(withIdentifier: "ChangePasswordSegue", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnEditAction(_ sender: Any) {
        
        if isEditMode
        {
            self.callApiChangeProfile()
            isEditMode = false
            self.editModeChanges()
        }
        else
        {
            isEditMode = true
            self.editModeChanges()
        }
    }
    
    @IBAction func changeNotificationSetting(_ sender: UIButton) {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
            })
        }
    }
    
    func callApiChangeProfile() {
        
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
            Api.userApi.updateProfile(params: self.params as! [String : Any], completion: { (success:Bool, message : String, user : UserVO?) in
                
                hideProgressHud(viewController: self)
                
                if success
                {
                    if user != nil
                    {
                        AppUser.setUser(user: user!)
                        self.isEditMode = false
                        self.editModeChanges()
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
    
    func updateProfileLocation() {
        
        let validationResult = validateFieldsForAddress()
        if (validationResult == kResultIsValid)
        {
            if !Connection.isInternetAvailable()
            {
                print("FIXXXXXXXX Internet not connected")
                Connection.showNetworkErrorView()
                return;
            }
            
            showProgressHud(viewController: self)
            Api.userApi.updateProfile(params: self.params as! [String : Any], completion: { (success:Bool, message : String, user : UserVO?) in
                
                hideProgressHud(viewController: self)
                
                if success
                {
                    if user != nil
                    {
                        AppUser.setUser(user: user!)
                        self.editModeChanges()
                    }
                    else
                    {
                        self.showInfoAlertWith(title: "Error", message: "Please try again...")
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
        
        let firstName = txtFirstName.text?.trimmed()
        let lastName = txtLastName.text?.trimmed()
        let phone = txtPhoneNumber.text?.trimmed()
        let validatePhone = validatePhoneNumber(value: phone!)
        
        if (firstName?.length())! < 3
        {
            result = "Please enter your first name"
            return result
        }
        else if (lastName?.length())! < 3 {
            result = "Please enter your last name"
            return result
        }
        else if (phone?.length())! < 3 {
            result = "please enter a phone number"
            return result
        }
        else if validatePhone == false
        {
            result = "please enter valid phone number"
            return result
        }
        
        self.params = [
            "firstName" : firstName!,
            "lastName" : lastName!,
            "email" : self.lblEmail.text!,
            "phone" : phone!,
        ]
        
        return result
    }
    
    func validateFieldsForAddress() -> String
    {
        var result = kResultIsValid
        
        if selectedLocation == nil
        {
            result = "Please choose address"
            return result
        }
        
        self.params = [
            
            "address": selectedLocation?.address!,
            "latitude" : selectedLocation?.latitude!,
            "longitude" : selectedLocation?.longitude!
        ]
        
        return result
    }
    
    @objc func updateImage() {
        
        print("Tapped Update Image")
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        
        if (UIImagePickerController.isSourceTypeAvailable(.camera))
        {
            let actionSheetController: UIAlertController = UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
            
            let cancelActionButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
                print("Cancel")
            }
            actionSheetController.addAction(cancelActionButton)
            
            
            
            let cameraActionButton: UIAlertAction = UIAlertAction(title: "Use Camera", style: .default)
            { action -> Void in
                
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
            actionSheetController.addAction(cameraActionButton)
            
            let galleryActionButton: UIAlertAction = UIAlertAction(title: "Choose From Gallery", style: .default)
            { action -> Void in
                
                imagePickerController.sourceType = .photoLibrary
                
                
                self.present(imagePickerController, animated: true, completion: nil)
            }
            actionSheetController.addAction(galleryActionButton)
            
            self.present(actionSheetController, animated: true, completion: nil)
        }
        else
        {
            // If on Simulator, open the gallery straight away
            
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    //Image Picker Controller Delgates
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImage: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        if !Connection.isInternetAvailable() {
            print("FIXXXXXXXX Internet not connected")
            Connection.showNetworkErrorView()
            return;
        }
        
        Api.userApi.changeProfileImage(image: selectedImage ?? UIImage()) { (suc, msg, url) in
            if suc {
                hideProgressHud(viewController: self)
                self.showInfoAlertWith(title: "Alert", message: msg)
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: URL(string: url)!) //make sure your image in this url does exist, otherwise
                    {
                        DispatchQueue.main.async {
                            
                            self.imgProfile.image = UIImage(data: data)
                        }
                    }
                }
            }
            else
            {
                hideProgressHud(viewController: self)
                self.showInfoAlertWith(title: "Alert", message: msg)
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? SetLocationVC
        {
            controller.delegate = self
        }
    }
    
    func shadowViewForBorder(backgroundView: UIView) -> UIView {
        
        var backView = UIView()
        backView = backgroundView
        
        backView.layer.shadowColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1).cgColor
        backView.layer.shadowOpacity = 1
        backView.layer.shadowOffset = CGSize.zero
        backView.layer.shadowRadius = 4
        return backView
    }
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }

}
