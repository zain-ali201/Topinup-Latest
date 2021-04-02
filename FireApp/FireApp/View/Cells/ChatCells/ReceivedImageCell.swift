//
//  ReceivedImageCell.swift
//  Topinup
//
//  Created by Zain Ali on 11/20/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import UIKit
import Kingfisher

class ReceivedImageCell: ReceivedBaseCell
{
    @IBOutlet weak var imageContent: UIImageView!
    
    override func bind(message: Message, user: User) {
        super.bind(message: message, user: user)
        
        imageContent.layer.cornerRadius = 8.0
        imageContent.layer.masksToBounds = true

        if message.localPath != ""
        {
            let url = URL(fileURLWithPath: message.localPath)

            let provider = LocalFileImageDataProvider(fileURL: url)
            imageContent.kf.setImage(
                with: provider,

                options: [
                        .processor(DownsamplingImageProcessor(size: imageContent.frame.size)),
                        .scaleFactor(UIScreen.main.scale),
                        .cacheOriginalImage
                ])
        }
        else
        {
            let cacheKey = message.messageId + "-thumb"
            let provider = Base64Provider(base64String: message.thumb, cacheKey: cacheKey)
            imageContent.kf.setImage(with: provider)
        }
    }
}
