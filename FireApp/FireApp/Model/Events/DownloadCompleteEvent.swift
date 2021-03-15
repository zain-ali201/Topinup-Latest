//
//  DownloadCompleteEvent.swift
//  Topinup
//
//  Created by Zain Ali on 9/12/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import Foundation

class DownloadCompleteEvent:NSObject {
    let id:String
  
    init(id:String) {
        self.id = id
    }
}
