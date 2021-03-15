//
//  UnSelectableTextView.swift
//  Topinup
//
//  Created by Zain Ali on 12/8/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import UIKit

class UnSelectableTextView: UITextView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {

        guard let pos = closestPosition(to: point) else { return false }

        guard let range = tokenizer.rangeEnclosingPosition(pos, with: .character, inDirection: .layout(.left)) else { return false }

        let startIndex = offset(from: beginningOfDocument, to: range.start)

        return attributedText.attribute(.link, at: startIndex, effectiveRange: nil) != nil
    }
}
