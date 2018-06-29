//
//  FilesTasksModel.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/6/29.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation
import HandyJSON

class FilesTasksModel: HandyJSON {
    var dst:DstSrcModel?
    var src:DstSrcModel?
    var entries:NSArray?
    var finished:Bool?
    var nodes:NSArray?
    var stepping:Bool?
    var type:String?
    var uuid:String?
    required init() {
        
    }
}

class DstSrcModel: HandyJSON {
    var dir:String?
    var drive:String?
    required init() {
        
    }
}

