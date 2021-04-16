//
//  UIImageView+Extensions.swift
//  Neighboorhood-iOS-Services
//
//  Created by Sarim Ashfaq on 24/08/2019.
//  Copyright © 2019 yamsol. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

extension UIImageView {
    func setImage(resource: String, placeholder: UIImage? = nil) {
        if let url = URL(string: resource.encodedStringForUrl()) {
           // self.kf.setImage(with: url, placeholder: placeholder, options: nil, progressBlock: nil, completionHandler: nil)
            
            self.kf.setImage(
                with: url,
                placeholder: placeholder,
                options: nil)
            {
                result in
                switch result {
                case .success(let value):
                    print("Task done for: \(value.source.url?.absoluteString ?? "")")
                case .failure(let error):
                    print("Job failed: \(error.localizedDescription)")
                }
            }
        }
    }
}
