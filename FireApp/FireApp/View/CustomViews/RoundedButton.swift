//
//  RoundedButton.swift
//  Topinup
//
//  Created by Zain Ali on 11/27/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import UIKit
class RoundedButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 0.5 * self.bounds.size.width
    }
}
