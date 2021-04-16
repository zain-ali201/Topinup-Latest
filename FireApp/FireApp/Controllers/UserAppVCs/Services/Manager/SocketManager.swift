//
//  SocketManager.swift
//  NeighboorhoodDriver
//
//  Created by Apple Zone  on 04/04/2017.
//  Copyright © 2017 Yamsol. All rights reserved.
//

import UIKit
import SocketIO
import SwiftyJSON
import AVFoundation


class SocketManager: NSObject {

    var audio : AVAudioPlayer!
    var manager: SocketManager?
    var socket : SocketIOClient?
    
//    let manager = SocketManager(socketURL: URL(string: URLConfiguration.ServerUrl)!, config: [.log(false), .connectParams(["auth_token": AppUser.getUser()?.token])])
//    let socket = manager.defaultSocket
    
    // Singleton Class. Can not be init outside
    private override init() { }
    
    static let shared = SocketManager()

    func establishConnection()
    {
//        socket?.forceNew = true
//        socket?.reconnectWait = 5
        
        if(AppUser.getUser() != nil && (socket == nil || socket?.status != .connected ) && DataModel.shared.socketConnection == false)
        {
            let driverUser = AppUser.getUser()
            
            if let token = driverUser?.token
            {
                
//                let urlAdress = URL(string: URLConfiguration.ServerUrl)
//                let config = ["log": true]
//                manager = SocketManager(socketURL: urlAdress!, config: config)
//                socket = manager!.defaultSocket
                
                ///socket = SocketIOClient(socketURL: URL(string: URLConfiguration.ServerUrl)!, config:[.log(false),.connectParams(["auth_token": token])])
                
                socket = SocketIOClient(socketURL: URL(string: URLConfiguration.ServerUrl)!, config: [.log(true),.connectParams(["auth_token": token])])
                
                registerListeners()
                
                self.connect()
                DataModel.shared.socketConnection = true
            }
            else
            {
                print("Driver token is lost . app can't connect to servers")
                NotificationCenter.default.post(name: .kSocketDisconnected, object: nil, userInfo: nil)
                
            }
        }
        else if (socket?.status == .connected)
        {
            print("Already Connected")
            NotificationCenter.default.post(name: .kSocketConnected, object: nil, userInfo: nil)
        }
        

    }
    
    func connect(){
        socket?.connect(timeoutAfter: 5, withHandler: {
            self.connect()
        })
    }
    
    func sendSocketRequest(name : String, params : [String : Any])
    {
        print("Calling ---------- \(name)  ---------- \n params \n \(params) \n\n\n ------------- ")
        socket?.emit(name, params)
        
        
        
    }
    
//    func logSocketCall( name : String, )
//    {
//        print("Calling ---------- \(name) ------------- on Socket")
//    }
    
    func closeConnection() {
        socket?.disconnect()
    }
    
