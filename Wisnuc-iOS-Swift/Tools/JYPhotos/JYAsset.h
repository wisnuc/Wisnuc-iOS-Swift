//
//  JYAsset.h
//  Photos
//
//  Created by JackYang on 2017/9/24.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef NS_ENUM(NSUInteger, JYAssetType) {
    JYAssetTypeImage,
    JYAssetTypeGIF,
    JYAssetTypeLivePhoto,
    JYAssetTypeVideo,
    JYAssetTypeAudio,
    JYAssetTypeNetImage,
    JYAssetTypeNetVideo,
    JYAssetTypeUnknown,
};

@interface JYAsset : NSObject <NSCopying,NSMutableCopying>

//asset对象
@property (nonatomic, strong) PHAsset *asset;

@property (nonatomic, strong) NSString *assetLocalIdentifier;
//asset类型
@property (nonatomic, assign) JYAssetType type;
//视频时长
@property (nonatomic, copy) NSString *duration;
//是否被选择
@property (nonatomic, assign, getter=isSelected) BOOL selected;

//网络/本地 图片url
@property (nonatomic, strong) NSURL *url;

@property (nonatomic) NSDate * createDateB;

//图片
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, copy) NSString * digest;

@property (nonatomic, strong) NSIndexPath *indexPath;

/**初始化model对象*/
+ (instancetype)modelWithAsset:(PHAsset *)asset type:(JYAssetType)type duration:(NSString *)duration;

// override
- (NSDate *)createDate;

@end

@interface JYAssetList : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, assign) BOOL isCameraRoll;

@property (nonatomic, strong) PHFetchResult *result;

@property (nonatomic, strong) NSArray<JYAsset *> *models;

@end
