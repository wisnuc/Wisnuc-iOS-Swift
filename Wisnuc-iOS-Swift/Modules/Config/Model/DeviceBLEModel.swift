//
//  DeviceBLEModel.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/9/13.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

enum DeviceBLEModelType:String, Codable  {
    case configFinish
    case configWithData
    case config
    case configErrorNoDisk
}

import Foundation

struct DeviceBLEModel:Codable  {
    var name:String?
    var type:DeviceBLEModelType?
}

