//
//  UploadManager.swift
//  Topinup
//
//  Created by Zain Ali on 3/14/20.
//  Copyright © 2020 Devlomi. All rights reserved.
//

import Foundation
import RxSwift
import FirebaseDatabase
import FirebaseStorage
import SwiftEventBus
import RealmSwift

class UploadManager{
    typealias Callback = (_ isSuccess: Bool) -> Void


      //save the file upload task to cancel it later if user wants to
      public static var uploadTaskDict = [String: StorageUploadTask]()

      //used in activity to get the current progress
      private static var progressDataDict = [String: ProgressData]()

      public static var jobIdDict = [String: Int]()
    
    public static func upload(message: Message, callback: Callback?,appRealm:Realm) {


        //get file path
        let filePath = message.localPath

        let pushKey = message.messageId
        //get file name from file path
        let fileName = filePath.fileName()

        let receivedId = message.chatId

        //get correct ref in firebase storage folders ,if it's an image it will be saved in images folder
        //if it's a video it will be saved in video folder
        let ref = FireConstants.getRef(type: message.typeEnum, fileName: fileName)


        let url = URL(fileURLWithPath: filePath)
        beginBackgroundTask(messageId: message.messageId)
        RealmHelper.getInstance(appRealm).updateDownloadUploadStat(messageId: message.messageId, downloadUploadStat: .LOADING)
        let task = ref.putFile(from: url, metadata: nil) { (meta, storageError) in
            //UPDATE UI
            removeProgressFromDict(messageId: pushKey)
            removeTaskFromHashmap(messageId: pushKey)

            // check if upload is success && the user is not cancelled the upload request
            if storageError == nil && message.completeAfterDownload() {


                let filePath = ref.fullPath
                setMessageContent(filePath: filePath, message: message,appRealm:appRealm)

                FireConstants.getMessageRef(isGroup: message.isGroup, isBroadcast: message.isBroadcast, groupOrBroadcastId: message.chatId).child(message.messageId).updateChildValues(message.toMap(), withCompletionBlock: { (error, ref) in
                        //update download upload state if it's success or not
                        RealmHelper.getInstance(appRealm).updateDownloadUploadStat(messageId: pushKey, downloadUploadStat: error == nil ? .SUCCESS : .FAILED)
                        updateJobCallback(isSuccess: error == nil, callback: callback)

                        onComplete(id: pushKey)

                    })
            }


            else {
                //if this process was not cancelled by the user (a network failure for example) then set the state as failed
                if let error = storageError as NSError?, error.code != StorageErrorCode.cancelled.rawValue {
                    RealmHelper.getInstance(appRealm).changeDownloadOrUploadStat(messageId: pushKey, state: .FAILED);
                    updateJobCallback(isSuccess: false, callback: callback);
                } else {
                    updateJobCallback(isSuccess: true, callback: callback);
                }

           onComplete(id: pushKey)
            }
        }

        task.observe(.progress) { (snapshot) in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
            / Double(snapshot.progress!.totalUnitCount)


            fillProgressDict(messageId: pushKey, receiverId: receivedId, progress: Float(percentComplete))

            //update progress in UI
            updateProgress(id: pushKey, progress: Float(percentComplete))

        }



        fillTaskDict(messageId: message.messageId, uploadTask: task)



    }
    
    //save file link from firebase storage in realm to use it later when forward a message
    private static func setMessageContent(filePath: String, message: Message,appRealm:Realm) {

        RealmHelper.getInstance(appRealm).changeMessageContent(messageId: message.messageId, content: filePath);


    }
    
    static func sendMessage(message: Message, callback: Callback?,appRealm:Realm) {
            let messageId = message.messageId
    //        let backgroundUploadID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
            FireConstants.getMessageRef(isGroup: message.isGroup, isBroadcast: message.isBroadcast, groupOrBroadcastId: message.chatId).child(message.messageId).updateChildValues(message.toMap()) { (error, _) in
                if error == nil {
                    if message.isBroadcast {
                        let broadcastedMessages = RealmHelper.getInstance(appRealm).getMessages(messageId: messageId)
                        for broadcastedMessage in broadcastedMessages {
                            RealmHelper.getInstance(appRealm).updateMessageStateLocally(messageId: broadcastedMessage.messageId, messageState: .SENT)
                            RealmHelper.getInstance(appRealm).getMessageAndUpdateIt(messageId: broadcastedMessage.messageId) { (foundMessage) in
                                if let message = foundMessage{
                                    message.downloadUploadState = .SUCCESS
                                }
                            }
                        }
                    } else {
                        RealmHelper.getInstance(appRealm).updateMessageStateLocally(messageId: messageId, messageState: .SENT)
                        RealmHelper.getInstance(appRealm).getMessageAndUpdateIt(messageId: messageId) { (foundMessage) in
                            if let message = foundMessage{
                                message.downloadUploadState = .SUCCESS
                            }
                        }
                    }

                }
                updateJobCallback(isSuccess: error == nil, callback: callback)
    //            UIApplication.shared.endBackgroundTask(backgroundUploadID)
            }
        }

    public static func onComplete(id: String) {
        endBackgroundTask(messageId: id)

        SwiftEventBus.post(EventNames.networkCompleteEvent, sender: DownloadCompleteEvent(id: id))
    }

 

    public static func fillTaskDict(messageId: String, uploadTask: StorageUploadTask) {
        uploadTaskDict[messageId] = uploadTask
    }

    public static func fillProgressDict(messageId: String, receiverId: String, progress: Float) {
        let progressData = ProgressData(progress: progress, receiverId: receiverId, messageId: messageId)
        progressDataDict[messageId] = progressData
    }

    public static func removeTaskFromHashmap(messageId: String) {
        uploadTaskDict.removeValue(forKey: messageId)
    }

    public static func removeProgressFromDict(messageId: String) {
        uploadTaskDict.removeValue(forKey: messageId)
    }

    public static func updateProgress(id: String, progress: Float) {
        SwiftEventBus.post(EventNames.networkProgressEvent, sender: ProgressEventData(id: id, progress: progress))
    }








    public static func cancelUpload(message: Message,appRealm:Realm) {
        let messageId = message.messageId

        if let uploadTask = uploadTaskDict[messageId] {
            uploadTask.cancel()
            uploadTaskDict.removeValue(forKey: messageId)
        }

        removeProgressFromDict(messageId: messageId)
        RealmHelper.getInstance(appRealm).changeDownloadOrUploadStat(messageId: messageId, state: .CANCELLED);

        endBackgroundTask(messageId: message.messageId)


    }


    public static func cancelUpload(messageId: String,appRealm:Realm) {
        if let uploadTask = uploadTaskDict[messageId] {
            uploadTask.cancel()
            uploadTaskDict.removeValue(forKey: messageId)
        }

        removeProgressFromDict(messageId: messageId)
        RealmHelper.getInstance(appRealm).changeDownloadOrUploadStat(messageId: messageId, state: .CANCELLED)

        endBackgroundTask(messageId: messageId)
        

    }

    
    public static func updateJobCallback(isSuccess: Bool, callback: Callback?) {
        callback?(isSuccess)
    }
    

        public static func endBackgroundTask(messageId: String) {
            if let taskId = jobIdDict[messageId] {
                UIApplication.shared.endBackgroundTask(UIBackgroundTaskIdentifier(rawValue: taskId))
            }

        }
    
        public static func beginBackgroundTask(messageId: String) -> UIBackgroundTaskIdentifier {
            let taskId = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
            jobIdDict[messageId] = taskId.rawValue
            return taskId
        }
}
