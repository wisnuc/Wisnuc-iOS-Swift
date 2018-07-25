//
//  FilesModel.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/8.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
//import HandyJSON

struct FilesModel:Codable  {
    var entries:[EntriesModel]?
    var path:[pathModel]?
//    required init() {
//
//    }
    
}
struct pathModel:Codable {
    var name:String?
    var mtime:Int64?
    var uuid:String?
}


