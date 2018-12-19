//
//  ImageAsyncTask.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/12/17.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit
import Kingfisher

class ImageAsyncTask: NSObject {
    var taskObjectPool: [AnyHashable] = []
    var taskObjectDictionary: [AnyHashable : Any] = [:]
    
    struct Static
    {
        static var instance: ImageAsyncTask?
    }
    
    class var sharedInstance: ImageAsyncTask
    {
        if Static.instance == nil
        {
            Static.instance = ImageAsyncTask()
        }
        
        return Static.instance!
    }
    
    func dispose()
    {
        ImageAsyncTask.Static.instance = nil
        print("Disposed Singleton instance")
    }
  
    func add(_ aObject: ImageAsyncTaskObject?) -> Bool {
        guard let aObject = aObject else {
            return false
        }
        taskArray.append(aObject)
        return true
    }
    func remove(_ aObject: ImageAsyncTaskObject?) {
        taskArray.removeAll { (objcet) -> Bool in
            return objcet.indexPath == aObject?.indexPath
        }
    }
    private(set) var taskArray: [ImageAsyncTaskObject] = []
}

class ImageAsyncTaskObject: NSObject {
    weak var taskDelegate: ImageAsyncTaskObjectDelegate?
    var imageURLString = ""
    private(set) var image: UIImage?
    var indexPath: IndexPath?
    lazy var imageManager = PHCachingImageManager.init()
    lazy var imageRequestOptions: PHImageRequestOptions = {
        let option = PHImageRequestOptions.init()
        
        option.resizeMode = PHImageRequestOptionsResizeMode.fast//控制照片尺寸
        option.deliveryMode = PHImageRequestOptionsDeliveryMode.opportunistic //控制照片质量
        option.isNetworkAccessAllowed = true
        option.version = PHImageRequestOptionsVersion.current
        return option
    }()
    //初始化的时候会自动将 ImageAsyncTaskObject 加入 ImageAsyncTask里面
    //完成下载后，ImageAsyncTaskObject 会自动从 ImageAsyncTask里面移除
//    init(imageURLString aImageURLString: String?) {
//    }
//    class func create(withImageURLString aImageURLString: String?, delegate: ImageAsyncTaskObjectDelegate?) -> Any? {
//    }
//    class func create(withImageURLString aImageURLString: String?) -> Any? {
//    }
    
    class func setCoverImage(model:WSAsset,size:CGSize? = nil,indexPath:IndexPath,delegate: ImageAsyncTaskObjectDelegate?){
        let imageAsyncTaskObjec = ImageAsyncTaskObject.init()
        imageAsyncTaskObjec.taskDelegate = delegate
        imageAsyncTaskObjec.indexPath = indexPath
        let rsize = size != nil ? size! : CGSize.init(width: 200, height: 200)
        if let asset = model.asset{
            imageAsyncTaskObjec.loadLocalCover(asset,rsize)
        }
        
        if let netAsset = model as? NetAsset{
            if let hash = netAsset.fmhash{
            imageAsyncTaskObjec.loadNetCover(hash,rsize)
            }
        }
    }
    
    class func setCoverImage(indexPath:IndexPath,delegate: ImageAsyncTaskObjectDelegate?,hash:String? = nil,asset:PHAsset? = nil){
        let imageAsyncTaskObjec = ImageAsyncTaskObject.init()
        imageAsyncTaskObjec.taskDelegate = delegate
        imageAsyncTaskObjec.indexPath = indexPath
        let size = CGSize.init(width: 200, height: 200)
        if let hash = hash{
            imageAsyncTaskObjec.loadNetCover(hash,size)
            return
        }
        
        if let asset = asset{
            imageAsyncTaskObjec.loadLocalCover(asset,size)
            return
        }
        _ = ImageAsyncTask.sharedInstance.add(imageAsyncTaskObjec)
    }
    
    
    func loadLocalCover(_ asset:PHAsset,_ size:CGSize){
//        self.imageView.image =  UIImage.init(color: UIColor.black.withAlphaComponent(0.04))
        let contentMode = PHImageContentMode.default
        self.imageManager.startCachingImages(for: [asset], targetSize: size, contentMode: contentMode, options:self.imageRequestOptions)
        _ = self.imageManager.requestImage(for: asset, targetSize: size, contentMode: contentMode, options: self.imageRequestOptions, resultHandler: { (image, info) in
            self.image = image
            self.taskDelegate?.imageAsyncTaskObjectDidFinishAsyncTask(self)
            ImageAsyncTask.sharedInstance.remove(self)
        })
    }
    
    func loadNetCover(_ hash:String,_ size:CGSize){
//        self.imageView.image =  UIImage.init(color: UIColor.black.withAlphaComponent(0.04))
        if let requestUrl =  PhotoHelper.requestImageUrl(size:size,hash:hash){
            ImageCache.default.retrieveImage(forKey: requestUrl.absoluteString, options: nil) {
                image, cacheType in
                if let image = image {
                    self.image = image
                    self.taskDelegate?.imageAsyncTaskObjectDidFinishAsyncTask(self)
                    ImageAsyncTask.sharedInstance.remove(self)
                    print("Get image \(image), cacheType: \(cacheType).")
                    //In this code snippet, the `cacheType` is .disk
                } else {
                    print("Not exist in cache.")
                    _ = AppNetworkService.getThumbnail(hash: hash, size:size) { (error, image,reqUrl)  in
                        if let image =  image, let url = reqUrl {
                            ImageCache.default.store(image,
                                                     original: nil,
                                                     forKey: url.absoluteString,
                                                     toDisk: true)
                            self.image = image
                            self.taskDelegate?.imageAsyncTaskObjectDidFinishAsyncTask(self)
                            ImageAsyncTask.sharedInstance.remove(self)
                        }
                    }
                }
            }
        }
    }
}


@objc protocol ImageAsyncTaskObjectDelegate: NSObjectProtocol {
    @objc func imageAsyncTaskObjectDidFinishAsyncTask(_ aTaskObject: ImageAsyncTaskObject?)
}


