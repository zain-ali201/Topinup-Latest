//
//  NotificationService.swift
//  NotificationService
//
//  Created by Zain Ali on 2/8/20.
//  Copyright © 2020 Devlomi. All rights reserved.
//

import UserNotifications
import RealmSwift
import RxSwift
import Firebase

private let fileURL = FileManager.default
    .containerURL(forSecurityApplicationGroupIdentifier: "group.\(Config.bundleName)")!
    .appendingPathComponent("default.realm")
private let config = RealmConfig.getConfig(fileURL: fileURL, objectTypes:
        [Message.self, Chat.self, User.self, DeletedMessage.self, RealmLocation.self, RealmContact.self, PhoneNumber.self, QuotedMessage.self, Group.self, Broadcast.self, Notifications.self, GroupEvent.self, PendingGroupJob.self, UnUpdatedMessageState.self, FireCall.self, MediaToSave.self
        ])

let appRealm = try! Realm(configuration: config)
let disposeBag = DisposeBag()

class NotificationService: UNNotificationServiceExtension {



    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?


    fileprivate func requestNewNotifications() {
        guard UserDefaultsManager.isAppInBackground() else {
            return
        }


        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {

            //                        MessageManager.fetchUnDeliveredMessages(appRealm: appRealm, disposeBag: disposeBag).subscribe().disposed(by: disposeBag)

//            if !UserDefaultsManager.isFetchingUnDeliveredMessages() {
            if let lastDate = UserDefaultsManager.getLastRequestUnDeliveredMessagesTime() {

                if TimeHelper.canRequestUnDeliveredNotifications(lastRequestTime: lastDate) {

                    MessageManager.requestForNewNotifications(disposeBag: disposeBag)
                }
            } else {

                MessageManager.requestForNewNotifications(disposeBag: disposeBag)
            }
//            }

        }
    }

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)


        if let bestAttemptContent = bestAttemptContent {
//

            if FirebaseApp.app() == nil {
                FirebaseApp.configure()
            }

            if !FireManager.isLoggedIn {
                return
            }


            DispatchQueue.main.async {
                let userInfo = bestAttemptContent.userInfo
//
                let notificationName = UserDefaultsManager.getRingtoneFileName()
                let notificationSound = UNNotificationSound(named: UNNotificationSoundName(rawValue: notificationName))
                bestAttemptContent.sound = notificationSound

                let isAppInBackground = UserDefaultsManager.isAppInBackground()

                if let event = userInfo["event"] as? String {
                    if event == "new_group" {
                        if let groupId = userInfo["groupId"] as? String {
                            if isAppInBackground {
                                MessageManager.deleteNewGroupEvent(groupId: groupId).subscribe().disposed(by: disposeBag)
                                self.handleNewGroup(userInfo, bestAttemptContent: bestAttemptContent)
                            } else {
                                contentHandler(bestAttemptContent)
                            }

                        }


                        self.requestNewNotifications()
                    } else if event == "message_deleted" {
                        if let messageId = userInfo["messageId"] as? String {

                            if isAppInBackground {
                                MessageManager.deleteDeletedMessage(messageId: messageId).subscribe().disposed(by: disposeBag)

                                self.handleDeletedMessage(messageId, bestAttemptContent: bestAttemptContent)
                            } else {
                                contentHandler(bestAttemptContent)
                            }
                            self.requestNewNotifications()

                        }
                    }
                } else if let messageId = userInfo["messageId"] as? String {
                    if isAppInBackground {
                        MessageManager.deleteMessage(messageId: messageId).subscribe().disposed(by: disposeBag)
                        self.handleNewMessage(userInfo, messageId, request: request, bestAttemptContent: bestAttemptContent)

                    } else {
                        //just a fallback solution in case anything wrong hanppened
                        if let message = RealmHelper.getInstance(appRealm).getMessage(messageId: messageId), let user = RealmHelper.getInstance(appRealm).getUser(uid: message.chatId) {
                            bestAttemptContent.title = GetUserInfo.getUserName(user: user, fromId: message.fromId, fromPhone: message.fromPhone)
                            bestAttemptContent.body = MessageTypeHelper.getMessageContent(message: message, includeEmoji: true)
                            bestAttemptContent.threadIdentifier = message.chatId
                            bestAttemptContent.userInfo["chatId"] = message.chatId
                            contentHandler(bestAttemptContent)
                        } else {
                            contentHandler(bestAttemptContent)
                        }
                    }




                    self.requestNewNotifications()

                }
            }


        } else {

        }
    }

    fileprivate func handleGroupEvent(_ userInfo: [AnyHashable: Any], bestAttemptContent: UNMutableNotificationContent) {

        if let groupId = userInfo["groupId"] as? String,
            let eventId = userInfo["eventId"] as? String, let contextStart = userInfo["contextStart"] as? String, let eventTypeStr = userInfo["eventType"] as? String, let contextEnd = userInfo["contextEnd"] as? String {

            let eventTypeInt = Int(eventTypeStr) ?? 0

            let eventType = GroupEventType(rawValue: eventTypeInt) ?? .UNKNOWN
            //if this event was by the admin himself  OR if the event already exists do nothing
            if contextStart != FireManager.number! && RealmHelper.getInstance(appRealm).getMessage(messageId: eventId) == nil {
                let groupEvent = GroupEvent(contextStart: contextStart, type: eventType, contextEnd: contextEnd)

                let pendingGroupJob = PendingGroupJob(groupId: groupId, type: eventType, event: groupEvent)
                RealmHelper.getInstance(appRealm).saveObjectToRealm(object: pendingGroupJob)
                GroupManager.updateGroup(groupId: groupId, groupEvent: groupEvent).subscribe(onCompleted: {

                    if let group = RealmHelper.getInstance(appRealm).getUser(uid: groupId)?.group {
                        bestAttemptContent.title = GroupEvent.extractString(messageContent: groupEvent.contextStart, users: group.users)

                        self.contentHandler?(bestAttemptContent)

                    }


                }).disposed(by: disposeBag)
            }
        }
    }

    fileprivate func handleNewGroup(_ userInfo: [AnyHashable: Any], bestAttemptContent: UNMutableNotificationContent) {
        /*
        if let groupId = userInfo["groupId"] as? String, let groupName = userInfo["groupName"] as? String {
            if let group = RealmHelper.getInstance(appRealm).getUser(uid: groupId)?.group {
                let users = group.users
                let contains = users.filter { $0.uid == FireManager.getUid() }.first != nil
                //if the group is not active or the group does not contain current user
                // then fetch and download it and set it as Active

                if (!group.isActive || !contains) {
                    let pendingGroupJob = PendingGroupJob(groupId: groupId, type: .GROUP_CREATION, event: nil)
                    RealmHelper.getInstance(appRealm).saveObjectToRealm(object: pendingGroupJob)
                    GroupManager.fetchAndCreateGroup(groupId: groupId, subscribeToTopic: false).subscribe(onCompleted: {
                        bestAttemptContent.title = Strings.new_group
                        bestAttemptContent.body = Strings.you_added_to_group + " " + groupName
                        self.contentHandler?(bestAttemptContent)
                    }).disposed(by: disposeBag)
                }
            } else {
                //if the group is not exists,fetch and download it
                let pendingGroupJob = PendingGroupJob(groupId: groupId, type: .GROUP_CREATION, event: nil)
                RealmHelper.getInstance(appRealm).saveObjectToRealm(object: pendingGroupJob)
                GroupManager.fetchAndCreateGroup(groupId: groupId, subscribeToTopic: false).subscribe(onError: { error in
                }, onCompleted: {

                        bestAttemptContent.title = Strings.new_group
                        bestAttemptContent.body = Strings.you_added_to_group + " " + groupName
                        self.contentHandler?(bestAttemptContent)
                    }).disposed(by: disposeBag)

            }
        }
 */
        NewNotificationsHandler(disposeBag: disposeBag).handleNewGroup(userInfo: userInfo).subscribe(onSuccess: { (notificationContent) in
            bestAttemptContent.title = notificationContent.title
            bestAttemptContent.body = notificationContent.body
            if let groupId = userInfo["groupId"] as? String {
                bestAttemptContent.threadIdentifier = groupId
            }
            self.contentHandler?(bestAttemptContent)
        }) { (error) in

        }.disposed(by: disposeBag)
    }

    fileprivate func handleDeletedMessage(_ messageId: String, bestAttemptContent: UNMutableNotificationContent) {
        let notificationsIds = Array(RealmHelper.getInstance(appRealm).getNotificationsByMessageId(messageId: messageId).map { $0.notificationId })
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: notificationsIds)

