//
//  AudioPorgress.swift
//  Topinup
//
//  Created by Zain Ali on 9/12/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import Foundation
class AudioProgress {
    let currentProgress: TimeInterval
    let duration: TimeInterval
    var playerState:PlayerState

    
    init(currentProgress:TimeInterval,duration:TimeInterval,playerState:PlayerState) {
        self.currentProgress = currentProgress
        self.duration = duration
        self.playerState = playerState
    }
}
