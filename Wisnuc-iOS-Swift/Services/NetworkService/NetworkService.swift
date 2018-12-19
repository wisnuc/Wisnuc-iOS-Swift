//
//  NetworkService.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/30.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher

enum ChannelState:String {
    case Connected
    case Disconnected
}

class NetworkService: NSObject {
    var networkState:NetworkServiceState?{
        didSet{
            switch networkState {
            case .normal?:
                networkStateNormalAction()
            case .local?:
                networkStateLocalAction()
            default:
                break
            }
        }
    }
    
    override init() {
        super.init()
    }
    
    func changeNet(_ status:WSNetworkStatus){
        #warning("切换网络")
        if !AppUserService.isUserLogin{
            return
        }
        switch status {
        case .WIFI:
            if networkState == .normal || networkState == nil {
                 self.networkState = .normal
                        guard let ip = AppUserService.currentUser?.lanIP else{
                            return
                        }
                        self.checkIP(address:ip, { (isLocal) in
                            if isLocal{
                                if AppUserService.currentUser?.localToken != nil{
                                    self.networkState = .local
                                }else{
                                    self.getLocalInCloudLogin { [weak self] (error, localToken) in
                                        if error == nil {
                                            AppUserService.currentUser?.localToken = localToken
                                            AppUserService.synchronizedCurrentUser()
                                             self?.networkState = .local
                                        }else{
                                            //                                  Message.message(text: (error?.localizedDescription)!)
                                            self?.networkState = .normal
                                        }
                                    }
                                    self.networkState = .normal
                                }
                            }
                        })
            }else{
//                 self.networkState = .normal
                guard let ip = AppUserService.currentUser?.lanIP else{
                    return
                }
                self.checkIP(address:ip, { (isLocal) in
                    if isLocal{
                        if AppUserService.currentUser?.localToken != nil{
                            self.networkState = .local
                        }else{
                            self.networkState = .normal
                        }
                    }
                })
            }
        case .ViaWWAN:
            if networkState == .local{
                if AppUserService.currentUser?.cloudToken != nil {
                    self.networkState = .normal
                }else{
                    self.networkState = .local
                }
            }
        default:
            break
        }
    }
    
    func networkStateNormalAction() {
        Message.message(text: "外网")
        
        RequestConfig.sharedInstance.baseURL = kCloudBaseURL
        AppTokenManager.token = AppUserService.currentUser?.cloudToken
    }
    
    func networkStateLocalAction() {
        Message.message(text: "内网")
        
        RequestConfig.sharedInstance.baseURL = AppUserService.currentUser?.localAddr!
        AppTokenManager.token = AppUserService.currentUser?.localToken
    }
    
    func checkIP(address:String, _ closure:@escaping (_ success:Bool)->()) {
        let requestURL = "http://\(address):3001/winasd/info"
        do {
            var urlRequest = try URLRequest.init(url: URL.init(string: requestURL)!, method: HTTPMethod.get)
            urlRequest.timeoutInterval = TimeInterval.init(10)
            Alamofire.request(urlRequest).validate().response { (response) in
                if response.error == nil{
                    guard let data = response.data else{
                        return closure(false)
                    }
            
                    guard let dic = dataToNSDictionary(data:data) else{
                        return closure(false)
                    }
                   
                    guard let channel = dic["channel"] as? NSDictionary else{
                        return closure(false)
                    }
                    
                    guard let state = channel["state"] as? String else{
                        return closure(false)
                    }
                    
                    if state == ChannelState.Connected.rawValue{
                        return closure(true)
                    }
                }else{
                   return closure(false)
                }
            }
        } catch {
           return closure(false)
        }
    }
    
