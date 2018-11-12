//
//  GetSmsCodeAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/9/18.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class GetSmsCodeAPI: BaseRequest {
    var phoneNumber:String?
    var wechatToken:String?
    init(phoneNumber:String,wechatToken:String? = nil) {
        self.phoneNumber = phoneNumber
        self.wechatToken = wechatToken
    }
    
    override init() {
        
    }
    
    override func requestURL() -> String {
//        switch AppNetworkService.networkState {
//        case .normal?:
//            return "\(kCloudCommonJsonUrl)?resource=\(resource)&method=\(RequestMethodValue.GET)"
//        case .local?:
//            return "/\(resource)"
//        default:
//            return ""
//        }
        return "/user/smsCode"
    }
    
    override func baseURL() -> String {
        return kCloudBaseURL
    }
    
    override func requestMethod() -> RequestHTTPMethod {
        return RequestHTTPMethod.get
    }
    
    override func requestParameters() -> RequestParameters? {
        let requestParameters:RequestParameters = ["phone":self.phoneNumber!]
        return requestParameters
    }
    
    override func requestHTTPHeaders() -> RequestHTTPHeaders? {
        if self.wechatToken != nil && !isNilString(wechatToken){
            return [kRequestWechatKey:wechatToken!]
        }else{
            return nil
        }
    }
}
