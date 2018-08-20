//
//  Test.m
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/8/20.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

#import "WBUploadManager.h"


/*
 * asset backup and calculate asset hash manager
 *
 */

@interface WBUploadManager ()
{
    BOOL _isdestroing;
    NSURL * _uploadURL;
    NSString * _token;
    NSInteger _lastNotifyCount;
    BOOL _shouldNotify;
    BOOL _needRetry;
    BOOL _isStartLocation;
}

@property (nonatomic, readwrite) NSMutableArray<WSAsset *> *hashwaitingQueue;

@property (nonatomic, readwrite) NSMutableArray<WSAsset *> *hashWorkingQueue;

@property (nonatomic, readwrite) NSMutableArray<WSAsset *> *hashFailQueue;

@property (nonatomic, readwrite) NSMutableArray<WSAsset *> *uploadPaddingQueue;

@property (nonatomic, readwrite) NSMutableArray<WBUploadModel *> *uploadingQueue;

@property (nonatomic, readwrite) NSMutableArray<WBUploadModel *> *uploadedQueue;

@property (nonatomic, readwrite) NSMutableArray<WBUploadModel *> *uploadErrorQueue;

@property (nonatomic, strong) NSMutableArray<EntriesModel *> * uploadedNetQueue;

@property (nonatomic, strong) NSMutableSet<NSString *> * uploadedNetHashSet;

@property (nonatomic, strong) NSMutableSet<NSString *> *uploadedLocalHashSet;

@property (nonatomic)  AFHTTPSessionManager  *manager;

@property (nonatomic) dispatch_queue_t managerQueue;

@property (nonatomic) dispatch_queue_t workingQueue;

@end

@implementation WBUploadManager

- (void)dealloc{
    NSLog(@"WBUploadManager dealloc");
}

- (instancetype)init {
    if(self = [super init]) {
        _isdestroing = NO;
        _shouldUpload = NO;
        _shouldNotify = NO;
        _needRetry = YES;
        _isStartLocation = NO;
        _lastNotifyCount = 0;
        _hashLimitCount = 4;
        _uploadLimitCount = 4;
        [self workingQueue];
        [self managerQueue];
    }
    return self;
}

- (AFHTTPSessionManager *)manager  {
    if(!_manager) {
        NSString * bundleId = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleIdentifier"];
        NSString * identifier = [NSString stringWithFormat:@"%@.backgroundSession", bundleId];
        NSURLSessionConfiguration * config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
        
        config.allowsCellularAccess = NO;
        _manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
        _manager.attemptsToRecreateUploadTasksForBackgroundSessions = YES;
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
        _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        @weaky(self);
        [_manager setDidFinishEventsForBackgroundURLSessionBlock:^(NSURLSession * _Nonnull session) {
            @strongy(self)
            dispatch_async(self.managerQueue, ^{
                [self schedule];
            });
        }];
    }
    return _manager;
}

