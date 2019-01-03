//
//  GetSmsCodeAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/9/18.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire

enum SendCodeType:String{
    case register
    case password
    case login
    case replace
    case bind
    case unbind
    case mail
}

//获取短信验证码
class GetSmsCodeAPI: BaseRequest {
    var phoneNumber:String?
    var wechatToken:String?
    var type:SendCodeType?
    init(phoneNumber:String,type:SendCodeType,wechatToken:String? = nil) {
        self.phoneNumber = phoneNumber
        self.wechatToken = wechatToken
        self.type = type
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
        return RequestHTTPMethod.post
    }
    
    override func requestEncoding() -> RequestParameterEncoding {
        return JSONEncoding.default
    }
    
    override func requestParameters() -> RequestParameters? {
        let requestParameters:RequestParameters = ["phone":self.phoneNumber!,"type":(self.type?.rawValue)!]
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
