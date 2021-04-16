//
//  JobPointVO.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 27/01/2018.
//  Copyright © 2018 yamsol. All rights reserved.
//

import Foundation

class JobPointVO : NSObject , NSCoding {
    
    var latitude : Double!
    var Longitude : Double!
    var time : String!
    
    override init()
    {
        super.init()
        latitude = 0
        Longitude = 0
        time = ""
    }
    
    
    
    init(lat : Double , long : Double , time  : String)
    {
        
        self.latitude = lat
        self.Longitude = long
        self.time = time
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.latitude = aDecoder.decodeObject(forKey: "latitude") as! Double
        self.Longitude = aDecoder.decodeObject(forKey: "Longitude") as! Double
        self.time = aDecoder.decodeObject(forKey: "time") as! String
        
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.latitude, forKey: "latitude")
        aCoder.encode(self.Longitude, forKey: "Longitude")
        aCoder.encode(self.time, forKey: "time")
        
    }
    
    func printDetails()
    {
        print("\(self.latitude) - latitude")
        print("\(self.Longitude) - Longitude")
        print("\(self.time) - time")
    }
    
    
    
}
