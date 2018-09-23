//
//  PhotoAlbumModel.swift
//  Wisnuc-iOS-Swift
//
//  Created by liupeng on 2018/9/23.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
enum PhotoAlbumType:String,Codable{
    case collecion
    case my
}

struct PhotoAlbumModel: Codable {
    var type:PhotoAlbumType?
    var name:String?
}