//        RealmHelper.getInstance(appRealm).setMessageDeleted(messageId: messageId)
//
//        if let message = RealmHelper.getInstance(appRealm).getMessage(messageId: messageId) {
//
//            if message.downloadUploadState == .LOADING {
//                DownloadManager.cancelDownload(message: message, appRealm: appRealm)
//            }
//
//
//            if let chat = RealmHelper.getInstance(appRealm).getChat(id: message.chatId) {
//                bestAttemptContent.title = chat.user?.userName ?? message.fromPhone
//            }
//
//            bestAttemptContent.body = Strings.this_message_deleted
//
//            contentHandler?(bestAttemptContent)
//
//        }

        let notificationContent = NewNotificationsHandler(disposeBag: disposeBag).handleDeletedMessage(messageId: messageId)

        bestAttemptContent.title = notificationContent.title
        bestAttemptContent.body = notificationContent.body
        contentHandler?(bestAttemptContent)
    }

    fileprivate func handleNewMessage(_ userInfo: [AnyHashable: Any], _ messageId: String, request: UNNotificationRequest, bestAttemptContent: UNMutableNotificationContent) {

        let isAppInBackground = UserDefaultsManager.isAppInBackground()


        NewMessageHandler.handleNewMessage(userInfo: userInfo, disposeBag: disposeBag, appRealm: appRealm, isSeen: !isAppInBackground, complete: {
            if let message = RealmHelper.getInstance(appRealm).getMessage(messageId: messageId), let user = RealmHelper.getInstance(appRealm).getUser(uid: message.chatId) {

                if isAppInBackground {
                    let badge = BadgeManager.incrementBadgeByOne(chatId: message.chatId)

                    bestAttemptContent.badge = badge as NSNumber

                    let unUpdatedState = UnUpdatedMessageState(messageId: messageId, myUid: FireManager.getUid(), chatId: message.chatId, statToBeUpdated: .RECEIVED)

                    RealmHelper.getInstance(appRealm).saveObjectToRealm(object: unUpdatedState, update: true)


                }

                let notificationId = request.identifier
                RealmHelper.getInstance(appRealm).saveNotificationId(chatId: message.chatId, notificationId: notificationId, messageId: messageId)
                bestAttemptContent.title = GetUserInfo.getUserName(user: user, fromId: message.fromId, fromPhone: message.fromPhone)
                bestAttemptContent.body = MessageTypeHelper.getMessageContent(message: message, includeEmoji: true)
                bestAttemptContent.threadIdentifier = message.chatId
                bestAttemptContent.userInfo["chatId"] = message.chatId



                self.contentHandler?(bestAttemptContent)


            }
        })
    }



    override func serviceExtensionTimeWillExpire() {

        UserDefaultsManager.setFetchingUnDeliveredMessages(bool: false)

        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
