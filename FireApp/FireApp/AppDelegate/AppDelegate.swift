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

//Userapp
import GoogleMaps
import GooglePlaces
import BRYXBanner
import UserNotifications
import IQKeyboardManagerSwift
import Firebase
import UserNotifications
import SwiftyJSON


private let fileURL = FileManager.default
    .containerURL(forSecurityApplicationGroupIdentifier: Config.groupName)!
    .appendingPathComponent("default.realm")
private let config = RealmConfig.getConfig(fileURL: fileURL)
let appRealm = try! Realm(configuration: config)

extension Notification.Name {
    static let gotoProfileNotification = Notification.Name("gotoProfileNotification")
    static let gotoDashboardNotification = Notification.Name("gotoDashboardNotification")
    static let gotoMessagesNotification = Notification.Name("gotoMessagesNotification")
    static let gotoMyJobsNotification = Notification.Name("gotoMyJobsNotification")
    static let gotoPaymentNotification = Notification.Name("gotoPaymentNotification")
    static let gotoContactNotification = Notification.Name("gotoContactNotification")
    static let gotoSettingsNotification = Notification.Name("gotoSettingsNotification")
}

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
    
    var section = ""
    let gcmMessageIDKey = "gcm.message_id"
    var isInBackground: Bool = false
    let notificationCenter = UNUserNotificationCenter.current()
    
    var assignedJobBanner = Banner()
    var jobInfoFromAlert = JobHistoryVO()

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
        
        //UserApp
        GMSServices.provideAPIKey("AIzaSyC4JOqbEZ1YzrUrH5dePNC-gtZY4EzdQbo")
        GMSPlacesClient.provideAPIKey("AIzaSyC4JOqbEZ1YzrUrH5dePNC-gtZY4EzdQbo")
        addNotificationObservers()

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

        UIApplication.shared.applicationIconBadgeNumber = 0
        isInBackground = false
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


//Userapp

extension AppDelegate {
    
