//
//  User.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 18/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import Foundation
import SwiftyJSON

class UserVO : NSObject, NSCoding {
    
    public var _id          : String? = nil
    public var firstname    : String? = nil
    public var lastname     : String? = nil
    public var created      : String? = nil
    public var roles        : [Any] = []
    public var categories   : [Any] = []
    public var reviews      : [Any] = []
    public var reviewCreated: String? = nil
    public var reviewDetail : String? = nil
    public var reviewRating : String? = nil
    public var type         : String? = nil
    public var job          : String? = nil
    public var coords       : [Any] = []
    public var latitude     : Double? = nil
    public var longitude    : Double? = nil
    public var address      : String? = nil
    public var status       : [Any] = []
    public var rating       : Double? = nil
    public var accountStatus = [Any]()
    public var deviceType   : String? = nil
    public var deviceKey    : String? = nil
    public var phone        : String? = nil
    public var email        : String? = nil
    public var displayName  : String? = nil
    public var token        : String! = nil
    
    public var profileImageURL : String? = nil
    
    public override init() { }
    
    public init(withJSON json: NSMutableDictionary) {
        print(json)
        let us = JSON(json)
        self._id = us["_id"].stringValue
        self.firstname = us["firstName"].stringValue
        self.lastname = us["lastName"].stringValue
        self.created = us["created"].stringValue
        
        self.profileImageURL = us["profileImageURL"].stringValue
        
        self.job = us["job"].stringValue
        
        self.latitude = us["latitude"].doubleValue
        self.longitude = us["longitude"].doubleValue
        self.address = us["address"].stringValue
        
        self.rating = us["rating"].doubleValue
        
        if(us["avgRating"].doubleValue != 0){
            self.rating = us["avgRating"].doubleValue
        }
        
        self.deviceType = us["deviceType"].stringValue
        self.deviceKey = us["deviceKey"].stringValue
        self.phone = us["phone"].string
        self.email = us["email"].stringValue
        self.displayName = us["displayName"].stringValue
        self.token = us["token"].stringValue
        Currency.currencyCode = us["currency"].stringValue
        
        
        if let category = us["categories"].arrayObject {
            self.categories = category
        }
        
        if let reviews = us["reviews"].arrayObject {
            self.reviews = reviews
            
        }
        
    }
    
    public required convenience init(coder aDecoder: NSCoder) {
        self.init()
        self._id = aDecoder.decodeObject(forKey: "_id") as? String
        self.firstname = aDecoder.decodeObject(forKey: "firstName") as? String
        self.lastname = aDecoder.decodeObject(forKey: "lastName") as? String
        self.created = aDecoder.decodeObject(forKey: "created") as? String
        self.address = aDecoder.decodeObject(forKey: "address") as? String
        self.phone = aDecoder.decodeObject(forKey: "phone") as? String
        self.deviceKey = aDecoder.decodeObject(forKey: "deviceKey") as? String
        self.deviceType = aDecoder.decodeObject(forKey: "deviceType") as? String
        self.displayName = aDecoder.decodeObject(forKey: "displayName") as? String
        self.email = aDecoder.decodeObject(forKey: "email") as? String
        self.job = aDecoder.decodeObject(forKey: "job") as? String
        self.latitude = aDecoder.decodeObject(forKey: "latitude") as? Double
        self.longitude = aDecoder.decodeObject(forKey: "longitude") as? Double
        self.profileImageURL = aDecoder.decodeObject(forKey: "profileImageURL") as? String
        self.rating = aDecoder.decodeObject(forKey: "rating") as? Double
        self.token = aDecoder.decodeObject(forKey: "token") as! String
        
        if(self.categories.count != 0){
            self.categories = aDecoder.decodeObject(forKey: "categories") as! Array
        }
        
        if(self.reviews.count != 0){
            self.reviews = aDecoder.decodeObject(forKey: "reviews") as! Array
        }
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(_id, forKey: "_id")
        aCoder.encode(firstname, forKey: "firstName")
        aCoder.encode(lastname, forKey: "lastName")
        aCoder.encode(address, forKey: "address")
        aCoder.encode(phone, forKey: "phone")
        aCoder.encode(created, forKey: "created")
        aCoder.encode(deviceKey, forKey: "deviceKey")
        aCoder.encode(deviceType, forKey: "deviceType")
        aCoder.encode(displayName, forKey: "displayName")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(job, forKey: "job")
        aCoder.encode(latitude, forKey: "latitude")
        aCoder.encode(longitude, forKey: "longitude")
        aCoder.encode(profileImageURL, forKey: "profileImageURL")
        aCoder.encode(rating, forKey: "rating")
        aCoder.encode(token, forKey: "token")
        if(self.categories.count != 0){
            aCoder.encode(categories, forKey: "categories")
        }
        if(self.reviews.count != 0){
            aCoder.encode(reviews, forKey: "reviews")
        }
        
    }
    
    
    
    
}
