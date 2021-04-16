//
//  HandymanNearbyVO.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 19/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation

class HandymanNearbyVO : NSObject {
    
    var _id : String!
    var type : String!
    var address : String!
    var created : String!
    var clientID : String!
    var profileImageURL : String!
    var contactNumber : String!
    var displayName : String!
    var title : String!
    var scheduleTime : String!
    var latitude : Double!
    var longitude : Double!
    var status : String!
    
    var coordinaate : CLLocationCoordinate2D? {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    
    override init()
    {
        super.init()
        _id = ""
        type = ""
        scheduleTime = ""
        address = ""
        created = ""
        clientID = ""
        profileImageURL = ""
        contactNumber = ""
        displayName = ""
        title = ""
        scheduleTime = ""
        latitude = 0
        longitude = 0
        status = ""
    }
    
    public init(withJSON json: NSDictionary) {
        let obj = JSON(json)
        
        self._id = obj["_id"].stringValue
        
        if let client = obj["client"].dictionary {
            self.clientID = client["_id"]?.stringValue
            self.profileImageURL = client["profileImageURL"]?.stringValue
            self.contactNumber = client["contactNumber"]?.stringValue
            self.displayName = client["displayName"]?.stringValue
        }
        
        self.title = obj["obj"].stringValue
        self.latitude = obj["latitude"].double
        self.longitude = obj["longitude"].double
        self.status = obj["status"].stringValue
        self.type = obj["type"].stringValue
        self.scheduleTime = obj["scheduleTime"].stringValue
        self.address = obj["address"].stringValue
        self.created = obj["created"].stringValue
    }
    
 
    
}
