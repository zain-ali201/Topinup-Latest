//
//  StateImageHelper.swift
//  Topinup
//
//  Created by Zain Ali on 9/5/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import UIKit
class StateImageHelper {
    static func getStateImage(state: MessageState) -> UIImage {
        var imageName = ""
        let colorTint = Colors.readTagsDefaultChatViewColor
        switch state {
        case .PENDING:
            return UIImage(named: "pending")!.tinted(with: colorTint)!
        case .SENT:
            imageName = "tick"
            break
        case.RECEIVED:
            imageName = "double_tick"
            break
        case.READ:
            imageName = "blue_tick"
            break
        case .NONE:
            return UIImage()
        }

        return UIImage(named: imageName)!

    }

    static func setImageForState(imageView: UIImageView, messageState: MessageState) {
        let image = getStateImage(state: messageState)
        imageView.image = image
    }

}
