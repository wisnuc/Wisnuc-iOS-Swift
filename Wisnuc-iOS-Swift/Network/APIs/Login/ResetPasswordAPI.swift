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
    var token:String?
    var phone:String?
    var password:String?
    init(token:String,phone:String,password:String) {
        self.token = token
        self.phone = phone
        self.password = password
    }
    
    override func requestURL() -> String {
        return "/user/password"
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
        guard let token = self.token else {
            return nil
        }
        guard let phone = self.phone else {
            return nil
        }
        guard let password = self.password else {
            return nil
        }
        return ["token":token,"phone":phone,"password":password]
    }
}
