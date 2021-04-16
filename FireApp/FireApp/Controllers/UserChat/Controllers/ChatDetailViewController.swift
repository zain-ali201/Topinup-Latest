//
//  ChatDetailViewController.swift
//  BN News
//
//  Created by ArhamSoft on 08/04/2019.
//  Copyright © 2019 ArhamSoft. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON
import MBProgressHUD
import ReverseExtension
import GrowingTextView
import IQKeyboardManagerSwift
import AVFoundation
import SVProgressHUD
import AudioToolbox
import Kingfisher
import AVKit
import MobileCoreServices

enum MessageSourceType : String
{
    case Company = "Client"
    case Driver  = "Provider"
}

class ChatDetailViewController: UIViewController {
    
    
    let imageView = UIImageView()
    
    // MARK: - IBOutlets
    @IBOutlet weak var inputToolbar: UIView!
    @IBOutlet weak var textView: GrowingTextView!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var conversation: UITableView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var titleLbl : UILabel!
    @IBOutlet weak var friendNameTitle: UIBarButtonItem!
    @IBOutlet weak var attachViewHeight: NSLayoutConstraint!
    @IBOutlet weak var audioViewHeight: NSLayoutConstraint!
    @IBOutlet weak var recordView: UIView!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var userBtn: UIButton!
    
    
    // MARK: - Variables
    
    var threadInfo = MessageListVO()
    var messages = [MessageThreadVO]()
    let defaults = UserDefaults.standard
    fileprivate var displayName: String!
    
    
    
    //    var senderID : String!
    var messageSourceType : MessageSourceType!
    //var queryType : QueryType!
    var queryMessages = [MessageThreadVO]()
    var queryID = String()
    var jobID = String()
    var providerID : String!
    
    var providerName : String!
    var providerCategory : String!
    var providerImageURL : String!
    var clientID = ""
    
