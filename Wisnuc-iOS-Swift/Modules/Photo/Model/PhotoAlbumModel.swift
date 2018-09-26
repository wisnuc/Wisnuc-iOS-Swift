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

class PhotoAlbumModel:HandyJSON{
    var type:PhotoAlbumType?
    var name:String?
    var describe:String?
    var dataSource:[WSAsset]?
    required init() {
        
    }
}
