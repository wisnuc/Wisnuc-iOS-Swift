//
//  AssetService.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/7/6.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Photos

class AssetService: NSObject,ServiceProtocol,PHPhotoLibraryChangeObserver {
    var userAuth:Bool?
    var allAssets:Array<WSAsset>?
//    {
//        get{
//            if allAssets == nil && userAuth! {
//                let all:NSMutableArray = NSMutableArray.init(capacity: 0)
////                [PHPhotoLibrary getAllAsset:^(PHFetchResult<PHAsset *> *result, NSArray<PHAsset *> *assets) {
////                    [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
////                    JYAssetType type = [obj getJYAssetType];
////                    NSString *duration = [obj getDurationString];
////                    [all addObject:[JYAsset modelWithAsset:obj type:type duration:duration]];
////                    }];
////                    _lastResult = result;
////                    }];
////                _allAssets = all;
//            }
////            return _allAssets;
//        }
//        set{
//
//        }
//    }
    
    
    
    deinit {
        
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
    }
    
    func abort() {
        
    }
    

}
