//
//  StatsModel.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/20.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import Foundation
//"files": {
//    "image": {
//        "count": 1234,
//        "totalSize": 12345678
//    },
//    "video": {
//        "count": 1234,
//        "totalSize": 12345678
//    },
//    "audio": {
//        "count": 1234,
//        "totalSize": 12345678
//    },
//    "document": {
//        "count": 1234,
//        "totalSize": 12345678
//    }
//},
//"space": {
//    "used": 12345678,
//    "total": 8888888888
//}
struct StatsModel:Codable {
    var image:FilesTypeStatsModel?
    var video:FilesTypeStatsModel?
    var audio:FilesTypeStatsModel?
    var document:FilesTypeStatsModel?
    var others:FilesTypeStatsModel?
}

//struct FilesStatsModel:Codable {
//    var image:FilesTypeStatsModel?
//    var video:FilesTypeStatsModel?
//    var audio:FilesTypeStatsModel?
//    var document:FilesTypeStatsModel?
//}

struct FilesTypeStatsModel:Codable {
    var count:Int64?
    var totalSize:Int64?
}

struct SpaceStatsModel:Codable {
    var used:String?
    var total:Int64?
}
