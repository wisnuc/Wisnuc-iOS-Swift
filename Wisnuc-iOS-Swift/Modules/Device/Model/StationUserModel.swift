//
//  StationUserModel.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/28.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

struct StationUserListModel: Codable {
    var owner:Array<StationUserModel>?
    var sharer:Array<StationUserModel>?
}

struct StationUserModel: Codable {
    var id :String?
    var username :String?
    var avatarUrl:String?
    var createdAt:String?
}
