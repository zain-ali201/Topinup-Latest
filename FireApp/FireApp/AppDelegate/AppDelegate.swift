//
//  AppDelegate.swift
//  Topinup
//
//  Created by Zain Ali on 5/17/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift
import IQKeyboardManagerSwift
import RxSwift
import FirebaseAuth
import FirebaseDatabase
import FirebaseUI
import MapKit
import SwiftEventBus
import FirebaseMessaging
import PushKit
import AgoraRtcKit


private let fileURL = FileManager.default
    .containerURL(forSecurityApplicationGroupIdentifier: Config.groupName)!
    .appendingPathComponent("default.realm")
private let config = RealmConfig.getConfig(fileURL: fileURL)
let appRealm = try! Realm(configuration: config)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var currentChatId = ""

    private var application: UIApplication?
    private var messages: Results<Message>!
    private var messagesNotificationToken: NotificationToken?
    private let disposeBag = DisposeBag()
    private var newNotificationsListeners: NewNotificationsListeners!
    private var updateChecker: UpdateChecker!
    var window: UIWindow?

    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    var agoraKit: AgoraRtcEngineKit!
    var isInCall = false

    private var disposables = [Disposable]()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UITabBar.appearance().barTintColor = .white
        UITabBar.appearance().unselectedItemTintColor = UIColor(red: 162.0/255.0, green: 170.0/255.0, blue: 182.0/255.0, alpha: 1)
        UITabBar.appearance().selectedImageTintColor = UIColor(red: 48.0/255.0, green: 123.0/255.0, blue: 248.0/255.0, alpha: 1)
        UINavigationBar.appearance().barTintColor = UIColor(red: 48.0/255.0, green: 123.0/255.0, blue: 248.0/255.0, alpha: 1)
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        UIBarButtonItem.appearance().tintColor = UIColor.white

        self.application = application
        FirebaseApp.configure()
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        updateChecker = UpdateChecker()

        resetApp(application)
        registerNotifications()
        Messaging.messaging().delegate = self
        configurePushKit()

        initIQKBMgr()

        createAgoraEngine()
        self.window = UIWindow()

        goToInitialVC()

        //this will be called when the is killed and the user taps on notification
        if FireManager.isLoggedIn, let notificationData = launchOptions?[.remoteNotification] as? NSDictionary, let chatId = notificationData["chatId"] as? String {

            //wait for view to become alive
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                SwiftEventBus.post(EventNames.notificationTapped, sender: chatId)
            }

        }

        UIApplication.shared.setMinimumBackgroundFetchInterval(15 * 60)


        NotificationCenter.default.addObserver(self, selector: #selector(userDidLogin), name: NSNotification.Name(rawValue: "userDidLogin"), object: nil)

        if FireManager.isLoggedIn && UserDefaultsManager.isUserInfoSaved() {
            setPresenceOnDisconnect()
            listenForConnected()
            syncContactsIfNeeded(appRealm: appRealm)
            checkForUpdate()
        }



        newNotificationsListeners = NewNotificationsListeners(disposeBag: disposeBag)

        return true
    }

    private func startUpdateVC() {
        unRegisterVCsEvents()
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "updateVC")
        self.window?.rootViewController = vc
    }

    private func checkForUpdate() {
        let currentNeedsUpdate = updateChecker.needsUpdate
        updateChecker.checkForUpdate().subscribe(onSuccess: { (needsUpdate) in
            if needsUpdate {
                self.startUpdateVC()
            }else{
                if currentNeedsUpdate != needsUpdate{
                self.goToInitialVC()
                }
                
            }
        }).disposed(by: disposeBag)
    }


    func setNotificationsListeners() {
        guard FireManager.isLoggedIn else {
            return
        }

        let newMessageListener = newNotificationsListeners.attachNewMessagesListeners().subscribe(onNext: { (event) in
            SwiftEventBus.post(EventNames.newMessageReceived, sender: event)
            let message = event.0

            let messageType = message.typeEnum

            if messageType.isMediaType() && AutoDownloadPossibility.canAutoDownload(type: messageType) {
                RequestManager.request(message: message, callback: nil, appRealm: appRealm)
            }

            if self.application?.applicationState == .active {
                if message.chatId != AppDelegate.shared.currentChatId {
                    FireManager.updateMessageState(messageId: message.messageId, chatId: message.chatId, state: .RECEIVED, appRealm: appRealm).subscribe().disposed(by: self.disposeBag)
                }
            }

            MessageManager.deleteMessage(messageId: message.messageId).subscribe().disposed(by: self.disposeBag)
        })


        disposables.append(newMessageListener)
        newMessageListener.disposed(by: disposeBag)

        let newGroupListener = newNotificationsListeners.attachNewGroupListeners().subscribe(onNext: { (user) in
            GroupManager.subscribeToGroupTopic(groupId: user.uid).subscribe().disposed(by: self.disposeBag)

            SwiftEventBus.post(EventNames.newGroupCreated, sender: user)
            MessageManager.deleteNewGroupEvent(groupId: user.uid).subscribe().disposed(by: self.disposeBag)
        })

        disposables.append(newGroupListener)
        newGroupListener.disposed(by: disposeBag)



        let deletedMessagesListener = newNotificationsListeners.attachDeletedMessageListener().subscribe(onNext: { (message, user) in

            SwiftEventBus.post(EventNames.messageDeleted, sender: (message, user))

            MessageManager.deleteDeletedMessage(messageId: message.messageId).subscribe().disposed(by: self.disposeBag)

        })

        disposables.append(deletedMessagesListener)
        deletedMessagesListener.disposed(by: disposeBag)


 

        let listenForScheduledMessageChanges = ScheduledMessagesManager.listenForScheduledMessages2().subscribe(onNext: { (messageId, state) in
            ScheduledMessagesManager.saveMessageAfterSchedulingSucceed(messageId: messageId, state: state)
        })

        disposables.append(listenForScheduledMessageChanges)
        listenForScheduledMessageChanges.disposed(by: disposeBag)


        let listenForScheduledMessageValueChanges = ScheduledMessagesManager.listenForScheduledMessages().subscribe(onNext: { (messageId, state) in
            ScheduledMessagesManager.saveMessageAfterSchedulingSucceed(messageId: messageId, state: state)
        })

        disposables.append(listenForScheduledMessageValueChanges)
        listenForScheduledMessageValueChanges.disposed(by: disposeBag)

        let newCallDisposable = newNotificationsListeners.attachNewCall().subscribe()
        disposables.append(newCallDisposable)
        newCallDisposable.disposed(by: disposeBag)
    }

    func goToInitialVC() {
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)

        if !UserDefaultsManager.hasAgreedToPolicy() {
            
            let vc = storyboard.instantiateViewController(withIdentifier: "mainVc")
            self.window?.rootViewController = vc
        }
        else if !FireManager.isLoggedIn {
            let vc = LoginVC()
            self.window?.rootViewController = vc
        }
        else
        {
            if updateChecker.needsUpdate
            {
                startUpdateVC()
            }
            else if !UserDefaultsManager.isUserInfoSaved()
            {
                let setupUserVc = storyboard.instantiateViewController(withIdentifier: "SetupUserNavVC")
                self.window?.rootViewController = setupUserVc
            }
            else
            {
                
                let rootVC = storyboard.instantiateViewController(withIdentifier: "RootVC")
                self.window?.rootViewController = rootVC
            }
        }
        self.window?.makeKeyAndVisible()
    }

    func syncContactsIfNeeded(appRealm: Realm) {

        if Permissions.isContactsPermissionsGranted() && UserDefaultsManager.needsSyncContacts() && UserDefaultsManager.isUserInfoSaved() {
            ContactsUtil.syncContacts(appRealm: appRealm).subscribe().disposed(by: disposeBag)
        }
    }

    func setPresenceOnDisconnect() {
        if FireManager.isLoggedIn {
            FireConstants.presenceRef.child(FireManager.getUid()).onDisconnectSetValue(ServerValue.timestamp())
        }
    }

    func listenForConnected() {
        if FireManager.isLoggedIn {

            Database.database().reference(withPath: ".info/connected").rx.observeEvent(.value).flatMap { snapshot -> Observable<DatabaseReference> in
                if let connected = snapshot.value as? Bool {
                    if connected {
                        UnProcessedJobs.process(disposeBag: self.disposeBag)
                        return FireManager.setOnlineStatus()
                    } else {
                        return FireManager.setLastSeen()

                    }
                } else {
                    return Observable.empty()
                }
            }.subscribe().disposed(by: disposeBag)
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationWillTerminate(_ application: UIApplication) {


        UserDefaultsManager.setAppTerminated(bool: true)
        UserDefaultsManager.setAppInBackground(bool: true)
        messages = nil
        messagesNotificationToken = nil
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if !FireManager.isLoggedIn {
            completionHandler(.noData)
            return
        }
        if application.applicationState == .background {

            if UserDefaultsManager.getCurrentPresenceState() == .online {
                FireManager.setLastSeen().subscribe(onError: { (error) in
                    completionHandler(.failed)
                }, onCompleted: {
                        completionHandler(.newData)
                    }).disposed(by: disposeBag)
            } else {
                completionHandler(.noData)
            }
        } else {
            completionHandler(.noData)
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {


        if FireManager.isLoggedIn {
            FireManager.setLastSeen().subscribe().disposed(by: disposeBag)
            for disposable in disposables {
                disposable.dispose()
            }
            disposables.removeAll()
        }


        UserDefaultsManager.setAppInBackground(bool: true)
        SwiftEventBus.post(EventNames.appStateChangedEvent, sender: UIApplication.State.background)
    }


    func applicationWillEnterForeground(_ application: UIApplication) {
        // If there is one established call, show the callView of the current call when
        // the App is brought to foreground. This is mainly to handle the UI transition
        // when clicking the App icon on the lockscreen CallKit UI.
        guard FireManager.isLoggedIn else {
            return
        }

        if isInCall {

            if var topController = self.window?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }


                // When entering the application via the App button on the CallKit lockscreen,
                // and unlocking the device by PIN code/Touch ID, applicationWillEnterForeground:
                // will be invoked twice, and "top" will be CallViewController already after
                // the first invocation.
                if !(topController is CallingVC) {
                    topController.performSegue(withIdentifier: "toCallingVC", sender: nil)
                }
            }
        }
        
    }
    
    

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

        
        //fix for textView when it gets pushed down while closing the app and re-open it
        IQKeyboardManager.shared.reloadLayoutIfNeeded()
        SwiftEventBus.post(EventNames.appStateChangedEvent, sender: UIApplication.State.active)
        if FireManager.isLoggedIn {

            RealmHelper.getInstance(appRealm).deleteExpiredStatuses()


            FireManager.setOnlineStatus().subscribe().disposed(by: disposeBag)

            UnProcessedJobs.process(disposeBag: disposeBag)

            setNotificationsListeners()



        }
        UserDefaultsManager.setAppInBackground(bool: false)

        UserDefaultsManager.setAppTerminated(bool: false)






    }



    @objc func userDidLogin() {


        registerNotifications()
        //sync contacts for the first time
        if FireManager.isLoggedIn && UserDefaultsManager.isUserInfoSaved() {
            if Permissions.isContactsPermissionsGranted() && RealmHelper.getInstance(appRealm).getUsers().isEmpty {
                ContactsUtil.syncContacts(appRealm: appRealm).subscribe().disposed(by: disposeBag)
            }

            if disposables.isEmpty {
                setNotificationsListeners()
            }
        }


        FCMTokenSaver.saveTokenToFirebase(token: nil).subscribe().disposed(by: disposeBag)
        checkForUpdate()
        if !UserDefaultsManager.isPKTokenSaved() {
            configurePushKit()
        }
        
        UserDefaultsManager.setUserDidLogin(true)
    }

    private func registerNotifications() {

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in

                center.delegate = self
            }


        )

        application?.registerForRemoteNotifications()
    }
    fileprivate func resetApp(_ application: UIApplication) {
        let userDefaults = UserDefaults.standard

        if !userDefaults.bool(forKey: "hasRunBefore") {
            // Remove Keychain items here

            do {
                application.applicationIconBadgeNumber = 0
                //if the user was logged in before then sign him out
                try FireManager.auth().signOut()

            } catch let error {

            }
            // Update the flag indicator
            userDefaults.set(true, forKey: "hasRunBefore")
        }
    }

    fileprivate func initIQKBMgr() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.touchResignedGestureIgnoreClasses.append(UnResignableKBView.self)
    }


    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        if response.actionIdentifier == UNNotificationDefaultActionIdentifier, let chatId = response.notification.request.content.userInfo["chatId"] as? String {

            SwiftEventBus.post(EventNames.notificationTapped, sender: chatId)

        }
        completionHandler()
    }

    func configurePushKit() {
        // Register for VoIP notifications
        let mainQueue = DispatchQueue.main
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
    }

    fileprivate func handleGroupEvent(userInfo: [AnyHashable: Any]) {
        if let groupId = userInfo["groupId"] as? String, let eventId = userInfo["eventId"] as? String, let contextStart = userInfo["contextStart"] as? String, let eventTypeStr = userInfo["eventType"] as? String, let contextEnd = userInfo["contextEnd"] as? String {

            let eventTypeInt = Int(eventTypeStr) ?? 0
            let eventType = GroupEventType(rawValue: eventTypeInt) ?? .UNKNOWN
            //if this event was by the admin himself  OR if the event already exists do nothing
            if contextStart != FireManager.number! && RealmHelper.getInstance(appRealm).getMessage(messageId: eventId) == nil {
                let groupEvent = GroupEvent(contextStart: contextStart, type: eventType, contextEnd: contextEnd)

                let pendingGroupJob = PendingGroupJob(groupId: groupId, type: eventType, event: groupEvent)
                RealmHelper.getInstance(appRealm).saveObjectToRealm(object: pendingGroupJob)
                GroupManager.updateGroup(groupId: groupId, groupEvent: groupEvent).subscribe(onCompleted: {
                    RealmHelper.getInstance(appRealm).deletePendingGroupJob(groupId: groupId)

                }).disposed(by: disposeBag)
            }
        }
    }


    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //



