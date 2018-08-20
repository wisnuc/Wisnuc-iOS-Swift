//
//  Test.h
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/8/20.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Wisnuc_iOS_Swift-Swift.h"
#import "AFNetworking.h"

#define HashCalculateFinishedNotify @"HashCalculateFinishedNotify"
#define WBUploadManagerDestroyedNotify @"WBUploadManagerDestroyedNotify"

@class WBUploadModel;
@interface WBUploadManager : NSObject

@property (nonatomic, readonly) NSMutableArray<WSAsset *> *hashwaitingQueue;

@property (nonatomic, readonly) NSMutableArray<WSAsset *> *hashWorkingQueue;

@property (nonatomic, readonly) NSMutableArray<WSAsset *> *hashFailQueue;

@property (nonatomic, readonly) NSMutableArray<WSAsset *> *uploadPaddingQueue;

@property (nonatomic, readonly) NSMutableArray<WBUploadModel *> *uploadingQueue;

@property (nonatomic, readonly) NSMutableArray<WBUploadModel *> *uploadedQueue;

@property (nonatomic, readonly) NSMutableArray<WBUploadModel *> *uploadErrorQueue;

@property (nonatomic) NSInteger hashLimitCount; // default 2

@property (nonatomic) NSInteger uploadLimitCount; // default 1

@property (nonatomic) BOOL shouldUpload; // default NO

- (void)getAllCount:(void(^)(NSInteger allCount))callback;

- (void)startWithLocalAssets:(NSArray<WSAsset *> *)localAssets andNetAssets:(NSArray<EntriesModel *> *)netAssets;

- (void)startUpload;

- (void)setNetAssets:(NSArray<EntriesModel *> *)netAssets;

- (void)stop;

- (void)destroy;

- (void)addTask:(WSAsset *)asset;

- (void)addTasks:(NSArray<WSAsset *> *)assets;

- (void)removeTask:(WSAsset *)rmAsset;

- (void)removeTasks:(NSArray<WSAsset *> *)assets;


@end

// error code
#define WBUploadDirNotFound   10011
#define WBUploadFileExist     10012

@interface WBUploadModel : NSObject

@property (nonatomic) WSAsset * asset;

@property (nonatomic) NSError * error;

@property (nonatomic) BOOL isRemoved;

@property (nonatomic) NSURLSessionDataTask * dataTask;

@property (nonatomic, copy) void(^callback)(NSError * , id);

+ (instancetype)initWithAsset:(WSAsset *)asset andManager:(AFHTTPSessionManager *)manager;

- (void)startUseTimeStamp:(BOOL)yesOrNo completeBlock:(void(^)(NSError * , id))callback;

// must call callback EABORT
- (void)cancel;
@end
