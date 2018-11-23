//
//  UserMailAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/22.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire

class UserMailAPI: BaseRequest {
    var method:RequestHTTPMethod?
    var mail:String?
    var code:String?
    init(_ method:RequestHTTPMethod? = nil,mail:String? = nil, code:String? = nil){
        super.init()
        self.method = method
        self.mail = mail
        self.code = code
    }
    override init() {
        
    }
    
    override func requestURL() -> String {
        return "/user/mail"
    }
    
    override func baseURL() -> String {
        return kCloudBaseURL
    }
    
    override func requestMethod() -> RequestHTTPMethod {
        return  self.method == nil ? RequestHTTPMethod.get : self.method!
    }
    
    override func requestParameters() -> RequestParameters? {
        if self.method == .post{
            if let mail = self.mail,let code = self.code{
                return ["mail":mail,"code":code]
            }
        }
        return nil
    }
    
    override func requestEncoding() -> RequestParameterEncoding {
        return  self.requestMethod() == RequestHTTPMethod.get ? URLEncoding.default : JSONEncoding
            .default
    }
    
    override func requestHTTPHeaders() -> RequestHTTPHeaders? {
        guard let token = AppUserService.currentUser?.cloudToken else {
            return nil
        }
        
        let params =  [kRequestAuthorizationKey:token]
        return params
    }
}
