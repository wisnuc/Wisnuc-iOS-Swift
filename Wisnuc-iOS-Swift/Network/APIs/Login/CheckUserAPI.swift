//
//  CheckUserAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/21.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit
enum CheckUserType:String {
    case mail
    case phone
}

class CheckUserAPI: BaseRequest {
    var accountNumber:String?
    var type:CheckUserType?
    init(accountNumber:String,type:CheckUserType) {
        self.accountNumber = accountNumber
        self.type = type
    }
    
    override func requestURL() -> String {
        guard let type = self.type else {
            return ""
        }
        let url = "/user/\(type.rawValue)/check"
        return url
    }
    
    override func baseURL() -> String {
        return kCloudBaseURL
    }
    
    override func requestMethod() -> RequestHTTPMethod {
        return RequestHTTPMethod.get
    }
    
    override func requestParameters() -> RequestParameters? {
        guard let type = self.type else {
            return nil
        }
        
        guard let accountNumber = self.accountNumber else {
            return nil
        }
        return [type.rawValue:accountNumber]
    }
}
