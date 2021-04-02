//
//  StatusVC.swift
//  Topinup
//
//  Created by Zain Ali on 10/24/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import UIKit
import RealmSwift
import iOSPhotoEditor
import AVFoundation
import BubbleTransition
import AlertBar

class StatusVC: BaseVC, UIViewControllerTransitioningDelegate {
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var statusTimeLbl: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var btnTextStatus: UIButton!
    @IBOutlet weak var btnPlus: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textStatusLbl: UILabel!
    @IBOutlet weak var circularStatusView: CircularStatusView!
    @IBOutlet weak var buttonsStack: UIStackView!

    private var isInSearchMode = false
    private var searchResults: Results<UserStatuses>!

    private var statusesList: Results<UserStatuses>!
    private var nonSeenStatusesList: Results<UserStatuses>!
    private var seenStatusesList: Results<UserStatuses>!
    private var myStatuses: UserStatuses?

    //thumb image that will be used when uploading a status
    private var thumbImage: UIImage!
    var notificationToken: NotificationToken?
    var user: User?

    let transition = BubbleTransition()
    let interactiveTransition = BubbleInteractiveTransition()

    fileprivate func initMyStatuses() {
        myStatuses = RealmHelper.getInstance(appRealm).getUserStatuses(userId: FireManager.getUid())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        user = RealmHelper.getInstance(appRealm).getUser(uid: FireManager.getUid())
        statusesList = RealmHelper.getInstance(appRealm).getAllStatuses()
        searchResults = statusesList

        seenStatusesList = RealmHelper.getInstance(appRealm).getAllStatuses(true)
        nonSeenStatusesList = RealmHelper.getInstance(appRealm).getAllStatuses(false)

        textStatusLbl.clipsToBounds = true

        textStatusLbl.layer.cornerRadius = textStatusLbl.frame.width / 2
        tableView.delegate = self
        tableView.dataSource = self

        notificationToken = statusesList.observe { [weak self] (changes: RealmCollectionChange) in
            guard let strongSelf = self else { return }

            strongSelf.tableView.reloadData()
        }

        btnCamera.addTarget(self, action: #selector(cameraTapped), for: .touchUpInside)
        btnTextStatus.addTarget(self, action: #selector(textStatusTapped), for: .touchUpInside)
        cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cardViewTapped)))
        btnPlus.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cardViewTapped)))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.navigationItem.title = "Status"
        setMyStatus()

//        StatusManager.fetchStatuses(users: RealmHelper.getInstance(appRealm).getUsers()).subscribe(onCompleted: nil) { (error) in
//
//              }.disposed(by: disposeBag)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @objc private func cameraTapped() {
        performSegue(withIdentifier: "toCameraVC", sender: nil)
    }
    
    @objc private func textStatusTapped() {
        performSegue(withIdentifier: "toTextStatus", sender: nil)
    }

    @objc private func cardViewTapped() {

        if let statuses = myStatuses, !statuses.getFilteredStatuses().isEmpty {
            performSegue(withIdentifier: "toMyStatuses", sender: nil)
        } else {
            performSegue(withIdentifier: "toCameraVC", sender: nil)
        }
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ViewStatusVC, let userStatuses = sender as? UserStatuses {

            destination.initialize(userStatuses: userStatuses)
        } else if let destination = segue.destination as? CameraVCViewController {
            destination.imagePickerDelegate = self
            destination.delegate = self
            destination.galleryBtnHidden = false
            destination.transitioningDelegate = self
            destination.modalPresentationStyle = .custom
            destination.interactiveTransition = interactiveTransition
            interactiveTransition.attach(to: destination)

        } else if let destination = segue.destination as? TextStatusVC {
            destination.delegate = self
        }
    }

    private func setMyStatus() {
        if myStatuses == nil {
            initMyStatuses()
        }

        //if user added a status
        if let statuses = myStatuses, !statuses.getFilteredStatuses().isEmpty, let lastStatus = statuses.statuses.last {
            circularStatusView.portionColor = Colors.circularStatusUserColor

            statusTimeLbl.text = TimeHelper.getStatusTime(timestamp: lastStatus.timestamp.toDate())
            btnPlus.isHidden = true


            if lastStatus.type == .image || lastStatus.type == .video {
                textStatusLbl.isHidden = true
                userImg.isHidden = false
                userImg.image = lastStatus.thumbImg.toUIImage()

            } else if lastStatus.type == .text {
                textStatusLbl.isHidden = false
                userImg.isHidden = true

                if let textStatus = lastStatus.textStatus {
                    textStatusLbl.text = textStatus.text
                    textStatusLbl.font = UIFont.getFontByFileName(textStatus.fontName)
                    textStatusLbl.backgroundColor = textStatus.backgroundColor.toUIColor()
                }
            }
            //if a user did not add a Status
        } else {
            btnPlus.isHidden = false
            textStatusLbl.isHidden = true
            statusTimeLbl.text = Strings.add_to_my_status
            circularStatusView.portionColor = .lightGray
            if let user = user {
                userImg.image = UIImage(contentsOfFile: user.userLocalPhoto)
            }
        }

    }


    private func uploadVideoStatus(url: URL) {
        self.showAlert(type: .notice, message: Strings.uploading_status)

        StatusManager.uploadVideoStatus(videoUrl: url).subscribe(onCompleted: {
            self.setMyStatus()
        }) { (error) in
            self.showAlert(type: .error, message: Strings.error)

        }.disposed(by: self.disposeBag)
    }

    override func viewWillDisappear(_ animated: Bool) {

        
    }
    deinit {
        notificationToken = nil
    }
}

