//
//  EntriesModel.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/6/4.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation
import HandyJSON

public class EntriesModel:HandyJSON {
    var name:String?
    var type:String?
    var uuid:String?
    var hash:String?
    var magic:NSNumber?
    var mtime:UInt64?
    var size:UInt64?
    var driveUUID:String?
    var parentUUID:String?
    var metadata:Metadata?
    
    required public init() {}
    
    public func mapping(mapper: HelpingMapper) {
        mapper >>> self.driveUUID
        mapper >>> self.parentUUID
    }
    
    public func didFinishMapping() {
//        print("you can fill some observing logic here")
        if self.size == nil {
            self.size = 0
        }
    }
}


class Metadata: HandyJSON {
    var w: NSNumber?
    var h: NSNumber?
    var type: String?
    var orient: NSNumber?
    
    required init() {}
}
