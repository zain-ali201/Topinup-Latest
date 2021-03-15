//
//  Message.swift
//  Topinup
//
//  Created by Zain Ali on 5/20/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import Foundation
import RealmSwift
import FirebaseDatabase
class Message: Object {

    override static func indexedProperties() -> [String] {
        return ["uid"]
    }

    @objc dynamic var messageId = ""
    @objc dynamic var fromId = ""
    @objc dynamic var fromPhone = ""
    @objc dynamic var toId = ""

    @objc dynamic private var type = MessageType.SENT_TEXT.rawValue

    var typeEnum: MessageType {
        get {
            return MessageType(rawValue: type)!
        }
        set {
            type = newValue.rawValue
        }
    }

    @objc dynamic var content = ""
    @objc dynamic var timestamp:CLong = 0
    @objc dynamic var chatId = ""
    @objc dynamic private var messageStat = MessageState.PENDING.rawValue

    var messageState: MessageState {
        get {
            return MessageState(rawValue: messageStat)!
        }
        set {
            messageStat = newValue.rawValue
        }
    }

    @objc dynamic var localPath = ""

    @objc dynamic private var downloadUploadStat = DownloadUploadState.DEFAULT.rawValue

    var downloadUploadState: DownloadUploadState {
        get {
            return DownloadUploadState(rawValue: downloadUploadStat)!
        }
        set {
            downloadUploadStat = newValue.rawValue
        }
    }


    @objc dynamic var metatdata = ""
    @objc dynamic var voiceMessageSeen = false
    @objc dynamic var mediaDuration = ""
    @objc dynamic var thumb = ""
    @objc dynamic var isForwarded = false
    @objc dynamic var videoThumb = ""
    @objc dynamic var fileSize = ""
    @objc dynamic var contact: RealmContact?
    @objc dynamic var location: RealmLocation?
    @objc dynamic var isGroup = false
    @objc dynamic var isBroadcast = false
    @objc dynamic var isSeen = false
 
    @objc dynamic var voiceMessageNeedsToUpdateState = false
    @objc dynamic var quotedMessage: QuotedMessage?

    func toMap() -> [String: Any] {
        var result: [String: Any] = [:]
        result[DBConstants.FROM_ID] = fromId
        result[DBConstants.TYPE] = typeEnum.rawValue
        result[DBConstants.CONTENT] = content
        result[DBConstants.TIMESTAMP] = ServerValue.timestamp()

        if(isGroup) {
            result[DBConstants.FROM_PHONE] = FireManager.number ?? ""
        } else if (!isBroadcast) {
            result[DBConstants.TOID] = toId
        }

        if mediaDuration != "" {
            result[DBConstants.MEDIADURATION] = mediaDuration
        }

        if thumb != "" {
            result[DBConstants.THUMB] = thumb
        }

        if metatdata != "" {
            result[DBConstants.METADATA] = metatdata
        }

        if(fileSize != "") {
            result[DBConstants.FILESIZE] = fileSize
        }

        if contact != nil {
            result[DBConstants.CONTACT] = contact?.toMap()
        }

        if location != nil {
            result[DBConstants.LOCATION] = location?.toMap()
        }

        if quotedMessage != nil {
            result["quotedMessageId"] = quotedMessage?.messageId
        }

        return result



    }
    func completeAfterDownload() -> Bool {
        return downloadUploadState != .CANCELLED && typeEnum != .SENT_DELETED_MESSAGE && typeEnum != .RECEIVED_DELETED_MESSAGE;
    }
    func isVoiceMessage() -> Bool {
        return typeEnum == .SENT_VOICE_MESSAGE || typeEnum == .RECEIVED_VOICE_MESSAGE
    }


    override func isEqual(_ object: Any?) -> Bool {
        if let message = object as? Message {
            return self.messageId == message.messageId
        }
        return false
    }
}
