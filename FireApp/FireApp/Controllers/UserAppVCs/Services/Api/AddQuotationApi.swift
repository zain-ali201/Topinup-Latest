//
//  AddQuotationApi.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 20/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class AddQuotationApi : NSObject {

    func createQuotationWith(params : [String:Any], completion: @escaping ((_ success: Bool, _ message : String) -> Void))
    {
        Alamofire.request(URLConfiguration.addQuotationURL, method: .post,parameters: params, encoding: URLEncoding.httpBody, headers: URLConfiguration.headers())
            .responseJSON { response in
                
                if let serverResponse = response.result.value
                {
                    let swiftyJsonVar = JSON(serverResponse)
                    let isSuccessful = swiftyJsonVar["success"].boolValue
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