extension StatusVC: CameraResult {

    func imageTaken(image: UIImage?) {
        guard let image = image else {
            return
        }
        
        let thumbImage = image.resized(to: CGSize(width: 200, height: 200))
        self.thumbImage = thumbImage
        
        let imageEditorVc = ImageEditorRequest.getRequest(image: image, delegate: self)
        imageEditorVc.modalPresentationStyle = .fullScreen
        self.present(imageEditorVc, animated: false, completion: nil)

    }

    func videoTaken(videoUrl: URL) {
        navigationController?.popViewController(animated: true)


        let outputUrl = DirManager.generateFile(type: .SENT_VIDEO)

        VideoUtil.exportAsMp4(inputUrl: videoUrl, outputUrl: outputUrl) {
            DispatchQueue.main.async {
                self.uploadVideoStatus(url: outputUrl)
                try? videoUrl.deleteFile()
            }

        }
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        let center = buttonsStack.convert(btnCamera.center, to: view)
        transition.startingPoint = center
        transition.bubbleColor = .black
        return transition
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let center = buttonsStack.convert(btnCamera.center, to: view)

        transition.transitionMode = .dismiss
        transition.startingPoint = center
        transition.bubbleColor = .black
        return transition
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransition
    }

}
extension StatusVC: MTImagePickerControllerDelegate {
    func imagePickerController(picker: MTImagePickerController, didFinishPickingWithPhotosModels models: [MTImagePickerPhotosModel]) {
        self.dismiss(animated: true, completion: nil)

        let model = models[0]
        if model.mediaType == .Photo {
            model.getImageAsync { (image) in
                if let image = image, let previewImage = models[0].getThumbImage(size: CGSize(width: 200, height: 200)) {
                    self.thumbImage = previewImage
                    let imageEditorVc = ImageEditorRequest.getRequest(image: image, delegate: self)
                    self.navigationController?.pushViewController(imageEditorVc, animated: true)
                }
            }
        } else {
            model.fetchAVPlayerItemAsync { (playerItem) in
                if let item = playerItem, let url = (item.asset as? AVURLAsset)?.url {
                    if item.duration.seconds > Config.maxVideoStatusTime {
                        self.present(Alerts.videoStatusLongAlert, animated: true, completion: nil)
                        return
                    }

                    if url.pathExtension != "mp4" {
                        let outputUrl = DirManager.generateFile(type: .SENT_VIDEO)

                        VideoUtil.exportAsMp4(inputUrl: url, outputUrl: outputUrl) {
                            DispatchQueue.main.async {
                                self.uploadVideoStatus(url: outputUrl)
                            }

                        }
                    } else {
                        let toUrl = DirManager.getSentVideoFolder()
                        let finalUrl = toUrl.appendingPathExtension(url.lastPathComponent)
                        if FileUtil.secureCopyItem(at: url, to: toUrl) {
                            self.uploadVideoStatus(url: finalUrl)
                        }

                    }
                }
            }
        }
    }
}

extension StatusVC: TextStatusDelegate {
    func didFinishWithText(textStatus: TextStatus) {


        self.showAlert(type: .notice, message: Strings.uploading_text_status)
        StatusManager.uploadTextStatus(textStatus: textStatus).subscribe(onCompleted: {
            self.setMyStatus()
        }) { (error) in
            self.showAlert(type: .error, message: Strings.error)
        }.disposed(by: disposeBag)

    }
}

