//
//  PhotoAlbumModel.swift
//  Wisnuc-iOS-Swift
//
//  Created by liupeng on 2018/9/23.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

enum PhotoAlbumType:String{
    case collecion
    case my
}

enum PhotoAlbumCollecionType:String{
    case allPhoto
    case video
    case backup
}

class PhotoAlbumModel:NSObject{
    var type:PhotoAlbumType?
    var detailType:PhotoAlbumCollecionType?
    var name:String?
    var describe:String?
    var drive:String?
    var coverThumbnilhash:String?
    var coverThumbnilAsset:PHAsset?
    var dataSource:[WSAsset]?
    var netDataSource:[NetAsset]?
    var count:Int?
    
    override init() {
        super.init()
    }
//    required init() {
//
//    }
}
