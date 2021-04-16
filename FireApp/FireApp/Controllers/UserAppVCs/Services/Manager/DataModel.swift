//
//  DataModel.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 24/01/2018.
//  Copyright © 2018 yamsol. All rights reserved.
//

import Foundation

class DataModel : NSObject {
    
    static let shared = DataModel()
    
    private override init()
    {
        
    }
    
    var deviceToken : String!
    
    var socketConnection = false
    
    
    
    
}
