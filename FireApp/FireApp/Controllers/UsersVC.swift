//
//  UsersVC.swift
//  Topinup
//
//  Created by Zain Ali on 9/21/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import UIKit
import RxSwift
import RealmSwift
import Permission
import ContactsUI

protocol DismissViewController
{
    func presentCompletedViewController(user: User)
}

class UsersVC: BaseSearchableVC
{
    var notificationToken: NotificationToken?

    var refreshControl = UIRefreshControl()

    var delegate: DismissViewController?

    var searchController: UISearchController!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noUsersView: UIView!
    @IBOutlet weak var noUsersLbl: UILabel!
    @IBOutlet weak var inviteBtn: UIButton!
    @IBOutlet weak var searchContainer: UIView!

    var users: Results<User>!
    var searchResults: Results<User>!
    
    var phoneContactsArray = [CNContact]()
    var contactsFilteredArray = [CNContact]()
    lazy var contactStore = CNContactStore()

    private var isInSearchMode = false

    fileprivate func syncContacts() {

        Permissions.requestContactsPermissions { (isAuthorized) in
            if isAuthorized {
                self.refreshControl.beginRefreshing()

                ContactsUtil.syncContacts(appRealm: appRealm).subscribe(onNext: { (user) in
                    self.updateNoUsersView()
                }, onError: { (error) in
                        self.showAlert(type: .error, message: Strings.error)
                        self.refreshControl.endRefreshing()
                        self.updateNoUsersView()
                    }, onCompleted: {
                        self.refreshControl.endRefreshing()
                        self.updateNoUsersView()


                }).disposed(by: self.disposeBag)
            }
        }
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = "New Message"

        users = RealmHelper.getInstance(appRealm).getUsers()

        searchResults = users

        tableView.delegate = self
        tableView.dataSource = self

        searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        self.definesPresentationContext = true

        searchController.searchBar.delegate = self
        searchContainer.addSubview(searchController.searchBar)

        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl

        notificationToken = users.observe { [weak self] (changes: RealmCollectionChange) in
            guard let strongSelf = self else {
                return
            }
            changes.updateTableView(tableView: strongSelf.tableView, section: 1)
        }

        //Sync Contacts for the first time
        if users.isEmpty {
            syncContacts()
        }
        
        self.fetchContacts()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissVc))

        updateNoUsersView()
        setupNoUsersView()
    }
    
    private func updateNoUsersView()
    {
        tableView.isHidden = users.isEmpty
        noUsersView.isHidden = !users.isEmpty
    }

    private func setupNoUsersView() {
        noUsersLbl.text = ""
        inviteBtn.addTarget(self, action: #selector(btnInviteTapped), for: .touchUpInside)
    }

    @objc private func btnInviteTapped() {
        showInviteDialog()
    }

    @objc private func dismissVc()
    {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func refresh(sender: AnyObject)
    {
        syncContacts()
    }

    deinit
    {
        notificationToken = nil
    }

    private func showInviteDialog()
    {
        let text = Strings.invite_text
        let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
}

extension UsersVC: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 0 {
            return isInSearchMode ? 0 : 2
        }
        else if section == 1
        {
            return getDataSource().count
        }
        else
        {
            return contactsFilteredArray.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0
        {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "nonUserCell") as? nonUserCell
            {
                if indexPath.row == 0
                {
                    let text = "New Group"
                    let imageName = "people"
                    let image = UIImage(named: imageName)
                    cell.lblTitle.text = text
                    cell.imgView.image = image
                }
                else if indexPath.row == 1
                {
                    let text = "New Contact"
                    let imageName = "invite"
                    let image = UIImage(named: imageName)
                    cell.lblTitle.text = text
                    cell.imgView.image = image
                }
//                else if indexPath.row == 2 {
//                    let text = Strings.invite_to_app
//                    let imageName = "invite"
//                    let image = UIImage(named: imageName)
//                    cell.textLabel?.text = text
//                    cell.imageView?.image = image
//                }
                
                return cell
            }
        }
        else if indexPath.section == 1
        {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as? UserCell {
                cell.lblInvite.alpha = 0
                cell.contactImgView.alpha = 0
                cell.userImg.alpha = 1
                let user = getDataSource()[indexPath.row]
                cell.bind(user: user)
                return cell
            }
        }
        else
        {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as? UserCell {
                cell.lblInvite.alpha = 1
                cell.contactImgView.alpha = 1
                cell.userImg.alpha = 0
                let contact:CNContact = contactsFilteredArray[indexPath.row]
                cell.userNameLbl.text = "\(contact.givenName) \(contact.familyName)"
                cell.userImg.image = UIImage(named: "avatar")
                if (contact.isKeyAvailable(CNContactPhoneNumbersKey))
                {
                    for phoneNumber:CNLabeledValue in contact.phoneNumbers {
                        let primaryPhoneNumber = phoneNumber.value
                        cell.userStatusLbl?.text = primaryPhoneNumber.stringValue
                    }
                }
                        
                // Set the contact image.
                let intialFirst = contact.givenName.first
                print(contact.givenName)
                
                if let imageData = contact.imageData {
                    cell.contactImgView.setValueForProfile(true, imageData: imageData)
                } else {
                    cell.contactImgView.setValueForProfile(true, nameInitials: "\(intialFirst ?? "N")", fontSize: 16.0, imageData: nil)
                }
                
                return cell
            }
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0
        {
            if indexPath.row == 0 {
                performSegue(withIdentifier: "toGroupUsers", sender: false)
            }
            else if indexPath.row == 1
            {
                let controller = CNContactViewController(forNewContact: nil)
                controller.delegate = self
                let navigationController = UINavigationController(rootViewController: controller)
                UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.black]
                UIBarButtonItem.appearance().tintColor = UIColor(red: 48.0/255.0, green: 123.0/255.0, blue: 248.0/255.0, alpha: 1)
                self.present(navigationController, animated: true)
            }
        }
        else if indexPath.section == 1
        {
            searchController.isActive = false

            if isInSearchMode {
                self.dismiss(animated: true, completion: nil)
            }
            
            if let user = getDataSource().getItemSafely(index: indexPath.row) as? User {
                self.dismiss(animated: true)
                self.delegate?.presentCompletedViewController(user: user)
            }
        }
        else if indexPath.section == 2
        {
            showInviteDialog()
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GroupUsersVC {
            let isBroadcast = sender as! Bool

            vc.initialize(mode: .create, isBroadcast: isBroadcast, delegate: delegate)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0
        {
            return 55
        }
        else
        {
            return 60.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 32
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        //add user image header
        if section == 1 || section == 2
        {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
            view.backgroundColor = .white
            
            let view1 = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 30))
            view1.backgroundColor = .lightGray
            view1.alpha = 0.3
            
            let lbl = UILabel(frame: CGRect(x: 15, y: 0, width: 200, height: 30))
            lbl.backgroundColor = .clear
            if section == 1 {
                lbl.text = "APP CONTACTS"
            } else if section == 2 {
                lbl.text = "PHONE CONTACTS"
            }
            lbl.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            lbl.textColor = .black
            
            view.addSubview(view1)
            view.addSubview(lbl)
            
            return view
        }
        
        return nil
    }

    private func getDataSource() -> Results<User> {
        return isInSearchMode ? searchResults : users
    }
    
    func fetchContacts()
    {
        //reset contact list
        phoneContactsArray.removeAll()
            
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactEmailAddressesKey,
            CNContactPhoneNumbersKey,
            CNContactImageDataKey] as [Any]
        
        // Get all the containers
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers
        {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do
            {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                phoneContactsArray.append(contentsOf: containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        
        phoneContactsArray = phoneContactsArray.sorted { $0.givenName < $1.givenName }
        contactsFilteredArray = phoneContactsArray
        tableView.reloadData()
    }
}

extension UsersVC: CNContactViewControllerDelegate {
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        UIBarButtonItem.appearance().tintColor = UIColor.white
        self.fetchContacts()
        dismiss(animated: true, completion: nil)
    }

    func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
        return true
    }
}

extension UsersVC: UISearchBarDelegate
{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        searchResults = RealmHelper.getInstance(appRealm).searchForUser(query: searchText)

        isInSearchMode = searchText.isNotEmpty
        
        if searchText != ""
        {
            contactsFilteredArray = phoneContactsArray.filter { contact in
                        return (contact.givenName.lowercased().contains(searchText.lowercased()) ||
                            contact.familyName.lowercased().contains(searchText.lowercased()))
            }
        }
        else
        {
            contactsFilteredArray = phoneContactsArray
        }
        
        tableView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isInSearchMode = false
        tableView.reloadData()
    }
}

class UsersVCNavController: UINavigationController, UINavigationControllerDelegate {
    var navigationDelegate: DismissViewController?

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let usersVc = viewController as? UsersVC {
            usersVc.delegate = navigationDelegate
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
}

class nonUserCell:UITableViewCell
{
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
}
