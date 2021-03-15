//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Zain Ali on 12/13/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import UIKit
import MobileCoreServices
import RealmSwift
import RxSwift




class ShareViewController: UITableViewController {
    let disposeBag = DisposeBag()

    private var itemsPaths = [String]()
    private var vcardPaths = [String]()
    private var textOrUrls = [String]()

    let bundleName = Config.groupName
    var users: Results<User>!
    var searchResults: Results<User>!

    var selectedUsers = [User]()

    var uiRealm: Realm!

    var isInSearchMode = false
    var searchController: UISearchController!

    var currentUid: CurrentUid!


    override func viewDidLoad() {
        super.viewDidLoad()

        initRealm()

        currentUid = uiRealm.objects(CurrentUid.self).first

        //the user did not authenticate yet
        if currentUid == nil {
            cancelTapped()
            return
        }


        users = getUsers()
        searchResults = users



        

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))



        navigationItem.rightBarButtonItem?.isEnabled = selectedUsers.count > 0

        searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchController.searchBar

    }

    @objc func cancelTapped() {
        let error = NSError(domain: "cancelled", code: -1, userInfo: nil)
        extensionContext?.cancelRequest(withError: error)
    }

    @objc func doneTapped() {
        manageImages()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "shareUserCell") as? ShareUserCell {
            let user = dataSource[indexPath.row]
            let circleImage = selectedUsers.contains(user) ? "check_circle" : "circle"

            cell.selectedImg.image = UIImage(named: circleImage)


            cell.bind(user: user)

            return cell
        }
        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = dataSource[indexPath.row]

        if selectedUsers.contains(user) {
            self.tableView(tableView, didDeselectRowAt: indexPath)

        } else {
            selectedUsers.append(user)
        }

        tableView.reloadRows(at: [indexPath], with: .none)

        navigationItem.rightBarButtonItem?.isEnabled = selectedUsers.count > 0
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let user = dataSource[indexPath.row]

        if !selectedUsers.contains(user) {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        } else {
            selectedUsers.removeAll(where: { $0.uid == user.uid })
        }

        tableView.reloadRows(at: [indexPath], with: .none)
        navigationItem.rightBarButtonItem?.isEnabled = selectedUsers.count > 0
    }

    func redirectToHostApp() {
        let url = URL(string: Config.shareUrl)
        var responder = self as UIResponder?
        let selectorOpenURL = sel_registerName("openURL:")

        while (responder != nil) {
            if (responder?.responds(to: selectorOpenURL))! {
                let _ = responder?.perform(selectorOpenURL, with: url)
            }
            responder = responder!.next
            

        }

        
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    func manageImages() {

        let content = extensionContext!.inputItems[0] as! NSExtensionItem

        let usersIds = selectedUsers.map { $0.uid }

        
        


        
        if let attachments = content.attachments {
            for att in attachments {
//
                let isVcard = att.hasItemConformingToTypeIdentifier(kUTTypeVCard as String)
                
            }
            getAttachmentsObservable(attachments: attachments).subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background)).observeOn(MainScheduler.instance).subscribe(onError: { (error)in
                
            }, onCompleted: {
                let userDefaults = UserDefaults(suiteName: self.bundleName)
                    userDefaults?.set(self.itemsPaths, forKey: ShareKeys.filesPathsKey)
                    userDefaults?.set(self.vcardPaths, forKey: ShareKeys.vcardsPaths)
                    userDefaults?.set(self.textOrUrls, forKey: ShareKeys.textOrUrlKey)
                    userDefaults?.set(usersIds, forKey: ShareKeys.usersIdsKey)
                    userDefaults?.synchronize()
                    self.redirectToHostApp()
                    
                }).disposed(by: self.disposeBag)


        }




    }


    private func initRealm() {
        let fileURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: bundleName)!
            .appendingPathComponent("default.realm")
        let config = RealmConfig.getConfig(fileURL: fileURL)
        uiRealm = try! Realm(configuration: config)
    }

    /*
     skipWhile({item -> Bool in
         let value = item.type == .fileUrl && item.url != nil
         || item.type == .vcardString &&   item.string != nil
         || item.type == .textString || item.type == .textString &&  item.string != nil
         
         return !value

     })
     */


    private func getAttachmentsObservable(attachments: [NSItemProvider]) -> Observable<Void> {

        let obsArr = attachments.map { attachment in

            attachment.loadItemRx().flatMap { item -> Observable<ShareItem> in

                if item.type == .fileUrl, let url = item.url {
//                    if url.isFileURL {
                    return self.copyItemRx(inputUrl: url).map { ShareItem(url: $0, string: nil, type: .fileUrl) }
//                    }
                } else if item.type == .vcardString, let string = item.string {
                    return self.writeStrRx(string: string).map { ShareItem(url: $0, string: nil, type: .vcardString) }
                } else if item.type == .textString || item.type == .url, let string = item.string {

                    return Observable.from(optional: ShareItem(url: nil, string: string, type: .textString))

                }
                return Observable.empty()


            } .map { item -> Void in


                let contentType = attachment.registeredTypeIdentifiers.first!
                if contentType == kUTTypeVCard as String {
                    self.vcardPaths.append(item.url!.absoluteString)
                } else if contentType == kUTTypePlainText as String || contentType == kUTTypeURL as String {
                    self.textOrUrls.append(item.string!)

                }
                else {
                    if let url = item.url {
                        self.itemsPaths.append(url.absoluteString)
                    }

                }

                return Void()
            }
        }

        return Observable.merge(obsArr)

    }

    var dataSource: Results<User> {
        return isInSearchMode ? searchResults : users
    }

    func getUsers() -> Results<User> {

        let currentUserFilterPredicate = NSPredicate(format: "NOT (\(DBConstants.UID) IN %@)", [currentUid.uid])

          return uiRealm.objects(User.self).filter(currentUserFilterPredicate).filter("\(DBConstants.isGroupBool) == true AND \(DBConstants.GROUP_DOT_IS_ACTIVE) == true OR \(DBConstants.isGroupBool) == false").sorted(byKeyPath: DBConstants.USERNAME)

    }

    public func searchForUser(query: String) -> Results<User> {

        return getUsers().filter(" \(DBConstants.USERNAME) contains[cd] '\(query)' OR \(DBConstants.PHONE) contains '\(query)'")
    }


}
class ShareUserCell: UserCell {
    @IBOutlet weak var selectedImg: UIImageView!

}

extension ShareViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        searchResults = searchForUser(query: searchText)

        isInSearchMode = !searchText.isEmpty
        tableView.reloadData()


    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isInSearchMode = false
        tableView.reloadData()

    }
}





