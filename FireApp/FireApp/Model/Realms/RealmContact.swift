//
//  RealmContact.swift
//  Topinup
//
//  Created by Zain Ali on 5/20/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import Foundation
import RealmSwift
class RealmContact: Object {
    @objc dynamic var name=""
    var realmList = List<PhoneNumber>()
    
    convenience init(name:String,numbers:List<PhoneNumber>) {
        self.init()
        self.name = name
        realmList = numbers
    }
    
    func toMap() -> [String : Bool]{
        var numbers : [String : Bool] = [:]
        for number in realmList {
            numbers[number.number] = true
        }
        return numbers
    }
}

