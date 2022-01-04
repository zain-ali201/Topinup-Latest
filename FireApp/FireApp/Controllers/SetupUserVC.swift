//
//  SetupUserVC.swift
//  Topinup
//
//  Created by Zain Ali on 11/28/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import UIKit
import RxSwift
import FirebaseDatabase
import FirebaseStorage
import Kingfisher
import FirebaseMessaging
import Permission
import PhotoCircleCrop

class SetupUserVC: BaseVC, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CircleCropViewControllerDelegate
{
    @IBOutlet weak var imgBtn: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!

    var pickedImage: UIImage?
    var currentUserPhotoUrl = ""
    var currentUserPhotoThumb = ""
    var fetchUserImageDisposable: Disposable!
    override func viewDidLoad() {
        super.viewDidLoad()

        pickedImage = UIImage(named: "avatar")
        
        imgBtn.layer.cornerRadius = 75
        imgBtn.layer.masksToBounds = true
//        userImgContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userImgTapped)))

        //fetch current user image
//        fetchUserImageDisposable = getUserImage().subscribe()

//        fetchUserImageDisposable.disposed(by: disposeBag)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))

    }
    @objc private func doneTapped()
    {
//        Permissions.requestContactsPermissions { (_) in
//            self.completeSetup()
//        }
        signInAction()
    }

    fileprivate func goToRoot()
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Chat", bundle: nil)

