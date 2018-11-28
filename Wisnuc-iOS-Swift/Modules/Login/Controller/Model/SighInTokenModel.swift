//
//  SighInTokenModel.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/9/19.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

struct SighInTokenModel: Decodable {
    var data:SighInData?
    var code:Int?
    var message:String?
}

struct SighInData:Decodable{
    var token:String?
    var avatarUrl:String?
    var id:String?
    var createdAt:String?
    var nickName:String?
    var updatedAt:String?
    var username:String?
    var mail:String?
    var safety:Int?
}
