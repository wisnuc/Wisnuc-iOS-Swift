//
//  FilesStatsModel.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/26.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import Foundation

struct FilesStatsModel:Codable {
    var fileCount:Int?
    var dirCount:Int?
    var fileTotalSize:Int64?
}
