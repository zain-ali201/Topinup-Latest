//
//  UserCategoryTVC.swift
//  Neighboorhood-iOS-Services-User
//
//  Created by Zain ul Abideen on 30/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import UIKit

class UserCategoryTVC: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblCategoryName: UILabel!
    @IBOutlet weak var lblCategoryDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func infoAction(_ sender: UIButton) {
        if let topVC = UIApplication.getTopViewController() {
            topVC.showInfoAlertWith(title: lblCategoryName.text ?? "", message: lblCategoryDescription.text ?? "")
        }
    }
    
}
