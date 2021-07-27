//
//  SettingsVC.swift
//  Topinup
//
//  Created by Zain Ali on 11/16/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import UIKit
import FirebaseAuth
import MessageUI

class SettingsVC: UIViewController, MFMailComposeViewControllerDelegate
{
    @IBOutlet weak var usrImg: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    var user: User!


    override func viewDidLoad()
    {
        super.viewDidLoad()

        usrImg.layer.cornerRadius = 60
        usrImg.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        tabBarController?.navigationItem.title = "Settings"
        
        user = RealmHelper.getInstance(appRealm).getUser(uid: FireManager.getUid())
        lblName.text = user.userName
        lblPhone.text = user.phone
        print(user.userName)
        usrImg.image = UIImage(contentsOfFile: user.userLocalPhoto)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func deleteBtnACtion(_ button: UIButton)
    {
        let alert: UIAlertController = UIAlertController(title: nil, message:"Are you sure to delete your account?", preferredStyle: .alert)
        
        let no: UIAlertAction = UIAlertAction(title: "NO", style: .cancel) { action -> Void in
            print("Cancel")
        }
        
        let yes: UIAlertAction = UIAlertAction(title: "YES", style: .destructive)
        { action -> Void in
            
            let delAlert: UIAlertController = UIAlertController(title: "By deleting your account:", message:"- Your account info and profile photo will be deleted\n- Your all Whatsapp groups and message history will be deleted", preferredStyle: .actionSheet)
            
            let cancel: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
                print("Cancel")
            }
            
            let delete: UIAlertAction = UIAlertAction(title: "Delete", style: .destructive)
            { action -> Void in
                
                let user = FireManager.auth().currentUser
                
                if user != nil
                {
//                    FireConstants.usersRef.child(user!.uid).remove().addOnSuccessListener { user?.delete().addOnCompleteListener
//                        {
//
//                        }
//                    }
                    
                    FireManager.deleteUserAccount(uid: user!.uid)

                    UserDefaultsManager.setAgreedToPolicy(bool: false)
                    let mainVC = self.storyboard!.instantiateViewController(withIdentifier: "mainVc")
                    UIApplication.shared.keyWindow?.rootViewController = mainVC
                }
            }
            
            delAlert.addAction(cancel)
            delAlert.addAction(delete)
            self.present(delAlert, animated: true, completion: nil)
        }
        
        alert.addAction(no)
        alert.addAction(yes)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func clickBtnACtion(_ button: UIButton)
    {
        if button.tag == 1
        {
            performSegue(withIdentifier: "toNotifications", sender: nil)
        }
        else if button.tag == 2
        {
            performSegue(withIdentifier: "toChatSettings", sender: nil)
            
        }
        else if button.tag == 3
        {
             if let url = URL(string: Config.privacyPolicyLink)
             {
                UIApplication.shared.open(url)
             }
        }
        else if button.tag == 4
        {
            performSegue(withIdentifier: "toAboutSettings", sender: nil)
        }
        else if button.tag == 5
        {
            performSegue(withIdentifier: "toProfile", sender: nil)
        }
        else if button.tag == 6
        {
            sendEmail()
        }
    }
    
    func sendEmail()
    {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([Config.email])
            mail.setSubject("Topinup - Feedback")

            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
