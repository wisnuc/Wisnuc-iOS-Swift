
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
    private var isDestroying = false
    private var shouldNotify = false
    private var needRetry = true

    lazy var hashwaitingQueue = Array<WSAsset>.init()
    
    lazy var hashWorkingQueue = Array<WSAsset>.init()
    
    lazy var hashFailQueue = Array<WSAsset>.init()
    
    lazy var uploadPaddingQueue = Array<WSAsset>.init()
    
    lazy var uploadingQueue = Array<WSUploadModel>.init()
    
    lazy var uploadedQueue = Array<WSUploadModel>.init()
    
    lazy var uploadErrorQueue = Array<WSUploadModel>.init()
    
    var sessionManager: SessionManager!
    
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
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.wisnuc.app.backgroundtransfer")
        sessionManager = Alamofire.SessionManager(configuration: configuration)
        shouldUpload = false
        hashLimitCount = 4
        uploadLimitCount = 4
    }

    func startAutoBcakup() {
        self.shouldUpload = false
        // notify for start
        defaultNotificationCenter().post(name: NSNotification.Name.Backup.AutoBackupCountChangeNotiKey, object: nil)
        self.managerQueue.async { [weak self]  in
            for model in (self?.uploadErrorQueue)!{
                self?.uploadPaddingQueue.append(model.asset!)
            }
            self?.uploadErrorQueue.removeAll()
            self?.shouldUpload = true
            self?.needRetry  = true
            self?.schedule()
        }
    }
    
    func destroy(){
        isDestroying = true
        self.stop()
        removeAll()
//        self.hashwaitingQueue.removeAll()
//        // TODO: cancel working queue?
//        self.hashWorkingQueue.removeAll()
//        self.hashFailQueue.removeAll()
//
//        self.uploadPaddingQueue.removeAll()
//
//        self.uploadingQueue.removeAll()
//        self.uploadedQueue.removeAll()
//        self.uploadErrorQueue.removeAll()
//        self.uploadedNetQueue.removeAll()
//        self.uploadedLocalHashSet.removeAll()
//
        self.sessionManager.session.invalidateAndCancel()
        shouldNotify = false
        needRetry = true
        shouldUpload = false
        isDestroying = false
    }
    
    
    func removeAll(){
        self.hashwaitingQueue.removeAll()
        // TODO: cancel working queue?
        self.hashWorkingQueue.removeAll()
        self.hashFailQueue.removeAll()
        
        self.uploadPaddingQueue.removeAll()
        self.uploadingQueue.removeAll()
        self.uploadedQueue.removeAll()
        self.uploadErrorQueue.removeAll()
        self.uploadedNetQueue.removeAll()
        self.uploadedLocalHashSet.removeAll()
    }
    
    func fetchAllCount(callback:@escaping (_ allCount:Int)->()) {
        self.managerQueue.async {
            let allCount =  self.hashwaitingQueue.count + self.hashWorkingQueue.count + self.hashFailQueue.count
            + self.uploadPaddingQueue.count + self.uploadingQueue.count
            + self.uploadedQueue.count + self.uploadErrorQueue.count
            callback(allCount)
        }
    }

    
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
    
    func start(localAssets:Array<WSAsset>,netAssets:Array<EntriesModel>){
        self.managerQueue.async { [weak self] in
            self?.shouldNotify = true
            self?.needRetry = true
//
            self?.hashwaitingQueue.append(contentsOf: localAssets)
            self?.hashwaitingQueue.sort { $0.createDate! > $1.createDate! }
            self?.uploadedNetQueue.append(contentsOf: netAssets)
            var hashSet = Set<String>.init()
            for model in netAssets{
                if model.type == FilesType.file.rawValue && model.hash != nil{
                    hashSet.insert(model.hash!)
                }
            }
            self?.shouldUpload = false
            self?.uploadedNetHashSet = hashSet
            self?.schedule()
        }
    }
    
    func schedule(){
        if isDestroying {return}
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
                if let eLocation = location{
                    self?.hashwaitingQueue.remove(at: eLocation)
                }
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
                            if let eLocation = location{
                                self?.hashWorkingQueue.remove(at: eLocation)
                            }
                            self?.schedule()
                        }
                    })
                }
            }
            
            if !(self?.shouldUpload!)! {return}
            while((self?.uploadPaddingQueue.count)! > 0 && (self?.uploadingQueue.count)! < (self?.uploadLimitCount)!) {
                let asset = self?.uploadPaddingQueue.first
                let location = self?.uploadPaddingQueue.index(of: asset!)
                if let eLocation = location{
                     self?.uploadPaddingQueue.remove(at: eLocation)
                }
                let model = WSUploadModel.init(asset: asset!, manager: (self?.sessionManager)!)
                if (self?.uploadedNetHashSet.contains((asset?.digest)!))! || (self?.uploadedLocalHashSet.contains((asset?.digest)!))! {
                    self?.uploadedQueue.append(model)
                    print("发现一个已上传的，直接跳过, error: \(String(describing: (self?.uploadErrorQueue.count)!)) finish:\(String(describing: (self?.uploadedQueue.count)!))")
                    defaultNotificationCenter().post(name: NSNotification.Name.Backup.AutoBackupCountChangeNotiKey, object: nil)
                    self?.schedule()
                    
                }else {
                    self?.uploadingQueue.append(model)
                    self?.workingQueue.async {
                           self?.scheduleForUpload(model: model, useTimeStamp: false)
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
            model.start(useTimeStamp:useTimeStamp , callback: { [weak self](error, response) in
                self?.managerQueue.async {
                    if error != nil{
                        if error is BaseError{
                            let baseError = error as! BaseError
                            switch baseError.code {
                            case ErrorCode.Backup.BackupDirNotFound:
                                 self?.stop()
                                 self?.destroy()
//                                 NSLog(@"文件上传目录丢失 开始重建");
                                 AppService.sharedInstance().rebuildAutoBackupManager()
                            case ErrorCode.Backup.BackupFileExist:
                                self?.scheduleForUpload(model: model, useTimeStamp: true)
                            default:
                                if !model.isRemoved!{
                                    self?.uploadErrorQueue.append(model)
                                    let location = self?.uploadingQueue.index(of: model)
                                    if let eLocation = location{
                                        self?.uploadingQueue.remove(at: eLocation)
                                    }
                                    print("上传失败 , error:\(String(describing: self?.uploadErrorQueue.count))  finish:\(String(describing: self?.uploadedQueue.count))")
                                }
                            }
                        }
                    }else{
                        print("上传成功 , error:\(String(describing: self?.uploadErrorQueue.count))  finish:\(String(describing: self?.uploadedQueue.count))")
                        if let location = self?.uploadingQueue.index(of: model){
                            self?.uploadingQueue.remove(at: location)
                        }
                        
                        self?.uploadedLocalHashSet.insert((model.asset?.digest!)!)
                        if !((self?.uploadedQueue.contains(model))!){
                            if !model.isRemoved! {
                                self?.uploadedQueue.append(model)
                                if let location = self?.uploadingQueue.index(of: model){
                                    self?.uploadingQueue.remove(at: location)
                                }
                                defaultNotificationCenter().post(name: NSNotification.Name.Backup.AutoBackupCountChangeNotiKey, object: nil)
                            }
                        }
                    }
                    self?.schedule()
                }
            })
        }
    }
    
//
    func stop(){
        self.shouldUpload = false
        //TODO: hash queue should stop?
        
        for model in self.uploadingQueue {
            model.cancel()
        }
       
        if let manager = sessionManager {
            manager.session.getAllTasks(completionHandler: { (uploadTasks) in
                uploadTasks.forEach { $0.cancel() }
            })
        }
        
         removeAll()
    }
    

//
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
        DispatchQueue.global(qos: .background).setTarget(queue: queue)
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
    
    var isRemoved:Bool? = false
    
    var requestFileID:PHImageRequestID?
    
    var manager:SessionManager?
    init(asset:WSAsset,manager:SessionManager) {
        super.init()
        self.asset = asset
        self.manager = manager
        self.shouldStop = false
    }
    
    func cancel() {
        self.shouldStop = false
        if requestFileID != nil {
            PHImageManager.default().cancelImageRequest(requestFileID!)
            requestFileID = PHInvalidImageRequestID
        }
        if manager != nil{
            manager?.session.getAllTasks(completionHandler: { (uploadTasks) in
                uploadTasks.forEach { $0.cancel() }
            })
        }
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
            
//            let requestTempPath = "\(filePath!)_temp"
//            let requestFileTempPathUrl = NSURL.init(fileURLWithPath: requestTempPath)
           
            
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
            NSLog("filename :\(String(describing: fileName!))")
            var urlString:String?
            let requestHTTPHeaders = [kRequestAuthorizationKey:JWTTokenString(token: AppTokenManager.token!)]
            var mutableDic:Dictionary<String, Any>? = Dictionary<String, Any>.init()
            if AppUserService.currentUser?.isLocalLogin == nil {return}
            if AppNetworkService.networkState == .local {
                urlString = "\((RequestConfig.sharedInstance.baseURL!))/drives/\(String(describing: (AppUserService.currentUser?.userHome!)!))/dirs/\(String(describing: (AppUserService.currentUser?.backUpDirectoryUUID!)!))/entries/"
                mutableDic = nil
                mutableDic = Dictionary<String, Any>.init()
            }else {
                    urlString = "\(kCloudAddr)\(kCloudCommonPipeUrl)"
                let requestUrl = "/drives/\((AppUserService.currentUser?.userHome!)!)/dirs/\((AppUserService.currentUser?.backUpDirectoryUUID!)!)/entries"
                    let resource = requestUrl.toBase64()
                var manifestDic  = Dictionary<String, Any>.init()
                    manifestDic[kRequestOpKey] = kRequestOpNewFileValue
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
                
                self?.manager?.upload(multipartFormData: { (formData) in
                    if AppNetworkService.networkState == .normal{
                        formData.append(URL.init(fileURLWithPath: filePath!), withName: fileName!, fileName: fileName!, mimeType: "image/jpeg")
                    }else{
                        let dic = ["size":NSNumber.init(value: sizeNumber) ,"sha256":hashString!, kRequestOpKey:kRequestOpNewFileValue] as NSDictionary
                        let jsonData =  jsonToData(jsonDic: dic)
                        let jsonString = String.init(data: jsonData!, encoding: String.Encoding.utf8)
                        formData.append(URL.init(fileURLWithPath: filePath!), withName: fileName!, fileName: jsonString!, mimeType: "image/jpeg")
                    }
                }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, with: encodedURLRequest, encodingCompletion: { (encodingResult) in
                    switch (encodingResult) {
                    // encodingResult success
                    case .success(let request, let streamingFromDisk, let streamFileURL):
                        print("\(streamingFromDisk) \(String(describing: streamFileURL))")
                        // upload progress closure
                        request.uploadProgress(closure: { (progress) in
                            print("upload progress: \(progress.fractionCompleted)")
                            // here you can send out to a delegate or via notifications the upload progress to interested parties
                        })
                        request.validate(statusCode: 200..<500)
                        // response handler
                        request.responseJSON(completionHandler: { response in
                            switch response.result {
                            case .success(let jsonData):
                                // do any parsing on your request's response if needed
                                callback(nil,(jsonData as AnyObject).value)
                            case .failure(let error):
                                print(error)
                                return callback(error,nil)
                            }
                            
                            if let filePath = filePath{
                                do {
                                    try FileManager.default.removeItem(atPath: filePath)
                                }catch{
                                    print(error)
                                }
                            }
                          
                            if let streamFileURL = streamFileURL{
                                do {
                                    try FileManager.default.removeItem(at: streamFileURL)
                                }catch{
                                    print(error)
                                }
                            }
                        })
                    // encodingResult failure
                    case .failure(let error):
                    print(error )
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
