//
//  ProposedJobVO.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 20/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import Foundation
import SwiftyJSON

class ProposedJobVO : NSObject {
    
    var quotationID : String!
    var providerID : String!
    var providerProfileImage : String!
    var provierContactNumber : String!
    var providerDisplayName : String!
    
    var rate : Double!
    var proporsal : String!
    var status : String!
    var created : String!
    
    var handymanObject : HandymanNearbyVO!
    
    
    override init() {
        super.init()
        
        quotationID = ""
        providerID = ""
        providerProfileImage = ""
        provierContactNumber = ""
        providerDisplayName = ""
        
        rate = 0.0
        proporsal = ""
        status = ""
        created = ""
        
        handymanObject = HandymanNearbyVO()
    }
    
    public init(withJSON json: NSDictionary) {
        let obj = JSON(json)
        
        self.quotationID = obj["_id"].stringValue
        
        if let provider = obj["provider"].dictionaryObject as? NSDictionary {
            self.providerID = obj["_id"].stringValue
            self.providerProfileImage = obj["profileImageURL"].stringValue
            self.provierContactNumber = obj["contactNumber"].stringValue
            self.providerDisplayName = obj["displayName"].stringValue
            
        }

        self.rate = obj["rate"].double
        self.proporsal = obj["proporsal"].stringValue
        self.status = obj["status"].stringValue
        self.created = obj["created"].stringValue
        
        if let handyman = obj["handyman"].dictionaryObject as? NSDictionary {
            
            print("")
            self.handymanObject = HandymanNearbyVO(withJSON: handyman as! NSDictionary)
        }
    }
}