//        push.application(application, didReceiveRemoteNotification: userInfo)
        if let event = userInfo["event"] as? String {
            if event == "group_event" {
                handleGroupEvent(userInfo: userInfo)
            } else {
                completionHandler(UIBackgroundFetchResult.noData)
            }



        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {

    }

    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {


        let token = deviceToken.reduce("") { $0 + String(format: "%02x", $1) }

//        push.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)

        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }

    func getUser(uid: String, phone: String) -> User {
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

    func createAgoraEngine() {
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: Config.agoraAppId, delegate: nil)
    }


    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {

            guard let url = userActivity.webpageURL else { return false }
            guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true) else { return false }
            guard let host = components.host else { return false }

            if let pathComponents = components.path {

                let groupLink = pathComponents.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "/", with: "")

                guard groupLink.isNotEmpty else { return false }

                SwiftEventBus.post(EventNames.groupLinkTapped, sender: groupLink)

                return true
            }
        }
        return false
    }


    fileprivate func unRegisterVCsEvents() {
        if let viewControllers = window?.rootViewController?.children {
            for viewController in viewControllers {
                if let baseVc = viewController as? Base {
                    //remove events to prevent duplicate unRead counts
                    baseVc.unRegisterEvents()
                }
                
            }
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {

        if url.absoluteString == Config.shareUrl {

            unRegisterVCsEvents()
            //reset chatId
            currentChatId = ""
            let storyboard = UIStoryboard(name: "Chat", bundle: nil)
//            //
            let shareNavVC = storyboard.instantiateViewController(withIdentifier: "shareNavVC")
            self.window?.rootViewController = shareNavVC
            self.window?.makeKeyAndVisible()



            return true

        }
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true) else { return false }


        if let scheme = components.scheme, scheme.starts(with: Config.groupVoiceCallLink), let conferenceId = components.host {

            SwiftEventBus.post(EventNames.groupVoiceCallLinkTapped, sender: conferenceId)



            return true

        }



        return false

    }
}




