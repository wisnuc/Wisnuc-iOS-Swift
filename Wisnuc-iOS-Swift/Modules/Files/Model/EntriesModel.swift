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
    var mtime:UInt64?
    var size:Int64?
    var driveUUID:String?
    var parentUUID:String?
    var metadata:Metadata?
    var pdir:String?
    var place:Int?
    
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
    var w: Int?
    var h: Int?
    var type: String?
    var orient: Int?
    
//    required init() {}
}
