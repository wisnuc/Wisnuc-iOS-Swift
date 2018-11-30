//
//  mailCodeTicket.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/29.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire
class MailCodeTicket: BaseRequest {
    var mail:String?
    var code:String?
    var type:SendCodeType?
    init(mail:String,code:String,type:SendCodeType) {
        self.code = code
        self.mail = mail
        self.type = type
    }
    
    override func requestURL() -> String {
        return "/user/mail/ticket"
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
        guard let mail = self.mail else {
            return nil
        }
        
        guard let type = self.type else {
            return nil
        }
        return ["mail":mail,"code":code,"type":type.rawValue]
    }
}
