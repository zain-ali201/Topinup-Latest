//
//  LocationVO.swift
//  Neighboorhood-iOS-Services-User
//
//  Created by Zain ul Abideen on 09/01/2018.
//  Copyright © 2018 yamsol. All rights reserved.
//

import Foundation
import CoreLocation
import GooglePlaces



class LocationVO : NSObject {
    
    var latitude : Double!
    var longitude : Double!
    var address : String!
    var coordinate : CLLocationCoordinate2D!
    
    override init()
    {
        super.init()
        
        latitude = 0.0
        longitude = 0.0
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        address = ""
    }
    
    init( gmsPlace : GMSPlace) {
        
        super.init()
        latitude = gmsPlace.coordinate.latitude
        longitude = gmsPlace.coordinate.longitude
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        if (gmsPlace.formattedAddress != nil)
        {
            address =  gmsPlace.formattedAddress!
        }
    }
    
    init( gmsPlace : GMSPlace, addr : String) {
        
        super.init()
        latitude = gmsPlace.coordinate.latitude
        longitude = gmsPlace.coordinate.longitude
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        if (gmsPlace.formattedAddress != nil)
        {
            address =  gmsPlace.formattedAddress!
        }
        else
        {
            address = addr
        }
    }
    
    
    init(lat : Double, long : Double, addr : String) {
        
        super.init()
        latitude = lat
        longitude = long
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        address = addr
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        self.latitude = aDecoder.decodeObject(forKey: "latitude") as! Double
        self.longitude = aDecoder.decodeObject(forKey: "longitude") as! Double
        self.address = aDecoder.decodeObject(forKey: "address") as! String
        self.coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        //self.coordinate = aDecoder.decodeObject(forKey: "coordinate") as! CLLocationCoordinate2D!
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.latitude, forKey: "latitude")
        aCoder.encode(self.longitude, forKey: "longitude")
        aCoder.encode(self.address, forKey: "address")
        //aCoder.encode(self.coordinate, forKey: "coordinate")
        
    }
    
    func savedDictionary(dict: LocationVO) -> NSDictionary {
        
        let dictionary = [
            
            "latitude" : dict.latitude,
            "longitude" : dict.longitude,
            "address" : dict.address
            
            ] as! NSDictionary
        
        return dictionary
    }
    
    init (dict: NSDictionary)  {
        self.latitude = dict["latitude"] as! Double
        self.longitude = dict["longitude"] as! Double
        self.address = dict["address"] as! String
    }
    
    
    
}
