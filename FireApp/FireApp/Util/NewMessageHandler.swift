//
//  NewMessageHandler.swift
//  Topinup
//
//  Created by Zain Ali on 2/9/20.
//  Copyright © 2020 Devlomi. All rights reserved.
//

import RealmSwift
import MapKit
import RxSwift
class NewMessageHandler {

    fileprivate static func saveNewMessage(message: Message, appRealm: Realm, fromId: String, phone: String, disposeBag: DisposeBag) {



        
        
        let needsToFetchUserData = RealmHelper.getInstance(appRealm).getUser(uid: message.chatId) == nil
             //if unknown number contacted us ,we want to download his data and save it in local db
                if !message.isGroup && needsToFetchUserData{
                    FireManager.fetchUserDataAndSaveIt(phone: phone, disposeBag: disposeBag, appRealm: appRealm)
                }
        
        if RealmHelper.getInstance(appRealm).getMessage(messageId: message.messageId, chatId: message.chatId) == nil {
            

            
            MessageCreator.saveNewMessage(message, user: self.getUser(uid: fromId, phone: phone, appRealm: appRealm), appRealm: appRealm)
            let messageType = message.typeEnum
            //check if user enabled auto download, then check if the app was terminated, if it's terminated start the download process from Notification Serivce, then check if it's an image or voice, because these types has a small size and Notification Service time is limited
            //if the app was NOT terminated we will leave it for the app service to Download it.
            if AutoDownloadPossibility.canAutoDownload(type: messageType) && UserDefaultsManager.isAppInBackground() && (messageType == .RECEIVED_VOICE_MESSAGE || messageType == .RECEIVED_IMAGE) {
                
                DownloadManager.download(message: message, callback: nil, appRealm: appRealm)

            }
        }

   
    }

    static func handleNewMessage(userInfo: [AnyHashable: Any], disposeBag: DisposeBag, appRealm: Realm,isSeen:Bool, complete: (@escaping () -> Void)) {

        guard FireManager.isLoggedIn else {
            return
        }

        //
        
        let dict = userInfo
        let messageId = dict[DBConstants.MESSAGE_ID] as? String ?? ""
        let isGroup = dict.keys.contains("isGroup")
        //getting data from fcm message and convert it to a message
        let phone = dict[DBConstants.PHONE] as? String ?? ""
        let content = dict[DBConstants.CONTENT]as? String ?? ""
        let timestampStr = dict[DBConstants.TIMESTAMP]as? String ?? Date().currentTimeMillisStr()
        let timestamp = Int(timestampStr) ?? Date().currentTimeMillisLong()
        let typeStr = dict[DBConstants.TYPE] as? String ?? "0"
        let typeInt = Int(typeStr) ?? 0

        let type = MessageType(rawValue: typeInt)
        //get sender uid
        let fromId = dict[DBConstants.FROM_ID]as? String ?? ""
        let toId = dict[DBConstants.TOID] as? String ?? ""
        let metadata = dict[DBConstants.METADATA] as? String ?? ""

        let mediaDuration = dict[DBConstants.MEDIADURATION] as? String ?? ""
        let fileSize = dict[DBConstants.FILESIZE] as? String ?? ""

        //convert sent type to received
        let convertedType = type!.convertSentToReceived()

        let thumb = dict["thumb"] as? String ?? ""

        //

        //if it's a group message and the message sender is the same
        if fromId == FireManager.getUid() {
            return
        }

        //if message is deleted do not save it
        if RealmHelper.getInstance(appRealm).getDeletedMessage(messageId: messageId) != nil {
            return
        }

        let message = Message()



        if let quotedMessageId = dict["quotedMessageId"] as? String, let quotedMessage = RealmHelper.getInstance(appRealm).getMessage(messageId: quotedMessageId) {
            message.quotedMessage = QuotedMessage.messageToQuotedMessage(quotedMessage)
        }




        if let contactJsonString = userInfo["contact"] as? String {
            message.downloadUploadState = .DEFAULT
            let numbers = JsonUtil.getPhoneNumbersList(jsonString: contactJsonString)
            let realmContact = RealmContact(name: content, numbers: numbers)
            message.contact = realmContact
        }

        if let locationJsonString = userInfo["location"] as? String {
            
            message.downloadUploadState = .DEFAULT
            if let location = JsonUtil.getRealmLocationFromJson(jsonString: locationJsonString) {
                message.location = location
            }
        }



        //create the message

        message.content = content
        message.timestamp = timestamp
        message.fromId = fromId
        message.typeEnum = convertedType
        message.messageId = messageId
        message.toId = toId
        message.chatId = isGroup ? toId : fromId
        message.isGroup = isGroup
        message.thumb = thumb
        message.metatdata = metadata
        message.mediaDuration = mediaDuration
        message.fileSize = fileSize



        if (isGroup) {
            message.fromPhone = phone
        }

 

        if convertedType == .RECEIVED_LOCATION, let location = message.location {

            self.getMapView(location: location) { (image) in
                if let image = image {

                    let thumb = image.wxCompress().toBase64String()
                    message.thumb = thumb
                } else {
                    
                }



                saveNewMessage(message: message, appRealm: appRealm, fromId: fromId, phone: phone, disposeBag: disposeBag)

                complete()
            }


        } else {



            //set it to loading to start downloading automatically when the app starts
            let downloadUploadState:DownloadUploadState = AutoDownloadPossibility.canAutoDownload(type: message.typeEnum) ? .LOADING : .FAILED

            message.downloadUploadState = downloadUploadState

            saveNewMessage(message: message, appRealm: appRealm, fromId: fromId, phone: phone, disposeBag: disposeBag)


            complete()


        }



    }

