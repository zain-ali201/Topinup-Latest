//
//  GroupVoiceCallLink.swift
//  Topinup
//
//  Created by Zain Ali on 4/22/20.
//  Copyright © 2020 Devlomi. All rights reserved.
//

import Foundation
class GroupVoiceCallLink {

    static func getVoiceGroupLink(groupId: String) -> String {
        return "\(Config.groupVoiceCallLink)://\(groupId)"
    }
}
