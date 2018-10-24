//
//  GetStationsAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/23.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class GetStationsAPI: BaseRequest {
    var token:String?
    init(token:String) {
        super.init()
        self.token = token
    }
    override func requestURL() -> String {
        return "\(kDevelopAddr)/station"
    }
    
    override func requestHTTPHeaders() -> RequestHTTPHeaders? {
        let dic = [kRequestAuthorizationKey:token!]
        return dic
    }
}
