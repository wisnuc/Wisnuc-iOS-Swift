//
//  SmsCodeTicket.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/16.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire

class SmsCodeTicket: BaseRequest {
    var phone:String?
    var code:String?
    var type:SmsCodeType?
    init(phone:String,code:String,type:SmsCodeType) {
        self.code = code
        self.phone = phone
        self.type = type
    }
    
    override func requestURL() -> String {
        return "/user/smsCode/ticket"
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
        guard let code = self.code else {
            return nil
        }
        guard let phone = self.phone else {
            return nil
        }
        
        guard let type = self.type else {
            return nil
        }
        return ["phone":phone,"code":code,"type":type.rawValue]
    }
}
