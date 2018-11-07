//
//  SighInTokenAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/9/19.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class SighInTokenAPI: BaseRequest {
    var phoneNumber:String?
    var password:String?
    init(phoneNumber:String,password:String) {
        self.phoneNumber = phoneNumber
        self.password = password
    }
    
    override init() {
        
    }
    
    override func requestURL() -> String {
        return "/user/token"
    }
    
    override func baseURL() -> String {
        return kCloudBaseURL
    }
    
    override func requestMethod() -> RequestHTTPMethod {
        return RequestHTTPMethod.get
    }
    
    override func requestParameters() -> RequestParameters? {
        print(getUniqueDevice() as Any)
        let requestParameters:RequestParameters = ["username":self.phoneNumber!,"password":self.password!,"clientId":getUniqueDevice() ?? "","type":"iOS"]
        return requestParameters
    }
}
