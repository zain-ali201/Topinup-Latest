//
//  UpdateGroupEvent.swift
//  Topinup
//
//  Created by Zain Ali on 12/5/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import Foundation
class UpdateGroupEvent: NSObject {
    let groupId:String
    init(groupId:String) {
        self.groupId = groupId
    }
}
