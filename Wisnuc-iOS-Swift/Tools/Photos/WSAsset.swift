//
//  WSAsset.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/7/5.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Photos

enum WSAssetType{
    case WSAssetTypeImage
    case WSAssetTypeGIF
    case WSAssetTypeLivePhoto
    case WSAssetTypeVideo
    case WSAssetTypeAudio
    case WSAssetTypeNetImage
    case WSAssetTypeNetVideo
    case WSAssetTypeUnknown
}

class WSAsset: NSObject {
    //asset对象
    var asset:PHAsset?
    
    var assetLocalIdentifier:String?
    //asset类型
    var type:WSAssetType?
    //视频时长
    var duration:String?
    //是否被选择
    var selected:Bool?
    
    //网络/本地 图片url
    var url:URL?
    
    var createDateB:Date?
    
    //图片
    var image:UIImage?
    
    var digest:String?
    
    var indexPath:IndexPath?
    
}
