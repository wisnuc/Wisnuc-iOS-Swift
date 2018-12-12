//
//  PHPhotoLibrary+JYEXT.m
//  Photos
//
//  Created by JackYang on 2017/9/24.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "PHPhotoLibrary+JYEXT.h"

#define AlbumName [[NSBundle mainBundle].infoDictionary valueForKey:(__bridge NSString *)kCFBundleNameKey]

/**
 PHAssetCollectionSubtypeAlbumRegular         = 2,///
 PHAssetCollectionSubtypeAlbumSyncedEvent     = 3,////
 PHAssetCollectionSubtypeAlbumSyncedFaces     = 4,////面孔
 PHAssetCollectionSubtypeAlbumSyncedAlbum     = 5,////
 PHAssetCollectionSubtypeAlbumImported        = 6,////
 
 // PHAssetCollectionTypeAlbum shared subtypes
 PHAssetCollectionSubtypeAlbumMyPhotoStream   = 100,///
 PHAssetCollectionSubtypeAlbumCloudShared     = 101,///
 
 // PHAssetCollectionTypeSmartAlbum subtypes        //// collection.localizedTitle
 PHAssetCollectionSubtypeSmartAlbumGeneric    = 200,///
 PHAssetCollectionSubtypeSmartAlbumPanoramas  = 201,///全景照片
 PHAssetCollectionSubtypeSmartAlbumVideos     = 202,///视频
 PHAssetCollectionSubtypeSmartAlbumFavorites  = 203,///个人收藏
 PHAssetCollectionSubtypeSmartAlbumTimelapses = 204,///延时摄影
 PHAssetCollectionSubtypeSmartAlbumAllHidden  = 205,/// 已隐藏
 PHAssetCollectionSubtypeSmartAlbumRecentlyAdded = 206,///最近添加
 PHAssetCollectionSubtypeSmartAlbumBursts     = 207,///连拍快照
 PHAssetCollectionSubtypeSmartAlbumSlomoVideos = 208,///慢动作
 PHAssetCollectionSubtypeSmartAlbumUserLibrary = 209,///所有照片
 PHAssetCollectionSubtypeSmartAlbumSelfPortraits NS_AVAILABLE_IOS(9_0) = 210,///自拍
 PHAssetCollectionSubtypeSmartAlbumScreenshots NS_AVAILABLE_IOS(9_0) = 211,///屏幕快照
 = 1000000201///最近删除知道值为（1000000201）但没找到对应的TypedefName
 // Used for fetching, if you don't care about the exact subtype
 PHAssetCollectionSubtypeAny = NSIntegerMax /////所有类型
 */


@implementation PHPhotoLibrary (JYEXT)

/*
 * data to animation image
 */

+ (UIImage *)animatedGIFWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    size_t count = CGImageSourceGetCount(source);
    
    UIImage *animatedImage;
    
    if (count <= 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
    } else {
        NSMutableArray *images = [NSMutableArray array];
        
        NSTimeInterval duration = 0.0f;
        
        for (size_t i = 0; i < count; i++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            
            duration += [self sd_frameDurationAtIndex:i source:source];
            
            [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
            
            CGImageRelease(image);
        }
        
        if (!duration) {
            duration = (1.0f / 10.0f) * count;
        }
        
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }
    
    CFRelease(source);
    
    return animatedImage;
}


+ (float)sd_frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTimeUnclampedProp != nil) {
        frameDuration = [delayTimeUnclampedProp floatValue];
    } else {
        
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTimeProp != nil) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    
    // Many annoying ads specify a 0 duration to make an image flash as quickly as possible.
    // We follow Firefox's behavior and use a duration of 100 ms for any frames that specify
    // a duration of <= 10 ms. See <rdar://problem/7689300> and <http://webkit.org/b/36082>
    // for more information.
    
    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }
    
    CFRelease(cfFrameProperties);
    return frameDuration;
}

/*************************/

// save image
+ (void)saveImageToAlbum:(UIImage *)image completion:(void(^)(BOOL, PHAsset *))completion
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusDenied) {
        if (completion) completion(NO, nil);
    } else if (status == PHAuthorizationStatusRestricted) {
        if (completion) completion(NO, nil);
    } else {
        __block PHObjectPlaceholder *placeholderAsset=nil;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *newAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            placeholderAsset = newAssetRequest.placeholderForCreatedAsset;
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (!success) {
                if (completion) completion(NO, nil);
                return;
            }
            PHAsset *asset = [self getAssetFromlocalIdentifier:placeholderAsset.localIdentifier];
            PHAssetCollection *desCollection = [self getDestinationCollection];
            
            if (!desCollection) completion(NO, nil);
            if (!asset) return completion(NO, nil);
            
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [[PHAssetCollectionChangeRequest changeRequestForAssetCollection:desCollection] addAssets:@[asset]];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (completion) completion(success, asset);
            }];
        }];
    }
}

