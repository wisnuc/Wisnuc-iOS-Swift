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
    
    func getTmpPath() -> String {
        let  mgr = FileManager.default
        let tmp = JY_TMP_Folder
        if !(mgr.fileExists(atPath: tmp!)){
            do {
                try  mgr.createDirectory(atPath: tmp!, withIntermediateDirectories: true, attributes: nil)
            } catch  {
                
            }
        }
        return tmp!
    }
    
    func getSha256(callback:(_ error:Error, _ sha256:String)->()) ->PHImageRequestID{
//    return [self getFile:^(NSError *error, NSString *filePath) {
//    if(error) return callback(error, NULL);
//    NSError * err;
//    NSDate * beforeDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&err] objectForKey:NSFileCreationDate];
//    if(err) return callback(err, NULL);
//    NSString * hashStr = [FileHash sha256HashOfFileAtPath:filePath];
//    NSDate * afterDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&err] objectForKey:NSFileCreationDate];
//    if(err) return callback(err, NULL);
//    // time  mismatch
//    if(![beforeDate isEqualToDate:afterDate]) return callback([NSError errorWithDomain:@"CreateTime MISMATCH" code:667 userInfo:nil], NULL);
//    if(!hashStr || !hashStr.length) return callback([NSError errorWithDomain:@"FILE HASH ERROR" code:666 userInfo:nil], NULL);
//    @try {
//    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
//    } @catch (NSException *exception) {
//    NSLog(@"%@", exception);
//    }
//    return callback(nil, hashStr);
//    }];
    }
    
    func getFile(callBack:@escaping (_ error:Error?, _ filePath:String?)->()) -> PHImageRequestID {
        let fileName = "tmp_\(Date.init().timeIntervalSince1970)_\(UIDevice.current.identifierForVendor!.uuidString)"
        var filePath = self.getTmpPath().appendingPathComponent(fileName)
        //TODO: do something for livephoto
        
        if(!self.isVideo()) {
            return PHPhotoLibrary.requestHighImageDataSync(for: self, completion: { (error, imageData, info) in
                if(imageData != nil) {
                    if( UIDevice.current.systemVersion.floatValue < 9.0 && info!["PHImageFileURLKey"] != nil){
                        filePath = self.getTmpPath().appendingPathComponent("PHImageFileURLKey").lastPathComponent
                        do {
                            try imageData?.write(to: URL(fileURLWithPath: filePath), options: .atomic)
                        } catch {
                            print(error)
                        }
                        return callBack(nil, filePath)
                    }else{
                        return callBack(error, nil);
                    }
                }
            })
        } else { // video
            //    // less then iOS9
            if(UIDevice.current.systemVersion.floatValue < 9.0) {
                let opt = PHVideoRequestOptions.init()
                opt.isNetworkAccessAllowed = false// TODO ??
                opt.deliveryMode = PHVideoRequestOptionsDeliveryMode.highQualityFormat
                return PHImageManager.default().requestExportSession(forVideo: self, options: opt, exportPreset: AVAssetExportPresetHighestQuality, resultHandler: { (exportSession, info) in
                    if exportSession == nil{
                    return callBack(BaseError(localizedDescription: ErrorLocalizedDescription.Asset.AssetNotFound, code:ErrorCode.Asset.AssetNotFound), nil)
                    }else{
                        //输出URL
                        exportSession?.outputURL = URL.init(fileURLWithPath: filePath)
                        //优化网络
                        exportSession?.shouldOptimizeForNetworkUse = true
                        //                //转换后的格式
                        //                exportSession.outputFileType = AVFileTypeMPEG4;
                        //异步导出
                        exportSession?.exportAsynchronously {
                            if exportSession?.error != nil {
                                return callBack(exportSession!.error, nil);
                            }
                            if(exportSession?.status == AVAssetExportSessionStatus.failed) {
                             return callBack(BaseError(localizedDescription: ErrorLocalizedDescription.Asset.AVAssetExportSessionStatusFailed, code:ErrorCode.Asset.AVAssetExportSessionStatusFailed), nil)
                            }
                            if(exportSession?.status == AVAssetExportSessionStatus.cancelled) {
                             return callBack(BaseError(localizedDescription: ErrorLocalizedDescription.Asset.AVAssetExportSessionStatusCancelled, code:ErrorCode.Asset.AVAssetExportSessionStatusCancelled), nil)
                            }
                            // 如果导出的状态为完成
                            if (exportSession?.status == AVAssetExportSessionStatus.completed) {
                            //                        [self saveVideo:[NSURL fileURLWithPath:path]];
//                            prin("压缩完毕,压缩后大小 %f MB",[self fileSize:[NSURL fileURLWithPath:filePath]]);
                            return callBack(nil, filePath)
                            }else{
//                            NSLog("当前压缩进度:%f",exportSession.progress);
                            }
                            }
                    }
                })
                
                //    return false
            }else{
                PHPhotoLibrary.requestVideoPath(from: self, filePath: filePath) { (error, filePath) in
                    if error != nil {
                        return callBack(error, nil)
                    }
                    return callBack(nil, filePath)
                }
                return 0
            }
        }
        return 0
    }
}
