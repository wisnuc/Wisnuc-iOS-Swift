
//
//  AutoBackupManager.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/8/16.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class AutoBackupManager: NSObject {
    private var isdestroing = false
    private var shouldNotify = false
    private var needRetry = true
    lazy var hashwaitingQueue = Array<WSAsset>.init()
    
    lazy var hashWorkingQueue = Array<WSAsset>.init()
    
    var hashFailQueue:Array<WSAsset>?
    
    lazy var uploadPaddingQueue = Array<WSAsset>.init()
    
    lazy var uploadingQueue = Array<WSUploadModel>.init()
    
    lazy var uploadedQueue = Array<WSUploadModel>.init()
    
    lazy var uploadErrorQueue = Array<WSUploadModel>.init()
    
    var hashLimitCount:Int? // default 2
    
    var uploadLimitCount:Int? // default 1
    
    var shouldUpload:Bool? // default NO
    
    override init() {
        super.init()
        hashLimitCount = 4
    }
    
//    func getAllCount:(callback:(allCount:Int)-())?
//
//    func startWithLocalAssets:(NSArray<WSAsset>)localAssets andNetAssets:(NSArray<EntriesModel>)netAssets?
//
//    func startUpload?
//
    func setNetAssets(netAssets:Array<EntriesModel>){
        managerQueue.async {
            self.uploadedNetQueue = netAssets
            var  hashSet = Set<String>.init()
            for model in netAssets{
                if model.type == FilesType.file.rawValue && model.hash != nil{
                  hashSet.insert(model.hash!)
                }
            }
          
            self.uploadedNetHashSet = hashSet
//            [self schedule];
        }
    }
    
    func schedule(){
        if isdestroing {return}
        if(self.hashwaitingQueue.count == 0 && self.hashWorkingQueue.count == 0) {
            if shouldNotify {
                shouldNotify = false
                defaultNotificationCenter().post(name: Notification.Name.Backup.HashCalculateFinishedNotiKey, object: nil)
            }
            print("hash calculate finish. uploadPaddingQueue:\(String(describing: self.uploadPaddingQueue.count))");
        }
        
        
        if(self.hashwaitingQueue.count == 0 && self.hashWorkingQueue.count == 0 && self.uploadPaddingQueue.count == 0 && self.uploadingQueue.count == 0){
            print("backup asset finish ----=======>>>><<<<<<<<====-----  errorCount:\(uploadErrorQueue.count)  finishedCount:\(uploadedQueue.count)")
            
            DispatchQueue.main.async {
                UIApplication.shared.isIdleTimerDisabled = false
            }
            self.managerQueue.async { [weak self] in
                if (self?.uploadErrorQueue.count)!>0 { // retry
                    self?.needRetry = false
                    for model in (self?.uploadErrorQueue)!{
                        if model.asset != nil{
                            self?.uploadPaddingQueue.append(model.asset!)
                        }
                    }
                    self?.uploadErrorQueue.removeAll()
                    self?.schedule()
                }
            }
        }
        
        self.managerQueue.async { [weak self] in
            while((self?.hashWorkingQueue.count)! < (self?.hashLimitCount!)! && (self?.hashwaitingQueue.count)! > 0) {
                let asset = self?.hashwaitingQueue.first
                let location = self?.hashwaitingQueue.index(of: asset!)
                self?.hashwaitingQueue.remove(at: location!)
                self?.hashWorkingQueue.append(asset!)
                self?.workingQueue.async {
                    
                }
                //    dispatch_async([self workingQueue], ^{
                //    [self asset:asset getSha256:^(NSError *error, NSString *sha256) {
                //    dispatch_async(self.managerQueue, ^{
                //    if (error) {
                //    [weakSelf.hashFailQueue addObject:asset];
                //    }else {
                //    asset.digest = sha256;
                //    [weakSelf.uploadPaddingQueue addObject:asset];
                //    }
                //    [weakSelf.hashWorkingQueue removeObject:asset];
                //    [weakSelf schedule];
                //    });
                //    }];
                //    });
            }
         
        }
        
        //    dispatch_async(self.managerQueue, ^{
        //    while(self.hashWorkingQueue.count < self.hashLimitCount && self.hashwaitingQueue.count > 0) {
        //    JYAsset * asset = [self.hashwaitingQueue firstObject];
        //    [self.hashwaitingQueue removeObject:asset];
        //    [self.hashWorkingQueue addObject:asset];
        //    __weak typeof(self) weakSelf = self;
        //    dispatch_async([self workingQueue], ^{
        //    [self asset:asset getSha256:^(NSError *error, NSString *sha256) {
        //    dispatch_async(self.managerQueue, ^{
        //    if (error) {
        //    [weakSelf.hashFailQueue addObject:asset];
        //    }else {
        //    asset.digest = sha256;
        //    [weakSelf.uploadPaddingQueue addObject:asset];
        //    }
        //    [weakSelf.hashWorkingQueue removeObject:asset];
        //    [weakSelf schedule];
        //    });
        //    }];
        //    });
        //    }
    }
        
//        - (void)schedule {
//    if(_isdestroing) return;
//    if(self.hashwaitingQueue.count == 0 && self.hashWorkingQueue.count == 0) {
//    if(_shouldNotify){
//    _shouldNotify = NO;
//    [[NSNotificationCenter defaultCenter] postNotificationName:HashCalculateFinishedNotify object:nil];
//    }
//    NSLog(@"hash calculate finish. uploadPaddingQueue:%lu", (unsigned long)self.uploadPaddingQueue.count);
//    }
    
    
    
    
    
