//
//  ProfileViewController.swift
//  Neighboorhood-iOS-Services
//
//  Created by Sarim Ashfaq on 06/09/2019.
//  Copyright © 2019 yamsol. All rights reserved.
//

import UIKit
import Cosmos

class ProfileViewController: UITableViewController {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userCategory: UILabel!
    @IBOutlet weak var userRating: CosmosView!
    
    public var userPhone: String!
    public var userEmail: String!
    public var userProfileImageURL: String!
    
    
    public var reviews      : [Any] = []
    
    var providerID: String = ""
    var jobID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchProfile()
    }
    
    func fetchProfile(){
        
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
        
        cell.name.text = dict.object(forKey: "displayName") as? String
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
        
        let storyBoard = UIStoryboard(name: "Chat", bundle: nil)
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