    var msgThreadID = ""
    var timer:Timer!
    var recordSeconds = 0
    var recordMinutes = 0
    var recorder: AVAudioRecorder!
    var soundFileURL: URL!
    var kRecorder = KAudioRecorder.shared
    var avPlayer: AVPlayer = AVPlayer()
    var currentPlayingIndex: Int = -1
    var currentPlayingIndexTime: Float64 = 0
    
    
    // MARK: - deinit
    deinit {
        NotificationCenter.default.removeObserver(self, name: .kSocketConnected, object: nil)
        NotificationCenter.default.removeObserver(self, name: .kSocketDisconnected, object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - view Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared.enableAutoToolbar = false
        textView.delegate = self
//        textView.inputAccessoryView = nil
        confirmDeleagte(tv: conversation)
        
        //You can apply reverse effect only set delegate.
        conversation.re.delegate = self
        conversation.re.scrollViewDidReachTop = { scrollView in
            print("scrollViewDidReachTop")
        }
        conversation.re.scrollViewDidReachBottom = { scrollView in
            print("scrollViewDidReachBottom")
        }
        
        messageSocketObservers()
        self.getJobMessages()
       // self.title = threadInfo.providerDisplayName
        //self.navigationItem.title = threadInfo.providerDisplayName
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didPlayToEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        //setupUserButton()
        
        
        setupScreenTitle()
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        userDidStopRecording(false)
        stopPlayer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        setupUserButton()
    }
    func setupScreenTitle() {
        // UIScreen.main.bounds.width
        let customView = UIView()
        customView.frame = CGRect.init(x: 0, y: 0, width: 150, height: 44.0)
        
        
        let userButton = UIButton()
        userButton.frame = CGRect.init(x: 0, y: 5, width: 34, height: 34)
        userButton.isUserInteractionEnabled = false
        var imageUrl = ""
        if let newStr = providerImageURL, newStr.count > 0 {
            var uri = newStr
            uri.remove(at: (newStr.startIndex))
            imageUrl = URLConfiguration.ServerUrl + uri
            userButton.cornerRadius = userButton.bounds.height / 2
            if let url = URL(string: imageUrl) {
                userButton.kf.setImage(with: url, for: .normal, placeholder: UIImage(named: "imagePlaceholder"), options: nil, progressBlock: nil) { (image, error, cacheTyle, uurl) in
                    //                    self.userBtn.setImage(image, for: .normal)
                }
            }
        }
        
        customView.addSubview(userButton)
        
        let fullname = providerName+"\n"
        
        let attrString = NSMutableAttributedString(string: fullname,
                                                   attributes: [ NSAttributedString.Key.font: UIFont(name: "Helvetica-Bold", size: 16.0)!,
                                                                 NSAttributedString.Key.foregroundColor: UIColor.white])
        
        attrString.append(NSMutableAttributedString(string: providerCategory,
                                                    attributes: [NSAttributedString.Key.font: UIFont(name: "Helvetica-Light", size: 12.0)!,
                                                    NSAttributedString.Key.foregroundColor: UIColor.white]))
        
        let label = UILabel(frame: CGRect(x: 40.0, y: 0.0, width: UIScreen.main.bounds.width-40, height: 44.0))
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.left
        label.attributedText = attrString
        customView.addSubview(label)
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        customView.addGestureRecognizer(tap)
        
        
        self.navigationItem.titleView = customView
        
        
    }
    func setupUserButton() {
        
        var imageUrl = ""
        if let newStr = providerImageURL, newStr.count > 0 {
            var uri = newStr
            uri.remove(at: (newStr.startIndex))
            imageUrl = URLConfiguration.ServerUrl + uri
            userBtn.cornerRadius = userBtn.bounds.height / 2
            if let url = URL(string: imageUrl) {
                userBtn.kf.setImage(with: url, for: .normal, placeholder: UIImage(named: "imagePlaceholder"), options: nil, progressBlock: nil) { (image, error, cacheTyle, uurl) in
                    //                    self.userBtn.setImage(image, for: .normal)
                }
            }
            userBtn.translatesAutoresizingMaskIntoConstraints = false
            userBtn.addConstraint(
                NSLayoutConstraint(
                    item: userBtn,
                    attribute: .width,
                    relatedBy: .equal,
                    toItem: userBtn,
                    attribute: .height,
                    multiplier: 1,
                    constant: 0
                )
            )
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        
        if let vcs = self.navigationController?.viewControllers {
            
            for previousVC in vcs {
                if previousVC is ProfileViewController {
                    self.navigationController!.popToViewController(previousVC, animated: true)
                    return
                }
            }
        }
        
        // handling code
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vc.providerID = providerID
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func gotoProfileAction(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vc.providerID = providerID
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func profileAction(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func messageSocketObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveAddMessagesResponse(notification:)), name: NSNotification.Name.kAddMessageThread, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveGetQueryMessagesResponse(notification:)), name: NSNotification.Name.kGetJobThreadMessages, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveSocketConectionResponse(notification:)), name: .kSocketConnected, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveSocketDisconectResponse(notification:)), name: .kSocketDisconnected, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveUnreadMessageResponse), name: NSNotification.Name.kGetUnreadMsgs, object: nil)
    }
    
    @objc func didReceiveUnreadMessageResponse(notification : Notification)
    {
        
        if let userInfo = notification.userInfo as NSDictionary?
        {
            UserDefaults.standard.set(userInfo["count"] as? Int ?? 0, forKey: DashboardVC.KEY_UNREAD_MESSAGES)
            UserDefaults.standard.synchronize()
            UIApplication.shared.applicationIconBadgeNumber = UserDefaults.standard.integer(forKey: DashboardVC.KEY_UNREAD_MESSAGES)
            
        }
    }
    
    @objc func didReceiveSocketDisconectResponse(notification : Notification)
    {
        //showProgressHud(viewController: self)
    }
    
    @objc func didReceiveSocketConectionResponse(notification : Notification)
    {
        hideProgressHud(viewController: self)
    }
    
    @objc func keyboardDismiss()
    {
        self.view.endEditing(true)
    }
    
    func getJobMessages() {
        
        if !Connection.isInternetAvailable()
        {
            Connection.showNetworkErrorView()
            return;
        }
        var client_id : String = ""
        if let usrrr = AppUser.getUser() {
            
            client_id = usrrr._id! as String
        }
        
       // let params = ["jobId" : jobID, "senderId" : client_id, "receiverId" : providerID! as String] as [String : Any]
        let params = ["jobId" : jobID, "senderId" : providerID! as String] as [String : Any]
        
        //let params = ["msgThreadId" : jobID, "senderId" : providerID! as String, "userId" : client_id,] as [String : Any]
        
        SocketManager.shared.sendSocketRequest(name: SocketEvent.GetJobThreadMessages, params: params)
        showProgressHud(viewController: self)
    }
    
    func newJobMessages(newMessage : String) {
        
        if !Connection.isInternetAvailable() {
            Connection.showNetworkErrorView()
            return;
        }
        
        
        let params = ["userType" : "client","jobId" : jobID, "message" : newMessage, "receiverId":self.providerID] as [String : Any]
        
        
        SocketManager.shared.sendSocketRequest(name: SocketEvent.AddMessageThread, params: params)
        showProgressHud(viewController: self)
    }
    
    func readMessageInfo() {
        let params = ["msgThreadId" : msgThreadID, "senderId": providerID ?? "", "userId": clientID ] as [String : Any]
        
        
        
        SocketManager.shared.sendSocketRequest(name: SocketEvent.READ_MESSAGE, params: params)
        SocketManager.shared.sendSocketRequest(name: SocketEvent.SOCKET_MARK_RECEIVED, params: params)
        SocketManager.shared.sendSocketRequest(name: SocketEvent.SOCKET_UPDATE_STATUS, params: params)
        SocketManager.shared.sendSocketRequest(name: SocketEvent.SOCKET_MARK_READ, params: params)
        getUnreadMessageCount()
    }
    
    func getUnreadMessageCount(){
        
        
        let params = ["userId": clientID ?? ""] as [String : Any]
        SocketManager.shared.sendSocketRequest(name: SocketEvent.getUnreadMsgs, params: params)
        
    }
    
    @objc func didReceiveGetQueryMessagesResponse(notification : Notification)
    {
        let userInfo = notification.userInfo as! NSDictionary
        print(#function , userInfo)
        
        let suc = userInfo.value(forKey: "isSuccess") as! Bool
        let msg = userInfo.value(forKey: "message") as! String
        hideProgressHud(viewController: self)
        
        if suc
        {
            self.readMessageInfo()
            if let queryMessagesDict = userInfo.object(forKey: "jobmessages") as? NSArray
            {
                self.queryMessages.removeAll()
                self.messages.removeAll()
                
                for item in queryMessagesDict
                {
                    let queryDict = MessageThreadVO(dictionary: item as! NSDictionary)
                    queryMessages.append(queryDict)
                }
                queryMessages = queryMessages.reversed()
                self.conversation.reloadData()
                self.scrollToBottom()
                
                
            } else {
                print("Parsing not happening")
            }
        }
        else
        {
            //showInfoAlertWith(title: "Failed", message: msg)
        }
    }
    
    @objc func didReceiveAddMessagesResponse(notification : Notification)
    {
        let userInfo = notification.userInfo as! NSDictionary
        print(#function , userInfo)
        
        let suc = userInfo.value(forKey: "isSuccess") as! Bool
        let msg = userInfo.value(forKey: "message") as! String
        hideProgressHud(viewController: self)
        
        if suc
        {
            self.readMessageInfo()
            if let jobmessage = userInfo.object(forKey: "jobmessage") as? NSDictionary
            {
                let queryDict = MessageThreadVO(dictionary: jobmessage as! NSDictionary)
                queryMessages = queryMessages.reversed()
                queryMessages.append(queryDict)
                queryMessages = queryMessages.reversed()
                self.textView.text = ""
                self.conversation.reloadData()
                self.scrollToBottom()
            }
        }
        else
        {
            //showInfoAlertWith(title: "Failed", message: msg)
        }
    }
    
    func stopPlayer(){
        if currentPlayingIndex != -1 {
            avPlayer.pause()
            currentPlayingIndexTime = 0
            updateProgressCellFor(currentPlayingIndex)
            updatePlayStateCellFor(currentPlayingIndex, false)
            currentPlayingIndex = -1
        }
    }
    
    func updateRecordOption(){
        recordView.isHidden = (self.textView.text.count != 0 && self.textView.text != "")
//        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveLinear], animations: { () -> Void in
//            self.view.layoutIfNeeded()
//        }, completion: nil)
    }
    
    // MARK: - Custom Functions
    private func confirmDeleagte(tv: UITableView) {

        tv.delegate = self
        tv.dataSource = self
        tv.separatorColor = .clear
        tv.backgroundColor = .clear
        tv.keyboardDismissMode = .interactive
        tv.keyboardDismissMode = .onDrag
    }

    // MARK: - IBActions
    @IBAction func btnSendTapped(_ sender: UIButton) {
        guard let newMessage = textView.text else { return }
        self.newJobMessages(newMessage: newMessage)
    }
    
    @IBAction func recordAction(_ sender: UIButton) {
        stopPlayer()
        if checkMicPermission() {
            audioViewHeight.constant = 96
            timerLbl.isHidden = false
            recordBtn.isHidden = true
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
            userDidBeginRecord()
        } else {
            let alert = UIAlertController(title: "Alert", message: "Please enable mic", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Settings", style: .default) { (alertAction) in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        })
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alertAction) in
                
            }
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func cancelAudioAction(_ sender: UIButton) {
        userDidStopRecording(false)
    }
    
    @IBAction func sendAudioAction(_ sender: UIButton) {
        userDidStopRecording(true)
    }
    
    @IBAction func attachAction(_ sender: UIButton) {
//        attachViewHeight.constant = attachViewHeight.constant == 44 ? 148:44
//        UIView.animate(withDuration: 0.25) {
//            self.view.layoutIfNeeded()
//        }
        stopPlayer()
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        actionSheet.addAction(cancelActionButton)
        
        let galleryActionButton = UIAlertAction(title: "Gallery", style: .default)
        { _ in
            print("gallery")
            self.openGallary()
        }
        actionSheet.addAction(galleryActionButton)
        
        let cameraActionButton = UIAlertAction(title: "Camera", style: .default)
        { _ in
            print("camera")
            self.openCamera()
        }
        actionSheet.addAction(cameraActionButton)
        
        let filesActionButton = UIAlertAction(title: "Files", style: .default) { (action) in
            self.showDocumentPicker()
        }
        actionSheet.addAction(filesActionButton)
        
        actionSheet.popoverPresentationController?.sourceView = sender
        actionSheet.popoverPresentationController?.sourceRect = sender.bounds
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func showDocumentPicker(){
        let picker = UIDocumentPickerViewController(documentTypes: [kUTTypePDF, kUTTypeText, kUTTypeRTF, kUTTypeSpreadsheet, kUTTypePNG, kUTTypeJPEG, "com.microsoft.word.doc", "org.openxmlformats.wordprocessingml.document"] as! [String], in: .import)
        picker.delegate = self
        if #available(iOS 11.0, *) {
            picker.allowsMultipleSelection = false
        } else {
            // Fallback on earlier versions
        }
        self.present(picker, animated: true, completion: nil)
    }
    
    func checkMicPermission() -> Bool {
        
        var permissionCheck: Bool = false
        
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSessionRecordPermission.granted:
            permissionCheck = true
        case AVAudioSessionRecordPermission.denied:
            permissionCheck = false
        case AVAudioSessionRecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                if granted {
                    permissionCheck = true
                } else {
                    permissionCheck = false
                }
            })
        default:
            break
        }
        
        return permissionCheck
    }

    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            self.conversation.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
