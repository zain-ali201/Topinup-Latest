//
//  CategoriesListVO.swift
//  Neighboorhood-iOS-Services-User
//
//  Created by Zain ul Abideen on 09/01/2018.
//  Copyright © 2018 yamsol. All rights reserved.
//

import Foundation
import SwiftyJSON

class CategoriesListVO : NSObject {
    
    var _id : String!
    var imageURL : String!
    var name : String!
    var descriptionn : String!
    var clientID : String!
    var displayName : String!
    
    override init()
    {
        super.init()
        _id = ""
        imageURL = ""
        name = ""
        descriptionn = ""
        clientID = ""
        displayName = ""
    }
    
    public init(withJSON json: NSDictionary) {
        
        let obj = JSON(json)
        print(obj)
        self._id = obj["_id"].stringValue
        
        if let client = obj["user"].dictionary {
            self.clientID = client["_id"]?.stringValue
            self.displayName = client["displayName"]?.stringValue
        }
        
        self.imageURL = obj["imageURL"].stringValue
        self.name = obj["name"].stringValue
        self.descriptionn = obj["description"].stringValue
    }
}