    func getLocalInCloudLogin(_ closure:@escaping (( _ error:Error?,_ token:String?)->())){
//        if  !AppUserService.isUserLogin {
//            return closure(LoginError(code: ErrorCode.Login.NotLogin, kind: LoginError.ErrorKind.LoginFailure, localizedDescription: LocalizedString(forKey: ErrorLocalizedDescription.Login.NotLogin)), nil)
//        }
        
        if isNilString( AppUserService.currentUser?.cloudToken){
            return closure(LoginError(code: ErrorCode.Login.NoToken, kind: LoginError.ErrorKind.LoginNoToken, localizedDescription: LocalizedString(forKey: ErrorLocalizedDescription.Login.NoToken)), nil)
        }
        
        LocalTokenInCloudAPI.init().startRequestJSONCompletionHandler({ [weak self] (response) in
            if response.error == nil{
                if let errorMessage = ErrorTools.responseErrorData(response.data){
                    let error = NSError(domain: response.response?.url?.absoluteString ?? "", code: ErrorCode.Request.CloudRequstError, userInfo: [NSLocalizedDescriptionKey:errorMessage])
                    return closure(error as! CustomNSError,nil)
                }
                let dic = (response.value as! NSDictionary).object(forKey: "data") as! NSDictionary
                if let token = dic.value(forKey: "token") as? String,let type = dic.value(forKey: "type") as? String{
                    if type == "JWT"{
                       closure(nil,token)
                    }else{
                         closure(LoginError(code: ErrorCode.Login.NoToken, kind: LoginError.ErrorKind.LoginNoToken, localizedDescription: LocalizedString(forKey: ErrorLocalizedDescription.Login.NoToken)),nil)
                    }
                }else{
                    closure(LoginError(code: ErrorCode.Login.NoToken, kind: LoginError.ErrorKind.LoginNoToken, localizedDescription: LocalizedString(forKey: ErrorLocalizedDescription.Login.NoToken)),nil)
                }
            }else{
                closure(response.error,nil)
            }
        })
    }
    
    func getUserAllDrive(user:User, _ callBack:@escaping (_ error:Error?, _ driveModels:[DriveModel]?)->()) {
        DriveAPI.init(type: .fetchInfo,user:user).startRequestJSONCompletionHandler { (response) in
            if response.error == nil{
                let isLocalRequest = AppNetworkService.networkState == .local
                let responseArr = isLocalRequest ? response.value as! NSArray : (response.value as! NSDictionary).object(forKey: "data") as! NSArray
                var models:[DriveModel] = [DriveModel]()
                responseArr.enumerateObjects({ (obj, idx, stop) in
                    let dic = obj as! NSDictionary
                    if let driveModel = DriveModel.deserialize(from: dic) {
                       models.append(driveModel)
                    }
                })
                return callBack(nil, models)
            }else{
                return callBack(response.error, nil)
            }
        }
    }
    
    func getUserAllBackupDrive(_ callBack:@escaping (_ error:Error?, _ driveModels:[DriveModel]?)->()) {
        if !AppUserService.isUserLogin {
            return callBack(LoginError(code: ErrorCode.Login.NotLogin, kind: LoginError.ErrorKind.LoginFailure, localizedDescription: ErrorLocalizedDescription.Login.NotLogin), nil)
        }
        
        DriveAPI.init(type: .fetchInfo).startRequestJSONCompletionHandler { (response) in
            if response.error == nil{
                let isLocalRequest = AppNetworkService.networkState == .local
                var responseArr:NSArray = NSArray.init()
                if let dataArray = (response.value as? NSDictionary)?.object(forKey: "data") as? NSArray{
                    responseArr = dataArray
                }else if let array = (response.value as? NSArray){
                    responseArr = array
                }
                
                var models:[DriveModel] = [DriveModel]()
                responseArr.enumerateObjects({ (obj, idx, stop) in
                    let dic = obj as! NSDictionary
                    if let driveModel = DriveModel.deserialize(from: dic) {
                        if driveModel.type == DriveType.backup.rawValue{
                            if !AppUserService.backupArray.contains(where: {$0.uuid == driveModel.uuid}){
                                AppUserService.backupArray.append(driveModel)
                            }
                            models.append(driveModel)
                        }
                    }
                })
                return callBack(nil, models)
            }else{
                return callBack(response.error, nil)
            }
        }
    }
    
    func getShareSpaceBuiltIn(_ callBack:@escaping (_ error:Error?, _ uuid:String?)->()) {
        if !AppUserService.isUserLogin {
            return callBack(LoginError(code: ErrorCode.Login.NotLogin, kind: LoginError.ErrorKind.LoginFailure, localizedDescription: ErrorLocalizedDescription.Login.NotLogin), nil)
        }
        
        var find:Bool = false
        DriveAPI.init(type: .fetchInfo).startRequestJSONCompletionHandler { (response) in
            if response.error == nil{
                let isLocalRequest = AppNetworkService.networkState == .local
                let responseArr = isLocalRequest ? response.value as! NSArray : (response.value as! NSDictionary).object(forKey: "data") as! NSArray
                responseArr.enumerateObjects({ (obj, idx, stop) in
                    let dic = obj as! NSDictionary
                    if let driveModel = DriveModel.deserialize(from: dic) {
                        if driveModel.tag == "built-in"{
                            find = true
                            stop.pointee = true
                            return callBack(nil, driveModel.uuid);
                        }
                    }
                })
                
                if !find{
                    return callBack(LoginError.init(code: ErrorCode.Login.NoUserHome, kind: LoginError.ErrorKind.LoginNoUserHome, localizedDescription: ErrorLocalizedDescription.Login.NoUserHome), nil)
                }
            }else{
                return callBack(response.error, nil)
            }
        }
    }
    
