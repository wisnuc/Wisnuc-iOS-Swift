//
//  UserPhoneAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/22.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class UserPhoneAPI: BaseRequest {
    var method:RequestHTTPMethod?
    var oldTicket:String?
    var newTicket:String?
    init(_ method:RequestHTTPMethod? = nil,oldTicket:String? = nil ,newTicket:String? = nil){
        super.init()
        self.oldTicket = oldTicket
        self.newTicket = newTicket
    }
    override init() {
        
    }
    
    override func requestURL() -> String {
        return "/user/phone"
    }
    
    override func baseURL() -> String {
        return kCloudBaseURL
    }
    
    override func requestMethod() -> RequestHTTPMethod {
        return  self.method == nil ? RequestHTTPMethod.get : self.method!
    }
    
    override func requestParameters() -> RequestParameters? {
        if  self.method == .patch{
            if let oldTicket = self.oldTicket,let newTicket = self.newTicket{
             return  ["oldTicket":oldTicket,"newTicket":newTicket]
            }
        }
        return nil
    }
    
    override func requestHTTPHeaders() -> RequestHTTPHeaders? {
        guard let token = AppUserService.currentUser?.cloudToken else {
            return nil
        }
        return [kRequestAuthorizationKey:token]
    }
}
