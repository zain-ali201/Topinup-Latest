//
//  MessagesListVO.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 03/05/2018.
//  Copyright © 2018 yamsol. All rights reserved.
//

import Foundation

class MessageListVO : NSObject {
    
    var _id : String!
    var created : String!
    var message : String!
    var msgCount : Int!
    
    var jobID : String!
    
    var clientID : String!
    var clientDisplayName : String!
    var clinetPhone : String!
    var clientProfileImageURL : String!
    
    var categoryID : String!
    var categoryDescription : String!
    var categoryImageURL : String!
    var categoryName : String!
    
    var providerID : String!
    var providerDisplayName : String!
    var providerPhone : String!
    var providerProfileImageURL : String!
    
    override init() {
        super.init()
        
        _id = ""
        created = ""
        message = ""
        jobID = ""
        clientID = ""
        msgCount = 0
        clientDisplayName = ""
        clinetPhone = ""
        clientProfileImageURL = ""
        providerID = ""
        providerDisplayName = ""
        providerPhone = ""
        providerProfileImageURL = ""
        
    }
    
    init(dictionary : NSDictionary) {
        
        
        
        
        _id = dictionary.value(forKey: "_id") as? String
        created = dictionary.value(forKey: "created") as? String
        message = dictionary.value(forKey: "message") as? String
        msgCount = dictionary.value(forKey: "msgCount") as? Int
        
        if let dict = dictionary.value(forKey: "client") as? NSDictionary
        {
            clientID = dict.value(forKey: "_id") as? String
            clientDisplayName = dict.value(forKey: "displayName") as? String
            clinetPhone = dict.value(forKey: "phone") as? String
            clientProfileImageURL = dict.value(forKey: "profileImageURL") as? String
        }
        
        if let dict = dictionary.value(forKey: "job") as? NSDictionary
        {
            jobID = dict.value(forKey: "_id") as? String
            
            if let dictttt = dict.value(forKey: "category") as? NSDictionary
            {
                
                categoryID = dictttt.value(forKey: "_id") as? String
                categoryDescription = dictttt.value(forKey: "description") as? String
                categoryImageURL = dictttt.value(forKey: "imageURL") as? String
                categoryName = dictttt.value(forKey: "name") as? String
            }
        }
        
        if let dict = dictionary.value(forKey: "provider") as? NSDictionary
        {
            providerID = dict.value(forKey: "_id") as? String
            providerDisplayName = dict.value(forKey: "displayName") as? String
            providerPhone = dict.value(forKey: "phone") as? String
            providerProfileImageURL = dict.value(forKey: "profileImageURL") as? String
        }
    }
    
    
    
}
