//
//  DeviceBLEModel.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/9/13.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

enum DeviceBLEModelType:Int {
    case NeedConfig
    case Done
//    case
//    case NeedConfig
//    case NeedConfigWithData
//    case NoDisk
//    case Error
//    
//    var value: Int {
//        switch self {
//        case .Default: return 0
//        case .NoData: return 0x00
//        case .Done: return  0x01
//        case .NeedConfig: return 0x02
//        case .NeedConfigWithData: return 0x03
//        case .NoDisk : return 0x04
//        case .Error : return 0x05
//        }
//    }
}

//enum DeviceBLEModelState:Int{
////    0x00: 首配未开始
////    0x01: 已配置完成
////    0x02: 设置与连接wifi中
////    0x03: 连接云服务中
////    0x04: 要求用户按下按键
////    0x05: 配置失败

//}

import Foundation
import CoreBluetooth

class DeviceBLEModel:NSObject{
    var name:String?
    var stationId:String?
    var peripheral:CBPeripheral?
    var type:DeviceBLEModelType?
    var stationStatusCharacteristic:CBCharacteristic?
    var spsDataCharacteristic:CBCharacteristic?
//    var state:DeviceBLEModelState?
}

