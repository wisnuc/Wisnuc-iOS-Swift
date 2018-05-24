//
//  TestAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/24.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class TestAPI: BaseRequest {
    override func requestURL() -> String {
        return "www.baidu.com"
    }
    
    override func baseURL() -> String {
        return "https://"
    }
    
}