    @objc func didReceiveClientNotificationResponse(notification : Notification)
    {
        if let userInfo = notification.userInfo as? NSDictionary
        {
            var title = "Alert"
            
            //audio.play()
            print("LL-22\(userInfo)")
            let suc = userInfo.value(forKey: "isSuccess") as! Bool
            let msg = userInfo.value(forKey: "message") as! String
            
            if let sections = userInfo.value(forKey: "section") {
                section = sections as! String
            }
            
            if let titlee = userInfo.value(forKey: "title") {
                title = titlee as! String
            }
            
            if suc
            {
                //audio.play()
                
                if section == "messages" {
                    if let messagesDict = userInfo.value(forKey: "jobmessage") as? NSDictionary
                    {
                        let dic = messagesDict.value(forKey: "sender") as? NSDictionary
                        let message = messagesDict["message"] as? String ?? ""
                        let displayName = dic?.value(forKey: "displayName") as? String ?? ""
                        
                        let banner = Banner(title: msg, subtitle: "\(displayName): \(message)" , image: UIImage(named: "logo"), backgroundColor: UIColor(red: 19/255, green: 151/255, blue: 245/255, alpha: 1))
                        banner.dismissesOnTap = true
                        banner.dismissesOnSwipe = true
                        banner.textColor = UIColor.white
                        banner.didTapBlock = {
                            
                            let chatView = ChatDetailViewController()
                            chatView.messages = []
                            chatView.jobID = (userInfo.value(forKey: "jobId") as? String)!
                            chatView.providerID = (dic?.value(forKey: "_id") as? String)!
                            chatView.msgThreadID = (userInfo.value(forKey: "messagethreadId") as? String)!
                            let chatNavigationController = UINavigationController(rootViewController: chatView)
                            self.visibleViewController?.present(chatNavigationController, animated: true, completion: nil)
                        }
                        if !isInBackground {
                            banner.show(duration: 3.0)
                        } else {
                            self.scheduleNotification(title: msg, notificationType: "\(displayName): \(message)")
                        }
                        
                    }
                } else {
                    let job = userInfo["job"] as? NSDictionary ?? NSDictionary()
                    let provider = job["client"] as? NSDictionary ?? NSDictionary()
                    let providerName = provider["displayName"] as? String ?? "Provider"
                    let category = job["category"] as? NSDictionary ?? NSDictionary()
                    title = category["name"] as? String ?? "Alert"
                    assignedJobBanner = Banner(title: title, subtitle: msg.replacingOccurrences(of: "Provider", with: providerName),  image: UIImage(named: "logo") , backgroundColor: UIColor(red: 19/255, green: 151/255, blue: 245/255, alpha: 1))
                    assignedJobBanner.dismissesOnTap = true
                    assignedJobBanner.dismissesOnSwipe = true
                    assignedJobBanner.textColor = UIColor.white
                    
                    if let job = userInfo.value(forKey: "job") as? NSDictionary
                    {
                        let jobInfo = JobHistoryVO(withJSON: job)
                        jobInfoFromAlert = jobInfo
                        print(jobInfo)
                    }
                    if let date = jobInfoFromAlert.when?.dateFromISO8601 {
                        NotificationCenter.default.post(name: .reloadDashboardJobs, object: nil)
                    }
                    NotificationCenter.default.post(name: .reloadDashboardJobs, object: nil)
                    if jobInfoFromAlert.status == JobStatus.onway.rawValue || jobInfoFromAlert.status == JobStatus.arrived.rawValue || jobInfoFromAlert.status == JobStatus.started.rawValue {
                        
                        if isAlreadyAttendingACall()
                        {
                            print("already in a call")
                            let vc = UIStoryboard.main().instantiateViewController(withIdentifier: "ProviderOnTheWayVC_ID") as! ProviderOnTheWayVC
                            
                            let jobDataDict : [String: String] = ["jobInfoID": jobInfoFromAlert._id]
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "providerOnTheWay"), object: nil, userInfo: jobDataDict)
                            return;
                        }
                    }
                    else if jobInfoFromAlert.status == JobStatus.completed.rawValue
                    {
//                        if isAlreadyAttendingACall()
//                        {
//                            let vc = UIStoryboard.main().instantiateViewController(withIdentifier: "ReceiptVC_ID") as! ReceiptVC
//                            vc.jobID = jobInfoFromAlert._id
//
//                            if let navController = UIApplication.topViewController()?.navigationController
//                            {
//                                navController.pushViewController(vc, animated: true)
//                            }
//                            return;
//                        }
                        let vc = UIStoryboard.main().instantiateViewController(withIdentifier: "ReceiptVC_ID") as! ReceiptVC
                        vc.jobID = jobInfoFromAlert._id
                        vc.modalPresentationStyle = .fullScreen
                        if let navController = UIApplication.topViewController()
                        {
                            navController.present(vc, animated: true, completion: nil)
                        }
                        return;
                    }
                    if !isInBackground {
                        assignedJobBanner.show(duration: 3.0)
                    } else {
                        self.scheduleNotification(title: title, notificationType: msg.replacingOccurrences(of: "Provider", with: providerName))
                    }
                    
                    
                    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AppDelegate.addGestureRecognizers))
                    assignedJobBanner.addGestureRecognizer(tap)
                }
            }
            else
            {
                
            }
        }
    }
    
    @objc func addGestureRecognizers() {
        print("Banner tapped")
        
        assignedJobBanner.dismiss()
        
        assignedJobBanner.isHidden = true
        
        print(jobInfoFromAlert)
        
        if jobInfoFromAlert.status == JobStatus.onway.rawValue || jobInfoFromAlert.status == JobStatus.arrived.rawValue || jobInfoFromAlert.status == JobStatus.started.rawValue {

            if isAlreadyAttendingACall()
            {
                print("already in a call")
                let vc = UIStoryboard.main().instantiateViewController(withIdentifier: "ProviderOnTheWayVC_ID") as! ProviderOnTheWayVC

                let jobDataDict : [String: String] = ["jobInfoID": jobInfoFromAlert._id]
                NotificationCenter.default.post(name: Notification.Name(rawValue: "providerOnTheWay"), object: nil, userInfo: jobDataDict)
                return;
            }

            let vc = UIStoryboard.main().instantiateViewController(withIdentifier: "ProviderOnTheWayVC_ID") as! ProviderOnTheWayVC
            vc.jobID = jobInfoFromAlert._id

            if let navController = UIApplication.topViewController()?.navigationController
            {
                navController.pushViewController(vc, animated: true)
            }

        }
        else if jobInfoFromAlert.status == JobStatus.completed.rawValue
        {

            let vc = UIStoryboard.main().instantiateViewController(withIdentifier: "ReceiptVC_ID") as! ReceiptVC
            vc.jobID = jobInfoFromAlert._id
            vc.modalPresentationStyle = .fullScreen
            if let navController = UIApplication.topViewController()
            {
                navController.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func isAlreadyAttendingACall() -> Bool
    {
        let topController = UIApplication.topViewController()
        
        if let _ = topController as? ProviderOnTheWayVC
        {
            return true
        }
        
        return false
    }
    
    var visibleViewController: UIViewController? {
        let rootViewController: UIViewController? = window!.rootViewController
        return getVisibleViewController(from: rootViewController)
    }
    
    func getVisibleViewController(from vc: UIViewController?) -> UIViewController? {
        if (vc is UINavigationController) {
            return getVisibleViewController(from: (vc as? UINavigationController)?.visibleViewController)
        } else if (vc is UITabBarController) {
            return getVisibleViewController(from: (vc as? UITabBarController)?.selectedViewController)
        } else {
            if vc?.presentedViewController != nil {
                return getVisibleViewController(from: vc?.presentedViewController)
            } else {
                return vc
            }
        }
    }
    
    func setLoginStoryBoardAsRoot ()
    {
        loadViewControllerWith(identifier: "MainLogin_ID", inStoryBoard: "Login")
    }
    
    func setMainStoryBoardAsRoot ()
    {
        loadViewControllerWith(identifier: "Dashboard_ID", inStoryBoard: "Main")
    }
    
    func loadViewControllerWith( identifier : String,  inStoryBoard : String)
    {
        let storyboard = UIStoryboard(name: inStoryBoard, bundle: nil)
        let initViewController = storyboard.instantiateViewController(withIdentifier: identifier)
        self.window?.rootViewController = initViewController
        self.window?.makeKeyAndVisible()
    }
    
    func addNotificationObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.gotoProfileNotification(_:)), name: .gotoProfileNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.gotoDashboardNotification(_:)), name: .gotoDashboardNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.gotoMyJobsNotification(_:)), name: .gotoMyJobsNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.gotoMessagesNotification(_:)), name: .gotoMessagesNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.gotoPaymentNotification(_:)), name: .gotoPaymentNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.gotoContactNotification(_:)), name: .gotoContactNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.gotoSettingsNotification(_:)), name: .gotoSettingsNotification, object: nil)
    }
    
    @objc func gotoProfileNotification(_ notification: Notification) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Profile_ID")
        switchRootViewController(rootViewController: vc, animated: true, completion: nil)
    }
    
    @objc func gotoDashboardNotification(_ notification: Notification) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Dashboard_ID")
        switchRootViewController(rootViewController: vc, animated: true, completion: nil)
    }
    
    @objc func gotoMyJobsNotification(_ notification: Notification) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MyJobs_ID")
        switchRootViewController(rootViewController: vc, animated: true, completion: nil)
    }
    
    @objc func gotoMessagesNotification(_ notification: Notification) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MessagesList_ID")
        switchRootViewController(rootViewController: vc, animated: true, completion: nil)
    }
    
    @objc func gotoPaymentNotification(_ notification: Notification) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "MyJobs_ID")