//low等级线程
- (dispatch_queue_t)workingQueue {
    if(!_workingQueue){
        _workingQueue = dispatch_queue_create("com.wisnucbox.uploadmanager.working", DISPATCH_QUEUE_CONCURRENT);
        dispatch_set_target_queue(_workingQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    }
    return _workingQueue;
}

- (dispatch_queue_t)managerQueue{
    if(!_managerQueue){
        _managerQueue = dispatch_queue_create("com.wisnucbox.uploadmanager.main", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(_managerQueue, dispatch_get_global_queue(1, 0));
    }
    return _managerQueue;
}

- (NSMutableSet<NSString *> *)uploadedNetHashSet{
    @synchronized (self) {
        if(!_uploadedNetHashSet){
            _uploadedNetHashSet = [NSMutableSet set];
        }
        return _uploadedNetHashSet;
    }
}

- (NSMutableSet<NSString *> *)uploadedLocalHashSet {
    @synchronized (self) {
        if(!_uploadedLocalHashSet){
            _uploadedLocalHashSet = [NSMutableSet set];
        }
        return _uploadedLocalHashSet;
    }
}

-(NSMutableArray<WSAsset *> *)hashwaitingQueue{
    @synchronized (self) {
        if (!_hashwaitingQueue) {
            _hashwaitingQueue= [NSMutableArray arrayWithCapacity:0];
        }
        return _hashwaitingQueue;
    }
}

- (NSMutableArray<WSAsset *> *)hashWorkingQueue{
    @synchronized (self) {
        if (!_hashWorkingQueue) {
            _hashWorkingQueue= [NSMutableArray<WSAsset *> arrayWithCapacity:0];
        }
        return _hashWorkingQueue;
    }
}

- (NSMutableArray *)uploadedNetQueue{
    @synchronized (self) {
        if (!_uploadedNetQueue) {
            _uploadedNetQueue= [NSMutableArray arrayWithCapacity:0];
        }
        return _uploadedNetQueue;
    }
}

- (NSMutableArray<WBUploadModel *> *)uploadingQueue{
    @synchronized (self) {
        if (!_uploadingQueue) {
            _uploadingQueue= [NSMutableArray<WBUploadModel *> arrayWithCapacity:0];
        }
        return _uploadingQueue;
    }
}

- (NSMutableArray<WSAsset *> *)uploadPaddingQueue{
    @synchronized (self) {
        if (!_uploadPaddingQueue) {
            _uploadPaddingQueue= [NSMutableArray<WSAsset *> arrayWithCapacity:0];
        }
        return _uploadPaddingQueue;
    }
}

- (NSMutableArray<WBUploadModel *> *)uploadedQueue{
    @synchronized (self) {
        if (!_uploadedQueue) {
            _uploadedQueue= [NSMutableArray<WBUploadModel *> arrayWithCapacity:0];
        }
        return _uploadedQueue;
    }
}
- (NSMutableArray<WBUploadModel *> *)uploadErrorQueue{
    @synchronized (self) {
        if (!_uploadErrorQueue) {
            _uploadErrorQueue= [NSMutableArray<WBUploadModel *> arrayWithCapacity:0];
        }
        return _uploadErrorQueue;
    }
}

- (void)addTask:(WSAsset *)asset {
    dispatch_async(self.managerQueue, ^{
        if(asset) {
            _shouldNotify = YES;
            _needRetry = YES;
            [self.hashwaitingQueue addObject:asset];
            [self schedule];
        }
    });
}

- (void)addTasks:(NSArray<WSAsset *> *)assets {
    dispatch_async(self.managerQueue, ^{
        if(assets.count){
            _shouldNotify = YES;
            _needRetry = YES;
            [self.hashwaitingQueue addObjectsFromArray:assets];
            [[NSNotificationCenter defaultCenter] postNotificationName:WBBackupCountChangeNotify object:nil];
            [self schedule];
        }
    });
}

- (void)removeTask:(WSAsset *)rmAsset {
    dispatch_async(self.managerQueue, ^{
        NSString * assetId = rmAsset.asset.localIdentifier;
        __block WSAsset * asset;
        [self.hashwaitingQueue enumerateObjectsUsingBlock:^(WSAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(IsEquallString(obj.asset.localIdentifier, assetId)){
                asset = obj;
                *stop = YES;
            }
        }];
        if(asset) [self.hashwaitingQueue removeObject:asset];
        asset = nil;
        
        [self.uploadPaddingQueue enumerateObjectsUsingBlock:^(WSAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(IsEquallString(obj.asset.localIdentifier, assetId)){
                asset = obj;
                *stop = YES;
            }
        }];
        if(asset) [self.uploadPaddingQueue removeObject:asset];
        
        __block WBUploadModel * upModel;
        [self.uploadingQueue enumerateObjectsUsingBlock:^(WBUploadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(IsEquallString(obj.asset.asset.localIdentifier, assetId)){
                obj.isRemoved = YES; // remove
                [obj cancel]; //  not to uploadErrorQueue or uploadedQueue if removed
                upModel = obj;
                *stop = YES;
            }
        }];
        if(upModel) {
            [self.uploadingQueue removeObject:upModel];
            [self.uploadErrorQueue removeObject:upModel];
        }
        upModel = nil;
        [self.uploadErrorQueue enumerateObjectsUsingBlock:^(WBUploadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(IsEquallString(obj.asset.asset.localIdentifier, assetId)){
                upModel = obj;
                *stop = YES;
            }
        }];
        if(upModel) [self.uploadErrorQueue removeObject:upModel];
        upModel = nil;
        [self.uploadedQueue enumerateObjectsUsingBlock:^(WBUploadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(IsEquallString(obj.asset.asset.localIdentifier, assetId)){
                upModel = obj;
                *stop = YES;
            }
        }];
        if(upModel) [self.uploadedQueue removeObject:upModel];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:WBBackupCountChangeNotify object:nil];
        upModel = nil;
    });
}

- (void)removeTasks:(NSArray<WSAsset *> *)assets {
    if(!assets || !assets.count)  return;
    [assets enumerateObjectsUsingBlock:^(WSAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeTask:obj];
    }];
}

