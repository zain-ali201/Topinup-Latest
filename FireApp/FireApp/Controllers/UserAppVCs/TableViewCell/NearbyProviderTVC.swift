//
//  NearbyProviderTVC.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 18/01/2018.
//  Copyright © 2018 yamsol. All rights reserved.
//

import UIKit
import Cosmos
class NearbyProviderTVC: UITableViewCell {

    
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var lblDetail: UILabel!
    
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var btnQuote: UIButton!
    
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
