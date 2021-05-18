//
//  SettingsVC.swift
//  Topinup
//
//  Created by Zain Ali on 11/16/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import UIKit


class SettingsVC: UIViewController {

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
        let alert: UIAlertController = UIAlertController(title: nil, message:"Are you sure you want to delete your account?", preferredStyle: .alert)
        
        let cancel: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            print("Cancel")
        }
        
        let delete: UIAlertAction = UIAlertAction(title: "Delete", style: .destructive)
        { action -> Void in
            
            let user = FireManager.auth().currentUser

            user?.delete { error in
                if let error = error
                {
                    print(error)
                }
                else
                {
                    UserDefaultsManager.setAgreedToPolicy(bool: false)
                    let mainVC = self.storyboard!.instantiateViewController(withIdentifier: "mainVc")
                    UIApplication.shared.keyWindow?.rootViewController = mainVC
                }
            }
        }
        
        alert.addAction(cancel)
        alert.addAction(delete)
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
    }
}