- (void)getAllCount:(void(^)(NSInteger allCount))callback {
    dispatch_async(self.managerQueue, ^{
        NSInteger allCount =  self.hashwaitingQueue.count + self.hashWorkingQueue.count + self.hashFailQueue.count
        + self.uploadPaddingQueue.count + self.uploadingQueue.count
        + self.uploadedQueue.count + self.uploadErrorQueue.count;
        callback(allCount);
    });
}

- (void)startWithLocalAssets:(NSArray<WSAsset *> *)localAssets andNetAssets:(NSArray<EntriesModel *> *)netAssets {
    dispatch_async(self.managerQueue, ^{
        _shouldNotify = YES;
        _needRetry = YES;
        [self.hashwaitingQueue addObjectsFromArray:localAssets];
        NSComparator cmptr = ^(WSAsset * photo1, WSAsset * photo2){
            NSDate * tempDate = [[photo1 asset].creationDate laterDate:[photo2 asset].creationDate];
            if ([tempDate isEqualToDate:[photo1 asset].creationDate]) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            if ([tempDate isEqualToDate:[photo2 asset].creationDate]) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        };
        [self.hashwaitingQueue sortUsingComparator:cmptr];
        [self.uploadedNetQueue addObjectsFromArray:netAssets];
        NSMutableSet * hashSet = [NSMutableSet set];
        [netAssets enumerateObjectsUsingBlock:^(EntriesModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(IsEquallString(obj.type, @"file") || !IsNilString(obj.photoHash)){
                [hashSet addObject:obj.photoHash];
            }
        }];
        self.uploadedNetHashSet = hashSet;
        [self schedule];
    });
}

- (void)setNetAssets:(NSArray<EntriesModel *> *)netAssets {
    dispatch_async(self.managerQueue, ^{
        self.uploadedNetQueue = [NSMutableArray arrayWithArray: netAssets];
        NSMutableSet * hashSet = [NSMutableSet set];
        [netAssets enumerateObjectsUsingBlock:^(EntriesModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(IsEquallString(obj.type, @"file") || !IsNilString(obj.photoHash)){
                [hashSet addObject:obj.photoHash];
            }
        }];
        self.uploadedNetHashSet = hashSet;
        [self schedule];
    });
}

// clean error queue
// insert to uploadpending queue for retry
- (void)startUpload {
    self.shouldUpload = NO;
    // notify for start
    [[NSNotificationCenter defaultCenter] postNotificationName:WBBackupCountChangeNotify object:nil];
    dispatch_async(self.managerQueue, ^{
        [self.uploadErrorQueue enumerateObjectsUsingBlock:^(WBUploadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.uploadPaddingQueue addObject:obj.asset];
        }];
        [self.uploadErrorQueue removeAllObjects]; //clean error queue
        self.shouldUpload = YES;
        _needRetry = YES;
        [self schedule];
    });
}

