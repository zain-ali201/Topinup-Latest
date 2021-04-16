//
//  Connection.swift
//  Neighboorhood-iOS-Services
//
//  Created by ZainSeafoam on 07/12/2018.
//  Copyright © 2018 yamsol. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SystemConfiguration
import BRYXBanner

class Connection : NSObject {
    
    static var networkStatus : Bool = false
    
    class func checkInternet() {
        
        let manager = NetworkReachabilityManager(host: "www.google.com")
        manager?.startListening()
        
        manager?.listener = { status in
            
            print("network reachable \(manager!.isReachable)")
            Connection.networkStatus = manager!.isReachable
        }
    }
    
    class func showNetworkErrorView () -> Void{
        
        // show banner
        var connectionBanner = Banner()
        connectionBanner = Banner(title: "Alert", subtitle: "Internet not connected",  image: UIImage(named: "internetConnection") , backgroundColor: UIColor(red: 255/255, green: 93/255, blue: 108/255, alpha: 1))
        connectionBanner.dismissesOnTap = true
        connectionBanner.dismissesOnSwipe = true
        connectionBanner.textColor = UIColor.white
        connectionBanner.show(duration: 2.0)
    }
    
    class func isInternetAvailable() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags)
        {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    
}