//save livephoto
+ (void)saveLivePhotoToAlbumWithPhoto:(NSURL *)photoURL video:(NSURL *)videoURL completion:(void (^)(BOOL, PHAsset *))completion {
    __block PHObjectPlaceholder *placeholderAsset=nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
        [request addResourceWithType:PHAssetResourceTypePhoto
                             fileURL:photoURL
                             options:nil];
        if (@available(iOS 9.1, *)) {
            [request addResourceWithType:PHAssetResourceTypePairedVideo
                                 fileURL:videoURL
                                 options:nil];
        } else {
            // Fallback on earlier versions
        }
        placeholderAsset = request.placeholderForCreatedAsset;
    } completionHandler:^(BOOL success,
                          NSError * _Nullable error) {
        if (!success) {
            if (completion) completion(NO, nil);
            return;
        }
        PHAsset *asset = [self getAssetFromlocalIdentifier:placeholderAsset.localIdentifier];
        PHAssetCollection *desCollection = [self getDestinationCollection];
        if (!desCollection) completion(NO, nil);
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [[PHAssetCollectionChangeRequest changeRequestForAssetCollection:desCollection] addAssets:@[asset]];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (completion) completion(success, asset);
        }];
    }];
}

// save video
+ (void)saveVideoToAblum:(NSURL *)url completion:(void (^)(BOOL, PHAsset *))completion
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusDenied) {
        if (completion) completion(NO, nil);
    } else if (status == PHAuthorizationStatusRestricted) {
        if (completion) completion(NO, nil);
    } else {
        __block PHObjectPlaceholder *placeholderAsset=nil;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *newAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
            placeholderAsset = newAssetRequest.placeholderForCreatedAsset;
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (!success) {
                if (completion) completion(NO, nil);
                return;
            }
            PHAsset *asset = [self getAssetFromlocalIdentifier:placeholderAsset.localIdentifier];
            PHAssetCollection *desCollection = [self getDestinationCollection];
            if (!desCollection) completion(NO, nil);
            
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [[PHAssetCollectionChangeRequest changeRequestForAssetCollection:desCollection] addAssets:@[asset]];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (completion) completion(success, asset);
            }];
        }];
    }
}

+ (PHAsset *)getAssetFromlocalIdentifier:(NSString *)localIdentifier{
    if(localIdentifier == nil){
        NSLog(@"localId could not be nil");
        return nil;
    }
    PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil];
    if(result.count){
        return result[0];
    }
    return nil;
}

+ (void)getAllAsset:(void(^)(PHFetchResult<PHAsset *> *result, NSArray<PHAsset *> *assets))block {
    NSMutableDictionary * tempDic = [NSMutableDictionary dictionaryWithCapacity:0];
    PHFetchResult<PHAssetCollection *> *collectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    for (PHAssetCollection * c in collectionResult) {
        if(c.assetCollectionSubtype == 100) continue; //屏蔽 我的照片流
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        // 遍历这个相册中的所有图片
        PHFetchResult<PHAsset *> *assetResult = [PHAsset fetchAssetsInAssetCollection:c options:options];
        [assetResult enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [tempDic setObject:obj forKey:obj.localIdentifier];
        }];
    }
    // fix bug ==> itunes sync merge
    PHFetchOptions * option = [[PHFetchOptions alloc]init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    option.includeHiddenAssets = YES;
    PHFetchResult<PHAsset *> * lastresult = [PHAsset fetchAssetsWithOptions:option];
    [lastresult enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [tempDic setObject:obj forKey:obj.localIdentifier];
    }];
    if(block) block(lastresult, [tempDic allValues]);
}



#pragma mark - <  获取相册里的所有图片的PHAsset对象  >
+ (NSArray *)getAllPhotosAssetInAblumCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending
{
    // 存放所有图片对象
    NSMutableArray *assets = [NSMutableArray array];
    
    // 是否按创建时间排序
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
//    option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    
    // 获取所有图片对象
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:option];
    // 遍历
    [result enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        [assets addObject:asset];
    }];
    return assets;
}

//get album(collection)
+ (PHAssetCollection *)getDestinationCollection
{
    // find collection
    PHFetchResult<PHAssetCollection *> *collectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collectionResult) {
        if ([collection.localizedTitle isEqualToString:AlbumName]) {
            return collection;
        }
    }
    //create it
    __block NSString *collectionId = nil;
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        collectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:AlbumName].placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    if (error) {
        NSLog(@"创建相册：%@失败", AlbumName);
        return nil;
    }
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[collectionId] options:nil].lastObject;
}



