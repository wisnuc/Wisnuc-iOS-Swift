//
//  RequestConfig.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/24.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Security

class RequestConfig: NSObject {
    var baseURL:String?
    //文件服务器地址
    var cdnURL:String?
    //加密策略
    var securityPolocy:SecPolicy?

    static let sharedInstance = RequestConfig()
    private override init(){
        super.init()
    }
}
