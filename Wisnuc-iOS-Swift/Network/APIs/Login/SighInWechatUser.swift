//
//  SighInWechatUser.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/9/19.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire

class SighInWechatUser: BaseRequest {
    var phoneNumber:String?
    var password:String?
    var code:String?
    var wechatToken:String?
    init(phoneNumber:String,code:String,wechatToken:String,password:String? = nil) {
        self.code = code
        self.phoneNumber = phoneNumber
        self.password = password
        self.wechatToken = wechatToken
    }
    
    override init() {
        
    }
    
    override func requestURL() -> String {
        return "/wechat/user"
    }
    
    override func baseURL() -> String {
        return kCloudBaseURL
    }
    
    override func requestMethod() -> RequestHTTPMethod {
        return RequestHTTPMethod.patch
    }
    
    override func requestEncoding() -> RequestParameterEncoding {
        return JSONEncoding.default
    }
    
    override func requestParameters() -> RequestParameters? {
        var requestParameters:RequestParameters = ["phone":self.phoneNumber!,"code":self.code!]
        if password != nil{
            requestParameters = ["phone":self.phoneNumber!,"code":self.code!,"password":self.password!]
        }
        return requestParameters
    }
    
    override func requestHTTPHeaders() -> RequestHTTPHeaders? {
        return [kRequestWechatKey:wechatToken!]
    }
}
