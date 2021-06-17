//
//  TabBarVC.swift
//  Topinup
//
//  Created by Zain Ali on 9/18/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import UIKit
class TabBarVC: UITabBarController {


    override func viewDidLoad() {
        super.viewDidLoad()

        if !UserDefaultsManager.userDidLogin() {
            NotificationCenter.default.post(name: Notification.Name("userDidLogin"), object: nil)
            
            //request permissions for first time
            Permissions.requestContactsPermissions(completion: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.navigationItem.title = " "
    }
    
    func goToUsersVC() {
        performSegue(withIdentifier: "toUsersVC", sender: nil)
    }
    
    func segueToChatVC(user:User) {
          performSegue(withIdentifier: "toChatVC", sender: user)
      }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let controller = segue.destination as? UsersVCNavController {
            controller.navigationDelegate = self
        } else if let controller = segue.destination as? ChatViewController, let user = sender as? User {
            controller.initialize(user: user,delegate: self)
        }
    }
    
   
}

extension TabBarVC: DismissViewController {
    func presentCompletedViewController(user: User) {
    
       goToChatVC(user: user)
    }
}


extension TabBarVC: ChatVCDelegate {
    func goToChatVC(user:User){
        segueToChatVC(user: user)
    }
}


