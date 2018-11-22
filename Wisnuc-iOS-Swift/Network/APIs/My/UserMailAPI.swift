//
//  UserMailAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/22.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class UserMailAPI: BaseRequest {
    var method:RequestHTTPMethod?
    init(_ method:RequestHTTPMethod? = nil){
        super.init()
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
    
    override func requestHTTPHeaders() -> RequestHTTPHeaders? {
        guard let token = AppUserService.currentUser?.cloudToken else {
            return nil
        }
        return [kRequestAuthorizationKey:token]
    }
}
