//
//  UserMailModel.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/22.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit
import HandyJSON

class UserMailModel:HandyJSON {
    var mail:String?
    var user: String?
    var createdAt:String?
    var updatedAt:String?
    required init() {}
}