extension AppDelegate: PKPushRegistryDelegate {
    // Handle updated push credentials

    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        
        let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
        

        if (!FireManager.isLoggedIn) { return }

        FCMTokenSaver.savePKTokenToFirebase(token: deviceToken).subscribe().disposed(by: disposeBag)
    }

    fileprivate func setMissedCall(_ fireCall: FireCall, _ groupName: String, _ user: User, _ callId: String) {
        RealmHelper.getInstance().setCallDirection(callId: fireCall.callId, callDirection: .MISSED)


        let body = groupName.isEmpty ? user.properUserName : groupName
        let content = UNMutableNotificationContent()
        content.title = Strings.missed_call
        content.body = body

        let request = UNNotificationRequest(identifier: callId, content: content, trigger: nil)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if let error = error { }
        })

    }

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        

        let data = payload.dictionaryPayload
        guard let callId = data["callId"] as? String else {
            return
        }



        let fromId = data["callerId"] as? String ?? ""

        let typeStr = Int((data["callType"]as? String ?? "1"))

        let type = CallType(rawValue: typeStr ?? CallType.VOICE.rawValue)!


        let groupId = data["groupId"] as? String ?? ""

        let isGroupCall = type.isGroupCall



        let channel = data["channel"] as! String

        let groupName = data["groupName"] as? String ?? ""

        let timestamp = Int(data["timestamp"] as? String ?? Date().currentTimeMillisStr())!

        let phoneNumber = data["phoneNumber"] as? String ?? ""

        let isVideo = type.isVideo

        let uid = isGroupCall ? groupId : fromId


        var user: User

        let storedUser = RealmHelper.getInstance().getUser(uid: uid)


        if (storedUser == nil) {
            //make dummy user temporarily
            user = User()
            if isGroupCall {
                user.uid = groupId
                user.isGroupBool = true
                user.userName = groupName
                let group = Group()
                group.groupId = groupId
                group.isActive = true


                let currentUser = RealmHelper.getInstance(appRealm).getUser(uid: FireManager.getUid())

                group.users.append(currentUser!)
                user.group = group
            } else {
                user.uid = uid
                user.phone = phoneNumber
            }
        } else {
            user = storedUser!
        }

        let callUUID = UUID()



        let fireCall = FireCall(callId: callId, callUUID: callUUID.uuidString, user: user, callType: type, callDirection: .INCOMING, channel: channel, timestamp: timestamp, duration: 0, phoneNumber: phoneNumber, isVideo: isVideo)

        

        ProviderDelegate.sharedInstance.reportIncomingCall(fireCall)

        if TimeHelper.isTimePassedBySeconds(biggerTime: Double(Date().currentTimeMillis()), smallerTime: Double(timestamp), seconds: FireCallsManager.CALL_TIEMOUT_SECONDS) {

            ProviderDelegate.sharedInstance.reportMissedCall(uuid: callUUID, date: Date(timeIntervalSince1970: TimeInterval(timestamp)), reason: .answeredElsewhere)

            setMissedCall(fireCall, groupName, user, callId)

        } else {

            if !isInCall {

                FireCallsManager().listenForEndingCall(callId: fireCall.callId, otherUid: uid, isIncoming: true).subscribe(onNext: { (snapshot) in
                    if snapshot.exists() {

                        if let call = RealmHelper.getInstance().getFireCall(callId: callId), call.callDirection != .ANSWERED {

                            self.setMissedCall(fireCall, groupName, user, callId)
                            ProviderDelegate.sharedInstance.reportMissedCall(uuid: callUUID, date: Date(timeIntervalSince1970: TimeInterval(timestamp)), reason: .unanswered)
                        }


                    }
                }).disposed(by: disposeBag)

            } else {
                ProviderDelegate.sharedInstance.reportMissedCall(uuid: callUUID, date: Date(timeIntervalSince1970: TimeInterval(timestamp)), reason: .answeredElsewhere)

                setMissedCall(fireCall, groupName, user, callId)

            }
        }





    }

    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {

    }



}



extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {

        if FireManager.isLoggedIn {
            FCMTokenSaver.saveTokenToFirebase(token: fcmToken).subscribe().disposed(by: disposeBag)
        }
    }


}
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //do not show system notifications while the app is active, instead show NotificationView in VC
        completionHandler([])
    }
}
