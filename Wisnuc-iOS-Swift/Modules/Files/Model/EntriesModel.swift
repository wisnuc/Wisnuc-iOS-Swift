//
//  EntriesModel.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/6/4.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation
//import HandyJSON

public struct EntriesModel:Codable {
    var name:String?
    var type:String?
    var uuid:String?
    var hash:String?
    var magic:AnyCodable?
    var mtime:Int64?
    var size:Int64?
    var driveUUID:String?
    var parentUUID:String?
    var metadata:Metadata?
    var pdir:String?
    var place:Int?
    var bname:String?
    var bctime:Int64?
    var bmtime:Int64?
    var otime:Int64?
    var indexPath:IndexPath?
    var backupRoot = false
    
    
    enum CodingKeys : String, CodingKey {
        case name
        case type
        case uuid
        case hash
        case magic
        case mtime
        case size
        case metadata
        case pdir
        case place
        case bname
        case bctime
        case bmtime
        case otime
    }
//    required public init() {}
//
//    public func mapping(mapper: HelpingMapper) {
//        mapper >>> self.driveUUID
//        mapper >>> self.parentUUID
//    }
//
//    public func didFinishMapping() {
////        print("you can fill some observing logic here")
//        if self.size == nil {
//            self.size = 0
//        }
//    }
}


struct Metadata: Codable {
    var w: Float?
    var h: Float?
    var type: String?
    var orient: Int?
    var make: String?
    var model: String?
    var date: String?
    var datec:String?
    var localPath:String?
    var disabled:Bool?
    var status:String?
    var lastBackupTime:Int64?
 
//    required init() {}
}
