
//
//  AutoBackupManager.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/8/16.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire

class AutoBackupManager: NSObject {
    private var isdestroing = false
    private var shouldNotify = false
    private var needRetry = true
    lazy var hashwaitingQueue = Array<WSAsset>.init()
    
    lazy var hashWorkingQueue = Array<WSAsset>.init()
    
    lazy var hashFailQueue = Array<WSAsset>.init()
    
    lazy var uploadPaddingQueue = Array<WSAsset>.init()
    
    lazy var uploadingQueue = Array<WSUploadModel>.init()
    
    lazy var uploadedQueue = Array<WSUploadModel>.init()
    
    lazy var uploadErrorQueue = Array<WSUploadModel>.init()
    
    var hashLimitCount:Int? // default 2
    
    var uploadLimitCount:Int? // default 1
    
    var shouldUpload:Bool? {
        didSet{
            DispatchQueue.main.async {
                UIApplication.shared.isIdleTimerDisabled = self.shouldUpload!
            }
        }
    }// default NO
    
    override init() {
        super.init()
        shouldUpload = false
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
            self.schedule()
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
                    self?.getAssetSha256(asset: asset!, callback: { [weak self] (error, sha256) in
                        self?.managerQueue.async {
                            if (error != nil) {
                                self?.hashFailQueue.append(asset!)
                            }else{
                                asset?.digest = sha256
                                self?.uploadPaddingQueue.append(asset!)
                            }
                            
                            let location = self?.hashWorkingQueue.index(of: asset!)
                            self?.hashWorkingQueue.remove(at: location!)
                            self?.schedule()
                        }
                    })
                }
            }
            if !(self?.shouldUpload!)! {return}
            while((self?.uploadPaddingQueue.count)! > 0 && (self?.uploadingQueue.count)! < (self?.uploadLimitCount)!) {
                let asset = self?.uploadPaddingQueue.first
                let location = self?.uploadPaddingQueue.index(of: asset!)
                self?.uploadPaddingQueue.remove(at: location!)
                let model = WSUploadModel.init(asset: asset!)
                if (self?.uploadedNetHashSet.contains((asset?.digest)!))! || (self?.uploadedLocalHashSet.contains((asset?.digest)!))! {
                    self?.uploadedQueue.append(model)
                    print("发现一个已上传的，直接跳过, error: \(String(describing: (self?.uploadErrorQueue.count)!)) finish:\(String(describing: (self?.uploadedQueue.count)!))")
                    defaultNotificationCenter().post(name: NSNotification.Name.Backup.AutoBackupCountChangeNotiKey, object: nil)
                    self?.schedule()
                    
                }else {
                    self?.uploadingQueue.append(model)
                    self?.workingQueue.async {
//                           [self scheduleForUpload:model andUseTimeStamp:NO];
                    }
                }
            }
        }
    }
    
    
    // retry if eexist
    func scheduleForUpload(model:WSUploadModel,useTimeStamp:Bool){
//    __weak typeof(self) weakSelf = self;
//    __weak typeof(WB_AppServices) weak_AppService = WB_AppServices;
        self.workingQueue.async { [weak self] in
            model.start(useTimeStamp:useTimeStamp , callback: { (error, response) in
                
            })
        }
        
        
//    dispatch_async(self.workingQueue, ^{
//    [model startUseTimeStamp:yesOrNo completeBlock:^(NSError *error, id response) {
//    if(!weakSelf) return;
//    dispatch_async(weakSelf.managerQueue, ^{
//    if (error) {
//    if (error.wbCode == WBUploadDirNotFound) {
//    [weakSelf stop];   // stop
//    // need rebuild
//    [weakSelf destroy];
//    NSLog(@"文件上传目录丢失 开始重建");
//    [weak_AppService rebulidUploadManager];
//    }else if (error.wbCode == WBUploadFileExist) {
//    // rename then retry
//    NSLog(@"文件 EExist,  重命名 再次尝试！");
//    [weakSelf scheduleForUpload:model andUseTimeStamp:YES];
//    }else {
//    if(!model.isRemoved)
//    [weakSelf.uploadErrorQueue addObject:model];
//    [weakSelf.uploadingQueue removeObject:model];
//    NSLog(@"上传失败 , error: %lu  finish:%lu", (unsigned long)weakSelf.uploadErrorQueue.count, (unsigned long)weakSelf.uploadedQueue.count);
//    }
//    }else{  // success
//    NSLog(@"上传成功 , error: %lu  finish:%lu", (unsigned long)weakSelf.uploadErrorQueue.count, (unsigned long)weakSelf.uploadedQueue.count);
//    [weakSelf.uploadingQueue removeObject:model];
//    [weakSelf.uploadedLocalHashSet addObject:model.asset.digest]; // record for skip equal-hash asset
//    if(![weakSelf.uploadedQueue containsObject:model]) {
//    if(!model.isRemoved)
//    [weakSelf.uploadedQueue addObject:model];
//    [weakSelf.uploadingQueue removeObject:model];
//    [[NSNotificationCenter defaultCenter] postNotificationName:WBBackupCountChangeNotify object:nil];
//    }
//    }
//    [weakSelf schedule];
//    });
//    }];
//    });
    }
    
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
    
    func  getAssetSha256(asset:WSAsset,callback:@escaping (_ error:Error?, _ sha256String:String?)->()){
        if asset.asset == nil {
            return callback(BaseError(localizedDescription: ErrorLocalizedDescription.Asset.AssetNotFound, code: ErrorCode.Asset.AssetNotFound),nil)
        }
        let localAsset = AppService.sharedInstance().assetService.getAsset(localId: asset.asset!.localIdentifier)
        if localAsset != nil{
                asset.digest = localAsset?.digest
            callback(nil, localAsset?.digest);
        }else{
           _ = asset.asset?.getSha256(callback: { (error, sha256) in
                if error != nil{
                  return callback(error, nil)
                }else{
                  asset.digest = sha256
                    DispatchQueue.global(qos: .default).async {
                        AppAssetService.saveAsset(localId: (asset.asset?.localIdentifier)!, digest: sha256!)
                    }
                    return callback(nil, sha256)
                }
            })
        }

    }
    
    lazy var uploadedNetHashSet = Set<String>.init()
    
    lazy var uploadedLocalHashSet = Set<String>.init()
    
    lazy var uploadedNetQueue =  Array<EntriesModel>.init()
    
    lazy var managerQueue: DispatchQueue = {
        let queue = DispatchQueue.init(label: "com.wisnuc.autoBackupManager.main")
        DispatchQueue.global(qos: .default).setTarget(queue: queue)
        return queue
    }()

    lazy var workingQueue: DispatchQueue = {
        let queue = DispatchQueue(label: "com.wisnuc.autoBackupManager.workingQueue", attributes: .concurrent)
         DispatchQueue.global(qos: .userInitiated).setTarget(queue: queue)
        return queue
    }()
}

