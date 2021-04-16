//
//  HandyManApi.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 19/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class HandyManApi : NSObject {
    
    func handymanNearby(params : [String:Any], completion: @escaping ((_ success: Bool, _ message : String, _ handymanNearby: [HandymanNearbyVO?]) -> Void))
    {
        
        Alamofire.request(URLConfiguration.handymanNearbyURL, method: .post,parameters: params, encoding: URLEncoding.httpBody, headers: URLConfiguration.headers())
            .responseJSON { response in

            if let serverResponse = response.result.value
            {
                
                let swiftyJsonVar = JSON(serverResponse)
                let isSuccessful = swiftyJsonVar["success"].boolValue
                if (!isSuccessful)
                {
                    let msg = swiftyJsonVar["message"].string
                    completion(false, msg!, [])
                }
                else
                {
                    if let usr = swiftyJsonVar["handymans"].arrayObject as NSArray?
                    {
                        var user = [HandymanNearbyVO]()
                        
                        for i in usr {
                            user.append(HandymanNearbyVO(withJSON: i as! NSDictionary))
                        }
                        completion(true, "", user)
                        
                    }
                    else
                    {
                        completion(false, "Error occurred", [])
                    }
                }
            }
            else
            {
                completion(false, "Timed out Error.  We’re sorry we’re not able to fetch data at this time. Please try again.", [])
            }
        }
    }
}
