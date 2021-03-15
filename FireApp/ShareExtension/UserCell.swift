//
//  UserCell.swift
//  ShareExtension
//
//  Created by Zain Ali on 1/6/20.
//  Copyright © 2020 Devlomi. All rights reserved.
//
import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userStatusLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func bind(user: User) {
        if user.isBroadcastBool {
            userImg.image = UIImage(named: "rss")

        } else {
            userImg.image = toUIImage(user.thumbImg)
        }
        userNameLbl.text = user.userName
        userStatusLbl.text = user.status
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func toUIImage(_ image: String) -> UIImage {

        guard let imageData = Data(base64Encoded: image, options: Data.Base64DecodingOptions.ignoreUnknownCharacters), let image = UIImage(data: imageData) else {
            return UIImage()
        }

        return image
    }

}