//        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
//            messages.append(message)
//        }
    }
    
    func openCamera()
    {
        if(UIImagePickerController.isSourceTypeAvailable(.camera))
        {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerController.SourceType.camera
//            picker.cameraCaptureMode = .photo
            picker.mediaTypes = ["public.image", "public.movie"]
            present(picker, animated: true, completion: nil)
        }
        else
        {
            openGallary()
        }
    }
    
    func openGallary()
    {
        //self.presentedViewController?.dismiss(animated: false, completion: nil)
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        picker.mediaTypes = ["public.image", "public.movie"]
        present(picker, animated: true, completion: nil)
        
    }
}

extension ChatDetailViewController: GrowingTextViewDelegate {
    // Call layoutIfNeeded on superview for animation when changing height
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveLinear], animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: nil)
        self.scrollToBottom()
        
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        updateRecordOption()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        updateRecordOption()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateRecordOption()
    }
    
}

extension ChatDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return queryMessages.count

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = queryMessages[indexPath.row]
        if (message.type == "Client") {
            if message.isTextMessage {
                let cell = conversation.dequeueReusableCell(withIdentifier: RecieverCell.identifier, for: indexPath) as!
                RecieverCell
                cell.tag = indexPath.row
                ChatCellManager.shared.set(chatMessage: message, for: cell)
                return cell
            } else {
                if message.mediaType == .audio || message.mediaType == .file {
                    let cell = conversation.dequeueReusableCell(withIdentifier: RecieverAudioCell.identifier, for: indexPath) as!
                    RecieverAudioCell
                    cell.delegate = self
                    cell.tag = indexPath.row
                    if indexPath.row == currentPlayingIndex {
                        cell.progressView.progress = Float(currentPlayingIndexTime)
                        cell.playBtn.isSelected = true
                    } else {
                        cell.playBtn.isSelected = false
                        cell.progressView.progress = 0.0
                    }
                    ChatCellManager.shared.set(chatMessage: message, for: cell)
                    return cell
                } else {
                    let cell = conversation.dequeueReusableCell(withIdentifier: RecieverMediaCell.identifier, for: indexPath) as!
                    RecieverMediaCell
                    cell.delegate = self
                    cell.tag = indexPath.row
                    ChatCellManager.shared.set(chatMessage: message, for: cell)
                    return cell
                }
            }
            
        }else{
            //Provider
            if message.isTextMessage {
                let cell = conversation.dequeueReusableCell(withIdentifier: SenderCell.identifier, for: indexPath) as!
                SenderCell
                cell.tag = indexPath.row
                ChatCellManager.shared.set(chatMessage: message, for: cell)
                return cell
            } else {
                if message.mediaType == .audio || message.mediaType == .file {
                    let cell = conversation.dequeueReusableCell(withIdentifier: SenderAudioCell.identifier, for: indexPath) as!
                    SenderAudioCell
                    cell.delegate = self
                    cell.tag = indexPath.row
                    if indexPath.row == currentPlayingIndex {
                        cell.progressView.progress = Float(currentPlayingIndexTime)
                        cell.playBtn.isSelected = true
                    } else {
                        cell.playBtn.isSelected = false
                        cell.progressView.progress = 0.0
                    }
                    ChatCellManager.shared.set(chatMessage: message, for: cell)
                    return cell
                } else  {
                    let cell = conversation.dequeueReusableCell(withIdentifier: SenderMediaCell.identifier, for: indexPath) as!
                    SenderMediaCell
                    cell.delegate = self
                    cell.tag = indexPath.row
                    ChatCellManager.shared.set(chatMessage: message, for: cell)
                    return cell
                }
            }
            

        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension ChatDetailViewController {
    
    func userDidStopRecording(_ upload: Bool) {
        timer?.invalidate()
        kRecorder.stop()
        
        audioViewHeight.constant = 44
        timerLbl.isHidden = true
        recordBtn.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
        if upload {
            if let url = kRecorder.url {
                do {
                    let data = try Data(contentsOf: url)
                    let duration = kRecorder.time * 60
                    print(duration)
                    UploadFileApi().uploadAudio(audioData: data, duration: duration) { (success, tempID, link) in
                        if success {
                            
                            
                            let params = ["jobId" : self.jobID, "message" : "Audio", "receiverId":self.providerID, "media": link, "duration": "\(duration)", "tempId": tempID, "userType" : "client"] as [String : Any]
                            SocketManager.shared.sendSocketRequest(name: SocketEvent.AddMessageThread, params: params)
                        }
                    }
                } catch {
                    
                }
            }
            
        }
    }
    
    func userDidBeginRecord() {
        recordMinutes = 0
        recordSeconds = 0
        countdown()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.countdown) , userInfo: nil, repeats: true)
        kRecorder.record()
        
    }
    
    @objc func countdown() {
        
        var seconds = "\(recordSeconds)"
        if recordSeconds < 10 {
            seconds = "0\(recordSeconds)"
        }
        var minutes = "\(recordMinutes)"
        if recordMinutes < 10 {
            minutes = "0\(recordMinutes)"
        }
        
        timerLbl.text = "● \(minutes):\(seconds)"
        
        recordSeconds += 1
        
        if recordSeconds == 60 {
            recordMinutes += 1
            recordSeconds = 0
        }
        
    }
    
}

