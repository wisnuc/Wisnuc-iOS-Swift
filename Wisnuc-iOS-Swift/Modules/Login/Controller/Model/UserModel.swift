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
    var id:String?
    var password:String?
    var createdAt:String?
    var updatedAt:String?
    var status:String?
    var avatarUrl:String?
    var nickName:String?
//    var isAdmin:Bool?
//    var isFirstUser:Bool?
//    var global:GlobalModel?
//    "id": "ff0120e6-4d1b-4f73-825d-bf3178dd63c9",
//    "username": "13621766832",
//    "password": "*6BB4837EB74329105EE4568DDA7DC67ED2CA2AD9",
//    "createdAt": "2018-09-14T01:04:17.000Z",
//    "updatedAt": "2018-10-31T23:47:04.000Z",
//    "status": "1",
//    "safety": null,
//    "avatarUrl": null,
//    "nickName": null
}

struct GlobalModel: Decodable {
    var id:String?
}