#pragma mark - fetch image

+ (PHImageRequestID)requestHighImageDataSyncForAsset:(PHAsset *)asset completion:(void (^)(NSError * error, NSData *, NSDictionary *))completion
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
    option.networkAccessAllowed = YES;
    option.version = PHImageRequestOptionsVersionCurrent;
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    option.synchronous = YES;
    return [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && imageData) {
            if (completion) completion(NULL, imageData, info);
        }else{
            // DEBUG
            NSLog(@"%@", info);
            if ([info objectForKey:PHImageErrorKey]) return completion([info objectForKey:PHImageErrorKey], NULL, info);
            else if ([[info objectForKey:PHImageCancelledKey] boolValue]) return completion([NSError errorWithDomain:@"cancled" code:400 userInfo:nil], NULL, info);
            else
                return completion([NSError errorWithDomain:@"no image data" code:400 userInfo:nil], NULL, info);
        }
    }];
}

+ (PHImageRequestID)requestOriginalImageSyncForAsset:(PHAsset *)asset completion:(void (^)(NSError * error, UIImage *, NSDictionary *))completion {
    CGFloat pW = UIScreen.mainScreen.bounds.size.width*UIScreen.mainScreen.scale;
    CGFloat pH = asset.pixelHeight * (pW/asset.pixelWidth);
    CGSize targetSize = CGSizeMake(pW, pH);
    PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
    imageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    CGRect square = CGRectMake(0, 0, asset.pixelWidth, asset.pixelHeight);
    CGRect cropRect = CGRectApplyAffineTransform(square,
                                                 CGAffineTransformMakeScale(1.0 / asset.pixelWidth,
                                                                            1.0 / asset.pixelHeight));
    imageRequestOptions.normalizedCropRect = cropRect;
    imageRequestOptions.synchronous = YES;
    imageRequestOptions.networkAccessAllowed = YES;
    return [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:imageRequestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(nil, result,info);
                }
            });
        }else
            NSLog(@"UNKNOWEN GET IMAGE ERROR !!!");
    }];
}


+ (PHImageRequestID)requestOriginalImageDataForAsset:(PHAsset *)asset completion:(void (^)(NSData *, NSDictionary *))completion
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
    option.networkAccessAllowed = YES;
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    return [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && imageData) {
            if (completion) completion(imageData, info);
        }
    }];
}


+ (PHImageRequestID)requestOriginalImageForAsset:(PHAsset *)asset completion:(void (^)(UIImage *, NSDictionary *))completion
{
    return [self requestImageForAsset:asset size:PHImageManagerMaximumSize resizeMode:PHImageRequestOptionsResizeModeExact completion:completion];
}

+ (PHImageRequestID)requestImageForAsset:(PHAsset *)asset size:(CGSize)size completion:(void (^)(UIImage *, NSDictionary *))completion
{
    return [self requestImageForAsset:asset size:size resizeMode:PHImageRequestOptionsResizeModeFast completion:completion];
}

/*
 resizeMode：对请求的图像怎样缩放。有三种选择：None，默认加载方式；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。
 deliveryMode：图像质量。有三种值：Opportunistic，在速度与质量中均衡；HighQualityFormat，不管花费多长时间，提供高质量图像；FastFormat，以最快速度提供好的质量。
 这个属性只有在 synchronous 为 true 时有效。
 */

/*
 info字典提供请求状态信息:
 PHImageResultIsInCloudKey：图像是否必须从iCloud请求
 PHImageResultIsDegradedKey：当前UIImage是否是低质量的，这个可以实现给用户先显示一个预览图
 PHImageResultRequestIDKey和PHImageCancelledKey：请求ID以及请求是否已经被取消
 PHImageErrorKey：如果没有图像，字典内的错误信息
 */

+ (PHImageRequestID)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *, NSDictionary *))completion
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    
    option.resizeMode = resizeMode;//控制照片尺寸
//        option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;//控制照片质量
    option.networkAccessAllowed = YES;
    
    return [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]&& ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
        if (downloadFinined && completion) {
            completion(image, info);
        }
    }];
}

+ (PHImageRequestID)requestLivePhotoForAsset:(PHAsset *)asset completion:(void (^)(PHLivePhoto *, NSDictionary *))completion
{
    PHLivePhotoRequestOptions *option = [[PHLivePhotoRequestOptions alloc] init];
    option.version = PHImageRequestOptionsVersionCurrent;
    option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    option.networkAccessAllowed = YES;
    
    return [[PHCachingImageManager defaultManager] requestLivePhotoForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:option resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
        if (completion) completion(livePhoto, info);
    }];
}

