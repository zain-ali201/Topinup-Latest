//
//  ChatMediaPlayerController.swift
//  Neighboorhood-iOS-Services
//
//  Created by Sarim Ashfaq on 24/08/2019.
//  Copyright © 2019 yamsol. All rights reserved.
//

import UIKit
import Kingfisher

class ChatMediaPlayerController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var urlString: String = ""
    var mediaType: MediaTypeUser = .image
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let url = URL(string: urlString) {
            if mediaType == .image {
                webView.isHidden = true
                imageView.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil) { (image, error, cacheType, urll) in
                    print(error.debugDescription)
                    self.activityIndicator.stopAnimating()
                }
            } else {
                imageView.isHidden = true
                webView.loadRequest(URLRequest(url: url))
                webView.delegate = self
            }
        }
        
        
    }
    
}

extension ChatMediaPlayerController: UIWebViewDelegate {
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.activityIndicator.stopAnimating()
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        self.activityIndicator.stopAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.activityIndicator.stopAnimating()
    }
}
