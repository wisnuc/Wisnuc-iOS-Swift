//
//  UserSafetyChange.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/28.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire

//用户双重验证操作API
class UserSafetyChange: BaseRequest {
    var safety:Int?
    init(safety:Int) {
        self.safety = safety
    }
    override func requestURL() -> String {
        return "/user/safety"
    }
    
    override func baseURL() -> String {
        return kCloudBaseURL
    }
    
    override func requestEncoding() -> RequestParameterEncoding {
        return  JSONEncoding.default
    }
    
    override func requestParameters() -> RequestParameters? {
        if let safety = self.safety{
            return ["safety":safety]
        }
        return nil
    }
    
    override func requestMethod() -> RequestHTTPMethod {
        return  RequestHTTPMethod.patch
    }
    
    override func requestHTTPHeaders() -> RequestHTTPHeaders? {
        guard let token = AppUserService.currentUser?.cloudToken else {
            return nil
        }
        
        let params =  [kRequestAuthorizationKey:token]
        return params
    }
}
