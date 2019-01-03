//
//  SighInWechatTokenAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/9/19.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

//微信登录Token
class SighInWechatTokenAPI: BaseRequest {
    var code:String?
    init(code:String) {
        self.code = code
    }
    
    override init() {
        
    }
    
    override func requestURL() -> String {
        return "/wechat/token"
    }
    
    override func baseURL() -> String {
        return kCloudBaseURL
    }
    
    override func requestMethod() -> RequestHTTPMethod {
        return RequestHTTPMethod.get
    }
    
    override func requestParameters() -> RequestParameters? {
        let requestParameters:RequestParameters = ["loginType":"mobile","code":self.code! ,"clientId":getUniqueDevice() ?? "","type":"iOS"]
        return requestParameters
    }
}
