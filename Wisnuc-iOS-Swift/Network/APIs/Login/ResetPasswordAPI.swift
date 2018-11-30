//
//  ResetPasswordAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/16.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire

class ResetPasswordAPI: BaseRequest {
    var mailTicket:String?
    var phoneTicket:String?
    var password:String?
    init(phoneTicket:String? = nil, mailTicket:String? = nil,password:String) {
        self.mailTicket = mailTicket
        self.phoneTicket = phoneTicket
        self.password = password
    }
    
    override func requestURL() -> String {
        return "/user/password"
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
        guard let password = self.password else {
            return nil
        }
        
        if let phoneTicket = self.phoneTicket,let mailTicket = self.mailTicket {
            return ["phoneTicket":phoneTicket,"mailTicket":mailTicket,"password":password]
        }
        
        if let mailTicket = self.mailTicket {
            return ["mailTicket":mailTicket,"password":password]
        }
        
        if let phoneTicket = self.phoneTicket {
            return ["phoneTicket":phoneTicket,"password":password]
        }
        
        
        return nil
    }
}