    func creactBackupDrive(user:User? = nil,callBack:@escaping (_ error:Error?,_ model:DriveModel?)->()){
        DriveAPI.init(type: .creatBackup,user:user).startRequestJSONCompletionHandler { (response) in
            if response.error == nil{
                if let errorMessage = ErrorTools.responseErrorData(response.data){
                    let error = NSError(domain: response.response?.url?.absoluteString ?? "", code: ErrorCode.Request.CloudRequstError, userInfo: [NSLocalizedDescriptionKey:errorMessage])
                    return callBack(error as! CustomNSError,nil)
                }
                let isLocalRequest = AppNetworkService.networkState == .local
                var responseDic = NSDictionary.init()
                if isLocalRequest{
                    responseDic = response.value as! NSDictionary
                }else{
                    guard let rootDic = response.value as? NSDictionary else {
                        let error = NSError(domain: response.response?.url?.absoluteString ?? "", code: ErrorCode.JsonModel.SwitchTOModelFail, userInfo: [NSLocalizedDescriptionKey:ErrorLocalizedDescription.JsonModel.SwitchTOModelFail])
                        return callBack(error as! CustomNSError,nil)
                    }
                    responseDic = rootDic["data"] as! NSDictionary
                }
               
                if let driveModel = DriveModel.deserialize(from: responseDic) {
                    if !AppUserService.backupArray.contains(where: {$0.uuid == driveModel.uuid}){
                        AppUserService.backupArray.append(driveModel)
                    }
                    return callBack(nil, driveModel)
                }
              
            }else{
                return callBack(response.error, nil)
            }
        }
    }
    
    
    func getUserBackupDir(name:String ,_ callback:@escaping (_ error:Error?,_ entryUUID:String?)->()){
        if !AppUserService.isUserLogin {
            return callback(LoginError(code: ErrorCode.Login.NotLogin, kind: LoginError.ErrorKind.LoginFailure, localizedDescription: ErrorLocalizedDescription.Login.NotLogin), nil)
        }
        
        self.getDirUUID(name: name, driveUUID: (AppUserService.currentUser?.userHome)! ,dirUUID: (AppUserService.currentUser?.userHome)!) {[weak self] (getDirUUIDError, directoryUUID) in
            if getDirUUIDError != nil{
                return callback(getDirUUIDError, nil)
            }else{
                //                saveToUserDefault(value: directoryUUID!, key: kBackupBaseEntryKey)
                // 获取backup 目录 ，如果没有就创建
                // backupBaseDir 就是 “上传的图片” 文件夹 , backupDir 就是 “来自xxx” 文件夹
                let fromName:String = "来自\(UIDevice.current.modelName)"
                self?.getDirUUID(name: fromName, driveUUID: (AppUserService.currentUser?.userHome)!,dirUUID:directoryUUID!,callBack: { (deviceFromError, deviceFromDirUUID) in
                    if deviceFromError != nil{
                        return callback(deviceFromError,nil)
                    }else{
                        //                        saveToUserDefault(value: directoryUUID!, key: kBackupDirectory)
                        return callback(nil, deviceFromDirUUID);
                    }
                })
            }
        }
    }
    
