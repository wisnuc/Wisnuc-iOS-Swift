//
//  JYAsset.m
//  Photos
//
//  Created by JackYang on 2017/9/24.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYAsset.h"

@implementation JYAsset

- (void)dealloc {
//    NSLog(@"---- %s ", __FUNCTION__);
}
//@property (nonatomic, strong) PHAsset *asset;
////asset类型
//@property (nonatomic, assign) JYAssetType type;
////视频时长
//@property (nonatomic, copy) NSString *duration;
////是否被选择
//@property (nonatomic, assign, getter=isSelected) BOOL selected;
//
////网络/本地 图片url
//@property (nonatomic, strong) NSURL *url;
//
//@property (nonatomic) NSDate * createDateB;
//
////图片
//@property (nonatomic, strong) UIImage *image;
//
//@property (nonatomic, copy) NSString * digest;
//
//@property (nonatomic, strong) NSIndexPath *indexPath
- (id)copyWithZone:(NSZone *)zone {
    JYAsset *newClass = [[JYAsset alloc]init];
    newClass.asset = self.asset;
    newClass.type = self.type;
    newClass.duration = self.duration;
    newClass.createDateB = self.createDateB;
    newClass.url = self.url;
    newClass.selected = self.selected;
    newClass.image = self.image;
    newClass.digest = self.digest;
    newClass.indexPath = self.indexPath;
    newClass.assetLocalIdentifier = self.assetLocalIdentifier;
    return newClass;
}
- (nonnull id)mutableCopyWithZone:(nullable NSZone *)zone {
    JYAsset *newClass = [[JYAsset alloc]init];
    newClass.asset = self.asset;
    newClass.type = self.type;
    newClass.duration = self.duration;
    newClass.createDateB = self.createDateB;
    newClass.url = self.url;
    newClass.selected = self.selected;
    newClass.image = self.image;
    newClass.digest = self.digest;
    newClass.indexPath = self.indexPath;
    newClass.assetLocalIdentifier = self.assetLocalIdentifier;
    return newClass;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder  encodeObject:self.assetLocalIdentifier forKey:@"assetLocalIdentifier"];

}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.assetLocalIdentifier = [aDecoder decodeObjectForKey:@"assetLocalIdentifier"];
    }
    return self;
}

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(JYAssetType)type duration:(NSString *)duration
{
    JYAsset *model = [[[self class] alloc] init];
    model.asset = asset;
    model.type = type;
    model.duration = duration;
    model.selected = NO;
    if (asset) {
        model.assetLocalIdentifier = asset.localIdentifier;
    }
    return model;
}

- (instancetype)init{
    if (self = [super init]) {
        if (self.asset) {
            self.assetLocalIdentifier = self.asset.localIdentifier;
        }
    }
    return self;
}

- (NSDate *)createDate{
    if(!self.createDateB)
        self.createDateB = self.asset.creationDate;
    return self.createDateB;
}

@end

@implementation JYAssetList


@end
