//
//  ProfileViewController.swift
//  Neighboorhood-iOS-Services
//
//  Created by Sarim Ashfaq on 06/09/2019.
//  Copyright © 2019 yamsol. All rights reserved.
//

import UIKit
import Cosmos
import Alamofire

class ProfileViewController: UITableViewController {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userCategory: UILabel!
    @IBOutlet weak var userRating: CosmosView!
    @IBOutlet weak var blockBtn: UIButton!
    
    public var userPhone: String!
    public var userEmail: String!
    public var userProfileImageURL: String!
    
    public var reviews: [Any] = []
    
    var providerID: String = ""
    var jobID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchProfile()
        callApiForBlock(request: .get)
//        self.blockBtn.setTitle("Block", for: .normal)
    }
    
    //MARK:- Button Actions
    
    @IBAction func blockBtnACtion(button: UIButton)
    {
        if button.titleLabel?.text == "Block"
        {
            callApiForBlock(request: .post)
        }
        else
        {
            callApiForBlock(request: .delete)
        }
    }
    
    @IBAction func dialPhone(_ sender: UIButton) {
        
        guard let number = URL(string: "tel://" + self.userPhone) else { return }
        UIApplication.shared.open(number)
    }
    
    @IBAction func sendEmail(_ sender: Any) {

        let url = NSURL(string: "mailto:info@topinup.com")
        UIApplication.shared.openURL(url as! URL)
    }
    
    @IBAction func sendMessages(_ sender: Any) {
        
        if let vcs = self.navigationController?.viewControllers {
            
            for previousVC in vcs {
                if previousVC is ChatDetailViewController {
                    self.navigationController!.popToViewController(previousVC, animated: true)
                    return
                }
            }
        }
        
        let storyBoard = UIStoryboard(name: "UserChat", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ChatDetailViewController") as! ChatDetailViewController
        vc.jobID            = jobID
        vc.providerID       = providerID
        vc.providerName     = self.userName.text
        vc.providerCategory = self.userCategory.text
        vc.providerImageURL = self.userProfileImageURL
        self.navigationController?.pushViewController(vc, animated: true)
//        let sms: String = "sms:\(self.userPhone!)&body=Dear, \(self.userName.text!)"
//        let strURL: String = sms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
//        UIApplication.shared.open(URL.init(string: strURL)!, options: [:], completionHandler: nil)
    }
    
    @IBAction func rateBtnAction()
    {
        let vc = UIStoryboard.main().instantiateViewController(withIdentifier: "ReceiptVC_ID") as! ReceiptVC
        vc.jobID = jobID
        vc.providerID = providerID
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK:- Call APIs
    
    func fetchProfile()
    {
        showProgressHud(viewController: self)
        UserApi().fetchUserProfile(providerID: providerID, completion: ({ (success, message, userObj) in
            hideProgressHud(viewController: self)
            
            self.userName.text = userObj?.displayName
            self.reviews = (userObj?.reviews)!
            
            var namerArray = [String]()
            // var _idrArray = [String]()
            for item in userObj?.categories ?? [Any]() {
                 
                 let dict = item as! NSDictionary
                 let name: String? = dict.object(forKey: "name") as? String
                 namerArray.append(name!)
             }
            
            self.userCategory.text  = namerArray.joined(separator:",")
            self.userRating.rating  = Double((userObj?.rating)!)
            self.userRating.text    = String(describing: (userObj?.rating)!.roundTo(places: 1))
            self.userPhone = userObj?.phone
            self.userEmail = userObj?.email
            self.userProfileImageURL = userObj?.profileImageURL
            
            self.userImageView.cornerRadius = self.userImageView.frame.size.height/2.0
            var newStr = (userObj?.profileImageURL)! as String
                newStr.remove(at: (newStr.startIndex))
                let imageUrl = URLConfiguration.ServerUrl + newStr
                if let url = URL(string: imageUrl) {
                    //self.userImageView.kf.setImage(with: url)
                    
                    self.userImageView.kf.setImage(with: url, placeholder: UIImage(named: "imagePlaceholder"), options: nil, progressBlock: nil) { (image, error, cacheTyle, uurl) in
                        //                    self.userBtn.setImage(image, for: .normal)
                    }
                }
            
            self.tableView.reloadData()
        }))
    }
    
    func callApiForBlock(request: HTTPMethod)
    {
        if !Connection.isInternetAvailable()
        {
            Connection.showNetworkErrorView()
            return;
        }
        
        showProgressHud(viewController: self)
        Api.jobHistoryApi.blockProvider(userID: AppUser.getUser()?._id ?? "", providerID: self.providerID, method: request, completion: { (success : Bool, message : String) in
            
            hideProgressHud(viewController: self)
            
            if success
            {
                if request == .get
                {
                    self.blockBtn.setTitle(message, for: .normal)
                }
                else
                {
                    var msg = ""
                    if self.blockBtn.titleLabel?.text == "Block"
                    {
                        self.blockBtn.setTitle("Unblock", for: .normal)
                        msg = "User has been blocked successfully."
                    }
                    else
                    {
                        self.blockBtn.setTitle("Block", for: .normal)
                        msg = "User has been unblocked successfully."
                    }
                    
                    let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in

                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            else
            {
                self.showInfoAlertWith(title: "Alert", message: message)
            }
        })
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.reviews.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileReviewCell") as! ProfileReviewCell
        
        let dict = self.reviews[indexPath.row] as! NSDictionary
        
        var name = "***"
        
        let fullName = dict.object(forKey: "displayName") as? String
        
        if fullName != nil
        {
            let nameArray = fullName?.components(separatedBy: " ")
            if nameArray!.count > 0
            {
                if nameArray!.count == 1
                {
                    let fname = nameArray![0]
                    if !fname.isEmpty
                    {
                        name = "\(fname.first!)***"
                    }
                }
                else
                {
                    let lname = nameArray![1]
                    if !lname.isEmpty
                    {
                        name = "\(lname.first!)***"
                    }
                }
            }
        }
        
        cell.name.text = name
        cell.review.text = dict.object(forKey: "details") as? String
        cell.rating.rating = (dict.object(forKey: "rating") as? Double)!
        
        let dateString = dict.object(forKey: "created") as! String
        cell.dateTime.text = DateUtil.getSimpleDateAndTime(dateString.dateFromISO8601!)
        
        
        let imageUrl = dict.object(forKey: "profileImageURL") as? String
        
        if(imageUrl != nil){
            if let url = URL(string: imageUrl!) {
                //self.userImageView.kf.setImage(with: url)
                
                cell.userImageView!.kf.setImage(with: url, placeholder: UIImage(named: "imagePlaceholder"), options: nil, progressBlock: nil) { (image, error, cacheTyle, uurl) in
                    //                    self.userBtn.setImage(image, for: .normal)
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileReviewHeaderCell") as! ProfileReviewHeaderCell
        if(self.reviews.count != 0){
            cell.reviews.text = "Reviews (\(self.reviews.count))"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

class ProfileReviewCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var review: UILabel!
    @IBOutlet weak var dateTime: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

class ProfileReviewHeaderCell: UITableViewCell {
    
    
    @IBOutlet weak var reviews: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
