//
//  ProgressData.swift
//  Topinup
//
//  Created by Zain Ali on 9/8/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import Foundation
struct ProgressData {

    var progress: Float
    var receiverId: String
    var messageId: String

    init(progress: Float, receiverId: String, messageId: String) {
        self.progress = progress
        self.receiverId = receiverId
        self.messageId = messageId
    }
}
