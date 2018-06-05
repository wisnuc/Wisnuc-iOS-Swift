
//
//  DriveModel.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/6/1.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation
import HandyJSON

struct DriveModel:HandyJSON {
    var owner:String?
    var uuid:String?
    var tag:String?
    var type:String?
    var label:String?
    var writelist:Array<Any>?
}