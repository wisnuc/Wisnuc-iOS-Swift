//
//  FilesTasksModel.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/6/29.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation
import HandyJSON

enum FilesTasksType:String,HandyJSONEnum{
    case copy
    case move
    case icopy
    case imove
    case ecopy
    case emove
    case ncopy
    case nmove
}
enum FilesTaskState:String,HandyJSONEnum{
    case Conflict
    case Working
    case Finish
    case Failed
    case Preparing
    case Parent
    
}

enum FilesTaskErrorCode:String,HandyJSONEnum{
    case EEXIST
}

enum FilesTaskErrorXCode:String,HandyJSONEnum{
    case EISDIR
}

class FilesTasksModel: HandyJSON {
    var dst:DstSrcModel?
    var src:DstSrcModel?
    var entries:NSArray?
    var finished:Bool?
    var nodes:Array<NodesModel>?
    var stepping:Bool?
    var type:FilesTasksType?
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

class NodesSrcModel: HandyJSON {
    var name:String?
    var uuid:String?
    required init() {
    }
}

class NodesErrorModel: HandyJSON {
    var code:FilesTaskErrorCode?
    var xcode:FilesTaskErrorXCode?
    required init() {
    }
}

class NodesModel: HandyJSON {
    var src:NodesSrcModel?
    var parent:String?
    var state:FilesTaskState?
    var error:NodesErrorModel?
    required init() {
    }
}

