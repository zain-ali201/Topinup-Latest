//
//  UnProcessedStatusSeen.swift
//  Topinup
//
//  Created by Zain Ali on 12/28/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import RealmSwift

class UnProcessedStatusSeen: Object {
    @objc dynamic var statusId:String = ""
    @objc dynamic var uid:String = ""
    
    override class func primaryKey() -> String? {
        return "statusId"
    }
    
    convenience init(statusId:String,uid:String) {
        self.init()
        self.statusId = statusId
        self.uid = uid
    }
}
