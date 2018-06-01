//
//  CloudLoginAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/24.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class CloudLoginAPI: BaseRequest {
    var code:String!
    init(code:String) {
        super.init()
        self.code = code
    }
    
    override func requestURL() -> String {
        return String(describing: "\(kCloudBaseURL)/token")
    }
    
    override func requestParameters() -> RequestParameters? {
        var dic = Dictionary<String, String>.init()
        dic["code"] = code
        dic["platform"] = "mobile"
        return dic
    }
}
