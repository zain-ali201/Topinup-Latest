//
//  SentTextCellTableViewCell.swift
//  Topinup
//
//  Created by Zain Ali on 5/31/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import UIKit

class SentTextCell: SentBaseCell {

    @IBOutlet weak var messageText: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func bind(message: Message,user:User) {
        super.bind(message: message,user:user)

        messageText.text = message.content
    }
}