    // Register Socket Listeners
    func registerListeners()
    {
        print("Here to register listeners")
        
        socket?.on("connect") {data, ack in
            print("socket connected")

            SocketManager.shared.sendSocketRequest(name: "updateSocketId", params: ["":""])
            if let deviceToken = AppUser.getToken()
            {
                if deviceToken.count > 5 {
                    // Making sure it's not an empty string
                    
                    var params = ["device" : "ios"]
                    params["key"] = deviceToken
                    
                    print("Sending deviceType - iOS & deviceKey - \(deviceToken)")
                    SocketManager.shared.sendSocketRequest(name: SocketEvent.UpdateProfile, params: params)
                }
            }
            
            URLConfiguration.delay(0.75, closure: {
                
                NotificationCenter.default.post(name: .kSocketConnected, object: nil, userInfo: nil)
                
            })
        }
        
        socket?.on("disconnect") {data, ack in
            print("socket DISCONNECTED")
            
            self.connect()
        }
        
        socket?.on("error") {data, ack in
            print("socket ERROR")
            //Post socket error  notification
            NotificationCenter.default.post(name: .kSocketDisconnected, object: nil, userInfo: nil)
            
        }
        
        //Assigning tune to audio object
        //audio = try! AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: Bundle.main.path(forResource: kTune, ofType: "mp3")!) as URL)
        
        socket?.on(SocketEvent.ClientNotifications) { (data, ack) in
            
            if let responseDict = data[0] as? NSDictionary
            {
                NotificationCenter.default.post(name: .KClientNotifications , object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
            return
            
        }
        
        socket?.on(SocketEvent.CurrentLocation) { (data, ack) in
            
            if let responseDict = data[0] as? NSDictionary
            {
                NotificationCenter.default.post(name: .KCurrentLocation , object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
            return
            
        }
        
        socket?.on(SocketEvent.JoinRoom) { (data, ack) in
            
            if let responseDict = data[0] as? NSDictionary
            {
                NotificationCenter.default.post(name: .KJoinRoom , object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
            return
            
        }
        
        socket?.on(SocketEvent.leaveRoom) { (data, ack) in
            
            if let responseDict = data[0] as? NSDictionary
            {
                NotificationCenter.default.post(name: .KLeaveRoom , object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
            return
            
        }
        
        
        socket?.on(SocketEvent.GetJobDisputes) { (data, ack) in
            
            if let responseDict = data[0] as? NSDictionary
            {
                NotificationCenter.default.post(name: .KGetJobDisputes , object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
            return
            
        }
        
        socket?.on(SocketEvent.NewJobDispute) {data, ack in
            
            if let responseDict = data[0] as? NSDictionary
            {
                NotificationCenter.default.post(name: .KNewJobDispute, object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
            return
        }
        
        socket?.on(SocketEvent.GetDisputeMessages) {data, ack in
            
            if let responseDict = data[0] as? NSDictionary
            {
                NotificationCenter.default.post(name: .KGetDisputeMessages, object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
            return
        }
        
        socket?.on(SocketEvent.AddMessageThread) {data, ack in
            
            
                
            
            if let responseDict = data[0] as? NSDictionary
            {
                print(responseDict)
                NotificationCenter.default.post(name: .kAddMessageThread, object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
            return
        }
        
        socket?.on(SocketEvent.GetJobThreadMessages) {data, ack in
            
            if let responseDict = data[0] as? NSDictionary
            {
                NotificationCenter.default.post(name: .kGetJobThreadMessages, object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
            return
        }
        
        socket?.on(SocketEvent.GetMessageThreads) {data, ack in
            
            if let responseDict = data[0] as? NSDictionary
            {
                NotificationCenter.default.post(name: .kGetMessageThreads, object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
            return
        }
        
        socket?.on(SocketEvent.UpdateProfile) { (data, ack) in
            
            if let responseDict = data[0] as? NSDictionary
            {
                NotificationCenter.default.post(name: .KUpdateProfile , object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
            return
            
        }
        
        socket?.on(SocketEvent.READ_MESSAGE) { (data, ack) in
            
            if let responseDict = data[0] as? NSDictionary
            {
                NotificationCenter.default.post(name: .kReadMessageEvent , object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
            return
            
        }
        
        socket?.on(SocketEvent.getUnreadMsgs) { (data, ack) in
            
            if let responseDict = data[0] as? NSDictionary
            {
                NotificationCenter.default.post(name: .kGetUnreadMsgs , object: nil, userInfo: responseDict as? [AnyHashable : Any])
            }
            return
            
        }
        
    }
    
//    func handleDispatchNotification( response : NSDictionary?)
//    {
//        if let responseDict = response
//        {
//            print("Dispatch Notifications Received")
//
//            if let jobDict = responseDict.value(forKey: "dispatch") as? NSDictionary
//            {
//                if let jobStatusText = jobDict.value(forKey: "jobStatus") as? String
//                {
//                    var notificationName : Notification.Name = .kAwyaiyeinAction
//
//
////                    if let jobStatus = JobStatus(rawValue: jobStatusText)
////                    {
////                        //self.audio.play()
////
////                        switch (jobStatus)
////                        {
////
////                        case .arrived:
////                            notificationName = Notification.Name.kDriverArrivedAction
////                            break
////                        case .informed:
////                            notificationName = Notification.Name.kDriverInformed
////                            break
////                        case .cancelled:
////                            notificationName = Notification.Name.kJobCancelledAction
////                            break
////                        case .started:
////                            notificationName = Notification.Name.kJobStartedAction
////                            break
////                        case .completed:
////                            notificationName = Notification.Name.kJobCompletedAction
////                            break
////                        case .charged:
////                            notificationName = Notification.Name.kJobCharged
////                            break
////                        case .finished:
////                            notificationName = Notification.Name.kJobFinished
////                            break
////                        default:
////                            notificationName = Notification.Name.kJobCancelledAction
////                            break
////                        }
////
////                        NotificationCenter.default.post(name: notificationName , object: nil, userInfo: responseDict as? [AnyHashable : Any])
////
////                    }
////                    else
////                    {
////                        print("Unknown jobStatus " + jobStatusText)
////                    }
////
//                }
//
//            }
//
//
//        }
//
//    }
    
//    func handleDriverNotification( response : NSDictionary?)
//    {
//        if let responseDict = response
//        {
//            print("Driver Notifications received")
//            
//            if let jobStatusText = responseDict.value(forKey: "jobStatus") as? String
//            {
//                
//                var notificationName : Notification.Name = .kAwyaiyeinAction
//                
//                
////                if let jobStatus = JobStatus(rawValue: jobStatusText)
////                {
////                    //self.audio.play()
////
////                    switch (jobStatus)
////                    {
////
////                    case .arrived:
////                        notificationName = Notification.Name.kDriverArrivedAction
////                        break
////                    case .informed:
////                        notificationName = Notification.Name.kDriverInformed
////                        break
////                    case .cancelled:
////                        notificationName = Notification.Name.kJobCancelledAction
////                        break
////                    case .started:
////                        notificationName = Notification.Name.kJobStartedAction
////                        break
////                    case .completed:
////                        notificationName = Notification.Name.kJobCompletedAction
////                        break
////                    case .finished:
////                        notificationName = Notification.Name.kJobFinished
////                        break
////                    case .charged:
////                        notificationName = Notification.Name.kJobCharged
////                        break
////                    default:
////                        notificationName = Notification.Name.kJobCancelledAction
////                        break
////                    }
////
////                    NotificationCenter.default.post(name: notificationName , object: nil, userInfo: responseDict as? [AnyHashable : Any])
////                }
////                else if (jobStatusText == "jobPayment")
////                {
////                    // Don't know why, but was told this is how it's done in Android.
////                    // So Copying it here
////                    NotificationCenter.default.post(name: Notification.Name.kClientPaidForJob , object: nil, userInfo: responseDict as? [AnyHashable : Any])
////                }
////                else
////                {
////                    print("Unknown jobStatus : " + jobStatusText)
////                }
//                
//            }
//            
//        }
//
//    }
    
}


struct SocketEvent
{
    
    static let Sign_Out = "signOut"
    static let Driver_Call = "callDriver"
    static let Dispatch_Call = "newDispatchCall"
    
    // new here
    
    static let ClientNotifications = "clientNotifications"
    static let CurrentLocation = "currentLocation"
    static let JoinRoom = "joinRoom"
    static let leaveRoom = "leaveRoom"
    static let UpdateProfile = "updateProfile"
    // end new here
    
    
    static let GetJobDisputes = "getJobDisputes"
    static let NewJobDispute = "newJobDispute"
    static let GetDisputeMessages = "getDisputeMessages"
    
    static let GetAssignedJobs = "getAssignedJobs"
    
    
    // New Variable for Volgo Provider
    static let AddMessageThread = "addMessageThread"
    static let GetJobThreadMessages = "getJobThreadMessages"
    static let GetMessageThreads = "getJobMessagesThread"
    static let READ_MESSAGE = "readMessages"
    static let SOCKET_MARK_RECEIVED = "getAllSentMsgs";
    static let SOCKET_MARK_READ = "updateSingeMsgStatus";
    static let SOCKET_UPDATE_STATUS = "notifyToMsgSender";
    static let getUnreadMsgs = "getUnreadMsgs"
}


extension Notification.Name
{
    // new here
    
    static let kSocketConnected = Notification.Name("kSocketConnected")
    static let kSocketDisconnected = Notification.Name("kSocketDisconnected")
    static let KCurrentLocation = Notification.Name("KCurrentLocation")
    static let KClientNotifications = Notification.Name("KClientNotifications")
    static let KJoinRoom = Notification.Name("KJoinRoom")
    static let KLeaveRoom = Notification.Name("KLeaveRoom")
    static let KUpdateProfile = Notification.Name("KUpdateProfile")
    // end new here
    
    
    static let KGetJobDisputes              = Notification.Name("KGetJobDisputes")
    static let KNewJobDispute               = Notification.Name("KNewJobDispute")
    static let KGetDisputeMessages          = Notification.Name("KGetDisputeMessages")
    
    static let KGetAssignedJobs             = Notification.Name("KGetAsssignedJobs")
    
    static let kAddMessageThread = Notification.Name("kAddMessageThread")
    static let kGetJobThreadMessages = Notification.Name("kGetJobThreadMessages")
    static let kGetMessageThreads = Notification.Name("kGetMessageThreads")
    static let kReadMessageEvent = Notification.Name("kReadMessages")
    static let kGetUnreadMsgs = Notification.Name("kGetUnreadMsgs")
}


