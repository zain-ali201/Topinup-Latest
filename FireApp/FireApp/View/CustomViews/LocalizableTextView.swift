//
//  LocalizableTextView.swift
//  Topinup
//
//  Created by Zain Ali on 1/8/20.
//  Copyright © 2020 Devlomi. All rights reserved.
//

import UIKit
class LocalizableTextView: UITextView,LocalizableView {
    @IBInspectable var translationKey: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let key = translationKey{
            text = key.localizedStr
        }
    }
    
    
}
