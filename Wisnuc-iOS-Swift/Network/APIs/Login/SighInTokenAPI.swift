//
//  SighInTokenAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/9/19.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

//登录
class SighInTokenAPI: BaseRequest {
    var phoneNumber:String?
    var password:String?
    var code:String?
    init(phoneNumber:String,password:String? = nil,code:String? = nil) {
        super.init()
        self.phoneNumber = phoneNumber
        self.password = password
        self.code = code
    }
    
    override init() {
        
    }
    
    override func requestURL() -> String {
        if self.password != nil{
           return "/user/password/token"
        }
        if self.code != nil{
            return "/user/smsCode/token"
        }
        return "/user/password/token"
    }
    
    override func baseURL() -> String {
        return kCloudBaseURL
    }
    
    override func requestMethod() -> RequestHTTPMethod {
        return RequestHTTPMethod.get
    }
    
    override func requestParameters() -> RequestParameters? {
        print(getUniqueDevice() as Any)
        var requestParameters:RequestParameters? = nil
        if let password = self.password{
           requestParameters = ["username":self.phoneNumber!,"password":password,"clientId":getUniqueDevice() ?? "","type":"iOS"]
        }
        if let code = self.code{
            requestParameters = ["phone":self.phoneNumber!,"code":code,"clientId":getUniqueDevice() ?? "","type":"iOS"]
        }
       
        return requestParameters
    }
}

