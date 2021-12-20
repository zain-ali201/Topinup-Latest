//
//  AppUser.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 18/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import Foundation

class AppUser : NSObject {
    
    internal static let KEY_LOGGED_IN="login";
    internal static let KEY_USER="the_user";
    internal static let KEY_USER_ID:String="user_id";
    internal static let KEY_DEVICE_TOKEN:String="device_token";
    internal static let KEY_USERNAME:String="Username";
    internal static let KEY_REMEMBER_ME:String="RememberMe";
    internal static let KEY_USER_PIC:String="userPic";
    internal static let KEY_APP_VERSION : String = "appVersion"
    internal static let KEY_UPDATE_FLAG : String = "updateFlag"
    
    
    
    //MARK: - Loggged in
    internal static func setLoggedIn(language:Bool) {
        UserDefaults.standard.set(language, forKey: KEY_LOGGED_IN);
        UserDefaults.standard.synchronize()
    }
    internal static func getLoggedIn() -> Bool? {
        
        if (UserDefaults.standard.bool(forKey: KEY_LOGGED_IN))
        {
            return (UserDefaults.standard.bool(forKey: KEY_LOGGED_IN))
        }
        
        return false
    }
    
    //MARK: - USER
    
    internal static func setUser(user : UserVO) {
        let userData = NSKeyedArchiver.archivedData(withRootObject: user)
        UserDefaults.standard.set(userData,forKey:KEY_USER);
        UserDefaults.standard.synchronize()
    }
    
    
    internal static func getUser() -> UserVO? {
        let userData:NSData? = (UserDefaults.standard.object(forKey: KEY_USER) as? NSData)
        if userData == nil {
            return nil;
        }
        let user : UserVO = NSKeyedUnarchiver.unarchiveObject(with: userData! as Data) as! UserVO;
        return user;
    }
    
    
    internal static func removeuser()
    {
        UserDefaults.standard.removeObject(forKey: KEY_USER)
    }
    
    //MARK: - Device Token
    internal static func setToken(token:String)
    {
        print(token);
        UserDefaults.standard.set(token, forKey: KEY_DEVICE_TOKEN);
        UserDefaults.standard.synchronize()
    }
    
    internal static func getToken() -> String? {
        
        return (UserDefaults.standard.string(forKey: KEY_DEVICE_TOKEN))
    }
    
    //MARK: - USERID
    internal static func setUserId(userId:String) {
        UserDefaults.standard.set(userId,forKey:KEY_USER_ID);
        UserDefaults.standard.synchronize()
    }
    internal static func getUserId() -> String? {
        
        return (UserDefaults.standard.string(forKey: KEY_USER_ID))
    }
    internal static func removeUserId()
    {
        UserDefaults.standard.removeObject(forKey: KEY_USER_ID)
    }
    
    internal static func clearAllUserData()
    {
        UserDefaults.standard.removeObject(forKey: KEY_USER)
        UserDefaults.standard.removeObject(forKey: KEY_USER_ID)
        UserDefaults.standard.removeObject(forKey: KEY_LOGGED_IN)
        UserDefaults.standard.removeObject(forKey: KEY_DEVICE_TOKEN)
    }
    
    internal static func setAppVersion(ver : String)
    {
        UserDefaults.standard.set(ver, forKey: KEY_APP_VERSION);
        UserDefaults.standard.synchronize()
        
    }
    
    internal static func getAppVersion () -> String?
    {
        if  let ver = UserDefaults.standard.value(forKey: KEY_APP_VERSION) as? String
        {
            return ver
        }
        
        return nil
    }
    
    internal static func removeAppVersion()
    {
        UserDefaults.standard.removeObject(forKey: KEY_APP_VERSION)
        UserDefaults.standard.removeObject(forKey: KEY_UPDATE_FLAG)
    }
    
    
    
}
