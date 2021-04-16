//
//  PlacesApi.swift
//  Neighboorhood-iOS-Services
//
//  Created by Rizwan Shah on 28/07/2020.
//  Copyright © 2020 yamsol. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire


class PlacesApi : NSObject {
    
    
    func autoComplete(params : [String:Any], completion: @escaping ((_ success: Bool, _ message : String, _ jobHistory: [PlacesVO?]) -> Void))
    {
        let textSearch = params["text"] as! String
        let replaced = textSearch.replacingOccurrences(of: " ", with: "%20")
        
        let completeURL = "\(URLConfiguration.mapBoxSearchURL)\(replaced).json?access_token=\(URLConfiguration.mapBoxAPIKey)"
        
        
        
        Alamofire.request(completeURL, method: .get, parameters: params, encoding: URLEncoding.default, headers: URLConfiguration.headers())
            .responseJSON { response in
                
                if let serverResponse = response.result.value
                {
                    let swiftyJsonVar = JSON(serverResponse)
                    print(swiftyJsonVar)
                    
                    if let feature = swiftyJsonVar["features"].arrayObject as NSArray?
                    {
                        var place = [PlacesVO]()
                        
                        for i in feature {
                            place.append(PlacesVO(withJSON: i as! NSDictionary))
                        }
                        completion(true, "", place)
                        
                    }
                    else
                    {
                        completion(false, "Error occurred", [])
                    }
                    
                    
                }
                else
                {
                    completion(false, "Timed out Error.  We’re sorry we’re not able to fetch data at this time. Please try again.", [])
                }
        }
    }
    
    func jobHistoryWith(jobID: String, completion: @escaping ((_ success: Bool, _ message : String, _ jobHistory: JobHistoryVO?) -> Void))
    {
        
        let url = URLConfiguration.jobHistoryURL + "/" + jobID
        
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: URLConfiguration.headers())
            .responseJSON { response in
                
                if let serverResponse = response.result.value
                {
                    let swiftyJsonVar = JSON(serverResponse)
                    let isSuccessful = swiftyJsonVar["isSuccess"].boolValue
                    if (!isSuccessful)
                    {
                        let msg = swiftyJsonVar["message"].string
                        completion(false, msg!, nil)
                    }
                    else
                    {
                        if let usr = swiftyJsonVar["job"].dictionaryObject as? NSDictionary
                        {
                            var user = JobHistoryVO()
                            user = JobHistoryVO(withJSON: usr)
                            completion(true, "", user)
                            
                        }
                        else
                        {
                            completion(false, "Error occurred", nil)
                        }
                    }
                }
                else
                {
                    completion(false, "Timed out Error.  We’re sorry we’re not able to fetch data at this time. Please try again.", nil)
                }
        }
    }
    
    func jobFeedback(jobID: String, params : [String:Any], completion: @escaping ((_ success: Bool, _ message : String) -> Void))
    {
        let jobURL = URLConfiguration.jobRatingURL// + jobID
        
        Alamofire.request(jobURL, method: .post, parameters: params, encoding: URLEncoding.default, headers: URLConfiguration.headers())
            .responseJSON { response in
                
                if let serverResponse = response.result.value
                {
                    let swiftyJsonVar = JSON(serverResponse)
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
                else
                {
                    completion(false, "Timed out Error.  We’re sorry we’re not able to fetch data at this time. Please try again.")
                }
        }
    }
}
