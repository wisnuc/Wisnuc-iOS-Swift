//
//  WinasdInfoModel.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/30.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

struct WinasdInfoModel: Codable {
    var net:WinasdInfoNetModel?
    var ble:WinasdInfoBleModel?
    var upgrade:WinasdInfoUpgradeModel?
    var winas:WinasdInfoWinasModel?
    var channel:WinasdInfoChannelModel?
    var device:WinasdInfoDeviceModel?
}

struct WinasdInfoNetModel: Codable {
    var state:String?
    var networkInterface:WinasdInfoNetNetworkInterfaceModel?
}

struct WinasdInfoNetNetworkInterfaceModel: Codable {
    var address:String?
    var netmask:String?
    var family:String?
    var mac:String?
//    var internal:Bool?
    var cidr:String?
    var interfaceName:String?
    var speed:Int?
    var essid:String?
}

struct WinasdInfoBleModel: Codable {
    var state:String?
    var address:String?
}

struct WinasdInfoUpgradeModel: Codable {
    var fetch:WinasdInfoUpgradeFetchModel?
    var download:WinasdInfoUpgradeDownloadModel?
}

struct WinasdInfoUpgradeFetchModel: Codable {
    var state:String?
    var view:WinasdInfoUpgradeFetchViewModel?
    var last:WinasdInfoUpgradeFetchLastModel?
}

struct WinasdInfoUpgradeFetchViewModel: Codable {
    var startTime:Int64?
    var timeout:Int64?
}

struct WinasdInfoUpgradeFetchLastModel: Codable {
    var time:Int64?
    var error:String?
    var data:Array<WinasdInfoUpgradeFetchLastDataModel>?
}

struct WinasdInfoUpgradeFetchLastDataModel: Codable {
    var Key:String?
    var LastModified:String?
    var ETag:String?
    var Size:Int?
    var StorageClass:String?
}

struct WinasdInfoUpgradeDownloadModel: Codable {
    var version:String?
    var state:String?
    var bytesWritten:Int64?
    
}

struct WinasdInfoWinasModel: Codable {
    var state:String?
    var isBeta:Bool?
}

struct WinasdInfoChannelModel: Codable {
    var state:String?
}

struct WinasdInfoDeviceModel: Codable {
    var ecc:String?
    var sn:String?
    var fingerprint:String?
    var cert:String?
    var signer:String?
    var notBefore:Int64?
    var notAfter:Int64?
    var bleAddr:String?
    var name:String?
}