- (void)asset:(WSAsset *)asset getSha256:(void(^)(NSError *, NSString *))callback {
    WBLocalAsset * as = [[AppServices sharedService].assetServices getAssetWithLocalId:asset.asset.localIdentifier];
    if(as) {
        asset.digest = as.digest;
        callback(NULL, as.digest);
    }else
        [asset.asset getSha256:^(NSError *error, NSString *sha256) {
            if(error) return callback(error, NULL);
            //save sha256
            asset.digest = sha256;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [WB_AppServices.assetServices saveAssetWithLocalId:asset.asset.localIdentifier digest:sha256];
            });
            callback(NULL, sha256);
        }];
}

- (void)schedule {
    if(_isdestroing) return;
    if(self.hashwaitingQueue.count == 0 && self.hashWorkingQueue.count == 0) {
        if(_shouldNotify){
            _shouldNotify = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:HashCalculateFinishedNotify object:nil];
        }
        NSLog(@"hash calculate finish. uploadPaddingQueue:%lu", (unsigned long)self.uploadPaddingQueue.count);
    }
    if(self.hashwaitingQueue.count == 0 && self.hashWorkingQueue.count == 0 && self.uploadPaddingQueue.count == 0 && self.uploadingQueue.count == 0){
        NSLog(@"backup asset finish ----=======>>>><<<<<<<<====-----  errorCount:%lu  finishedCount:%lu", (unsigned long)_uploadErrorQueue.count, (unsigned long)_uploadedQueue.count);
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].idleTimerDisabled = NO;
        });
        dispatch_async(self.managerQueue, ^{
            if(self.uploadErrorQueue.count) { // retry
                _needRetry = NO;
                [self.uploadErrorQueue enumerateObjectsUsingBlock:^(WBUploadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [self.uploadPaddingQueue addObject:obj.asset];
                }];
                [self.uploadErrorQueue removeAllObjects];
                [self schedule];
            }
        });
    }
    dispatch_async(self.managerQueue, ^{
        while(self.hashWorkingQueue.count < self.hashLimitCount && self.hashwaitingQueue.count > 0) {
            WSAsset * asset = [self.hashwaitingQueue firstObject];
            [self.hashwaitingQueue removeObject:asset];
            [self.hashWorkingQueue addObject:asset];
            __weak typeof(self) weakSelf = self;
            dispatch_async([self workingQueue], ^{
                [self asset:asset getSha256:^(NSError *error, NSString *sha256) {
                    dispatch_async(self.managerQueue, ^{
                        if (error) {
                            [weakSelf.hashFailQueue addObject:asset];
                        }else {
                            asset.digest = sha256;
                            [weakSelf.uploadPaddingQueue addObject:asset];
                        }
                        [weakSelf.hashWorkingQueue removeObject:asset];
                        [weakSelf schedule];
                    });
                }];
            });
        }
        
        if(!_shouldUpload) return;
        while(self.uploadPaddingQueue.count > 0 && self.uploadingQueue.count < self.uploadLimitCount) {
            WSAsset * asset = [self.uploadPaddingQueue firstObject];
            [self.uploadPaddingQueue removeObject:asset];
            WBUploadModel * model = [WBUploadModel initWithAsset:asset andManager:self.manager];
            if([self.uploadedNetHashSet containsObject:asset.digest] || [self.uploadedLocalHashSet containsObject:asset.digest]) {
                [self.uploadedQueue addObject:model];
                NSLog(@"发现一个已上传的，直接跳过, error: %lu  finish:%lu", (unsigned long)_uploadErrorQueue.count, (unsigned long)_uploadedQueue.count);
                [[NSNotificationCenter defaultCenter] postNotificationName:WBBackupCountChangeNotify object:nil];
                [self schedule];
                
            }else {
                [self.uploadingQueue addObject:model];
                dispatch_async(self.workingQueue, ^{
                    [self scheduleForUpload:model andUseTimeStamp:NO];
                });
            }
        }
    });
}

