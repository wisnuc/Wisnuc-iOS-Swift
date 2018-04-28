//
//  StationModel.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/16.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

enum DeviceForSearchState:String {
    case applyToUse = "applyToUse"
    case initialization = "initialization"
    case importTo = "importTo"
}

class StationModel: NSObject {
    var name:String?
    var type:String?
    var state:String?
    var adress:String?
}

class FoundStationModel: NSObject {
    var name:String?
    var type:String?
}

class DiskModel: NSObject {
    var name:String?
    var type:String?
    var capacity:NSNumber?
    var effectiveCapacity:NSNumber?
    var isError:Bool?
    var serial:String?
    var admin:String?
}