        let newViewController = storyBoard.instantiateViewController(withIdentifier: "RootVC") as! RootNavController
        self.dismiss(animated: false) {
            self.view.window?.rootViewController = newViewController
        }
    }
    
    private func saveUserInfo(userName: String, thumb: String, photo: String, localPhoto: String) {
        let user = User()
        user.uid = FireManager.getUid()
        user.userName = userName
        user.thumbImg = thumb
        user.photo = photo
        user.userLocalPhoto = localPhoto
        let defaultStatus = Strings.default_status

        user.status = defaultStatus

        let number = FireManager.number!

        user.phone = number

        //save current uid so the ShareExtension can read/check the current user's info
        RealmHelper.getInstance(appRealm).saveObjectToRealm(object: CurrentUid(uid: FireManager.getUid()), update: true)

        //save current user info
        RealmHelper.getInstance(appRealm).saveObjectToRealm(object: user, update: true)
    }
    
    func signInAction()
    {
        self.view.endEditing(true)
        
        if !Connection.isInternetAvailable()
        {
            print("FIXXXXXXXX Internet not connected")
            Connection.showNetworkErrorView()
            return
        }
        
        let phone = UserDefaults.standard.string(forKey: "phoneNumber") ?? ""
        
        let params : [String : Any] = ["phone" : phone, "password" : "Topinup@123"]
         
        showProgressHud(viewController: self)
        
        Api.userApi.loginUserWith(params: params, completion: { (success:Bool, message : String, user : UserVO?) in
            
            hideProgressHud(viewController: self)
            
            if success
            {
                if user != nil
                {
                    AppUser.setUser(user: user!)
                    self.callApiChangeProfile()
                }
                else
                {
                    self.callApiForSignUp()
                }
            }
            else
            {
                self.callApiForSignUp()
            }
        })
    }
    
    func callApiChangeProfile()
    {
        if !Connection.isInternetAvailable()
        {
            print("FIXXXXXXXX Internet not connected")
            Connection.showNetworkErrorView()
            return;
        }
        
        let firstName = textField.text?.trimmed() ?? ""
        let lastName = txtLastName.text?.trimmed() ?? ""
        let email = txtEmail.text?.trimmed() ?? ""
        let phone = UserDefaults.standard.string(forKey: "phoneNumber") ?? ""
        
        let params = [
            "firstName" : firstName,
            "lastName" : lastName,
            "email" : email,
            "phone" : phone
        ]
        
        showProgressHud(viewController: self)
        Api.userApi.updateProfile(params: params as [String : Any], completion: { (success:Bool, message : String, user : UserVO?) in
            
            hideProgressHud(viewController: self)
            
            if success
            {
                if user != nil
                {
                    AppUser.setUser(user: user!)
                    self.updateFireBaseUser()
                }
                else
                {
                    self.showInfoAlertWith(title: "Internal Error", message: "Please try again later.")
                }
            }
            else
            {
                self.showInfoAlertWith(title: "Error", message: message)
            }
        })
    }
    
    func updateFireBaseUser()
    {
        let userName = "\(textField.text ?? "") \(txtLastName.text ?? "")"
        
        showLoadingViewAlert()

        if let image = pickedImage
        {
            FireManager.changeMyPhotoObservable(image: image, appRealm: appRealm)
                .flatMap { (thumb, localUrl, photoUrl) -> Observable<DatabaseReference> in

                    let userDict = self.getUserInfoDict(userName: userName, photoUrl: photoUrl, thumb: thumb, filePath: localUrl)

                    //save user info locally
                    self.saveUserInfo(userName: userName, thumb: thumb, photo: photoUrl, localPhoto: localUrl)

                    let number = FireManager.number!

                    let countryCode = ContactsUtil.extractCountryCodeFromNumber(number)

                    //set default country code
                    UserDefaultsManager.setCountryCode(countryCode)
                    //save user info in Firebase
                    return FireConstants.usersRef.child(FireManager.getUid()).rx.updateChildValues(userDict).asObservable()

                }.flatMap { ref -> Observable<([User], [String], Void)> in
                    //fetch previous groups if exists
                    let fetchGroups = GroupManager.fetchUserGroups()
                    //fetch previous broadcasts if exists
                    let fetchBroadcasts = BroadcastManager.fetchBroadcasts(uid: FireManager.getUid())
                    //combine both observables and execute them

                    let subscribeToTopic = self.subscribeToHisOwnTopic()
                    let observables = Observable.zip(fetchGroups, fetchBroadcasts, subscribeToTopic)

                    return observables
                }.subscribe(onError: { error in
                    self.hideAndShowAlert()
                }, onCompleted: {
                        //set the user info saved to true
                        UserDefaultsManager.setUserInfoSaved(true)
                        self.goToRoot()
                    }).disposed(by: disposeBag)
        }
        else
        {
            self.saveUserInfo(userName: userName, thumb: "", photo: "", localPhoto: "")
            self.goToRoot()
        }
    }
    
    func callApiForSignUp()
    {
        self.view.endEditing(true)
        if !Connection.isInternetAvailable()
        {
            print("FIXXXXXXXX Internet not connected")
            Connection.showNetworkErrorView()
            return;
        }
        
        let email = txtEmail.text?.trimmed()
        let firstName = textField.text?.trimmed()
        let lastName = txtLastName.text?.trimmed()
        let phone = UserDefaults.standard.string(forKey: "phoneNumber")
        
        let params : [String : Any] = ["firstName" : firstName!, "lastName" : lastName!, "email" : email!, "password" : "Topinup@123", "countryCode": "", "phone": phone ?? ""]
        
        showProgressHud(viewController: self)
        
        var imagesArray = [UIImage]()
        if let image = pickedImage
        {
            imagesArray.append(image)
        }
        
        Api.userApi.signUpUser(with: params, profileImage: imagesArray, completion: { (successful, msg , user) in
            hideProgressHud(viewController: self)
            
            if successful
            {
                print(user!)
                AppUser.setUser(user: user!)
                UserApi().updateFirebaseToken(params: ["deviceToken": UserDefaults.standard.string(forKey: AppUser.KEY_DEVICE_TOKEN) ?? "", "deviceType":"ios", "role":"provider"]) { (success, message) in
                }
                self.updateFireBaseUser()
            }
            else
            {
                self.showInfoAlertWith(title: "Oooppppsss", message: msg)
            }
        })
    }
        
    private func getUserInfoDict(userName: String, photoUrl: String, thumb: String, filePath: String? = nil) -> [String: Any] {
        var dict = [String: Any]()
        dict["photo"] = photoUrl
        dict["name"] = userName
        dict["phone"] = FireManager.number!
        dict["thumbImg"] = thumb

        let defaultStatus = Strings.default_status
        dict["status"] = defaultStatus

        return dict
    }
    
    private func hideAndShowAlert() {
        self.hideLoadingViewAlert {
            self.showAlert(type: .error, message: Strings.error)
        }
    }

    @IBAction func userImgTapped(button: UIButton) {
        let permission: Permission = .photos

        let alert = permission.deniedAlert // or permission.disabledAlert

        alert.title = "In order to set an image please allow image access."
        alert.message = nil
        alert.cancel = Strings.cancel
        alert.settings = Strings.settings

        permission.deniedAlert = alert

//        permission.request { status in
//            let vc = CropImageRequest.getRequest { (image, asset) in
//                if let image = image {
//                    self.pickedImage = image
//                    self.imgBtn.setImage(image, for: .normal)
//
//                    self.dismiss(animated: true, completion: nil)
//                }
//            }
//            self.present(vc, animated: true, completion: nil)

//        }
    
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        
        let photoAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        photoAlert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (_) in
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        photoAlert.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { (_) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))

        photoAlert.addAction(UIAlertAction(title: Strings.cancel, style: .cancel, handler: nil))

        self.present(photoAlert, animated: true)
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
        self.pickedImage = image
        self.imgBtn.setImage(image, for: .normal)
    }

    fileprivate func loadImageFromUrl(_ url: URL) {
        
    }

    private func getUserImage() -> Observable<(String, String)> {

        return FireConstants.usersRef.child(FireManager.getUid())
            .rx.observeSingleEvent(.value).asObservable().map { snapshot -> (String, String) in
                if let photoUrl = snapshot.childSnapshot(forPath: "photo").value as? String, let thumb = snapshot.childSnapshot(forPath: "thumbImg").value as? String {

                    self.loadImageFromUrl(URL(string: photoUrl)!)
                    self.currentUserPhotoUrl = photoUrl
                    self.currentUserPhotoThumb = thumb
                    return (photoUrl, thumb)
                } else {
                    return ("", "")
                }
        }
    }

    //this will fetch the 'defaultUserProfilePhoto' on the server
    //it will be called if this user did not choose an image and he does not have a previous image on the server
    private func getDefaultUserProfilePhoto() -> Observable<(String, String, String)> {
        return FireConstants.mainRef.child("defaultUserProfilePhoto").rx.observeSingleEvent(.value).asObservable().flatMap { snap -> Observable<(URL, String)> in
            if let imgUrl = snap.value as? String {

                if let url = URL(string: imgUrl) {
                    self.loadImageFromUrl(url)
                }
                let filePath = DirManager.generateUserProfileImage()

                return FireConstants.storage.reference(forURL: imgUrl).rx.write(toFile: filePath).map { ($0, imgUrl) }
            }
            return Observable.error(NSError(domain: "user did not upload default user profile photo", code: -5, userInfo: nil))

        }.map { tuple -> (String, String, String) in
            let filePath = tuple.0.path
            let imgUrl = tuple.1

            let img = UIImage(contentsOfFile: filePath)
            let thumb = img!.toProfileThumbImage.circled().toBase64StringPng()
            self.currentUserPhotoThumb = thumb

            return (filePath, imgUrl, thumb)
        }
    }

    //we will make a 'Dummy Topic' to subscribe this user
    //so when this user sends a message to the group he will not receive it.
    private func subscribeToHisOwnTopic() -> Observable<Void> {
        return Messaging.messaging().subscribeToTopicRx(topic: FireManager.getUid()).asObservable()
    }
}
