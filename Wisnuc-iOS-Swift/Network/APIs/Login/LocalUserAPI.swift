//
//  LocalUserAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/31.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class LocalUserAPI: BaseRequest {
    var url:String?
    init(url:String) {
        super.init()
        self.url = url
    }
    
    override func requestURL() -> String {
        return "\(String(describing: url))/users"
    }

}
