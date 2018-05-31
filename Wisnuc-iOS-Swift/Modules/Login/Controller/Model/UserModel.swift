//
//  UserModel.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/24.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

struct UserModel: Decodable {
    var username:String?
    var uuid:String?
    var avatar:String?
    var disabled:Bool?
    var isAdmin:Bool?
    var isFirstUser:Bool?
    var global:GlobalModel?
}

struct GlobalModel: Decodable {
    var id:String?
}
