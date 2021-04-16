//
//  SideMenuTVC.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 18/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import UIKit
import Cosmos

class SideMenuTVC: UITableViewCell {

    @IBOutlet weak var imgPerson: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgMenuItems: UIImageView!
    @IBOutlet weak var lblMenuItems: UILabel!
    
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var cosmosView: CosmosView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
