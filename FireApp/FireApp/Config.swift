//
//  Config.swift
//  Topinup
//
//  Created by Zain Ali on 12/8/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import UIKit

class Colors {

    static let appColor = "#307BF8".toColor
    
    static let typingAndRecordingColors = "#8B8B8D".toColor
    static let notTypingColor = typingAndRecordingColors

    static let circularStatusUserColor = "#307BF8".toColor
    static let circularStatusSeenColor = "#8B8B8D".toColor

    static let circularStatusNotSeenColor = "#307BF8".toColor

    static let voiceMessageSeenColor = "#307BF8".toColor
    static let voiceMessageNotSeenColor = "#8B8B8D".toColor

    static let chatsListIconColor = "#8B8B8D".toColor

    //the default colors for read tags(pending,sent,received) in ChatVC
    static let readTagsDefaultChatViewColor = "#307BF8".toColor

    static let readTagsPendingColor = "#8B8B8D".toColor
    static let readTagsSentColor = "#8B8B8D".toColor
    static let readTagsReceivedColor = "#8B8B8D".toColor
    static let readTagsReadColor = "#307BF8".toColor

    static let replySentMsgAuthorTextColor = "#307BF8".toColor
    static let replySentMsgBackgroundColor = "#D8E7FD".toColor
    static let sentMsgBgColor = "#D8E7FD".toColor

    static let replyReceivedMsgAuthorTextColor = "#0080D4".toColor
    static let replyReceivedMsgBackgroundColor = "#f1f1f1".toColor
    static let receivedMsgBgColor = UIColor.white

    static let highlightMessageColor = "#FFD801".toColor
}

class TextStatusColors {
    public static let colors = [
        "#FF8A8C",
        "#54C265",
        "#8294CA",
        "#A62C71",
        "#90A841",
        "#C1A03F",
        "#792138",
        "#AE8774",
        "#F0B330",
        "#B6B327",
        "#C69FCC",
        "#8B6990",
        "#26C4DC",
        "#57C9FF",
        "#74676A",
        "#5696FF"
    ]
}

class Config
{
    static let maxVideoStatusTime: Double = 30.0
    static let maxVideoTime: Double = 30.0

    static let appName = "Topinup"
    static let bundleName = "com.volgo.services"
    static let groupName = "group.\(bundleName)"
    private static let teamId = "H6FU4X6RK3"

    private static let shareURLScheme = "TopinupShare"
     static let groupVoiceCallLink = "TopinupCall"
    static let shareUrl = "\(shareURLScheme)://dataUrl=Share"

    static let groupHostLink = ""

    private static let appId = "1538549059"
    static let appLink = "https://apps.apple.com/app/id\(appId)"

    static let sharedKeychainName = "\(teamId).\(bundleName).\(groupName)"

    static let privacyPolicyLink = "https://www.topinup.com"
    

    static let agoraAppId = "003807407a6a40f392e79e0302732a3e"
    
    //Ads Disable/Enable
    static let isChatsAdsEnabled = false
    static let isCallsAdsEnabled = false
    static let isStatusAdsEnabled = false

    //Ads Units IDs
    static let mainViewAdsUnitId = ""//this is a Test Unit ID, replace it with your AdUnitId

    //About
    static let twitter = ""
    static let website = "https://www.topinup.com"
    static let email = "topnupapp@gmail.com"

    public static let MAX_GROUP_USERS_COUNT = 50
    public static let MAX_BROADCAST_USERS_COUNT = 100
    public static let maxGroupCallCount = 11
}


fileprivate extension String {

    var toColor: UIColor {
        var cString: String = self.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
