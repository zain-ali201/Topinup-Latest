//
//  JobDetailApi.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 20/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class JobDetailApi : NSObject {
    
    func jobDetailWith(jobID : String, completion: @escaping ((_ success: Bool, _ message : String, _ jobDetail: RequestJobDetailVO?) -> Void))
    {
        print(jobID)
        let urlString = URLConfiguration.requestJobDetailURL + jobID
        
        Alamofire.request(urlString,method: .get, encoding: JSONEncoding.default, headers: URLConfiguration.headersContentType()).responseJSON { response in
            
            if let result = response.result.value
            {
                let swiftyJsonVar = JSON(result)
                print(swiftyJsonVar)
                
                let isSuccessful = swiftyJsonVar["isSuccess"].boolValue
                if (isSuccessful)
                {
                    if let usr = swiftyJsonVar["request"].dictionaryObject as NSDictionary?
                    {
                        var jobDetail = RequestJobDetailVO()
                        jobDetail = RequestJobDetailVO(withJSON: usr)
                        completion(true, "", jobDetail)
                    }
                }
                else
                {
                    let msg = swiftyJsonVar["message"].string
                    completion(false, msg!,nil)
                }
            }
            else
            {
                completion(false, "No internet connection",nil)
            }
        }
    }
    
    func jobHistoryWith(completion: @escaping ((_ success: Bool, _ message : String, _ jobHistory: [HandymanNearbyVO]?) -> Void))
    {
       Alamofire.request(URLConfiguration.jobHistoryURL,method: .get, headers: URLConfiguration.headersAuth()).responseJSON { response in
            
            if let result = response.result.value
            {
                let swiftyJsonVar = JSON(result)
                print(swiftyJsonVar)
                
                let isSuccessful = swiftyJsonVar["success"].boolValue
                if (isSuccessful)
                {
                    if let handyman = swiftyJsonVar["handymans"].arrayObject as NSArray?
                    {
                        var history = [HandymanNearbyVO]()
                        
                        for i in handyman {
                            history.append(HandymanNearbyVO(withJSON: i as! NSDictionary))
                        }
                        completion(true, "", history)
                        
                    }
                }
                else
                {
                    let msg = swiftyJsonVar["message"].string
                    completion(false, msg!,nil)
                }
            }
            else
            {
                completion(false, "No internet connection",nil)
            }
        }
    }
    
    func currentJobsWith(completion: @escaping ((_ success: Bool, _ message : String, _ currentJobs: [HandymanNearbyVO]?) -> Void))
    {
        print("URLCurrentJobs: \(URLConfiguration.currentJobsURL)")
        
        Alamofire.request(URLConfiguration.currentJobsURL,method: .get, headers: URLConfiguration.headersAuth()).responseJSON { response in
            
            if let result = response.result.value
            {
                let swiftyJsonVar = JSON(result)
                print(swiftyJsonVar)
                
                let isSuccessful = swiftyJsonVar["success"].boolValue
                if (isSuccessful)
                {
                    if let handyman = swiftyJsonVar["handymans"].arrayObject as NSArray?
                    {
                        var history = [HandymanNearbyVO]()
                        
                        for i in handyman {
                            history.append(HandymanNearbyVO(withJSON: i as! NSDictionary))
                        }
                        completion(true, "", history)
                        
                    }
                }
                else
                {
                    let msg = swiftyJsonVar["message"].string
                    completion(false, msg!,nil)
                }
            }
            else
            {
                completion(false, "No internet connection",nil)
            }
        }
    }
    
    
    
}
