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
    var loginToken:String?
    var wechatToken:String?
    init(wechatToken:String,loginToken:String) {
        self.loginToken = loginToken
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
        guard let wechatToken = self.wechatToken else {
            return nil
        }
        let  requestParameters:RequestParameters = [kRequestWechatKey:wechatToken]
        return requestParameters
    }
    
    override func requestHTTPHeaders() -> RequestHTTPHeaders? {
        guard let loginToken = self.loginToken else {
            return nil
        }
        return [kRequestAuthorizationKey:loginToken]
    }
}