class WSUploadModel: NSObject {
    
    var shouldStop:Bool?
    
    var asset:WSAsset?
    
    var isRemoved:Bool?
    
    var dataTask:URLSessionDataTask?
    
    var requestFileID:PHImageRequestID?
    
    init(asset:WSAsset) {
        super.init()
        self.asset = asset
        self.shouldStop = false
    }
    
    func start(useTimeStamp:Bool,callback:@escaping (_ error:Error?,_ any:Any?)->()){
    /*
     * WISNUC API:UPLOAD A FILE
     */
//    self.callback = callback;
    let invaildChars = ["/", "?", "<", ">", "\\", ":", "*", "|", "\""]
        self.requestFileID =  self.asset?.asset?.getFile(callBack: { [weak self] (error, filePath) in
            if error != nil{
              return callback(error,nil)
            }
            if (self?.shouldStop!)! {
                return callback(BaseError(localizedDescription: ErrorLocalizedDescription.Backup.BackupCancel, code: ErrorCode.Backup.BackupCancel), nil)
            }
       print("==========================开始上传==============================")
            let hashString = self?.asset?.digest
            let sizeNumber = FileTools.fileSizeAtPath(filePath: filePath!)
            let exestr = filePath?.lastPathComponent
            var fileName = PHAssetResource.assetResources(for: (self?.asset?.asset!)!).first?.originalFilename
            if fileName == nil {
                fileName = exestr
            }
            
            let requestTempPath = "\(filePath!)_temp"
            let requestFileTempPathUrl = NSURL.init(fileURLWithPath: requestTempPath)
           
            
            let  tempFileName = NSMutableString.init(string: fileName!)
            for i in 0..<tempFileName.length{
                if invaildChars.contains(((fileName! as NSString).substring(with: NSMakeRange(i, 1))) as String){
                    tempFileName.replaceCharacters(in: NSMakeRange(i, 1), with:"_" )
                }
            }
            fileName = tempFileName as String
            if(useTimeStamp) {
                fileName = "\(Date.init().timeIntervalSince1970)_\(String(describing: fileName))"
            }
            NSLog("filename :\(String(describing: fileName))")
            var urlString:String?
            let requestHTTPHeaders = [kRequestAuthorizationKey:JWTTokenString(token: AppTokenManager.token!)]
            var mutableDic:Dictionary<String, Any>? = Dictionary<String, Any>.init()
            if AppUserService.currentUser?.isLocalLogin == nil {return}
            if AppNetworkService.networkState == .local {
                //    urlString = [NSString stringWithFormat:@"%@drives/%@/dirs/%@/entries/",[JYRequestConfig sharedConfig].baseURL,AppUserService.currentUser.userHome, AppUserService.currentUser.backUpDir];
                //    mutableDic = nil;
                //    [_manager.requestSerializer setValue:[NSString stringWithFormat:@"JWT %@",AppUserService.defaultToken] forHTTPHeaderField:@"Authorization"];
            }else {
                    urlString = "\(kCloudAddr)\(kCloudCommonPipeUrl)"
                let requestUrl = "/drives/\((AppUserService.currentUser?.userHome!)!)/dirs/\((AppUserService.currentUser?.backUpDirectoryUUID!)!)/entries"
                    let resource = requestUrl.toBase64()
                var manifestDic  = Dictionary<String, Any>.init()
                    manifestDic[kRequestOpKey] = "newfile"
                    manifestDic[kRequestMethodKey] = RequestMethodValue.POST
                    manifestDic[kRequestToNameKey] = fileName!
                    manifestDic[kRequestResourceKey] = resource
                    manifestDic["sha256"]  = hashString!
                    manifestDic["size"] = NSNumber.init(value: sizeNumber)
                    let josnData = jsonToData(jsonDic: manifestDic as NSDictionary)
    
                    let result = String.init(data: josnData!, encoding: String.Encoding.utf8)
                    mutableDic!["manifest"] = result
            }
            var originalRequest: URLRequest?
            do {
                originalRequest = try URLRequest(url: URL.init(string: urlString!)! , method:.post, headers: requestHTTPHeaders)
                originalRequest?.timeoutInterval = TimeInterval(30)
                let encodedURLRequest = try  URLEncoding.default.encode(originalRequest!, with: nil)
                Alamofire.upload(multipartFormData: { (formData) in
                    if AppNetworkService.networkState == .normal{
                        formData.append(URL.init(fileURLWithPath: filePath!), withName: fileName!, fileName: fileName!, mimeType: "image/jpeg")
                    }else{
                        let dic = ["size":NSNumber.init(value: sizeNumber) ,"sha256":hashString!] as NSDictionary
                        let jsonData =  jsonToData(jsonDic: dic)
                        let jsonString = String.init(data: jsonData!, encoding: String.Encoding.utf8)
                        formData.append(URL.init(fileURLWithPath: filePath!), withName: fileName!, fileName: jsonString!, mimeType: "image/jpeg")
                    }
                }, with: encodedURLRequest, encodingCompletion: { (response) in
                    switch response {
                    case .success(let upload, _, _):
                        upload.validate(statusCode: 200..<500)
                            .validate(contentType: ["application/json"])
                            .responseData(completionHandler: { (responseData) in
                            
                                    
                                
                            })
                    case .failure(let error):
                        return  callback(error,nil)
                    }
                })
                
            } catch {
                return callback(BaseError.init(localizedDescription: LocalizedString(forKey: "无法创建请求"), code: ErrorCode.Network.CannotBuidRequest),nil)
            }
          
            
//    NSString * requestTempPath = [NSString stringWithFormat:@"%@_temp", filePath];
//    NSURL *requestFileTempPath = [NSURL fileURLWithPath:requestTempPath];
//    
//    
//    NSMutableURLRequest *request = [_manager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:mutableDic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//    if(AppUserService.currentUser.isCloudLogin) {
//    [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:fileName fileName:fileName mimeType:@"image/jpeg" error:nil];
//    }else {
//    NSDictionary *dic = @{@"size":@(sizeNumber),@"sha256":hashString};
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
//    NSString *jsonString =  [[NSString alloc] initWithData:jsonData  encoding:NSUTF8StringEncoding];
//    [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:fileName fileName:jsonString mimeType:@"image/jpeg" error:nil];
//    }
//    } error:nil];
//    
//    [_manager.requestSerializer requestWithMultipartFormRequest:request writingStreamContentsToFile:requestFileTempPath completionHandler:^(NSError * _Nullable error) {
//    if(error) return callback(error, nil);
//    if(_shouldStop) return callback([NSError errorWithDomain:@"cancel" code:20010 userInfo:nil], nil);
//    request.HTTPBodyStream = nil;
//    weak_self.dataTask = [_manager uploadTaskWithRequest:request fromFile:requestFileTempPath progress:^(NSProgress * _Nonnull uploadProgress) {
//    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
//    NSError *fileError;
//    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&fileError];
//    [[NSFileManager defaultManager] removeItemAtPath:requestTempPath error:&fileError];
//    
//    NSLog(@"%@",fileError);
//    if(!weak_self) return;
//    if(_shouldStop) return callback([NSError errorWithDomain:@"cancel" code:20010 userInfo:nil], nil);
//    if(!error) {
//    NSLog(@"Upload Success -->");
//    if(weak_self.callback) weak_self.callback(nil, responseObject);
//    }else {
//    NSLog(@"Upload Failure ---> : %@", error);
//    NSLog(@"Upload Failure ---> : %@  ----> statusCode: %ld", fileName, (long)((NSHTTPURLResponse *)response).statusCode);
//    NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
//    if(errorData.length >0 && ((NSHTTPURLResponse *)response).statusCode == 403){
//    NSMutableArray *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
//    NSLog(@"Upload Failure ---> :serializedData %@", serializedData);
//    if([serializedData isKindOfClass:[NSArray class]]) {
//    @try {
//    NSDictionary *errorRootDic = serializedData[0];
//    NSDictionary *errorDic = errorRootDic[@"error"];
//    NSString *code = errorDic[@"code"];
//    NSInteger status = [errorDic[@"status"] integerValue];
//    if ([code isEqualToString:@"EEXIST"])
//    error.wbCode = WBUploadFileExist;
//    if(status == 404)
//    error.wbCode = WBUploadDirNotFound;
//    } @catch (NSException *exception) {
//    NSLog(@"%@", exception);
//    }
//    }
//    }
//    weak_self.error = error;
//    if (weak_self.callback) weak_self.callback(error, nil);
//    }
//    
//    }];
//    [weak_self.dataTask resume];
//    }];
//            
        })
    }
    
    
//    @property (nonatomic, copy) void(^callback)(NSError * , id);
}