    // 获取backup目录下的所有文件
    func getEntriesInUserBackupDirectory(uuid:String,callback:@escaping (_ error:Error?,_ entries:Array<EntriesModel>?)->()){
//        if let backUpDirectoryUUID = AppUserService.currentUser?.backUpDirectoryUUID {
            DriveDirAPI.init(driveUUID: uuid, directoryUUID: uuid).startRequestJSONCompletionHandler { [weak self] (response) in
                if response.error == nil{
                    if let errorMessage = ErrorTools.responseErrorData(response.data){
                        Message.message(text: errorMessage)
                        return
                    }
                    let dic = self?.networkState == .normal ? (response.value as! NSDictionary)["data"] as! NSDictionary: response.value as! NSDictionary
                    let array = NSArray.init(array: dic.object(forKey: "entries") as! NSArray)
                    var entries = Array<EntriesModel>.init()
                    array.enumerateObjects({ (obj, idx, stop) in
                        let dic = obj as! NSDictionary
                        do{
                            let data = jsonToData(jsonDic: dic)
                            let model = try JSONDecoder().decode(EntriesModel.self, from: data!)
                            entries.append(model)
                        }catch{
                            callback(BaseError(localizedDescription: ErrorLocalizedDescription.JsonModel.SwitchTOModelFail, code: ErrorCode.JsonModel.SwitchTOModelFail),nil)
                        }
                    })
                  callback(nil,entries)
                }else{
                    if let httpStatusCode = response.response?.statusCode {
                        switch(httpStatusCode) {
                        case 404:
                         callback(BaseError(localizedDescription: ErrorLocalizedDescription.Backup.BackupDirNotFound, code: ErrorCode.Backup.BackupDirNotFound), nil)
                        default:
                         callback(response.error, nil)
                        }
                    } else {
                        callback(response.error, nil)
                    }
                }
            }
        }
//        else{
//
//            callback(BaseError(localizedDescription: ErrorLocalizedDescription.Backup.BackupDirNotFound, code: ErrorCode.Backup.BackupDirNotFound), nil)
//        }
       
//    FLGetDriveDirAPI *api = [FLGetDriveDirAPI apiWithDrive:WB_UserService.currentUser.userHome dir:WB_UserService.currentUser.backUpDir];
//    [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
//    NSDictionary * dic = WB_UserService.currentUser.isCloudLogin ? request.responseJsonObject[@"data"] : request.responseJsonObject;
//    NSArray * arr = [NSArray arrayWithArray:[dic objectForKey:@"entries"]];
//    NSMutableArray * entries = [NSMutableArray arrayWithCapacity:0];
//    [arr enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//    EntriesModel *model = [EntriesModel modelWithDictionary:obj];
//    [entries addObject:model];
//    }];
//    callback(nil, entries);
//    } failure:^(__kindof JYBaseRequest *request) {
//    if(request.responseStatusCode == 404)
//    request.error.wbCode = WBUploadDirNotFound;
//    NSLog(@"get backup dir entries error : %@", request.error);
//    callback(request.error, nil);
//    }];
//    }
    
    // 获取 名为 “上传的照片”（任何name都可以） 的文件夹， 没有就创建
    func getDirUUID(name:String,driveUUID:String,dirUUID:String,callBack:@escaping ((_ error:Error?,_ directoryUUID:String?)->())) {
        let request = DriveDirAPI.init(driveUUID:driveUUID, directoryUUID: dirUUID)
        
        request.startRequestJSONCompletionHandler { (response) in
            if response.error == nil{
                let isLocalRequest = AppNetworkService.networkState == .local
                let dic = isLocalRequest ? response.value as! NSDictionary : (response.value as! NSDictionary).object(forKey: "data") as! NSDictionary
                if dic["code"] != nil{
                    let code = dic["code"] as! NSNumber
                    let message = dic["message"] as! NSString
                    if code.intValue != 1 && code.intValue > 200 {
                        return  callBack(BaseError.init(localizedDescription: message as String, code: Int(code.int64Value)), nil)
                    }
                }
                let arr = NSArray.init(array: dic.object(forKey: "entries") as! NSArray)
                var find:Bool = false
                arr.enumerateObjects({ (obj, idx, stop) in
                    let dic = obj as! NSDictionary
                    //                    if let model = EntriesModel.deserialize(from: dic) {
                    
                    do{
                        let data = jsonToData(jsonDic: dic)
                        let model = try JSONDecoder().decode(EntriesModel.self, from: data!)
                        if model.name == name && model.type == "directory" {
                            find = true
                            stop.pointee = true
                            return callBack(nil, model.uuid)
                        }
                    }catch{
                        return  callBack(BaseError(localizedDescription: ErrorLocalizedDescription.JsonModel.SwitchTOModelFail, code: ErrorCode.JsonModel.SwitchTOModelFail), nil)
                    }
                })
                
                if(!find) {
                    let closure = {(_ callBackError:Error?,directoriesModel:DirectoriesModel?)->() in
                        if callBackError != nil {
                            return callBack(callBackError,nil)
                        }else{
                            return callBack(nil,directoriesModel!.uuid)
                        }
                    }
                    
                    AppNetworkService.networkState == .normal ? self.mkDirIn(dirveUUID: (AppUserService.currentUser?.userHome!)!, directoryUUID:dirUUID , name: name, closure: closure) : self.mkDirLocalIn(driveUUID: (AppUserService.currentUser?.userHome!)!, directoryUUID: dirUUID, name: name, closure: closure)
                }
            }else{
                callBack(response.error,nil)
            }
        }
    }
    
