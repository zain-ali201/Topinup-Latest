//
//  ReportApi.swift
//  Neighboorhood-iOS-Services
//
//  Created by Rizwan Shah on 04/09/2020.
//  Copyright © 2020 yamsol. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ReportApi: NSObject {

    func resize(image: UIImage, toSize size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
        let destImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return destImage!
    }
    
    
    func reportWith(with params : NSMutableDictionary,detailImages : [UIImage], completion: @escaping ((_ success: Bool, _ message : String) -> Void))
    {
        
        
        Alamofire.upload(multipartFormData: { MultipartFormData in
            
            print(params)
            
            for (key, value) in params {
                print(key)
                print(value)
                MultipartFormData.append(((value) as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key as! String)
            }
            
            
            for i in detailImages {
                
                let image = self.resize(image: i, toSize: CGSize(width: 200.0, height: 200.0))
                
                
                let timestamp = NSDate().timeIntervalSince1970
                MultipartFormData.append(image.pngData() ?? Data(), withName: "media", fileName: "\(timestamp).png", mimeType: "image/png")
                
            }
            print(MultipartFormData)
            
        }, to: URLConfiguration.reportURL, method: .post , headers: URLConfiguration.headersAuth())  { (result) in
            
            switch result {
            case .success(let upload, _, _):
                
                upload.responseJSON { response in
                    print(response.result.value as Any)
                    
                    if response == nil
                    {
                        return;
                    }
                    
                    let swiftyJsonVar = JSON(response.result.value!)
                    print(swiftyJsonVar)
                    
                    let isSuccessful = swiftyJsonVar["isSuccess"].boolValue
                    if (!isSuccessful)
                    {
                        let msg = swiftyJsonVar["message"].string
                        completion(false, msg!)
                    }
                    else
                    {
                        let msg = swiftyJsonVar["message"].string
                        completion(true, msg!)
                    }
                }
                
                break
                
            case .failure(let encodingError):
                print(encodingError)
                completion(false, encodingError as! String)
                break
                
            }
        }
     }
    
}
