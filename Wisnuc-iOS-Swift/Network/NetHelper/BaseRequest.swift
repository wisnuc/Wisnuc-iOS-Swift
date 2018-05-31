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

struct BaseError:Error {
    var localizedDescription: String
}

//protocol RequestDelegate{
//    func requestMethod() -> HTTPMethod
//    func requestURL() -> String
//}
typealias RequestParameters = Parameters
typealias RequestHTTPHeaders = HTTPHeaders
typealias RequestParameterEncoding = ParameterEncoding
class BaseRequest: NSObject{
    var task:URLSessionTask?
    func requestURL() -> String {
        return ""
    }
    
    func requestMethod() -> HTTPMethod {
        return .get
    }
    
    func requestParameters() -> RequestParameters?{
        return nil
    }
    
    func requestEncoding() -> RequestParameterEncoding{
        return URLEncoding.default
    }
    
    func requestHTTPHeaders() -> RequestHTTPHeaders? {
        return nil
    }
    
    func timeoutIntervalForRequest() -> TimeInterval {
        return 15.0
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
    
    func startRequestJSONCompletionHandler(_ requestCompletionHandler:@escaping NetworkResonseJSONCompletionHandler) {
        networkState { (isConnect) in
            if isConnect{
                NetEngine.sharedInstance.addNormalRequetJOSN(requestObj: self, requestCompletionHandler)
            }else{
                requestCompletionHandler(DataResponse<Any>.init(request: nil, response: nil, data: nil, result: Result<Any>.failure(BaseError.init(localizedDescription: LocalizedString(forKey: "无法连接服务器，请检查网络")))))
            }
        }
    }
    
    func startRequestJSONCompletionHandler(_ queue: DispatchQueue?,_ requestCompletionHandler:@escaping NetworkResonseJSONCompletionHandler) {
        networkState { (isConnect) in
            if isConnect{
              NetEngine.sharedInstance.addNormalRequetJOSN(requestObj: self, queue: queue, requestCompletionHandler)
            }else{
                requestCompletionHandler(DataResponse<Any>.init(request: nil, response: nil, data: nil, result: Result<Any>.failure(BaseError.init(localizedDescription: LocalizedString(forKey: "无法连接服务器，请检查网络")))))
            }
        }
    }
    
    func startRequestDataCompletionHandler(_ requestCompletionHandler:@escaping NetworkResonseDataCompletionHandler) {
        networkState { (isConnect) in
            if isConnect{
               NetEngine.sharedInstance.addNormalRequetData(requestObj: self, requestCompletionHandler)
            }else{
                requestCompletionHandler(DataResponse<Data>.init(request: nil, response: nil, data: nil, result: Result<Data>.failure(BaseError.init(localizedDescription: LocalizedString(forKey: "无法连接服务器，请检查网络")))))
            }
        }
    }
    
    func startRequestStringCompletionHandler(_ requestCompletionHandler:@escaping NetworkResonseStringCompletionHandler) {
        networkState { (isConnect) in
            if isConnect{
                NetEngine.sharedInstance.addNormalRequetString(requestObj: self, requestCompletionHandler)
            }else{
              requestCompletionHandler(DataResponse<String>.init(request: nil, response: nil, data: nil, result: Result<String>.failure(BaseError.init(localizedDescription: LocalizedString(forKey: "无法连接服务器，请检查网络")))))
            }
        }
    }
    
    func networkState(_ closure:@escaping (_ isConnected:Bool)->()){
        NetworkStatus.getNetworkStatus { (status) in
            if status == .Disconnected{
                Message.message(text: LocalizedString(forKey: "无法连接服务器，请检查网络"))
               closure(false)
            }else{
               closure(true)
            }
        }
    }
    
    func stop(){
        
    }

}

