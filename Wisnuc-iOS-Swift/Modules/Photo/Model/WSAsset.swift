//
//  WSAsset.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/7/5.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Photos
import Kingfisher

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
    //是否被选择
    var selected:Bool?
    
    //网络/本地 图片url
    var url:URL?
    
    //图片
    var image:UIImage?
   
    
    var digest:String?
    
    var indexPath:IndexPath?
    
    var cellIndexPath:IndexPath?
    
    
    override init() {
        super.init()
//        createDateB = createDate
    }
    
    
    
    init(asset:PHAsset?,type:WSAssetType?,duration:String?) {
        super.init()
        self.asset = asset
        self.type = type
        self.duration = duration
        self.selected = false
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
        if (asset) != nil {
            model.assetLocalIdentifier = asset?.localIdentifier;
        }
        return model
    }
    
    var createDate:Date?{
        get{
            if self is NetAsset{
                let date = (self as? NetAsset)?.netDate
                return date
            }else{
                guard let creationDate = self.asset?.creationDate else{
                    return  Date.init(timeIntervalSinceNow: 0)
                }
    
                return creationDate
            }
        }
        set(newValue){
            
        }
    
    }
    
    var duration:String?
    
    
    var createDateB:Date?
    
}

//extension WSAsset {
//    static func ==(m1:WSAsset,m2:WSAsset) -> Bool{
//        return m1.asset == m2.asset && m1.type == m2.type
//    }
//    override var hash: Int{//hashValue的实现
//        return self.duration.hashValue ^ self.createDateB.hashValue
//    }
//}


@objc class WSAssetList: NSObject {
    var title:String?
    var count:Int?
    var isCameraRoll:Bool?
    var result:PHFetchResult<PHAsset>?
    var models:Array<WSAsset>?
}
