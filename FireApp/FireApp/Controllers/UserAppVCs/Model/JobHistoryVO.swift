//
//  JobHistoryVO.swift
//  Neighboorhood-iOS-Services-User
//
//  Created by Zain ul Abideen on 08/01/2018.
//  Copyright © 2018 yamsol. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON

class JobHistoryVO : NSObject {
    
    var _id : String!
    var wheree : String!
    var type : String!
    var budget : String!
    var currency : String!
    var latitude : Double!
    var longitude : Double!
    var category : String!
    var created : String!
    var images = [String]()
    var status : String!
    var details : String!
    var when : String!
    var name : String!
    var clientID : String!
    var providerID : String!
    var displayName : String!
    var profileImageURL : String!
    
    var categoryName : String!
    var categoryDescription : String!
    var categoryID : String!
    var categoryImageURL : String!
    
    var providerLatitude : Double!
    var providerLongitude : Double!
    var providerHourlyRate : Double!
    var providerPhone : String!
    var providerRating : Double!
    var providerImageURL : String?
    
    var orderService : Int!
    var orderID : String!
    var orderCreated : String!
    var orderJobID : String!
    var orderAcceptedTime : String!
    var orderArrivedTime : String!
    var orderTotalTime : String!
    var orderFee : Int!
    var orderCompany : Int!
    var orderEndedTime : String!
    var orderStartedTime : String!
    var orderOnwayedTime : String!
    
    
    
    
    
    
    
    
    
    
    var coordinaate : CLLocationCoordinate2D? {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    
    override init()
    {
        super.init()
        
        _id = ""
        providerID = ""
        wheree = ""
        type = ""
        budget = ""
        currency = ""
        created = ""
        clientID = ""
        category = ""
        displayName = ""
        details = ""
        when = ""
        latitude = 0
        longitude = 0
        status = ""
        profileImageURL = ""
        name = ""
        
        categoryName = ""
        categoryDescription = ""
        categoryID = ""
        categoryImageURL = ""
        
        providerLatitude = 0
        providerLongitude = 0
        providerHourlyRate = 0
        providerPhone = ""
        providerRating = 0
        
        providerImageURL = ""
        
        orderService = 0
        orderID = ""
        orderCreated = ""
        orderJobID = ""
        orderAcceptedTime = ""
        orderArrivedTime = ""
        orderTotalTime = ""
        orderFee = 0
        orderCompany = 0
        orderEndedTime = ""
        orderStartedTime = ""
        orderOnwayedTime = ""
        
        
        images = [String]()
        
        
        
        
        
    }
    
    public init(withJSON json: NSDictionary) {
        let obj = JSON(json)
        print(obj)
        
        self._id = obj["_id"].stringValue
        
        if let client = obj["client"].dictionary {
            self.clientID = client["_id"]?.stringValue
            self.displayName = client["displayName"]?.stringValue
            self.profileImageURL = client["profileImageURL"]?.stringValue
            
        }
        
        if let provider = obj["provider"].dictionary
        {
            self.providerID = provider["_id"]?.stringValue
            self.displayName = provider["displayName"]?.stringValue
            self.providerImageURL = provider["profileImageURL"]?.stringValue
            
            self.providerLatitude = provider["latitude"]?.doubleValue
            self.providerLongitude = provider["longitude"]?.doubleValue
            self.providerPhone = provider["phone"]?.stringValue
            self.providerHourlyRate = provider["hourlyRate"]?.doubleValue
            self.providerRating = provider["rating"]?.doubleValue
        }
        
        if let category = obj["category"].dictionary {
            self.categoryID = category["_id"]?.stringValue
            self.categoryName = category["name"]?.stringValue
            self.categoryDescription = category["description"]?.stringValue
            self.categoryImageURL = category["imageURL"]?.stringValue
            
        }
        
        if let order = obj["jobDetail"].dictionary {
            self.orderService = order["service"]?.intValue
            self.orderID = order["_id"]?.stringValue
            self.orderCreated = order["created"]?.stringValue
            self.orderJobID = order["job"]?.stringValue
            self.orderAcceptedTime = order["acceptedTime"]?.stringValue
            self.orderArrivedTime = order["arrivedTime"]?.stringValue
            self.orderTotalTime = order["totalTime"]?.stringValue
            self.orderFee = order["fee"]?.intValue
            self.orderCompany = order["company"]?.intValue
            self.orderEndedTime = order["endedTime"]?.stringValue
            self.orderStartedTime = order["startedTime"]?.stringValue
            self.orderOnwayedTime = order["onwayedTime"]?.stringValue
            
        }
       
        self.name = obj["name"].stringValue
        self.wheree = obj["where"].stringValue
        self.latitude = obj["latitude"].doubleValue
        self.longitude = obj["longitude"].doubleValue
        self.status = obj["status"].stringValue
        self.type = obj["type"].stringValue
        self.budget = obj["budget"].stringValue
        self.currency = obj["currency"].stringValue
        self.category = obj["category"].stringValue
        self.created = obj["created"].stringValue
        self.details = obj["details"].stringValue
        self.when = obj["when"].stringValue
        
        self.images.removeAll()
        
        for i in obj["images"] {
            self.images.append(i.1.stringValue)
            
        }
    }
    
    
}