+ (PHImageRequestID)requestVideoForAsset:(PHAsset *)asset completion:(void (^)(AVPlayerItem *, NSDictionary *))completion
{
    PHVideoRequestOptions * opt = [PHVideoRequestOptions new];
    opt.networkAccessAllowed = YES;
    opt.deliveryMode = PHVideoRequestOptionsDeliveryModeFastFormat;
    return [[PHCachingImageManager defaultManager] requestPlayerItemForVideo:asset options:opt resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
        if (completion) completion(playerItem, info);
    }];
}


// more than iOS9
+ (void)requestVideoPathFromPHAsset:(PHAsset *)asset filePath:(NSString *)filePath Complete:(void(^)(NSError  *error, NSString *filePath))result {
    NSArray *assetResources = [PHAssetResource assetResourcesForAsset:asset];
    PHAssetResource *resource;
    
    for (PHAssetResource *assetRes in assetResources) {
        if (assetRes.type == PHAssetResourceTypePairedVideo ||
            assetRes.type == PHAssetResourceTypeVideo) {
            resource = assetRes;
        }
    }
    if (asset.mediaType == PHAssetMediaTypeVideo || asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.networkAccessAllowed = true;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        if (resource == nil) {
             result([[NSError alloc]initWithDomain:@"not video" code:555 userInfo:nil], nil);
        }
        [[PHAssetResourceManager defaultManager] writeDataForAssetResource:resource
                                                                    toFile:[NSURL fileURLWithPath:filePath]
                                                                   options:nil
                                                         completionHandler:^(NSError * _Nullable error) {
                                                             if (error) {
                                                                 result(error, nil);
                                                             } else {
                                                                 result(nil, filePath);
                                                             }
                                                         }];
    } else {
        result([[NSError alloc]initWithDomain:@"not video" code:555 userInfo:nil], nil);
    }
}


#pragma mark - video 

+ (void)analysisEverySecondsImageForAsset:(PHAsset *)asset interval:(NSTimeInterval)interval size:(CGSize)size complete:(void (^)(AVAsset *, NSArray<UIImage *> *))complete
{
    PHVideoRequestOptions* options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = YES;
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        [self analysisAVAsset:asset interval:interval size:size complete:complete];
    }];
}

+ (void)analysisAVAsset:(AVAsset *)asset interval:(NSTimeInterval)interval size:(CGSize)size complete:(void (^)(AVAsset *, NSArray<UIImage *> *))complete
{
    long duration = round(asset.duration.value) / asset.duration.timescale;
    
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.maximumSize = size;
    generator.appliesPreferredTrackTransform = YES;
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    
    //每秒的第一帧
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < duration; i += interval) {
        /*
         CMTimeMake(a,b) a当前第几帧, b每秒钟多少帧
         */
        CMTime time = CMTimeMake((i+0.35) * asset.duration.timescale, asset.duration.timescale);
        NSValue *value = [NSValue valueWithCMTime:time];
        [arr addObject:value];
    }
    
    NSMutableArray *arrImages = [NSMutableArray array];
    
    __block long count = 0;
    [generator generateCGImagesAsynchronouslyForTimes:arr completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        switch (result) {
            case AVAssetImageGeneratorSucceeded:
                [arrImages addObject:[UIImage imageWithCGImage:image]];
                break;
            case AVAssetImageGeneratorFailed:
                NSLog(@"第%ld秒图片解析失败", count);
                break;
            case AVAssetImageGeneratorCancelled:
                NSLog(@"取消解析视频图片");
                break;
        }
        
        count++;
        
        if (count == arr.count && complete) {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(asset, arrImages);
            });
        }
    }];
}

+ (void)exportEditVideoForAsset:(AVAsset *)asset range:(CMTimeRange)range complete:(void (^)(BOOL, PHAsset *))complete
{
    NSTimeInterval interval = [[[NSDate alloc] init] timeIntervalSince1970];
    
    NSString *exportFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%f.mov", interval]];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetPassthrough];
    
    NSURL *exportFileUrl = [NSURL fileURLWithPath:exportFilePath];
    
    exportSession.outputURL = exportFileUrl;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    exportSession.timeRange = range;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        switch ([exportSession status]) {
            case AVAssetExportSessionStatusFailed:
                NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Export canceled");
                break;
                
            case AVAssetExportSessionStatusCompleted:{
                NSLog(@"Export completed");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self saveVideoToAblum:exportFileUrl completion:^(BOOL isSuc, PHAsset *asset) {
                        if (complete) complete(isSuc, asset);
                        if (isSuc) {
                            NSLog(@"导出的的视频路径: %@", exportFilePath);
                        } else {
                            NSLog(@"导出视频失败");
                        }
                    }];
                });
            }
                break;
                
            default:
                NSLog(@"Export other");
                break;
        }
    }];
}

@end
