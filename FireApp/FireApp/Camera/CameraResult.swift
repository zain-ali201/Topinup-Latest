//
//  CameraResult.swift
//  Topinup
//
//  Created by Zain Ali on 6/29/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import Foundation
import UIKit
protocol CameraResult {
    func imageTaken(image :UIImage?)  
    func videoTaken(videoUrl:URL)
}
