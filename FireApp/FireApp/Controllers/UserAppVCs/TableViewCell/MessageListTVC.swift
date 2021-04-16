//
//  MessageListTVC.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 18/04/2018.
//  Copyright © 2018 yamsol. All rights reserved.
//

import UIKit

class MessageListTVC: UITableViewCell {

    @IBOutlet weak var imgPerson: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblLastMessage: UILabel!
    @IBOutlet weak var lablTotalMesage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lablTotalMesage.layer.cornerRadius = lablTotalMesage.frame.size.height/2
        lablTotalMesage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
