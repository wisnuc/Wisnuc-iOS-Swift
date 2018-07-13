//
//  PHAssetExtension.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/7/6.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation
import Photos
extension PHAsset{
   func getWSAssetType() -> WSAssetType{
    return self.isGif() ? WSAssetType.GIF
    : self.isLivePhoto() ? WSAssetType.LivePhoto
    : self.isVideo() ? WSAssetType.Video
    : self.isAudio() ? WSAssetType.Audio
    : self.isImage() ? WSAssetType.Image
    : WSAssetType.Unknown
    }
    
    func getDurationString() -> String? {
        if self.mediaType != PHAssetMediaType.video {return nil}
    
        let duration:Int64 = Int64(round(self.duration))
    
        if duration < 60{
            return String.init(format: "00:%02ld", duration)
        }else if duration < 3600 {
            return String.init(format: "%02ld:%02ld",  duration / 60, duration % 60)
        }
    
        let h:Int64 = duration / 3600;
        let m:Int64 = (duration % 3600) / 60
        let s:Int64 = duration % 60
        return String.init(format: "%02ld:%02ld:%02ld", h, m,s)
    }
    
    func isGif() -> Bool{
     return (self.mediaType == PHAssetMediaType.image) && (self.value(forKey: "filename") as! NSString).hasSuffix("GIF")
    }
    
    func isLivePhoto()-> Bool{
        if #available(iOS 9.1, *) {
            return (self.mediaType == PHAssetMediaType.image) && (self.mediaSubtypes == PHAssetMediaSubtype.photoLive || self.mediaSubtypes.rawValue == 10)
        } else {
            return false
        }
    }
    
    func isVideo() -> Bool{
    return self.mediaType == PHAssetMediaType.video
    }
    
    func isAudio() -> Bool{
    return self.mediaType == PHAssetMediaType.audio
    }
    
    func isImage() -> Bool{
    return (self.mediaType == PHAssetMediaType.image) && !self.isGif() && !self.isLivePhoto()
    }
    
    func isLocal() -> Bool{
        let option = PHImageRequestOptions.init()
        option.isNetworkAccessAllowed = false
        option.isSynchronous = true
        
        var isInLocalAblum = true
        PHCachingImageManager.default().requestImageData(for: self, options: option) { (imageData, dataUTI, orientation, info) in
            isInLocalAblum = imageData != nil ? true : false
        }
        return isInLocalAblum;
    }

}