//        switchRootViewController(rootViewController: vc, animated: true, completion: nil)
    }
    
    @objc func gotoContactNotification(_ notification: Notification) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "Dashboard_ID")
//        switchRootViewController(rootViewController: vc, animated: true, completion: nil)
    }
    
    @objc func gotoSettingsNotification(_ notification: Notification) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "MyJobs_ID")
//        switchRootViewController(rootViewController: vc, animated: true, completion: nil)
    }
    
    func switchRootViewController(rootViewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard let win = window else {
            return
        }
        if animated {
            UIView.transition(with: win, duration: 0.25, options: .transitionCrossDissolve, animations: {
                let oldState: Bool = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(false)
                win.rootViewController = rootViewController
                UIView.setAnimationsEnabled(oldState)
            }, completion: { (finished: Bool) -> () in
                if (completion != nil) {
                    completion!()
                }
            })
        } else {
            win.rootViewController = rootViewController
        }
    }
}

extension AppDelegate {
    //MARK: Local Notification Methods Starts here
    
    //Prepare New Notificaion with deatils and trigger
    
    func scheduleNotification(title: String, notificationType: String) {
        if !self.isRegisteredForRemoteNotifications() {
            return
        }
        
        //Compose New Notificaion
        let content = UNMutableNotificationContent()
        let categoryIdentifire = "Delete Notification Type"
        content.title = title
        content.sound = UNNotificationSound.default
        content.body = notificationType
        content.badge = 1
        content.categoryIdentifier = categoryIdentifire
        
        //Add attachment for Notification with more content
        if (notificationType == "Local Notification with Content")
        {
            let imageName = "Apple"
            guard let imageURL = Bundle.main.url(forResource: imageName, withExtension: "png") else { return }
            let attachment = try! UNNotificationAttachment(identifier: imageName, url: imageURL, options: .none)
            content.attachments = [attachment]
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let identifier = "Local Notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        //Add Action button the Notification
        if (notificationType == "Local Notification with Action")
        {
            let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
            let deleteAction = UNNotificationAction(identifier: "DeleteAction", title: "Delete", options: [.destructive])
            let category = UNNotificationCategory(identifier: categoryIdentifire,
                                                  actions: [snoozeAction, deleteAction],
                                                  intentIdentifiers: [],
                                                  options: [])
            notificationCenter.setNotificationCategories([category])
        }
    }
    
    func isRegisteredForRemoteNotifications() -> Bool {
        if #available(iOS 10.0, *) {
            var isRegistered = false
            let semaphore = DispatchSemaphore(value: 0)
            let current = UNUserNotificationCenter.current()
            current.getNotificationSettings(completionHandler: { settings in
                if settings.authorizationStatus != .authorized {
                    isRegistered = false
                } else {
                    isRegistered = true
                }
                semaphore.signal()
            })
            _ = semaphore.wait(timeout: .now() + 5)
            return isRegistered
        } else {
            return UIApplication.shared.isRegisteredForRemoteNotifications
        }
    }
}

extension UIApplication {
    
    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
            
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)
            
        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}
