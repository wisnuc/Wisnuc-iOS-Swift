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

class WSAsset: NSObject,NSCopying{
   
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
    
    //图片
    var image:UIImage?
    
    var digest:String?
    
    var indexPath:IndexPath?
    
    var cellIndexPath:IndexPath?
    
    var createDate:Date?
    
    override init() {
        super.init()
    }
    
    
    init(asset:PHAsset?,type:WSAssetType?,duration:String?) {
        super.init()
        self.asset = asset
        self.type = type
        self.duration = duration
        self.selected = false
        self.createDate = self.createDateB
        if (asset) != nil {
            self.assetLocalIdentifier = asset?.localIdentifier
        }
    }
    
    func copy(with zone: NSZone? = nil) -> Any {

        let theCopyObj = Swift.type(of: self).assetModel(asset: asset, type: type, duration: duration)
       return theCopyObj
    }
    
    
    class func assetModel(asset:PHAsset?,type:WSAssetType?,duration:String?)->WSAsset{
        let model = WSAsset.init()
        model.asset = asset
        model.type = type
        model.duration = duration
        model.selected = false
        model.createDate = model.createDateB
        if (asset) != nil {
            model.assetLocalIdentifier = asset?.localIdentifier;
        }
        return model
    }
    
    
    lazy var createDateB: Date? = {
        return self.asset?.creationDate
        }()
}

@objc class WSAssetList: NSObject {
    var title:String?
    var count:Int?
    var isCameraRoll:Bool?
    var result:PHFetchResult<PHAsset>?
    var models:Array<WSAsset>?
}
