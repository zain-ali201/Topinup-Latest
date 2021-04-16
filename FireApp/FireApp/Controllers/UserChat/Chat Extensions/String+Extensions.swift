//
//  String+Extensions.swift
//  ChatKit
//
//  Created by Sarim Ashfaq on 11/08/2019.
//  Copyright © 2019 Sarim Ashfaq. All rights reserved.
//

import Foundation
import UIKit

extension String {
    // Make Encoded URL
    func encodedStringForUrl() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    }
    
    // Width of string
    func width(_ font: UIFont) -> CGFloat {
        return self.size(withAttributes: [NSAttributedString.Key.font: font]).width
    }
    
    // height of string
    func height(_ font: UIFont) -> CGFloat {
        return self.size(withAttributes: [NSAttributedString.Key.font: font]).height
    }
    
    // Remove all white spaces
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
