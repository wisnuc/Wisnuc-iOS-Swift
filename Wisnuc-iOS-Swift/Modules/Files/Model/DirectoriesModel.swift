//
//  DirectoriesModel.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/6/4.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation

struct DirectoriesModel:Decodable{
    var uuid:String?
    var name:String?
    var parent:String?
    var mtime:UInt64?
    var tag:String?
    var type:String?
}
