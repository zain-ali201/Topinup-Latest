//
//  UserProfileVO.swift
//  Neighboorhood-iOS-Services
//
//  Created by Sarim Ashfaq on 10/09/2019.
//  Copyright © 2019 yamsol. All rights reserved.
//

import Foundation
import SwiftyJSON

class UserProfileVO: NSObject {
    
    
    override init() {
        super.init()
    }
    
    init(dict: NSDictionary) {
        let json = JSON(dict)
    }
}
