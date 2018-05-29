//
//  CloudGetStationsAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/28.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class CloudGetStationsAPI: BaseRequest {
    var guid:String?
    var cloudToken:String?
    
    init(guid:String,token:String) {
        super.init()
        self.guid = guid
        self.cloudToken = token
    }
    override func requestURL() -> String {
        return "\(kCloudBaseURL)users/\(guid!)/stations"
    }
    
    override func requestHTTPHeaders() -> RequestHTTPHeaders? {
        let dic = ["Authorization":cloudToken!]
        return dic
    }
}
