//
//  GetMailCodeAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/22.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire

class GetMailCodeAPI: BaseRequest {
    var mail:String?
    var type:SendCodeType?
    init(mail:String,type:SendCodeType) {
        self.mail = mail
        self.type = type
    }
    
    override init() {
        
    }
    
    override func requestURL() -> String {
        return "/user/mailCode"
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
        guard let mail = self.mail else {
            return nil
        }
        
        guard let type = self.type else {
            return nil
        }
        let requestParameters:RequestParameters = ["mail":mail,"type":type]
        return requestParameters
    }
}