//    if(self.hashwaitingQueue.count == 0 && self.hashWorkingQueue.count == 0 && self.uploadPaddingQueue.count == 0 && self.uploadingQueue.count == 0){
//    NSLog(@"backup asset finish ----=======>>>><<<<<<<<====-----  errorCount:%lu  finishedCount:%lu", (unsigned long)_uploadErrorQueue.count, (unsigned long)_uploadedQueue.count);
//    dispatch_async(dispatch_get_main_queue(), ^{
//    [UIApplication sharedApplication].idleTimerDisabled = NO;
//    });
//    dispatch_async(self.managerQueue, ^{
//    if(self.uploadErrorQueue.count) { // retry
//    _needRetry = NO;
//    [self.uploadErrorQueue enumerateObjectsUsingBlock:^(WBUploadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//    [self.uploadPaddingQueue addObject:obj.asset];
//    }];
//    [self.uploadErrorQueue removeAllObjects];
//    [self schedule];
//    }
//    });
//    }
    
    
    
//    dispatch_async(self.managerQueue, ^{
//    while(self.hashWorkingQueue.count < self.hashLimitCount && self.hashwaitingQueue.count > 0) {
//    JYAsset * asset = [self.hashwaitingQueue firstObject];
//    [self.hashwaitingQueue removeObject:asset];
//    [self.hashWorkingQueue addObject:asset];
//    __weak typeof(self) weakSelf = self;
//    dispatch_async([self workingQueue], ^{
//    [self asset:asset getSha256:^(NSError *error, NSString *sha256) {
//    dispatch_async(self.managerQueue, ^{
//    if (error) {
//    [weakSelf.hashFailQueue addObject:asset];
//    }else {
//    asset.digest = sha256;
//    [weakSelf.uploadPaddingQueue addObject:asset];
//    }
//    [weakSelf.hashWorkingQueue removeObject:asset];
//    [weakSelf schedule];
//    });
//    }];
//    });
//    }
//
//    if(!_shouldUpload) return;
//    while(self.uploadPaddingQueue.count > 0 && self.uploadingQueue.count < self.uploadLimitCount) {
//    JYAsset * asset = [self.uploadPaddingQueue firstObject];
//    [self.uploadPaddingQueue removeObject:asset];
//    WBUploadModel * model = [WBUploadModel initWithAsset:asset andManager:self.manager];
//    if([self.uploadedNetHashSet containsObject:asset.digest] || [self.uploadedLocalHashSet containsObject:asset.digest]) {
//    [self.uploadedQueue addObject:model];
//    NSLog(@"发现一个已上传的，直接跳过, error: %lu  finish:%lu", (unsigned long)_uploadErrorQueue.count, (unsigned long)_uploadedQueue.count);
//    [[NSNotificationCenter defaultCenter] postNotificationName:WBBackupCountChangeNotify object:nil];
//    [self schedule];
//
//    }else {
//    [self.uploadingQueue addObject:model];
//    dispatch_async(self.workingQueue, ^{
//    [self scheduleForUpload:model andUseTimeStamp:NO];
//    });
//    }
//    }
//    });
//    }
    
    
//
//    func stop?
//
//    func destroy?
//
//    func addTask:(WSAsset)asset?
//
//    func addTasks:(NSArray<WSAsset>)assets?
//
//    func removeTask:(WSAsset)rmAsset?
//
//    func removeTasks:(NSArray<WSAsset>)assets?
    
    func  getAssetSha256(asset:WSAsset,callback:(_ error:Error?, _ sha256String:String?)->()){
        if asset.asset == nil {
            return callback(BaseError(localizedDescription: ErrorLocalizedDescription.Asset.AssetNotFound, code: ErrorCode.Asset.AssetNotFound),nil)
        }
        let localAsset = AppService.sharedInstance().assetService.getAsset(localId: asset.asset!.localIdentifier)
        if localAsset != nil{
                asset.digest = localAsset?.digest
            callback(nil, localAsset?.digest);
        }else{
//                asset.asset getSha256:^(NSError *error, NSString *sha256) {
//                if(error) return callback(error, NULL);
//                //save sha256
//                asset.digest = sha256;
//                dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                [WB_AppServices.assetServices saveAssetWithLocalId:asset.asset.localIdentifier digest:sha256];
//                });
//                callback(NULL, sha256);
        }

    }
    
    lazy var uploadedNetHashSet = Set<String>.init()
    
    lazy var uploadedNetQueue =  Array<EntriesModel>.init()
       
    
    lazy var managerQueue: DispatchQueue = {
        let queue = DispatchQueue.init(label: "com.wisnuc.autoBackupManager.main")
        return queue
    }()

    lazy var workingQueue: DispatchQueue = {
        let queue = DispatchQueue(label: "queuename", attributes: .concurrent)
        return queue
    }()
}

class WSUploadModel: NSObject {
    var asset:WSAsset?
    
    var isRemoved:Bool?
    
    var dataTask:URLSessionDataTask?
    
//    @property (nonatomic, copy) void(^callback)(NSError * , id);
}
