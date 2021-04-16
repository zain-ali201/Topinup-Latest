//
//  ProposedJobApi.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 20/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ProposedJobApi: NSObject {
    
    
    func proposedJobsWith(completion: @escaping ((_ success: Bool, _ message : String, _ proposedJobs: [ProposedJobVO]?) -> Void))
    {
        
        Alamofire.request(URLConfiguration.proposedJobURL,method: .get, encoding: JSONEncoding.default, headers: URLConfiguration.headersAuth()).responseJSON { response in
            
            if let result = response.result.value
            {
                let swiftyJsonVar = JSON(result)
                print(swiftyJsonVar)
                
                let isSuccessful = swiftyJsonVar["success"].boolValue
                if (isSuccessful)
                {
                    if let quotations = swiftyJsonVar["quotations"].arrayObject as NSArray?
                    {
                        var proposedJob = [ProposedJobVO]()
                        
                        for i in quotations {
                            proposedJob.append(ProposedJobVO(withJSON: i as! NSDictionary))
                        }
                        completion(true, "", proposedJob)
                        
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
    
    func proposedJobQuotationDetailWith(jobID : String, completion: @escaping ((_ success: Bool, _ message : String, _ jobDetail: ProposedJobVO?) -> Void))
    {
        let urlString = URLConfiguration.jobQuotationDetailURL + jobID
        
        Alamofire.request(urlString,method: .get, encoding: JSONEncoding.default, headers: URLConfiguration.headersAuth()).responseJSON { response in
            
            if let result = response.result.value
            {
                let swiftyJsonVar = JSON(result)
                print(swiftyJsonVar)
                
                let isSuccessful = swiftyJsonVar["success"].boolValue
                if (isSuccessful)
                {
                    if let quote = swiftyJsonVar["quotation"].dictionaryObject as NSDictionary?
                    {
                        var jobDetail = ProposedJobVO()
                        jobDetail = ProposedJobVO(withJSON: quote)
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
    
    
}
