//
//  DeletedMessage.swift
//  Topinup
//
//  Created by Zain Ali on 12/10/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import RealmSwift
class DeletedMessage: Object {
    override static func primaryKey() -> String? {
        return "messageId"
    }

    @objc dynamic var messageId: String = ""

    convenience init(messageId: String) {
        self.init()
        self.messageId = messageId
    }

}
