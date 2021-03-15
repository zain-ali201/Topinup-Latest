//
//  PhoneNumber.swift
//  Topinup
//
//  Created by Zain Ali on 5/20/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import Foundation
import RealmSwift
class PhoneNumber: Object {
    @objc dynamic var number = ""
    
    convenience init(number:String) {
        self.init()
        self.number = number
    }
}
