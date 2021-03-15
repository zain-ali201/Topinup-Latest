//
//  Chat.swift
//  Topinup
//
//  Created by Zain Ali on 5/20/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import Foundation
import RealmSwift

class Chat: Object {
    
    override static func primaryKey() -> String? {
        return "chatId"
    }
    
    override static func indexedProperties() -> [String] {
        return ["chatId"]
    }
    
    @objc dynamic var chatId=""
    @objc dynamic var lastMessage:Message?
    @objc dynamic var lastMessageTimestamp = ""
    @objc dynamic var user : User?
    @objc dynamic var isMuted = false
    @objc dynamic var unReadCount = 0
    @objc dynamic var firstUnreadMessageId = ""
    let unreadMessages = List<Message>()
    
}

