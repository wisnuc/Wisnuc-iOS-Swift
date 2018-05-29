//
//  CloudLoginModel.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/25.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import HandyJSON

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

class CloadLoginUserRemotModel: HandyJSON {
    var isAdmin:Int?
    var name:String?
    var username:String?
    var uuid:String?
    var isFirstUser:Int?
    var id:String?
    var LANIP:String?
    var isOnline:Bool?
    var state:Int?
    var global:CloadLoginGlobalModel?
    var type:String?
    required init() {
        
    }
}

class CloadLoginGlobalModel: HandyJSON {
    var id:String?
    required init() {}
}
