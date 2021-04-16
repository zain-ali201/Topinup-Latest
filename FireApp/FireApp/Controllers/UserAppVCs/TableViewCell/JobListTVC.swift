//
//  JobListTVC.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 19/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import UIKit

class JobListTVC: UITableViewCell {

    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var imgClient: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
