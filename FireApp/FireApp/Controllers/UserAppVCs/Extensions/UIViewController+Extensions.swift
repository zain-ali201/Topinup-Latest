//
//  UIViewController+Extensions.swift
//  Neighboorhood-iOS-Services
//
//  Created by Sarim Ashfaq on 10/08/2019.
//  Copyright © 2019 yamsol. All rights reserved.
//

import Foundation
import UIKit
import SideMenu

extension UIViewController {
    func setupSideMenu(){
//        SideMenuManager.default.menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "SideMenuNavigationControllerId") as? UISideMenuNavigationController
//        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.view)
//        SideMenuManager.default.menuAnimationBackgroundColor = UIColor.clear
//        SideMenuManager.default.menuPresentMode = .menuSlideIn
        
        // SideMenuVC
        
        
        
        SideMenuManager.default.leftMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "SideMenuNavigationControllerId") as? SideMenuNavigationController
       
        SideMenuManager.default.addPanGestureToPresent(toView: navigationController!.navigationBar)
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.view)
        
        
        var settings = SideMenuSettings()
        settings.presentationStyle = .menuSlideIn
        SideMenuManager.default.leftMenuNavigationController?.settings = settings
        
        
        
    }
}
