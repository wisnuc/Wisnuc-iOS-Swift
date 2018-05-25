//
//  CloudLoginModel.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/25.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

struct CloudLoginModel: Decodable {
    var  url:String?
    var  data:CloadLoginDataModel?
}

struct CloadLoginDataModel: Decodable {
    var token:String?
    var user:CloadLoginUserModel?
}

struct CloadLoginUserModel: Decodable {
    var avatarUrl:String?
    var nickName:String?
    var id:String?
}
