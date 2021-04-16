//
//  MessageThreadVO.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 03/05/2018.
//  Copyright © 2018 yamsol. All rights reserved.
//

import Foundation

enum MessageStatus: String {
    case sent = "sent"
    case read = "read"
}

enum MediaTypeUser {
    case audio, image, video, file
}

class MessageThreadVO : NSObject {
    
    var messageID : String = ""
    
    
    // sender
    var senderID : String = ""
    var displayName : String = ""
    
    var type : String = ""
    var created : String = ""
    var message : String = ""
    var messageThreadID : String = ""
    var senderPhone : String = ""
    var profileImageURL : String = ""
    var status : String = ""
    var mediaURL: String = ""
    var thumbnailURL: String = ""
    var mediaType: MediaTypeUser = .file
    var duration: Int = 0
    var isTextMessage = true
    
    override init() {
        super.init()
        
        messageID = ""
        senderID = ""
        displayName = ""
        type = ""
        message = ""
        created = ""
        messageThreadID = ""
        senderPhone = ""
        profileImageURL = ""
        status = ""
    }
    
    init(dictionary : NSDictionary) {
        
        messageID = dictionary["_id"] as? String ?? ""
        
        if let dict = dictionary["sender"] as? NSDictionary
        {
            senderID = dict["_id"] as? String ?? ""
            displayName = dict["displayName"] as? String ?? ""
            senderPhone = dict["phone"] as? String ?? ""
            profileImageURL = dict["profileImageURL"] as? String ?? ""
        }
        
        status = dictionary["status"] as? String ?? ""
        type = dictionary["type"] as? String ?? ""
        message = dictionary["message"] as? String ?? ""
        created = dictionary["created"] as? String ?? ""
        messageThreadID = dictionary["messagethread"] as? String ?? ""
        mediaURL = dictionary["media"] as? String ?? ""
        thumbnailURL = dictionary["thumbnailUrl"] as? String ?? ""
        duration = (dictionary["duration"] as? Int ?? 0) / 60
        
        isTextMessage = mediaURL.count == 0
        if !isTextMessage {
            if MessageThreadVO.isAudioMessage(urlString: mediaURL) {
                mediaType = .audio
            } else if thumbnailURL.count != 0 {
                mediaType = .video
            } else if MessageThreadVO.isImageMessage(urlString: mediaURL) {
                mediaType = .image
            } else {
                mediaType = .file
            }
        }
        
        
    }
    
    
    class func isAudioMessage(urlString: String) -> Bool {
        let soundExtenions = ["mp3", "caf", "m4a", "wav"]
        if let url = URL(string: urlString.encodedStringForUrl()) {
            return soundExtenions.contains(url.pathExtension)
        }
        return false
    }
    
    class func isImageMessage(urlString: String) -> Bool {
        let imageExtenions = ["jpg", "jpeg", "png", "gif", "jpej"]
        if let url = URL(string: urlString.encodedStringForUrl()) {
            print(url.pathExtension)
            return imageExtenions.contains(url.pathExtension)
        }
        return false
    }
    
}
