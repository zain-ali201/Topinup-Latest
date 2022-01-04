//
//  JobHistoryApi.swift
//  Neighboorhood-iOS-Services-User
//
//  Created by Zain ul Abideen on 07/01/2018.
//  Copyright © 2018 yamsol. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class JobHistoryApi : NSObject {
    
    
    func jobHistory(params : [String:Any], completion: @escaping ((_ success: Bool, _ message : String, _ jobHistory: [JobHistoryVO?]) -> Void))
    {
        
        Alamofire.request(URLConfiguration.jobHistoryURL, method: .get, parameters: params, encoding: URLEncoding.default, headers: URLConfiguration.headers())
            .responseJSON { response in
                
                
                
                
                
                if let serverResponse = response.result.value
                {
                    let swiftyJsonVar = JSON(serverResponse)
                    print(swiftyJsonVar)
                    
                    let isSuccessful = swiftyJsonVar["isSuccess"].boolValue
                    if (!isSuccessful)
                    {
                        let msg = swiftyJsonVar["message"].string
                        completion(false, msg!, [])
                    }
                    else
                    {
                        var user = [JobHistoryVO]()
                        
                        if let usr = swiftyJsonVar["jobs"].arrayObject as NSArray?
                        {
                            
                            for i in usr {
                                user.append(JobHistoryVO(withJSON: i as! NSDictionary))
                            }
                            
                            
                        }
                        
                        
                        
                        if let usr = swiftyJsonVar["completed"].arrayObject as NSArray?
                        {
                            
                            for i in usr {
                                user.append(JobHistoryVO(withJSON: i as! NSDictionary))
                            }
                            
                            
                        }
                        
                        
                        if let usr = swiftyJsonVar["cancelled"].arrayObject as NSArray?
                        {
                            
                            for i in usr {
                                user.append(JobHistoryVO(withJSON: i as! NSDictionary))
                            }
                            
                            
                        }
                        
                        completion(true, "", user)
                        
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
    
    func blockProvider(userID: String, providerID: String, method: HTTPMethod, completion: @escaping ((_ success: Bool, _ message : String) -> Void))
    {
        let jobURL = "\(URLConfiguration.blockProviderURL)/\(userID)/\(providerID)"
        print(jobURL)
        Alamofire.request(jobURL, method: method, parameters: nil, encoding: URLEncoding.default, headers: URLConfiguration.headers())
            .responseJSON { response in
                
                if let serverResponse = response.result.value
                {
                    let swiftyJsonVar = JSON(serverResponse)
                    print(swiftyJsonVar)
                    
                    let success = swiftyJsonVar["status"].string
                    let isBlocked = swiftyJsonVar["isBlocked"].boolValue
                    
                    if success != "success"
                    {
                        let msg = swiftyJsonVar["message"].string
                        completion(false, msg!)
                    }
                    else
                    {
                        if isBlocked
                        {
                            completion(true, "Unblock")
                        }
                        else
                        {
                            completion(true, "Block")
                        }
                    }
                }
                else
                {
                    completion(false, "Timed out Error.  We’re sorry we’re not able to fetch data at this time. Please try again.")
                }
        }
    }
    
    
    func removeJobCommunication(messageID: String, params : [String:Any], completion: @escaping ((_ success: Bool, _ message : String) -> Void))
    {
        let jobURL = URLConfiguration.jobDeleteURL// + jobID
        
        print(jobURL)
        
        Alamofire.request(jobURL, method: .post, parameters: params, encoding: URLEncoding.default, headers: URLConfiguration.headers())
            .responseJSON { response in
                
                print(response.result.value as Any)
                
                if let serverResponse = response.result.value
                {
                    let swiftyJsonVar = JSON(serverResponse)
                    print(swiftyJsonVar)
                    
                    let isSuccessful = swiftyJsonVar["isSuccess"].boolValue
                    
                    if (!isSuccessful)
                    {
                        let msg = swiftyJsonVar["msg"].string
                        completion(false, msg!)
                    }
                    else
                    {
                        let msg = swiftyJsonVar["msg"].string
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