// retry if eexist
- (void)scheduleForUpload:(WBUploadModel *)model andUseTimeStamp:(BOOL)yesOrNo {
    __weak typeof(self) weakSelf = self;
    __weak typeof(WB_AppServices) weak_AppService = WB_AppServices;
    dispatch_async(self.workingQueue, ^{
        [model startUseTimeStamp:yesOrNo completeBlock:^(NSError *error, id response) {
            if(!weakSelf) return;
            dispatch_async(weakSelf.managerQueue, ^{
                if (error) {
                    if (error.wbCode == WBUploadDirNotFound) {
                        [weakSelf stop];   // stop
                        // need rebuild
                        [weakSelf destroy];
                        NSLog(@"文件上传目录丢失 开始重建");
                        [weak_AppService rebulidUploadManager];
                    }else if (error.wbCode == WBUploadFileExist) {
                        // rename then retry
                        NSLog(@"文件 EExist,  重命名 再次尝试！");
                        [weakSelf scheduleForUpload:model andUseTimeStamp:YES];
                    }else {
                        if(!model.isRemoved)
                            [weakSelf.uploadErrorQueue addObject:model];
                        [weakSelf.uploadingQueue removeObject:model];
                        NSLog(@"上传失败 , error: %lu  finish:%lu", (unsigned long)weakSelf.uploadErrorQueue.count, (unsigned long)weakSelf.uploadedQueue.count);
                    }
                }else{  // success
                    NSLog(@"上传成功 , error: %lu  finish:%lu", (unsigned long)weakSelf.uploadErrorQueue.count, (unsigned long)weakSelf.uploadedQueue.count);
                    [weakSelf.uploadingQueue removeObject:model];
                    [weakSelf.uploadedLocalHashSet addObject:model.asset.digest]; // record for skip equal-hash asset
                    if(![weakSelf.uploadedQueue containsObject:model]) {
                        if(!model.isRemoved)
                            [weakSelf.uploadedQueue addObject:model];
                        [weakSelf.uploadingQueue removeObject:model];
                        [[NSNotificationCenter defaultCenter] postNotificationName:WBBackupCountChangeNotify object:nil];
                    }
                }
                [weakSelf schedule];
            });
        }];
    });
}

- (void)setShouldUpload:(BOOL)shouldUpload {
    _shouldUpload = shouldUpload;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].idleTimerDisabled = _shouldUpload;
    });
}

- (void)stop {
    self.shouldUpload = NO;
    //TODO: hash queue should stop?
    [self.uploadingQueue enumerateObjectsUsingBlock:^(WBUploadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj cancel];
    }];
    if([[UIDevice currentDevice].systemVersion floatValue] > 9.0)
        [self.manager.session getAllTasksWithCompletionHandler:^(NSArray<__kindof NSURLSessionTask *> * _Nonnull tasks) {
            [tasks enumerateObjectsUsingBlock:^(__kindof NSURLSessionTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj cancel];
            }];
        }];
}

- (void)destroy {
    _isdestroing = YES;
    [self.hashwaitingQueue removeAllObjects];
    // TODO: cancel working queue?
    [self.hashWorkingQueue removeAllObjects];
    [self.hashFailQueue removeAllObjects];
    
    [self.uploadPaddingQueue removeAllObjects];
    [self stop];
    [self.uploadingQueue removeAllObjects];
    [self.uploadedQueue removeAllObjects];
    [self.uploadErrorQueue removeAllObjects];
    [self.uploadedNetQueue removeAllObjects];
    [self.uploadedLocalHashSet removeAllObjects];
    [self.manager.session invalidateAndCancel];
    _isdestroing = NO;
}



@end

@implementation WBUploadModel {
    PHImageRequestID _requestFileID;
    AFHTTPSessionManager * _manager;
    BOOL _shouldStop;
}

