//
//  EntriesModel.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/6/4.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation
import HandyJSON

class EntriesModel:HandyJSON {
    var name:String?
    var type:String?
    var uuid:String?
    var hash:String?
    var magic:NSNumber?
    var mtime:UInt64?
    var size:UInt64?
    var driveUUID:String?
    var parentUUID:String?
    
    required init() {}
    
    func mapping(mapper: HelpingMapper) {
        mapper >>> self.driveUUID
        mapper >>> self.parentUUID
    }
    
    func didFinishMapping() {
//        print("you can fill some observing logic here")
        if self.size == nil {
            self.size = 0
        }
    }
}
