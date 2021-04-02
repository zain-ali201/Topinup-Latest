//
//  CallsVC.swift
//  Topinup
//
//  Created by Zain Ali on 5/17/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import UIKit
import RealmSwift

class CallsVC: BaseSearchableVC
{
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    private var isInSearchMode = false
    private var searchController: UISearchController!

    private var calls: Results<FireCall>!
    private var searchResults: Results<FireCall>!
    private var notificationToken: NotificationToken?

    override var enableAds: Bool {
         get {
             return Config.isCallsAdsEnabled
         }
         set { }
     }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        calls = RealmHelper.getInstance(appRealm).getCalls()
        searchResults = calls

        tableView.delegate = self
        tableView.dataSource = self

        notificationToken = calls.observe({ [weak self] (changes: RealmCollectionChange) in
            
            guard  let strongSelf = self else{return}


            changes.updateTableView(tableView: strongSelf.tableView)

        })

        setupSearchController()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "call-plus"), style: .plain, target: self, action: #selector(rightBarBtnTapped))

        tabBarController?.navigationItem.title = "Calls"
    }

    override func viewWillDisappear(_ animated: Bool) {
//dismiss search when going to another VC
        if searchController.isActive {
            isInSearchMode = false
            searchController.isActive = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @objc private func rightBarBtnTapped() {
        performSegue(withIdentifier: "toNewCallVC", sender: nil)
    }

    fileprivate func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchContainer.addSubview(searchController.searchBar)
    }

    deinit {
        notificationToken = nil
    }
    
    private func exitSearchModeExplicitly(){
        isInSearchMode = false
        tableView.reloadData()
    }
}

extension CallsVC: UISearchBarDelegate {

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isInSearchMode = false
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchResults = RealmHelper.getInstance(appRealm).searchForCall(text: searchText)
        isInSearchMode = searchText.isNotEmpty
        tableView.reloadData()
    }
}

extension CallsVC: UITableViewDelegate, UITableViewDataSource {

    private func getDataSource() -> Results<FireCall> {
        return isInSearchMode ? searchResults : calls
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getDataSource().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "callCell") as? CallCell {
            let call = getDataSource()[indexPath.row]
            cell.delegate = self
            cell.bind(call: call)
            return cell
        }

        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let call = getDataSource().getItemSafely(index: indexPath.row) as? FireCall else{
            return nil
        }
        let deleteAction = UIContextualAction(style: .destructive, title: Strings.delete) { (action, view, actionPerformed) in
            RealmHelper.getInstance(appRealm).deleteFireCall(callId:call.callId)
            actionPerformed(true)
//            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let call = getDataSource()[indexPath.row]
        if let user = call.user {
            exitSearchModeExplicitly()
            makeACall(user: user, callType: call.callType)
        }
    }
}

extension CallsVC: CallCellDelegate {
    func btnTapped(call: FireCall) {
        if let user = call.user {
            exitSearchModeExplicitly()
            makeACall(user: user, callType:  call.callType)
        }
    }
}

protocol CallCellDelegate {
    func btnTapped(call: FireCall)
}

class CallCell: UITableViewCell
{
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var contactImgView: CustomProfileView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var callTypeImgView: UIImageView!
    @IBOutlet weak var callTimeLbl: UILabel!
    @IBOutlet weak var callBtn: UIButton!

    private var call: FireCall!
    var delegate: CallCellDelegate?

    func bind(call: FireCall)
    {
        self.call = call
        if let user = call.user{
            userImg.image = user.thumbImg.toUIImage()
            userName.text = user.userName
            callTimeLbl.text = TimeHelper.getCallTime(timestamp: call.timestamp.toDate())
            callBtn.addTarget(self, action: #selector(btnCallTapped), for: .touchUpInside)
            let imageName = call.isVideo ? "vid" : "call"
            callBtn.setImage(UIImage(named: imageName), for: .normal)
            callTypeImgView.image = getCallStateType(callDirection: call.callDirection)
        }
    }

    @objc private func btnCallTapped() {
        delegate?.btnTapped(call: call)
    }

    private func getCallStateType(callDirection: CallDirection) -> UIImage? {
        let madeCall = UIImage(named: "call_made")
        let receivedCall = UIImage(named: "call_received")
        switch callDirection {
        case .ANSWERED:
            return receivedCall

        case .INCOMING:
            return receivedCall

        case .MISSED:
            return receivedCall?.tinted(with: .red)

        case .OUTGOING:
            return madeCall
        }
    }
}
