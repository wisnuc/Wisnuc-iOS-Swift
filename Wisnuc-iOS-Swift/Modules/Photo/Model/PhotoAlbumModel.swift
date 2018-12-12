//
//  PhotoAlbumModel.swift
//  Wisnuc-iOS-Swift
//
//  Created by liupeng on 2018/9/23.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import HandyJSON
enum PhotoAlbumType:String,HandyJSONEnum{
    case collecion
    case my
}

enum PhotoAlbumCollecionType:String,HandyJSONEnum{
    case normal
    case backup
}

class PhotoAlbumModel:HandyJSON{
    var type:PhotoAlbumType?
    var detailType:PhotoAlbumCollecionType?
    var name:String?
    var describe:String?
    var drive:String?
    var coverThumbnilhash:String?
    var coverThumbnilAsset:PHAsset?
    var dataSource:[WSAsset]?
    var count:Int?
    required init() {
        
    }
}
