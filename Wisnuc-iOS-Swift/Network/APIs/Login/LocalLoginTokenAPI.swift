//
//  LocalLoginTokenAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/6/22.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class LocalLoginTokenAPI: BaseRequest {
    var url:String?
    var auth:String?
    init(url:String,auth:String) {
        self.url = url
        self.auth = auth
    }
    override func baseURL() -> String {
        return url!
    }
    override func requestURL() -> String {
        return "/token"
    }
    
    override func requestHTTPHeaders() -> RequestHTTPHeaders? {
        let dic = [kRequestAuthorizationKey:"Basic \(auth!)"]
        return dic
    }
}
