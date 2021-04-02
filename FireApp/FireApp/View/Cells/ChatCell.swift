//
//  ChatCell.swift
//  Topinup
//
//  Created by Zain Ali on 9/22/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {

    @IBOutlet weak var chatImgView: UIImageView!
    @IBOutlet weak var contactImgView: CustomProfileView!
    @IBOutlet weak var chatName: UILabel!
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var lastMessageIcon: UIImageView!
    @IBOutlet weak var readTags: UIImageView!
    @IBOutlet weak var unReadCountBadge: UILabel!
    @IBOutlet weak var dateLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func bind(chat: Chat) {
        if let user = chat.user {
            chatName.text = chat.user?.userName
            loadUserPhoto(user: user)

            setLastMessageStuff(chat: chat, user: user)
            dateLbl.text = TimeHelper.getMessageTime(date: chat.lastMessageTimestamp.toDate())
            let unreadCount = chat.unReadCount

            if unreadCount == 0 {
                unReadCountBadge.isHidden = true
            } else {
                unReadCountBadge.isHidden = false
                unReadCountBadge.text = "\(unreadCount)"
            }
        }
    }

    private func setLastMessageStuff(chat: Chat, user: User) {
        guard let message = chat.lastMessage else {

            lastMessageIcon.isHidden = true
            lastMessage.isHidden = true
            readTags.isHidden = true

            return
        }
        
        let type = message.typeEnum

        lastMessageIcon.isHidden = !type.isMediaType()
        lastMessage.isHidden = false

        let imageName = MessageTypeHelper.getMessageTypeImage(type: message.typeEnum)
        lastMessageIcon.image = UIImage(named: imageName)
        readTags.isHidden = !message.typeEnum.isSentType()

        if type.isText() || type == .GROUP_EVENT || type.isDeletedMessage() {
            if type == .GROUP_EVENT, let users = user.group?.users {
                let groupEvent = GroupEvent.extractString(messageContent: message.content, users: users)
                lastMessage.text = groupEvent

            } else if type.isDeletedMessage() {
                if type == .SENT_DELETED_MESSAGE {
                    lastMessage.text = Strings.you_deleted_this_message
                } else {
                    lastMessage.text = Strings.this_message_deleted
                }
            } else {
                lastMessage.text = message.content
            }

            lastMessageIcon.image = UIImage(named: imageName)

        } else {
            lastMessage.text = MessageTypeHelper.extractMessageTypeMetadataText(message: message)
            let image = MessageTypeHelper.getColoredImage(message: message)
            lastMessageIcon.image = image
        }

        //set recipient marks
        if type == .GROUP_EVENT || type.isDeletedMessage() {
            readTags.isHidden = true
        } else if message.fromId == FireManager.getUid() {
            readTags.isHidden = false
            readTags.image = MessageTypeHelper.getColoredReadTags(state: message.messageState)
        } else {
            readTags.isHidden = true
        }

    }
    private func loadUserPhoto(user: User) {
        if (user.isBroadcastBool)
        {
            chatImgView.image = UIImage(named: "rss")
        }
        else
        {
            if user.thumbImg != ""
            {
                chatImgView.image = user.thumbImg.toUIImage()
            }
            else
            {
                chatImgView.alpha = 0
                contactImgView.alpha = 1
                contactImgView.setValueForProfile(true, nameInitials: "\(user.userName.first ?? "N")", fontSize: 16.0, imageData: nil)
            }
        }
    }
}
