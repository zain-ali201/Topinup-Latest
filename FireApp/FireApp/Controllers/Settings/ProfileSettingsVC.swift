//
//  ProfileVC.swift
//  Topinup
//
//  Created by Zain Ali on 11/16/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import UIKit
import ALCameraViewController
import PhotoCircleCrop

class ProfileSettingsVC: BaseVC, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CircleCropViewControllerDelegate {
    
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var btnPickImage: UIButton!

    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var phoneNumberLbl: UILabel!

    @IBOutlet weak var btnEditUsername: UIButton!
    var user: User!
    
    let circleCropController: CircleCropViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImg.layer.cornerRadius = 75
        userImg.layer.masksToBounds = true

        btnEditUsername.addTarget(self, action: #selector(btnEditUsernameTapped), for: .touchUpInside)
        btnPickImage.addTarget(self, action: #selector(btnPickImageTapped), for: .touchUpInside)
        statusLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(statusLblTapped)))
        setUI()
    }

    //set user's info
    private func setUI()
    {
        user = RealmHelper.getInstance(appRealm).getUser(uid: FireManager.getUid())
        userNameLbl.text = user.userName
        statusLbl.text = user.status
        phoneNumberLbl.text = user.phone

        userImg.image = UIImage(contentsOfFile: user.userLocalPhoto)
    }

    //change status
    @objc private func statusLblTapped()
    {
        let alert = UIAlertController(title: Strings.enter_your_status, message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = Strings.status
            textField.text = self.user.status
        }

        alert.addAction(UIAlertAction(title: Strings.ok, style: .default, handler: { (_) in
            if let newStatus = alert.textFields?[0].text, newStatus.isNotEmpty {
                self.showLoadingViewAlert()

                FireManager.changeMyStatus(status: newStatus,appRealm: appRealm).subscribe(onCompleted: {
                    self.hideLoadingViewAlert()
                    self.setUI()
                }) { (error) in
                    self.hideLoadingViewAlert()
                }.disposed(by: self.disposeBag)
            }
        }))

        alert.addAction(UIAlertAction(title: Strings.cancel, style: .cancel, handler: nil))

        self.present(alert, animated: true)

    }

    //change user's image
    @objc private func btnPickImageTapped() {

//        let cameraViewController = CropImageRequest.getRequest { (image, asset) in
//            if let image = image {
//                self.showLoadingViewAlert()
//                FireManager.changeMyPhoto(image: image,appRealm: appRealm).subscribe(onCompleted: {
//
//                    DispatchQueue.main.async {
//                        self.userImg.image = image
//                        self.setUI()
//                    }
//                    self.hideLoadingViewAlert()
//                }) { (error) in
//                    self.hideLoadingViewAlert()
//                }.disposed(by: self.disposeBag)
//            }
//            self.dismiss(animated: true, completion: nil)
//        }
//
//        present(cameraViewController, animated: true, completion: nil)
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (_) in
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { (_) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))

        alert.addAction(UIAlertAction(title: Strings.cancel, style: .cancel, handler: nil))

        self.present(alert, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImage: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        picker.dismiss(animated: false, completion:
        {
            let circleCropController = CircleCropViewController()
            circleCropController.image = selectedImage
            circleCropController.delegate = self
            circleCropController.modalPresentationStyle = .fullScreen
            self.present(circleCropController, animated: true, completion: nil)
        })
    }
    
    func circleCropDidCropImage(_ image: UIImage)
    {
        self.userImg.image = image
        self.showLoadingViewAlert()
        FireManager.changeMyPhoto(image: image,appRealm: appRealm).subscribe(onCompleted: {

            DispatchQueue.main.async {
                self.userImg.image = image
                self.setUI()
            }
            self.hideLoadingViewAlert()
        }) { (error) in
            self.hideLoadingViewAlert()
        }.disposed(by: self.disposeBag)
    }

    //change user's name
    @objc private func btnEditUsernameTapped()
    {
        let alert = UIAlertController(title: Strings.enter_your_name, message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = Strings.name
            textField.text = self.user.userName
        }

        alert.addAction(UIAlertAction(title: Strings.ok, style: .default, handler: { (_) in
            if let newUserName = alert.textFields?[0].text, newUserName.isNotEmpty {
                self.showLoadingViewAlert()

                FireManager.changeUserName(userName: newUserName,appRealm: appRealm).subscribe(onCompleted: {
                    self.hideLoadingViewAlert()
                    self.setUI()
                }) { (error) in
                    self.hideLoadingViewAlert()
                }.disposed(by: self.disposeBag)
            }
        }))

        alert.addAction(UIAlertAction(title: Strings.cancel, style: .cancel, handler: nil))

        self.present(alert, animated: true)
    }
}
