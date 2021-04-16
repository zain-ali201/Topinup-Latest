//
//  SignUpProviderVC.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 18/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import UIKit

class SignUpProviderVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imgProvider: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewSelectProvider: UIView!
    @IBOutlet weak var lblProvider: UILabel!
    @IBOutlet weak var viewAddType: UIView!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var viewBackgroundPicker: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var profileImageArray = [UIImage]()
    var providerNamesList = [String]()
    var dummyProviderNames = ["First","Second","Third","Fourth","Fifth"]
    var selectedProviderName = ""
    var params : NSMutableDictionary!
    var newProvider = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewInitializer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func viewInitializer() {
        
        self.viewSelectProvider.layer.cornerRadius = self.viewSelectProvider.frame.height/2
        self.viewAddType.layer.cornerRadius = self.viewAddType.frame.height/2
        self.btnSignUp.layer.cornerRadius = self.btnSignUp.frame.height/2
        
        self.btnDone.layer.borderWidth = 1
        self.btnDone.layer.borderColor = UIColor.gray.cgColor
        self.btnDone.layer.cornerRadius = 8
        imgProvider.layer.cornerRadius = imgProvider.frame.size.height/2
        
        let tapProviderType = UITapGestureRecognizer(target: self, action: #selector(SignUpProviderVC.showBodyTypePicker))
        viewSelectProvider.addGestureRecognizer(tapProviderType)
        
        let tapGestureAddType = UITapGestureRecognizer(target: self, action: #selector(SignUpProviderVC.showAddTypePopup))
        self.viewAddType.addGestureRecognizer(tapGestureAddType)
        
        imgProvider.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpProviderVC.tappedImageView))
        imgProvider.addGestureRecognizer(tapGesture)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.getProviderList()
    }
    
    @objc func showBodyTypePicker() {
        
        self.viewBackgroundPicker.isHidden = false
        self.pickerView.reloadAllComponents()
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
        imgProvider.image = selectedImage
        profileImageArray.append(selectedImage!)
        
        picker.dismiss(animated: true, completion: nil)
    }
    

    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.providerNamesList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.providerNamesList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if self.providerNamesList.isEmpty {
            selectedProviderName = ""
        } else {
            selectedProviderName = self.providerNamesList[row]
        }
    }
    
    @IBAction func btnDoneAction(_ sender: Any) {
        
        self.viewBackgroundPicker.isHidden = true
        lblProvider.text = selectedProviderName
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSignUp(_ sender: Any) {
        
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
            Api.userApi.signUpUser(with: (self.params as! [String : Any]), profileImage: self.profileImageArray, completion: { (successful, msg , user) in
                
                hideProgressHud(viewController: self)
                
                if successful
                {
                    //                    self.showInfoAlertWith(title: "Hurray", message: "Sign Up Worked")
                    AppUser.setUser(user: user!)
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
    
    func getProviderList() {
        
        if !Connection.isInternetAvailable()
        {
            print("FIXXXXXXXX Internet not connected")
            Connection.showNetworkErrorView()
            return;
        }
        
        showProgressHud(viewController: self)
        
        Api.userApi.providerList(completion: { (success, message,list) in
            
            hideProgressHud(viewController: self)
            
            if (success)
            {
                self.providerNamesList = self.dummyProviderNames
                
//                self.providerNamesList.removeAll()
//                for i in list {
//                    self.providerNamesList.append(i)
//                }
            }
            else
            {
                self.showInfoAlertWith(title: "Error", message: message)
            }
        })
    }
    
    
    @objc func showAddTypePopup() {
        let alert = UIAlertController(title: "Add Type", message: "Add new provider type", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.text = ""
        })
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (action) -> Void in
            let textField = alert?.textFields![0]
            print("Text field: \(String(describing: textField?.text!))")
            
            if (String(describing: textField?.text!).length()) < 1
            {
                print("Do not add in providers")
            } else {
                self.newProvider = String(describing: textField?.text!)
                self.providerNamesList.append(self.newProvider)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func validateFields() -> String
    {
        var result = kResultIsValid
        
        let defaultImage = UIImage(named: "imagePlaceholder")
        
//        if (self.imgProvider.image?.isEqualToImage(image: defaultImage!))!
//        {
//            result = "Pleasse select a profile image"
//            return result
//        }
//        else
        if profileImageArray.isEmpty
        {
            result = "Please choose profile picture"
            return result
        }else if (lblProvider.text?.isEmpty)!
        {
            result = "Please select a provider"
            return result
        }
        
        print(self.params)
        self.params["type"] = lblProvider.text!
        
        print(self.params)
        return result
    }
    

}
