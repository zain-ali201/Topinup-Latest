//
//  File.swift
//  ShareExtension
//
//  Created by Zain Ali on 12/17/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import Foundation
class ShareItem {
    var url: URL?
    var string: String?
    var type: ShareItemType
    init(url: URL?, string: String?, type: ShareItemType) {
        self.url = url
        self.string = string
        self.type = type
    }

}

enum ShareItemType {
    case fileUrl
    case vcardString
    case textString
    case url
}
