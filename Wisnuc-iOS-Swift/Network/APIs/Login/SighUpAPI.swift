//
//  SighUpAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/9/18.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire

//注册
class SighUpAPI: BaseRequest {
    var phoneNumber:String?
    var ticket:String?
    var password:String?
    init(phoneNumber:String,ticket:String,password:String) {
        self.phoneNumber = phoneNumber
        self.ticket = ticket
        self.password = password
    }
    
    override init() {
        
    }
    
    override func requestURL() -> String {
        return "/user"
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
        let requestParameters:RequestParameters = ["phone":self.phoneNumber!,"ticket":ticket!,"password":self.password! ,"clientId":getUniqueDevice() ?? "","type":"iOS"]
        return requestParameters
    }
}
