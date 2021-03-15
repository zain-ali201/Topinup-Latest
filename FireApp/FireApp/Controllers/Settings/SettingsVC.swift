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
        
        user = RealmHelper.getInstance(appRealm).getUser(uid: FireManager.getUid())
        
        lblName.text = user.userName
        lblPhone.text = user.phone
        
        usrImg.image = UIImage(contentsOfFile: user.userLocalPhoto)
    }

    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        tabBarController?.navigationItem.title = "Settings"
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
