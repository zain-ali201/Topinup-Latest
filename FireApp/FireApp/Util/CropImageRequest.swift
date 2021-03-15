//
//  CropImageRequest.swift
//  Topinup
//
//  Created by Zain Ali on 11/28/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import Foundation
import ALCameraViewController

class CropImageRequest {
    static func getRequest(completion: @escaping CameraViewCompletion) -> CameraViewController {

        return CameraViewController(croppingParameters: CroppingParameters(isEnabled: true, allowResizing: true, allowMoving: true, minimumSize: CGSize(width: 200, height: 200)), allowsLibraryAccess: true, allowsSwapCameraOrientation: true, allowVolumeButtonCapture: false, completion: completion)
    }
}
