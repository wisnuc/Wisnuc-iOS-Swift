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
    case Image
    case GIF
    case LivePhoto
    case Video
    case Audio
    case NetImage
    case NetVideo
    case Unknown
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
    
   
    class func assetModel(asset:PHAsset?,type:WSAssetType?,duration:String?)->WSAsset{
        let model = WSAsset.init()
        model.asset = asset
        model.type = type
        model.duration = duration
        model.selected = false
        if (asset) != nil {
            model.assetLocalIdentifier = asset?.localIdentifier;
        }
        return model
    }
}

@objc class WSAssetList: NSObject {
    var title:String?
    var count:Int?
    var isCameraRoll:Bool?
    var result:PHFetchResult<PHAsset>?
    var models:Array<WSAsset>?
}
