//
//  JobDetailVO.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 20/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON

class JobDetailVO : NSObject {
    
    var descriptionn : String!
    var images = [String]()
    var startTime : String!
    var endTime : String!
    
    var totalFee : Int!
    var totalHours : Int!
    var hourlyRate : Int!
    var fixedRate : Int!
    
    var jobDetailObject : HandymanNearbyVO!
    
    override init()
    {
        super.init()
        descriptionn = ""
        images = [String]()
        startTime = ""
        endTime = ""
        totalFee = 0
        totalHours = 0
        hourlyRate = 0
        fixedRate = 0
        
        jobDetailObject = HandymanNearbyVO()
    }
    
    public init(withJSON json: NSDictionary) {
        let obj = JSON(json)
        
        self.descriptionn = obj["description"].stringValue
        self.startTime = obj["startTime"].stringValue
        self.endTime = obj["endTime"].stringValue
        self.totalFee = obj["totalFee"].intValue
        self.totalHours = obj["totalHours"].intValue
        self.hourlyRate = obj["hourlyRate"].intValue
        self.fixedRate = obj["fixedRate"].intValue
        
        self.images.removeAll()
        
        if let imagess = obj["images"].arrayObject {
            for i in imagess {
                let image = String(describing: i)
                self.images.append(image)
            }
        }
        
        self.jobDetailObject = HandymanNearbyVO(withJSON: json)
    }
    
    
    
    
}
