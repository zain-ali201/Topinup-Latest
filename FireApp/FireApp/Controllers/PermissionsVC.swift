//
//  PermissionsVC.swift
//  Topinup
//
//  Created by Zain Ali on 12/1/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import UIKit
import Permission

class PermissionsVC: BaseVC {
    @IBOutlet weak var topViewLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        
        checkPermissions()
        
    }

    private func checkPermissions() {

        let titlesColors: [PermissionStatus: UIColor] = [
                .notDetermined: .white,
                .authorized: .green,
                .denied: .orange
        ]


        let contacts = PermissionButton(.contacts)
        let camera = PermissionButton(.camera)
        let microphone = PermissionButton(.microphone)
        let photos = PermissionButton(.photos)
        let notifications = PermissionButton(.notifications)

        let permissionSet = PermissionSet(contacts, camera, microphone, photos, notifications)
        if permissionSet.status == .authorized {
            goToRoot()
        } else {
            permissionSet.delegate = self




            contacts.setTitles([
                .notDetermined:Strings.permissions_contacts_not_determined,
                .authorized: Strings.permissions_contacts_authorized,
                .denied: Strings.permissions_contacts_denied
                ])


            camera.setTitles([
                .notDetermined: Strings.permissions_camera_not_determined,
                .authorized: Strings.permissions_camera_authorized,
                .denied: Strings.permissions_camera_denied
                ])


            microphone.setTitles([
                .notDetermined: Strings.permissions_mic_not_determined,
                .authorized: Strings.permissions_mic_authorized,
                .denied: Strings.permissions_mic_denied
                ])


            photos.setTitles([
                .notDetermined:Strings.permissions_photos_not_determined,
                .authorized: Strings.permissions_photos_authorized,
                .denied: Strings.permissions_photos_denied
                ])



            notifications.setTitles([
                .notDetermined: Strings.permissions_notifications_not_determined,
                .authorized: Strings.permissions_notifications_authorized,
                .denied: Strings.permissions_notifications_denied
                ])



            //

            contacts.setTitleColors(titlesColors)
            camera.setTitleColors(titlesColors)
            microphone.setTitleColors(titlesColors)
            photos.setTitleColors(titlesColors)
            notifications.setTitleColors(titlesColors)

    



            let stackView = UIStackView(arrangedSubviews: [contacts, camera, microphone, photos, notifications])
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical

            view.addSubview(stackView)

            stackView.centerXAnchor.constraint(equalTo: topViewLabel.centerXAnchor).isActive = true
            stackView.topAnchor.constraint(equalTo: topViewLabel.bottomAnchor, constant: 30).isActive = true
            view.addSubview(stackView)




        }

    }
    
    fileprivate func goToRoot() {
         let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

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
}

extension PermissionsVC: PermissionSetDelegate {
    func permissionSet(_ permissionSet: PermissionSet, didRequestPermission permission: Permission) {
        if permissionSet.status == .authorized {
            goToRoot()
        }
    }
}
