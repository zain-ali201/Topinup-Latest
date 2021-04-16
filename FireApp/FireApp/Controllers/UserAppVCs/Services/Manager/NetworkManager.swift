//
//  NetworkManager.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 18/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import Foundation
import Alamofire

typealias successCall = (_ data: AnyObject?) -> Void
typealias failureCall = (_ error: NSError?)  -> Void

var serverURL : String = URLConfiguration.ServerUrl

class NetworkManager : NSObject {
    
    class func createErrorMessage(_ message:String, code:Int) -> NSError {
        return NSError(domain: "server response!", code: code, userInfo: [NSLocalizedDescriptionKey:message])
    }
    
    class func handleRequestResponse(_ json:AnyObject?, error:NSError!, success:successCall, failure:failureCall){
        print("S-E-R-V-E-R  C-A-L-L  C-O-M-P-L-E-T-E-D")
        
        if (error == nil) {
            
            var data = [String: AnyObject]();
            
            if let dict = json as? [String: AnyObject]{
                data = dict;
            } else if let list = json! as? [AnyObject] {
                data = ["data":list as AnyObject];
            }
            
            print("Request Response: \(data)")
            
            var code = 0;
            
            if let codeObj = data["response_status"] as? NSNumber {
                code = codeObj.intValue;
            }

            if ( code == 1 ){
                success(data as AnyObject?);
            } else if let successObj = data["response_status"] as? String {
                if successObj == "OK" {
                    success(data as AnyObject?)
                }
            } else{
                var message = "Something went wrong";
                if let msg = data["message"] {
                    message = msg as! String;
                }
                let errorObj = createErrorMessage(message, code: code);
                failure(errorObj);
            }
        } else {
            print("Request Error: \(error.localizedDescription)")
            failure(error);
        }
    }
    
    class func postWithURL( _ url:String, params:Dictionary<String,AnyObject>,
                            success:@escaping successCall, failure:@escaping failureCall) {
        
        print("Request URL: " + url)
        print("Request Params: \(params)")
        
//        if !HelperClass.isInternetAvailable() {
//
//            HelperClass.showNetworkErrorView()
//            return
//        }
        
        request(url, method: .post, parameters: params)
            .responseJSON { response in
                
            switch response.result {
            case .success:
                if let JSON = response.result.value {
                    self.handleRequestResponse(JSON as AnyObject?, error: nil, success: success, failure: failure);
                }
            case .failure(let error):
                print("my response",error)
                failure(error as NSError?);
            }
        }
    }
    
}