    private static func getMapView(location: RealmLocation, complete: (@escaping (UIImage?) -> Void)) {

        let mapSnapshotOptions = MKMapSnapshotter.Options()

        let location = CLLocation(latitude: location.lat, longitude: location.lng)


        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapSnapshotOptions.region = region

        // Set the scale of the image. We'll just use the scale of the current device, which is 2x scale on Retina screens.
        mapSnapshotOptions.scale = UIScreen.main.scale

        // Set the size of the image output.
        mapSnapshotOptions.size = CGSize(width: 300, height: 300)

        // Show buildings and Points of Interest on the snapshot
        mapSnapshotOptions.showsBuildings = true
        mapSnapshotOptions.showsPointsOfInterest = true



        let snapShotter = MKMapSnapshotter(options: mapSnapshotOptions)

        snapShotter.start { (snapshot, error) in
            guard let snapshot = snapshot, error == nil else {
                
                return
            }

            UIGraphicsBeginImageContextWithOptions(mapSnapshotOptions.size, true, 0)
            snapshot.image.draw(at: .zero)

            let pinView = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
            let pinImage = pinView.image

            var point = snapshot.point(for: location.coordinate)

            //            if rect.contains(point) {
            let pinCenterOffset = pinView.centerOffset
            point.x -= pinView.bounds.size.width / 2
            point.y -= pinView.bounds.size.height / 2
            point.x += pinCenterOffset.x
            point.y += pinCenterOffset.y
            pinImage?.draw(at: point)
            //            }

            let image = UIGraphicsGetImageFromCurrentImageContext()

            UIGraphicsEndImageContext()
            complete(image)
        }
    }
    static func getUser(uid: String, phone: String, appRealm: Realm) -> User {
        if let user = RealmHelper.getInstance(appRealm).getUser(uid: uid) {
            return user
        }

        //save temp user data while fetching all data later
        let user = User()
        user.phone = phone
        user.uid = uid
        user.userName = phone
        user.isStoredInContacts = false

        RealmHelper.getInstance(appRealm).saveObjectToRealm(object: user)
        

        return user
    }
}
