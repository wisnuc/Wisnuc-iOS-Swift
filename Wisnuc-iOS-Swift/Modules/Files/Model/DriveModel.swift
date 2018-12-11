
//
//  DriveModel.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/6/1.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation
import HandyJSON
enum DriveClientModelState:String {
    case Working
    case Idle
}

enum BackupPlatformType:String {
    case WinPC = "Win-PC"
    case MacPC = "Mac-PC"
    case LinuxPC = "Linux-PC"
    case AndroidMobile = "Android-Mobile"
    case iOSMobile = "iOS-Mobile"
}

struct DriveModel:HandyJSON {
    var owner:String?
    var uuid:String?
    var tag:String?
    var type:String?
    var label:String?
    var writelist:Array<Any>?
    var readlist:Array<Any>?
    var privacy:Bool?
    var isDeleted:Bool?
    var smb:Bool?
    var ctime:Int64?
    var mtime:Int64?
    var client:DriveClientModel?
    var fileTotalSize:Int64?
}

struct DriveClientModel:HandyJSON {
    var id: String?
    var type:String?
    var lastBackupTime:Int64?
    var disabled:Bool?
    var status:String?
}
