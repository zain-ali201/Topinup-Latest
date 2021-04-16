//
//  UploadFileApi.swift
//  Neighboorhood-iOS-Services
//
//  Created by Sarim Ashfaq on 17/08/2019.
//  Copyright © 2019 yamsol. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import SVProgressHUD

class UploadFileApi : NSObject {
    
    func uploadPhoto( imageTaken: UIImage?, completion: @escaping ((_ success: Bool, _ tempID: String, _ uploadLink : String) -> Void) ){
        
        if imageTaken == nil {
            return
        }
        SVProgressHUD.show()
        let tid = self.randomString(length: 10)
        let parameters = ["tempId":tid, "duration":0] as [String : Any]
        
        
        
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            if let imageData = imageTaken?.jpegData(compressionQuality: 5) {
                multipartFormData.append(imageData, withName: "media", fileName: "\(Date())mediaImage.jpej", mimeType: "image/jpej")
            }
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            //            for (key, value) in parameters {
            //                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            //            }
            
        }, to: URLConfiguration.uploadMessageMedia,
           method:.post,
           headers:URLConfiguration.headersContentType(), encodingCompletion: { (encodingResult) in
            
            switch encodingResult {
            case .success(let uploadRequest, _, _):
                uploadRequest.responseString(completionHandler: { (dataResponse) in
                    
                    print(dataResponse)
                    SVProgressHUD.dismiss()
                    
                    
                })
                uploadRequest.responseJSON(completionHandler: { (dataResponse) in
                    
                    switch dataResponse.result {
                    case .success(let json):
                        print(json)
                        let data = JSON(json)
                        completion(data["isSuccess"].boolValue, tid, data["link"].stringValue)
                        SVProgressHUD.dismiss()
                        break
                        
                    case .failure(let error):
                        print(error)
                        completion(false, tid, "")
                        SVProgressHUD.dismiss()
                        break
                    }
                    
                })
                break
            case .failure(let error):
                print(error)
                completion(false, tid, "")
                SVProgressHUD.dismiss()
                break
            }
        })
        
        
    }
    
    func uploadVideo( videoData: Data?, thumbnailImage: UIImage?, duration: Int, videoURL: URL, completion: @escaping ((_ success: Bool, _ tempID: String, _ uploadLink : String, _ thumbnailLink: String) -> Void) ){
        
        if videoData == nil {
            return
        }
        SVProgressHUD.show()
        let tid = self.randomString(length: 10)
        let parameters = ["tempId":tid, "duration":duration] as [String : Any]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            if let data = videoData {
                multipartFormData.append(data, withName: "media", fileName: "\(videoURL.lastPathComponent)", mimeType: videoURL.mimeType())
            }
            if let imageData = thumbnailImage?.pngData() {
                multipartFormData.append(imageData, withName: "media", fileName: "\(Date())mediaThumbnail.png", mimeType: "image/png")
            }
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            //            for (key, value) in parameters {
            //                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            //            }
            
        }, to: URLConfiguration.uploadMessageMedia,
           method:.post,
           headers:URLConfiguration.headersContentType(), encodingCompletion: { (encodingResult) in
            
            switch encodingResult {
            case .success(let uploadRequest, _, _):
                uploadRequest.responseString(completionHandler: { (dataResponse) in
                    
                    print(dataResponse)
                    SVProgressHUD.dismiss()
                    
                    
                })
                uploadRequest.responseJSON(completionHandler: { (dataResponse) in
                    
                    switch dataResponse.result {
                    case .success(let json):
                        print(json)
                        let data = JSON(json)
                        completion(data["isSuccess"].boolValue, tid, data["link"].stringValue, data["thumbnailUrl"].stringValue)
                        SVProgressHUD.dismiss()
                        break
                        
                    case .failure(let error):
                        print(error)
                        completion(false, tid, "", "")
                        SVProgressHUD.dismiss()
                        break
                    }
                    
                })
                break
            case .failure(let error):
                print(error)
                completion(false, tid, "", "")
                SVProgressHUD.dismiss()
                break
            }
        })
        
        
    }
    
    func uploadAudio( audioData: Data?, duration: Int, completion: @escaping ((_ success: Bool, _ tempID: String, _ uploadLink : String) -> Void) ){
        
        if audioData == nil {
            return
        }
        SVProgressHUD.show()
        let tid = self.randomString(length: 10)
        let parameters = ["tempId":tid, "duration":duration] as [String : Any]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            if let data = audioData {
                multipartFormData.append(data, withName: "media", fileName: "\(Date())mediaImage.m4a", mimeType: "audio/m4a")
            }
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            //            for (key, value) in parameters {
            //                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            //            }
            
        }, to: URLConfiguration.uploadMessageMedia,
           method:.post,
           headers:URLConfiguration.headersContentType(), encodingCompletion: { (encodingResult) in
            
            switch encodingResult {
            case .success(let uploadRequest, _, _):
                uploadRequest.responseString(completionHandler: { (dataResponse) in
                    
                    print(dataResponse)
                    SVProgressHUD.dismiss()
                    
                    
                })
                uploadRequest.responseJSON(completionHandler: { (dataResponse) in
                    
                    switch dataResponse.result {
                    case .success(let json):
                        print(json)
                        let data = JSON(json)
                        completion(data["isSuccess"].boolValue, tid, data["link"].stringValue)
                        SVProgressHUD.dismiss()
                        break
                        
                    case .failure(let error):
                        print(error)
                        completion(false, tid, "")
                        SVProgressHUD.dismiss()
                        break
                    }
                    
                })
                break
            case .failure(let error):
                print(error)
                completion(false, tid, "")
                SVProgressHUD.dismiss()
                break
            }
        })
        
        
    }
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func uploadDocument(fileURL: URL, completion: @escaping ((_ success: Bool, _ tempID: String, _ uploadLink : String) -> Void)){
        SVProgressHUD.show()
        let tid = self.randomString(length: 10)
        let parameters = ["tempId":tid] as [String : Any]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            do {
                let fileData = try Data(contentsOf: fileURL)
                multipartFormData.append(fileData, withName: "media", fileName: "\(Date())mediaImage.\(fileURL.pathExtension)", mimeType: "\(fileURL.mimeType())")
            }
            catch {
                print(error.localizedDescription)
                return
                
            }
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            //            for (key, value) in parameters {
            //                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            //            }
            
        }, to: URLConfiguration.uploadMessageMedia,
           method:.post,
           headers:URLConfiguration.headersContentType(), encodingCompletion: { (encodingResult) in
            
            switch encodingResult {
            case .success(let uploadRequest, _, _):
                uploadRequest.responseString(completionHandler: { (dataResponse) in
                    
                    print(dataResponse)
                    SVProgressHUD.dismiss()
                    
                    
                })
                uploadRequest.responseJSON(completionHandler: { (dataResponse) in
                    
                    switch dataResponse.result {
                    case .success(let json):
                        print(json)
                        let data = JSON(json)
                        completion(data["isSuccess"].boolValue, tid, data["link"].stringValue)
                        SVProgressHUD.dismiss()
                        break
                        
                    case .failure(let error):
                        print(error)
                        completion(false, tid, "")
                        SVProgressHUD.dismiss()
                        break
                    }
                    
                })
                break
            case .failure(let error):
                print(error)
                completion(false, tid, "")
                SVProgressHUD.dismiss()
                break
            }
        })

    }
}
