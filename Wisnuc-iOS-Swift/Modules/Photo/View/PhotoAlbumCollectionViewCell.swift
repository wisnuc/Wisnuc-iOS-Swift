//
//  PhotoAlbumCollectionViewCell.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/9/20.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoAlbumCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    var indexPath:IndexPath?
    
   
    override func awakeFromNib() {
        super.awakeFromNib()
        self.nameLabel.textColor = DarkGrayColor
        self.countLabel.textColor = LightGrayColor
        self.imageView.backgroundColor = UIColor.colorFromRGB(rgbValue:0xf5f5f5)
        self.imageView.layer.cornerRadius = 4
        self.imageView.contentMode = UIViewContentMode.scaleAspectFill
        self.imageView.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
        self.imageView.image =  UIImage.init(color: UIColor.black.withAlphaComponent(0.04))
    }
    
    func setCoverImage(indexPath:IndexPath,hash:String? = nil,asset:PHAsset? = nil){
       

        let size = CGSize.init(width: 200, height: 200)
        if let hash = hash{
            loadNetCover(hash,size,indexPath)
            return
        }
        
        if let asset = asset{
            loadLocalCover(asset,size,indexPath)
            return
        }
    }
    
    func loadLocalCover(_ asset:PHAsset,_ size:CGSize,_ indexPath:IndexPath){
        self.imageView.image =  UIImage.init(color: UIColor.black.withAlphaComponent(0.04))
        let contentMode = PHImageContentMode.default
        self.imageManager.startCachingImages(for: [asset], targetSize: size, contentMode: contentMode, options:self.imageRequestOptions)
        _ = self.imageManager.requestImage(for: asset, targetSize: size, contentMode: contentMode, options: self.imageRequestOptions, resultHandler: { [weak self] (image, info) in
            if indexPath != self?.indexPath{
                return
            }
            self?.imageView.image = image
        })
    }
    
    func loadNetCover(_ hash:String,_ size:CGSize,_ indexPath:IndexPath){
        self.imageView.image =  UIImage.init(color: UIColor.black.withAlphaComponent(0.04))
        if let requestUrl =  PhotoHelper.requestImageUrl(size:size,hash:hash){
            ImageCache.default.retrieveImage(forKey: requestUrl.absoluteString, options: nil) {
                image, cacheType in
                if let image = image {
                    if indexPath != self.indexPath{
                    return
                    }
                    self.imageView.image = image
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
                            if indexPath != self.indexPath{
                                return
                            }
                            self.imageView.image = image
                        }
                    }
                }
            }
        }
    }
    
    lazy var imageManager = PHCachingImageManager.init()
    lazy var imageRequestOptions: PHImageRequestOptions = {
        let option = PHImageRequestOptions.init()
        
        option.resizeMode = PHImageRequestOptionsResizeMode.fast//控制照片尺寸
        option.deliveryMode = PHImageRequestOptionsDeliveryMode.opportunistic //控制照片质量
        option.isNetworkAccessAllowed = true
        option.version = PHImageRequestOptionsVersion.current
        return option
    }()
}
