//
//  PhoneContact.swift
//  Topinup
//
//  Created by Zain Ali on 9/19/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import Foundation
class PhoneContact {
    var name:String = ""
    var numbers = [String]()
    
    init(name:String,numbers:[String]) {
        self.name = name
        self.numbers = numbers
    }
}