extension ChatDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil);
        print("picker cancel.")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            do {
                let data = try Data(contentsOf: videoUrl, options: .mappedIfSafe)
                let asset = AVAsset(url: videoUrl)
                let thumbnailImage = generateThumbnail(for: asset)
                let duration = Int(asset.duration.seconds * 60)
                UploadFileApi().uploadVideo(videoData: data, thumbnailImage: thumbnailImage, duration: duration, videoURL: videoUrl) { (success, tempID, link, thumbnailLink) in
                    if success {
                        let params = ["jobId" : self.jobID, "message" : "Video", "receiverId":self.providerID, "media": link, "thumbnailUrl": thumbnailLink, "duration": "\(duration)", "tempId": tempID, "userType" : "client"] as [String : Any]
                        SocketManager.shared.sendSocketRequest(name: SocketEvent.AddMessageThread, params: params)
                    }
                }
            } catch  {
            }
        } else {
            var selectedImage: UIImage?
            if let editedImage = info[.editedImage] as? UIImage {
                selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                selectedImage = originalImage
            }
            UploadFileApi().uploadPhoto(imageTaken: selectedImage) { (success, tempID, link) in
                if success {
                    let params = ["jobId" : self.jobID, "message" : "Picture", "receiverId":self.providerID, "media": link, "tempId": tempID, "userType" : "client"] as [String : Any]
                    SocketManager.shared.sendSocketRequest(name: SocketEvent.AddMessageThread, params: params)
                }
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func generateThumbnail(for asset:AVAsset) -> UIImage? {
        let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMake(value: 1, timescale: 2)
        let img = try? assetImgGenerate.copyCGImage(at: time, actualTime: nil)
        if img != nil {
            let frameImg  = UIImage(cgImage: img!)
            return frameImg
        }
        return nil
    }
}

extension ChatDetailViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print(urls)
        for url in urls {
            UploadFileApi().uploadDocument(fileURL: url) { (success, tempID, link) in
                if success {
                    let params = ["jobId" : self.jobID, "message" : "Document", "receiverId":self.providerID, "media": link, "tempId": tempID, "userType" : "client"] as [String : Any]
                    SocketManager.shared.sendSocketRequest(name: SocketEvent.AddMessageThread, params: params)
                }
            }
        }
        //        viewModel.attachDocuments(at: urls)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("CANCELED")
        //        controller.dismiss(animated: true, completion: nil)
    }
}
