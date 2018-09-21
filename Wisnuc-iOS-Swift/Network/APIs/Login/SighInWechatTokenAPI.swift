//
//  SighInWechatTokenAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/9/19.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

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
        return kDevelopAddr
    }
    
    override func requestMethod() -> RequestHTTPMethod {
        return RequestHTTPMethod.get
    }
    
    override func requestParameters() -> RequestParameters? {
        let requestParameters:RequestParameters = ["type":"mobile","code":self.code! ]
        return requestParameters
    }
}
