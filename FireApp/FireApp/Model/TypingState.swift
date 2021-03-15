//
//  TypingState.swift
//  Topinup
//
//  Created by Zain Ali on 9/23/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import Foundation
enum TypingState: Int {
    case NOT_TYPING = 0
    case TYPING = 1
    case RECORDING = 2
}

extension TypingState {
    public func getStatString() -> String {
        switch (self) {
        case .NOT_TYPING:
            return ""

        case .TYPING:
            return Strings.typing

        case .RECORDING:
            return Strings.recording
            
        }
    }
}
