//
//  MessageManager.swift
//  Topinup
//
//  Created by Zain Ali on 3/23/20.
//  Copyright © 2020 Devlomi. All rights reserved.
//

import FirebaseDatabase
import FirebaseAuth
import FirebaseFunctions
import RxFirebase
import RxSwift
import RealmSwift

class MessageManager {

    static func deleteMessage(messageId: String) -> Single<DatabaseReference> {
        return FireConstants.userMessages.child(FireManager.getUid()).child(messageId).rx.removeValue()
    }
    
    static func deleteMissedCall(callId: String) -> Single<DatabaseReference> {
        return FireConstants.missedCalls.child(FireManager.getUid()).child(callId).rx.removeValue()
      }
    
    static func deleteNewGroupEvent(groupId: String) -> Single<DatabaseReference> {
      return FireConstants.mainRef.child("newGroups").child(FireManager.getUid()).child(groupId).rx.removeValue()
    }
    
    static func deleteDeletedMessage(messageId: String) -> Single<DatabaseReference> {
         return FireConstants.mainRef.child("deletedMessages").child(FireManager.getUid()).child(messageId).rx.removeValue()
       }

    static func fetchUnDeliveredMessages(appRealm: Realm, disposeBag: DisposeBag) -> Single<DataSnapshot> {
        let ref = FireConstants.userMessages.child(FireManager.getUid())
        return ref.rx.observeSingleEvent(.value).do(onSuccess: { (snapshot) in
            if snapshot.exists() {
                var messagesToDelete = [String:Any]()
                for item in snapshot.children.allObjects {
                    if let snapshot = item as? DataSnapshot,
                        let dict = snapshot.value as? Dictionary<String, AnyObject>, let messageId = dict["messageId"] as? String {

                        messagesToDelete[messageId] = NSNull()
                        
                        let isAppInBackground = UserDefaultsManager.isAppInBackground()

                        NewMessageHandler.handleNewMessage(userInfo: dict, disposeBag: disposeBag, appRealm: appRealm, isSeen: !isAppInBackground, complete: {
                            if let message = RealmHelper.getInstance(appRealm).getMessage(messageId: messageId), let user = RealmHelper.getInstance(appRealm).getUser(uid: message.chatId) {

                                let content = UNMutableNotificationContent()
                                content.title = message.chatId
                                content.body = message.content
                                
                                let request = UNNotificationRequest(identifier: message.messageId, content: content, trigger: nil)
                                
                                UNUserNotificationCenter.current().add(request,withCompletionHandler: {error in
                                    if let error = error{
                                        
                                    }
                                })
                                
                                
                                if isAppInBackground {
                                    let badge = BadgeManager.incrementBadgeByOne(chatId: message.chatId)


                                    let unUpdatedState = UnUpdatedMessageState(messageId: messageId, myUid: FireManager.getUid(), chatId: message.chatId, statToBeUpdated: .RECEIVED)

                                    RealmHelper.getInstance(appRealm).saveObjectToRealm(object: unUpdatedState, update: true)
                                }
                            }
                        })
                    }
                }
                
                if messagesToDelete.isNotEmpty{
                    ref.rx.updateChildValues(messagesToDelete as [AnyHashable : Any]).subscribe().disposed(by: disposeBag)
                }
                
            }
        })
    }
    
    static func requestForNewNotifications(disposeBag:DisposeBag){
        UserDefaultsManager.setLastRequestUnDeliveredMessagesTime(date: Date())
        Functions.functions().httpsCallable("sendUnDeliveredNotifications").rx.call().subscribe(onNext: { (callableResult) in
            
        }, onError: { (error) in
            UserDefaultsManager.setFetchingUnDeliveredMessages(bool: false)

        
        }).disposed(by: disposeBag)
    }

}
