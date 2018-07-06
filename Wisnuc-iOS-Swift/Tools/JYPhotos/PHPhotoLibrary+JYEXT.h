//
//  PHPhotoLibrary+JYEXT.h
//  Photos
//
//  Created by JackYang on 2017/9/24.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Photos/Photos.h>


@interface PHPhotoLibrary (JYEXT)

/*
 * get asset use localId
 */
+ (PHAsset *)getAssetFromlocalIdentifier:(NSString *)localIdentifier;

/*
 * save image to assetLibrary
 */
+ (void)saveImageToAlbum:(UIImage *)image completion:(void(^)(BOOL, PHAsset *))completion;
// save video
+ (void)saveVideoToAblum:(NSURL *)url completion:(void (^)(BOOL, PHAsset *))completion;
 

/*
 * get gif with data
 */
+ (UIImage *)animatedGIFWithData:(NSData *)data;

/*
 * get all asset and last fetchresult handle (use for library change)
 */
+ (void)getAllAsset:(void(^)(PHFetchResult<PHAsset *> *result, NSArray<PHAsset *> *assets))block;

/**
 * @brief 获取相机胶卷相册列表对象
 */
//+ (WSAssetList *)getCameraRollAlbumList:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage;
//+ (WSAssetList *)getCameraRollAlbumList:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage sortAscend:(BOOL)sortAscending;


#pragma mark - request image

/**
 *  get high image binary data sync
 */
+ (PHImageRequestID)requestHighImageDataSyncForAsset:(PHAsset *)asset completion:(void (^)(NSError * error, NSData *, NSDictionary *))completion;
+ (PHImageRequestID)requestOriginalImageSyncForAsset:(PHAsset *)asset completion:(void (^)(NSError * error, UIImage *, NSDictionary *))completion;
/**
 * get image binary data
 */
+ (PHImageRequestID)requestOriginalImageDataForAsset:(PHAsset *)asset completion:(void (^)(NSData *, NSDictionary *))completion;

/**
 * get full screen image or original image
 */
//+ (PHImageRequestID)requestSelectedImageForAsset:(WSAsset *)model isOriginal:(BOOL)isOriginal allowSelectGif:(BOOL)allowSelectGif completion:(void (^)(UIImage *, NSDictionary *))completion;

/**
 * 获取原图
 */
+ (PHImageRequestID)requestOriginalImageForAsset:(PHAsset *)asset completion:(void (^)(UIImage *, NSDictionary *))completion;

/**
 * 获取 size 大小的图
 */
+ (PHImageRequestID)requestImageForAsset:(PHAsset *)asset size:(CGSize)size completion:(void (^)(UIImage *, NSDictionary *))completion;
+ (PHImageRequestID)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *, NSDictionary *))completion;

/**
 * get live photo
 */
+ (PHImageRequestID)requestLivePhotoForAsset:(PHAsset *)asset completion:(void (^)(PHLivePhoto *, NSDictionary *))completion API_AVAILABLE(ios(9.1));

/**
 * get video
 */
+ (PHImageRequestID)requestVideoForAsset:(PHAsset *)asset completion:(void (^)(AVPlayerItem *, NSDictionary *))completion;

+ (void)requestVideoPathFromPHAsset:(PHAsset *)asset filePath:(NSString *)filePath Complete:(void(^)(NSError  *error, NSString *filePath))result;

#pragma mark - video

/**
 解析视频，获取每秒对应的一帧图片
 
 @param size 图片size
 */
+ (void)analysisEverySecondsImageForAsset:(PHAsset *)asset interval:(NSTimeInterval)interval size:(CGSize)size complete:(void (^)(AVAsset *avAsset, NSArray<UIImage *> *images))complete;

/**
 导出视频并保存到相册
 
 @param range 需要到处的视频间隔
 */
+ (void)exportEditVideoForAsset:(AVAsset *)asset range:(CMTimeRange)range complete:(void (^)(BOOL isSuc, PHAsset *asset))complete;

@end