+ (instancetype)initWithAsset:(WSAsset *)asset andManager:(AFHTTPSessionManager *)manager{
    WBUploadModel * model = [WBUploadModel new];
    model.asset = asset;
    model->_manager = manager;
    model->_shouldStop = NO;
    return model;
}

static NSArray * invaildChars;
- (void)startUseTimeStamp:(BOOL)yesOrNo completeBlock:(void(^)(NSError * , id))callback {
    /*
     * WISNUC API:UPLOAD A FILE
     */
    self.callback = callback;
    invaildChars = [NSArray arrayWithObjects:@"/", @"?", @"<", @">", @"\\", @":", @"*", @"|", @"\"", nil];
    @weaky(self);
    _requestFileID =  [self.asset.asset getFile:^(NSError *error, NSString *filePath) {
        if(error)
            return callback(error, nil);
        if(_shouldStop) return callback([NSError errorWithDomain:@"cancel" code:20010 userInfo:nil], nil);
        NSLog(@"==========================开始上传==============================");
        NSString * hashString = weak_self.asset.digest;
        NSInteger sizeNumber = (NSInteger)[WB_FileService fileSizeAtPath:filePath];
        NSString * exestr = [filePath lastPathComponent];
        NSString * fileName = [PHAssetResource assetResourcesForAsset:weak_self.asset.asset].firstObject.originalFilename;
        if(IsNilString(fileName)) fileName = exestr;
        NSMutableString * tempFileName = [NSMutableString stringWithString:fileName];
        for (int i = 0; i < tempFileName.length; i++) {
            if([invaildChars containsObject: [fileName substringWithRange:NSMakeRange(i, 1)]]){
                [tempFileName replaceCharactersInRange:NSMakeRange(i, 1) withString:@"_"];
            }
        }
        fileName = tempFileName;
        if(yesOrNo) {
            fileName = [NSString stringWithFormat:@"%f_%@", [[NSDate date] timeIntervalSince1970], fileName];
            //          NSString * fileNameDeletingPathExtension = [fileName stringByDeletingPathExtension];
            //            // 获得文件的后缀名（不带'.'）
            //          NSString * pathExtension = [filePath pathExtension];
            //            fileName = [NSString stringWithFormat:@"%@_%f.%@", fileNameDeletingPathExtension, [[NSDate date] timeIntervalSince1970],pathExtension];
            
        }
        NSLog(@"filename : %@", fileName);
        NSString *urlString;
        NSMutableDictionary * mutableDic = [NSMutableDictionary dictionaryWithCapacity:0];
        if (WB_UserService.currentUser.isCloudLogin) {
            urlString = [NSString stringWithFormat:@"%@%@", kCloudAddr, kCloudCommonPipeUrl];
            NSString *requestUrl = [NSString stringWithFormat:@"/drives/%@/dirs/%@/entries", WB_UserService.currentUser.userHome,  WB_UserService.currentUser.backUpDir];
            NSString *resource =[requestUrl base64EncodedString] ;
            NSMutableDictionary *manifestDic  = [NSMutableDictionary dictionaryWithCapacity:0];
            [manifestDic setObject:@"newfile" forKey:kCloudBodyOp];
            [manifestDic setObject:@"POST" forKey:kCloudBodyMethod];
            [manifestDic setObject:fileName forKey:kCloudBodyToName];
            [manifestDic setObject:resource forKey:kCloudBodyResource];
            [manifestDic setObject:hashString forKey:@"sha256"];
            [manifestDic setObject:@(sizeNumber) forKey:@"size"];
            NSData *josnData = [NSJSONSerialization dataWithJSONObject:manifestDic options:NSJSONWritingPrettyPrinted error:nil];
            NSString *result = [[NSString alloc] initWithData:josnData  encoding:NSUTF8StringEncoding];
            [mutableDic setObject:result forKey:@"manifest"];
            [_manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", WB_UserService.currentUser.cloudToken] forHTTPHeaderField:@"Authorization"];
            _manager.requestSerializer.timeoutInterval = 60;
        }else {
            urlString = [NSString stringWithFormat:@"%@drives/%@/dirs/%@/entries/",[JYRequestConfig sharedConfig].baseURL,WB_UserService.currentUser.userHome, WB_UserService.currentUser.backUpDir];
            mutableDic = nil;
            [_manager.requestSerializer setValue:[NSString stringWithFormat:@"JWT %@",WB_UserService.defaultToken] forHTTPHeaderField:@"Authorization"];
        }
        NSString * requestTempPath = [NSString stringWithFormat:@"%@_temp", filePath];
        NSURL *requestFileTempPath = [NSURL fileURLWithPath:requestTempPath];
        
        
        NSMutableURLRequest *request = [_manager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:mutableDic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            if(WB_UserService.currentUser.isCloudLogin) {
                [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:fileName fileName:fileName mimeType:@"image/jpeg" error:nil];
            }else {
                NSDictionary *dic = @{@"size":@(sizeNumber),@"sha256":hashString};
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
                NSString *jsonString =  [[NSString alloc] initWithData:jsonData  encoding:NSUTF8StringEncoding];
                [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:fileName fileName:jsonString mimeType:@"image/jpeg" error:nil];
            }
        } error:nil];
        
        [_manager.requestSerializer requestWithMultipartFormRequest:request writingStreamContentsToFile:requestFileTempPath completionHandler:^(NSError * _Nullable error) {
            if(error) return callback(error, nil);
            if(_shouldStop) return callback([NSError errorWithDomain:@"cancel" code:20010 userInfo:nil], nil);
            request.HTTPBodyStream = nil;
            weak_self.dataTask = [_manager uploadTaskWithRequest:request fromFile:requestFileTempPath progress:^(NSProgress * _Nonnull uploadProgress) {
            } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                NSError *fileError;
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:&fileError];
                [[NSFileManager defaultManager] removeItemAtPath:requestTempPath error:&fileError];
                
                NSLog(@"%@",fileError);
                if(!weak_self) return;
                if(_shouldStop) return callback([NSError errorWithDomain:@"cancel" code:20010 userInfo:nil], nil);
                if(!error) {
                    NSLog(@"Upload Success -->");
                    if(weak_self.callback) weak_self.callback(nil, responseObject);
                }else {
                    NSLog(@"Upload Failure ---> : %@", error);
                    NSLog(@"Upload Failure ---> : %@  ----> statusCode: %ld", fileName, (long)((NSHTTPURLResponse *)response).statusCode);
                    NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
                    if(errorData.length >0 && ((NSHTTPURLResponse *)response).statusCode == 403){
                        NSMutableArray *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
                        NSLog(@"Upload Failure ---> :serializedData %@", serializedData);
                        if([serializedData isKindOfClass:[NSArray class]]) {
                            @try {
                                NSDictionary *errorRootDic = serializedData[0];
                                NSDictionary *errorDic = errorRootDic[@"error"];
                                NSString *code = errorDic[@"code"];
                                NSInteger status = [errorDic[@"status"] integerValue];
                                if ([code isEqualToString:@"EEXIST"])
                                    error.wbCode = WBUploadFileExist;
                                if(status == 404)
                                    error.wbCode = WBUploadDirNotFound;
                            } @catch (NSException *exception) {
                                NSLog(@"%@", exception);
                            }
                        }
                    }
                    weak_self.error = error;
                    if (weak_self.callback) weak_self.callback(error, nil);
                }
                
            }];
            [weak_self.dataTask resume];
        }];
    }];
}

- (void)cancel {
    self->_shouldStop = YES;
    if(_requestFileID) {
        [[PHImageManager defaultManager] cancelImageRequest:_requestFileID];
        _requestFileID = PHInvalidImageRequestID;
    }
    if(_dataTask) {
        [_dataTask cancel];
    }
}

@end

