//
//  JobHistoryListTVC.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 07/05/2018.
//  Copyright © 2018 yamsol. All rights reserved.
//

import UIKit

class JobHistoryListTVC: UITableViewCell {

    
    @IBOutlet weak var imgPerson: UIImageView!
    
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var lblScheduleTime: UILabel!
    
    @IBOutlet weak var lblAddress: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