    func mkDirLocalIn(driveUUID:String,directoryUUID:String,name:String,closure:@escaping (_ callBackError:Error?, _ directoriesModel:DirectoriesModel?)->()) {
        let detailURL = "\(kRquestDrivesURL)/\(String(describing: driveUUID))/dirs/\(String(describing: directoryUUID))/entries"
        let requestURL = "\(RequestConfig.sharedInstance.baseURL!)/\(detailURL)"
        let requestHTTPHeaders = [kRequestAuthorizationKey:JWTTokenString(token: AppTokenManager.token!)]
        var originalRequest: URLRequest?
        do {
            originalRequest = try URLRequest(url: URL.init(string: requestURL)! , method:.post, headers: requestHTTPHeaders)
            originalRequest?.timeoutInterval = TimeInterval(30)
            let encodedURLRequest = try  URLEncoding.default.encode(originalRequest!, with: nil)
            Alamofire.upload(multipartFormData: { (formData) in
                let dic = [kRequestOpKey: kRequestMkdirValue]
                do {
                    let data = try JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions.prettyPrinted)
                    formData.append(data, withName: name)
                    
                }catch{
                    return  closure(BaseError.init(localizedDescription: ErrorLocalizedDescription.JsonModel.SwitchTODataFail, code: ErrorCode.JsonModel.SwitchTODataFail),nil)
                }
                
            }, with: encodedURLRequest) { (response) in
                switch response {
                case .success(let upload, _, _):
                    upload.validate(statusCode: 200..<500)
                        .validate(contentType: ["application/json"])
                        .responseData(completionHandler: { (responseData) in
                            do{
                                let json = try JSONSerialization.jsonObject(with: responseData.data!, options: .mutableContainers)
                                if json is NSArray{
                                    let array = json as! NSArray
                                    for value in array{
                                        let dic =  value as! NSDictionary
                                        let dataDic = dic["data"] as! NSDictionary
                                        if dataDic["name"] as! String == name && dataDic["type"] as! String == FilesType.directory.rawValue {
                                            let data = jsonToData(jsonDic: dataDic)
                                            do{
                                                let directoriesModel = try JSONDecoder().decode(DirectoriesModel.self, from: data!)
                                                return closure(nil,directoriesModel)
                                            }catch{
                                                return  closure(BaseError(localizedDescription: ErrorLocalizedDescription.JsonModel.SwitchTOModelFail, code: ErrorCode.JsonModel.SwitchTOModelFail),nil)
                                            }
                                        }
                                    }
//                                    print(array)
                                }else if json is NSDictionary{
                                    let dic = json as! NSDictionary
                                    if dic["code"] != nil{
                                        if dic["message"] is String{
                                            let code = dic["code"] as! String
                                            let message = dic["message"] as! NSString
                                            if code == "EEXIST"{
                                                return closure(BaseError.init(localizedDescription: message as String, code: 0), nil)
                                            }
                                        }else{
                                            let code = dic["code"] as! NSNumber
                                            let message = dic["message"] as! NSString
                                            if code.intValue != 1 && code.intValue > 200 {
                                                return  closure(BaseError.init(localizedDescription: message as String, code: Int(code.int64Value)), nil)
                                            }
                                        }
                                    }
                                }
                            }catch{
                                return closure(BaseError(localizedDescription: ErrorLocalizedDescription.JsonModel.SwitchTOModelFail, code: ErrorCode.JsonModel.SwitchTOModelFail),nil)
                            }
                            do{
                                let directoriesModel = try JSONDecoder().decode(DirectoriesModel.self, from: responseData.data!)
                                return closure(nil,directoriesModel)
                            }catch{
                                return  closure(BaseError(localizedDescription: ErrorLocalizedDescription.JsonModel.SwitchTOModelFail,  code: ErrorCode.JsonModel.SwitchTOModelFail),nil)
                            }
                            
                        })
                case .failure(let error):
                    return  closure(error,nil)
                }
            }
            
        } catch {
            return closure(BaseError.init(localizedDescription: LocalizedString(forKey: "无法创建请求"), code: ErrorCode.Network.CannotBuidRequest),nil)
        }
        
    }
    
    func mkDirIn(dirveUUID:String,directoryUUID:String,name:String,closure:@escaping (_ callBackError:Error?, _ directoriesModel:DirectoriesModel?)->()) {
        MkdirAPI.init(driveUUID: dirveUUID, directoryUUID: directoryUUID, name: name).startRequestDataCompletionHandler { (response) in
            if response.error == nil{
                do{
                    let directoriesModel = try JSONDecoder().decode(DirectoriesModel.self, from: response.data!)
                    closure(nil,directoriesModel)
                }catch{
                    closure(BaseError(localizedDescription: ErrorLocalizedDescription.JsonModel.SwitchTOModelFail, code: ErrorCode.JsonModel.SwitchTOModelFail),nil)
                }
            }else{
                closure(response.error,nil)
            }
        }
    }
    
    //Asset
    func getThumbnail(hash:String,size:CGSize? = nil,callback:@escaping (Error?,UIImage?,URL?)->())->RetrieveImageDownloadTask?{
     
        
//                KingfisherManager.shared
//                    .shared().imageDownloader?.headersFilter = { [weak self] (url:URL?,headers:Dictionary<String,String>?) -> Dictionary<String,String>?  in
//                    var dic = Dictionary<String, String>.init()
//                    dic.merge(with: headers!)
//                    dic = [kRequestAuthorizationKey : self?.networkState == .normal ? AppTokenManager.token! : JWTTokenString(token: AppTokenManager.token!)]
//                    return dic
//                    }
        let detailURL = "media"
        var frameWidth = size?.width
        var frameHeight = size?.height
        if size == nil ||  size == CGSize.zero{
            frameWidth = 200
            frameHeight = 200
        }
        let resource = "/media/\(hash)"
        let param = "\(kRequestImageAltKey)=\(kRequestImageThumbnailValue)&\(kRequestImageWidthKey)=\(String(describing: frameWidth!))&\(kRequestImageHeightKey)=\(String(describing: frameHeight!))&\(kRequestImageModifierKey)=\(kRequestImageCaretValue)&\(kRequestImageAutoOrientKey)=true"
     
        let params:[String:String] = [kRequestImageAltKey:kRequestImageThumbnailValue,kRequestImageWidthKey:String(describing: frameWidth!),kRequestImageHeightKey:String(describing: frameHeight!),kRequestImageModifierKey:kRequestImageCaretValue,kRequestImageAutoOrientKey:"true"]
        let dataDic = [kRequestUrlPathKey:resource,kRequestVerbKey:RequestMethodValue.GET,kRequestImageParamsKey:params] as [String : Any]
        guard let data = jsonToData(jsonDic: dataDic as NSDictionary) else {
          return nil
        }
        
        guard let dataString = String.init(data: data, encoding: .utf8) else {
            return nil
        }
        
        guard let urlString = String.init(describing:"\(kCloudBaseURL)\(kCloudCommonPipeUrl)?data=\(dataString)").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return nil
        }
        
        guard  let normalUrl = URL.init(string:urlString) else {
            return nil
        }
