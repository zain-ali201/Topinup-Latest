//
//  SentTextQuotedCell.swift
//  Topinup
//
//  Created by Zain Ali on 11/21/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import UIKit

class SentTextQuotedCell: SentTextCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        containerView.layer.cornerRadius = 8.0
        containerView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
