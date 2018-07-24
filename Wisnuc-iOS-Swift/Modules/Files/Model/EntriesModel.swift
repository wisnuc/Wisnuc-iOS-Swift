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
    var name:String? = nil
    var type:String? = nil
    var uuid:String? = nil
    var hash:String? = nil
    var magic:Bool? = nil
    var mtime:UInt64? = nil
    var size:UInt64? = nil
    var driveUUID:String? = nil
    var parentUUID:String? = nil
    var metadata:Metadata? = nil
    
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
    var w: Int? = nil
    var h: Int? = nil
    var type: String? = nil
    var orient: Int? = nil
    
//    required init() {}
}
