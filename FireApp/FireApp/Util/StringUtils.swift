//
//  StringUtils.swift
//  Topinup
//
//  Created by Zain Ali on 12/5/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import Foundation
class StringUtils {
    //this will remove the separators if it's exists at the end of text
    public static func removeExtraSeparators(text: String, separator: String) -> String {


        if let lastChar = text.last,lastChar == " " {
            return String(text.dropLast(3))
        }
       
        return text


    }
}
