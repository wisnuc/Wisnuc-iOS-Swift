//
//  BaseRequest.swift
//  FruitMix-Swift
//
//  Created by wisnuc-imac on 2018/3/21.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire
enum RequestMethodType:Int{
   case get = 0
   case post
   case head
   case put
   case delete
   case patch
}

//protocol RequestDelegate{
//    func requestMethod() -> HTTPMethod
//    func requestURL() -> String
//}
typealias RequestParameters = Parameters
class BaseRequest: NSObject{
    var task:URLSessionTask?
    var completionHandler:NetworkRequestCompletionHandler?
    func requestURL() -> String {
        return ""
    }
    
    func requestMethod() -> HTTPMethod {
        return .get
    }
    
    func requestParameters() -> RequestParameters?{
        return nil
    }
    
    func requestEncoding() -> ParameterEncoding{
        return URLEncoding.default
    }
    
    func requestHTTPHeaders() -> HTTPHeaders? {
        return nil
    }
    
    func timeoutIntervalForRequest() -> TimeInterval {
        return 20.0
    }
    
    func useCDN() -> Bool {
        return false
    }
    
    func cdnURL() -> String {
        return ""
    }

    func baseURL() -> String {
        return ""
    }
    
    func start(_ requestCompletionHandler:@escaping NetworkRequestCompletionHandler) {
        completionHandler = requestCompletionHandler
        start()
    }
 
    private func start(){
        NetEngine.sharedInstance.addNormalRequet(requestObj: self)
    }
    
    func stop(){
        
    }

}

