//
//  ImageEditorRequest.swift
//  Topinup
//
//  Created by Zain Ali on 11/2/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import Foundation
import iOSPhotoEditor

class ImageEditorRequest {
    public static func getRequest(image: UIImage, delegate: PhotoEditorDelegate) -> PhotoEditorViewController {
        let photoEditor = PhotoEditorViewController(nibName: "PhotoEditorViewController", bundle: Bundle(for: PhotoEditorViewController.self))

        //PhotoEditorDelegate
        photoEditor.photoEditorDelegate = delegate

        //The image to be edited
        photoEditor.image = image

        //Stickers that the user will choose from to add on the image

        let fileManager = FileManager.default
        let bundleURL = Bundle.main.bundleURL
        let assetURL = bundleURL.appendingPathComponent("stickers.bundle")

        do {
            let contents = try fileManager.contentsOfDirectory(at: assetURL, includingPropertiesForKeys: [URLResourceKey.nameKey, URLResourceKey.isDirectoryKey], options: .skipsHiddenFiles)

            for item in contents{

                if let image = UIImage(named: item.path) {
                    photoEditor.stickers.append(image)
                }
            }
        }
        catch let error as NSError {

        }

        photoEditor.hiddenControls = [.share, .clear, .save]

        return photoEditor


    }
}