extension StatusVC: PhotoEditorDelegate {
    func canceledEditing() {
    }
    

    func doneEditing(image: UIImage) {

        StatusManager.uploadImageStatus(image: image, thumbImg: thumbImage).subscribe(onCompleted: {
            self.setMyStatus()

        }, onError: { (error) in
                self.showAlert(type: .error, message: Strings.error)

            }).disposed(by: self.disposeBag)




        navigationController?.popViewController(animated: true)
        showAlert(type: .notice, message: Strings.uploading_status)


    }


}

extension StatusVC: UITableViewDataSource, UITableViewDelegate {

    private func getDataSource(section: Int) -> Results<UserStatuses> {
        if isInSearchMode {
            return searchResults
        }

        if section == 0 {
            return nonSeenStatusesList
        }

        return seenStatusesList

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isInSearchMode {
            return searchResults.count
        }
        if section == 0 {
            return nonSeenStatusesList.count
        }
        return seenStatusesList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "statusCell") as? StatusCell {


            let userStatuses = getDataSource(section: indexPath.section)[indexPath.row]
            cell.userImg.hero.id = userStatuses.user.uid
            cell.bind(userStatuses: userStatuses)
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userStatuses = getDataSource(section: indexPath.section)[indexPath.row]
        navigationController?.hero.isEnabled = true
        performSegue(withIdentifier: "toViewStatus", sender: userStatuses)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if isInSearchMode {
            return 1
        }
        return 2
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isInSearchMode {
            return nil
        }
        

        if section == 0 && nonSeenStatusesList.count > 0 {
            return Strings.recent_updates
        } else if section == 1 && seenStatusesList.count > 0 {
            return Strings.viewed_updates
        }

        return nil
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        //add user image header
//        if section == 1 || section == 2
//        {
//            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 25))
//            view.backgroundColor = .lightGray
//            let lbl = UILabel(frame: CGRect(x: 15, y: 0, width: 0, height: 25))
//
//            if section == 0 && nonSeenStatusesList.count > 0 {
//                lbl.text = "RECENT UPDATES"
//            } else if section == 1 && seenStatusesList.count > 0 {
//                lbl.text = "VIEWED UPDATES"
//            }
//            lbl.backgroundColor = .clear
//            lbl.font = UIFont.systemFont(ofSize: 16, weight: .medium)
//
//            view.addSubview(lbl)
//
//            return view
//        }
//
//        return nil
//    }
}

extension StatusVC: UISearchBarDelegate {

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isInSearchMode = false
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchResults = RealmHelper.getInstance(appRealm).searchForStatus(text: searchText)
        isInSearchMode = searchText.isNotEmpty
        tableView.reloadData()
    }
}

class StatusCell: UITableViewCell
{
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var statusTime: UILabel!
    @IBOutlet weak var textStatusLbl: UILabel!
    @IBOutlet weak var userImgContainer: CircularStatusView!

    func bind(userStatuses: UserStatuses) {
        guard let user = userStatuses.user else {
            return
        }

        textStatusLbl.clipsToBounds = true
        textStatusLbl.layer.cornerRadius = textStatusLbl.frame.width / 2

        userImgContainer.layer.cornerRadius = userImgContainer.frame.width / 2
        let filteredStatuses = userStatuses.getFilteredStatuses()


        userName.text = user.userName

        if let lastStatus = filteredStatuses.last {
            statusTime.text = TimeHelper.getStatusTime(timestamp: lastStatus.timestamp.toDate())
            userImg.image = lastStatus.thumbImg.toUIImage()

            userImgContainer.portionsCount = filteredStatuses.count

            if (userStatuses.areAllSeen) {
                userImgContainer.portionColor = Colors.circularStatusSeenColor
            }
            else {
                setCircularStatusColors(filteredStatuses: filteredStatuses)
            }

            if let textStatus = lastStatus.textStatus {
                userImg.isHidden = true
                textStatusLbl.isHidden = false
                textStatusLbl.text = textStatus.text
                textStatusLbl.backgroundColor = textStatus.backgroundColor.toUIColor()
            } else {
                userImg.isHidden = false
                textStatusLbl.isHidden = true
            }
        }

    }
    private func setCircularStatusColors(filteredStatuses: Results<Status>) {
        for i in 0...filteredStatuses.count - 1 {
            let status = filteredStatuses[i]
            let color = status.isSeen ? Colors.circularStatusSeenColor : Colors.circularStatusNotSeenColor
            userImgContainer.setPortionColorForIndex(index: i, color: color)
        }
    }

}


