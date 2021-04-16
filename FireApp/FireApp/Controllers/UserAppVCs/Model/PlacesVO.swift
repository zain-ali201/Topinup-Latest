//
//  PlacesVO.swift
//  Neighboorhood-iOS-Services
//
//  Created by Rizwan Shah on 27/07/2020.
//  Copyright © 2020 yamsol. All rights reserved.
//

import Foundation
import SwiftyJSON

class PlacesVO : NSObject {
    
    public var _id : String!
    public var type : String!
    public var relevance : Double!
    public var text : String!
    
    public var place_name : String!
    public var latitude     : Double? = nil
    public var longitude    : Double? = nil
    
    
    override init() {
        super.init()
        
        _id     = ""
        type    = ""
        relevance = 0
        text = ""
        place_name = ""
        latitude = 0
        longitude = 0
        
        
    }
    
    public init(withJSON json: NSDictionary) {
        let obj = JSON(json)
        
        self._id = obj["_id"].stringValue
        self.type = obj["type"].stringValue
        self.relevance = obj["relevance"].double
        self.text = obj["text"].stringValue
        self.place_name = obj["place_name"].stringValue
        
        
        
        if let addresss = obj["center"].arrayObject {
             longitude = addresss.first as! Double
             latitude = addresss.last as! Double
            
        }
        
    }
}