//                req.addValue(dataString, forHTTPHeaderField: kRequestImageDataValue)
       guard let url = AppNetworkService.networkState == .local ? URL.init(string: "\(RequestConfig.sharedInstance.baseURL!)/\(detailURL)/\(hash)?\(param)") : normalUrl else {
            return nil
        }
      
        let modifier = AnyModifier { request in
            var req = request
            req.setValue(self.networkState == .normal ? AppTokenManager.token! : JWTTokenString(token: AppTokenManager.token!), forHTTPHeaderField: kRequestAuthorizationKey)
            if let cookie = AppUserService.currentUser?.cookie{
                if self.networkState == .normal{
                 req.addValue(cookie, forHTTPHeaderField: kRequestSetCookieKey)
                }
            }
           
//            if self.networkState == .normal{
//                if let data = jsonToData(jsonDic: dataDic as NSDictionary){
//                    if let dataString = String.init(data: data, encoding: .utf8){
//                        req.addValue(dataString, forHTTPHeaderField: kRequestImageDataValue)
//                    }
//                }
//            }
            return req
        }
        ImageDownloader.default.downloadTimeout = 20000
        ImageCache.default.maxMemoryCost = 20
        let task =  ImageDownloader.default.downloadImage(with: url, retrieveImageTask: nil, options: [.requestModifier(modifier),.forceRefresh,.backgroundDecode], progressBlock: nil) { (image, error, reqUrl, data) in
            if (image != nil) {
                if let image =  image, let url = reqUrl ,let data = data{
                    ImageCache.default.store(image,
                                             original: data,
                                             forKey: url.absoluteString,
                                             toDisk: true)
                      callback(nil, image,reqUrl)
                }
              
            }else{
                callback(error, nil,reqUrl)
            }
            }
        return task
        //        return SDWebImageDownloader.shared().downloadImage(with: url, options: SDWebImageDownloaderOptions.useNSURLCache, progress: nil, completed: { (image, data, error, finished) in
        //            if (image != nil) {
        //            callback(nil, image)
        //            }else{
        //            callback(error, nil)
        //            }
        //        })!
    }
    
    func getThumbnailx(hash:String,size:CGSize? = nil,callback:@escaping (Error?,UIImage?,URL?)->())->SDWebImageDownloadToken?{
        
        let detailURL = "media"
        var frameWidth = size?.width
        var frameHeight = size?.height
        if size == nil ||  size == CGSize.zero{
            frameWidth = 200
            frameHeight = 200
        }
        let resource = "/media/\(hash)"
        let param = "\(kRequestImageAltKey)=\(kRequestImageThumbnailValue)&\(kRequestImageWidthKey)=\(String(describing: frameWidth!))&\(kRequestImageHeightKey)=\(String(describing: frameHeight!))&\(kRequestImageModifierKey)=\(kRequestImageCaretValue)&\(kRequestImageAutoOrientKey)=true"
        
        let params:[String:String] = [kRequestImageAltKey:kRequestImageThumbnailValue,kRequestImageWidthKey:String(describing: frameWidth!),kRequestImageHeightKey:String(describing: frameHeight!),kRequestImageModifierKey:kRequestImageCaretValue,kRequestImageAutoOrientKey:"true"]
        let dataDic = [kRequestUrlPathKey:resource,kRequestVerbKey:RequestMethodValue.GET,kRequestImageParamsKey:params] as [String : Any]
        guard let data = jsonToData(jsonDic: dataDic as NSDictionary) else {
            return nil
        }
        
        guard let dataString = String.init(data: data, encoding: .utf8) else {
            return nil
        }
        
        guard let urlString = String.init(describing:"\(kCloudBaseURL)\(kCloudCommonPipeUrl)?data=\(dataString)").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return nil
        }
        
        guard  let normalUrl = URL.init(string:urlString) else {
            return nil
        }
        //                req.addValue(dataString, forHTTPHeaderField: kRequestImageDataValue)
        guard let url = AppNetworkService.networkState == .local ? URL.init(string: "\(RequestConfig.sharedInstance.baseURL!)/\(detailURL)/\(hash)?\(param)") : normalUrl else {
            return nil
        }
        
        SDWebImageDownloader.shared().headersFilter = { (requsetUrl,header) in
            var dic = header
            if let token = AppTokenManager.token{
                dic?[kRequestAuthorizationKey] = self.networkState == .normal ? token : JWTTokenString(token: token)
            }
            if let cookie = AppUserService.currentUser?.cookie{
                if self.networkState == .normal{
                    dic?[kRequestSetCookieKey] =  cookie
                }
            }
            return dic
        }
      
        let task = SDWebImageDownloader.shared().downloadImage(with: url, options: SDWebImageDownloaderOptions.highPriority, progress: nil) { (image, data, error, finish) in
            if let image = image {
                 YYImageCache.shared().setImage(image, imageData: data, forKey: "\(hash)_big", with: .disk)
                callback(nil, image, url)
            }else{
                callback(error, nil, url)
            }
        }
        
        return task
    }
    
    func getThumbnailBackgroud(hash:String,size:CGSize? = nil,callback:@escaping (Error?,UIImage?,URL?)->())->SDWebImageDownloadToken?{
     
        let detailURL = "media"
        var frameWidth = size?.width
        var frameHeight = size?.height
        if size == nil ||  size == CGSize.zero{
            frameWidth = 200
            frameHeight = 200
        }
        let resource = "/media/\(hash)"
        let param = "\(kRequestImageAltKey)=\(kRequestImageThumbnailValue)&\(kRequestImageWidthKey)=\(String(describing: frameWidth!))&\(kRequestImageHeightKey)=\(String(describing: frameHeight!))&\(kRequestImageModifierKey)=\(kRequestImageCaretValue)&\(kRequestImageAutoOrientKey)=true"
        
        let params:[String:String] = [kRequestImageAltKey:kRequestImageThumbnailValue,kRequestImageWidthKey:String(describing: frameWidth!),kRequestImageHeightKey:String(describing: frameHeight!),kRequestImageModifierKey:kRequestImageCaretValue,kRequestImageAutoOrientKey:"true"]
        let dataDic = [kRequestUrlPathKey:resource,kRequestVerbKey:RequestMethodValue.GET,kRequestImageParamsKey:params] as [String : Any]
        guard let data = jsonToData(jsonDic: dataDic as NSDictionary) else {
            return nil
        }
        
        guard let dataString = String.init(data: data, encoding: .utf8) else {
            return nil
        }
        
        guard let urlString = String.init(describing:"\(kCloudBaseURL)\(kCloudCommonPipeUrl)?data=\(dataString)").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return nil
        }
        
        guard  let normalUrl = URL.init(string:urlString) else {
            return nil
        }
        //                req.addValue(dataString, forHTTPHeaderField: kRequestImageDataValue)
        guard let url = AppNetworkService.networkState == .local ? URL.init(string: "\(RequestConfig.sharedInstance.baseURL!)/\(detailURL)/\(hash)?\(param)") : normalUrl else {
            return nil
        }
        
        SDWebImageDownloader.shared().headersFilter = { (requsetUrl,header) in
            var dic = header
            if let token = AppTokenManager.token{
                dic?[kRequestAuthorizationKey] = self.networkState == .normal ? token : JWTTokenString(token: token)
            }
            if let cookie = AppUserService.currentUser?.cookie{
                if self.networkState == .normal{
                    dic?[kRequestSetCookieKey] =  cookie
                }
            }
            return dic
        }
        
        YYImageCache.shared().memoryCache.countLimit = 100
        let task = SDWebImageDownloader.shared().downloadImage(with: url, options: SDWebImageDownloaderOptions.lowPriority, progress: nil) { (image, data, error, finish) in
            if let image = image {
                YYImageCache.shared().setImage(image, imageData: data, forKey: hash, with: .disk)
                callback(nil, image, url)
            }else{
                callback(error, nil, url)
            }
        }
    
        return task
    }
    
    
    /*
     * WISNUC API:GET IMAGE(High Resolution)
     */
    func getHighWebImage(url:URL,callback:@escaping (Error?,UIImage?)->())->RetrieveImageDownloadTask?{
        //        SDWebImageManager.shared().imageDownloader?.headersFilter = { [weak self] (url:URL?,headers:Dictionary<String,String>?) -> Dictionary<String,String>?  in
        //            var dic = Dictionary<String, String>.init()
        //            dic.merge(with: headers!)
        //            dic = [kRequestAuthorizationKey : self?.networkState == .normal ? AppTokenManager.token! : JWTTokenString(token: AppTokenManager.token!)]
        //            return dic
        //        }
        
        let modifier = AnyModifier { request in
            var req = request
            req.setValue(self.networkState == .normal ? AppTokenManager.token! : JWTTokenString(token: AppTokenManager.token!), forHTTPHeaderField: kRequestAuthorizationKey)
            if let cookie = AppUserService.currentUser?.cookie{
                req.addValue(cookie, forHTTPHeaderField: kRequestSetCookieKey)
            }
            
            return req
        }
        let imageDownloader = ImageDownloader.init(name: "orginImageDownloader")
        imageDownloader.downloadTimeout = 20000
        ImageCache.default.maxMemoryCost = 50 * 1024 * 1024
        return imageDownloader.downloadImage(with: url, retrieveImageTask: nil, options: [.requestModifier(modifier)], progressBlock: nil) { (image, error, reqUrl, data) in
            if (image != nil) {
                if let image =  image, let url = reqUrl {
//                    ImageCache.default.store(image,
//                                             original: nil,
//                                             forKey: url.absoluteString,
//                                             toDisk: true)
                }
                callback(nil, image)
            }else{
                callback(error, nil)
            }
        }
    }
}


