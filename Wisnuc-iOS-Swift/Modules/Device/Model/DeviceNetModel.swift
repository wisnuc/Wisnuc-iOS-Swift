//
//  DeviceNetModel.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/26.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import Foundation
import HandyJSON
struct DeviceNetModel:Codable{
    var name:String?
    var address:String?
    var mtu:Int?
    var wireless:Bool?
    var state:String?
    var ipAddresses:Array<DeviceNetIpAddressesModel>?
}

struct DeviceNetIpAddressesModel:Codable{
    var netmask:String?
    var address:String?
    var family:String?
    var mac:String?
    var scopeid:Int?
    var cidr:String?
}

