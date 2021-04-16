//
//  CategoryApi.swift
//  Neighboorhood-iOS-Services-User
//
//  Created by Zain ul Abideen on 09/01/2018.
//  Copyright © 2018 yamsol. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class CategoryApi : NSObject {
    
    func getCategories(completion: @escaping ((_ success: Bool, _ message : String, _ category: [CategoriesListVO]?) -> Void))
    {
        
        Alamofire.request(URLConfiguration.categoryListURL,method: .get, encoding: JSONEncoding.default, headers: URLConfiguration.headersContentType()).responseJSON { response in
            
            if let result = response.result.value
            {
                let swiftyJsonVar = JSON(result)
                print(swiftyJsonVar)
                
                let isSuccessful = swiftyJsonVar["isSuccess"].boolValue
                if (isSuccessful)
                {
                    if let usr = swiftyJsonVar["categories"].arrayObject as NSArray?
                    {
                        var categoryObj = [CategoriesListVO]()
                        
                        for i in usr {
                            categoryObj.append(CategoriesListVO(withJSON: i as! NSDictionary))
                        }
                        
                        completion(true, "", categoryObj)
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
