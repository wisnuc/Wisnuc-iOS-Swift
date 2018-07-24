//
//  NetworkService.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/30.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

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
        if !AppUserService.isUserLogin{
            return
        }
        switch status {
        case .WIFI:
            if networkState == .normal{
           
                getLocalInCloudLogin { [weak self] (error, localToken) in
                    if error == nil {
                        self?.checkIP(address: (AppUserService.currentUser?.localAddr)!, { (isLocal) in
                            if isLocal{
                                AppUserService.currentUser?.localToken = localToken
                                AppUserService.synchronizedCurrentUser()
                                self?.networkState = .local
                            }
                        })
                    }else{
                        Message.message(text: (error?.localizedDescription)!)
                        self?.networkState = .normal
                    }
                }
            }else{
                if AppUserService.currentUser?.cloudToken != nil {
                    self.networkState = .normal
                }else{
                    self.networkState = .local
                }
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
        RequestConfig.sharedInstance.baseURL = kCloudBaseURL
        AppTokenManager.token = AppUserService.currentUser?.cloudToken
    }
    
    func networkStateLocalAction() {
        RequestConfig.sharedInstance.baseURL = AppUserService.currentUser?.localAddr!
        AppTokenManager.token = AppUserService.currentUser?.localToken
    }
    
    func checkIP(address:String, _ closure:@escaping (_ success:Bool)->()) {
        let requestURL = "\(address)/station/info"
        do {
            var urlRequest = try URLRequest.init(url: URL.init(string: requestURL)!, method: HTTPMethod.get)
            urlRequest.timeoutInterval = TimeInterval.init(3)
            Alamofire.request(urlRequest).validate().response { (response) in
                if response.error == nil{
                    closure(true)
                }else{
                    closure(false)
                }
            }
        } catch {
            closure(false)
        }
    }
    
    func getLocalInCloudLogin(_ closure:@escaping (( _ error:Error?,_ token:String?)->())){
        if  !AppUserService.isUserLogin {
            return closure(LoginError(code: ErrorCode.Login.NotLogin, kind: LoginError.ErrorKind.LoginFailure, localizedDescription: LocalizedString(forKey: ErrorLocalizedDescription.Login.NotLogin)), nil)
        }
        
        if isNilString( AppUserService.currentUser?.cloudToken){
            return closure(LoginError(code: ErrorCode.Login.NoToken, kind: LoginError.ErrorKind.LoginNoToken, localizedDescription: LocalizedString(forKey: ErrorLocalizedDescription.Login.NoToken)), nil)
        }
        
        LocalTokenInCloudAPI.init().startRequestJSONCompletionHandler({ [weak self] (response) in
            if response.error == nil{
                let isLocalRequest = self?.networkState == .local
                let dic = isLocalRequest ? response.value as! NSDictionary : (response.value as! NSDictionary).object(forKey: "data") as! NSDictionary
                if dic.value(forKey: "token") != nil{
                    let token =  dic.value(forKey: "token") as! String
                    closure(nil,token)
                }else{
                    closure(LoginError(code: ErrorCode.Login.NoToken, kind: LoginError.ErrorKind.LoginNoToken, localizedDescription: LocalizedString(forKey: ErrorLocalizedDescription.Login.NoToken)),nil)
                }
            }else{
                closure(response.error,nil)
            }
        })
    }
    
    func getUserHome(_ callBack:@escaping (_ error:Error?, _ userHome:String?)->()) {
        if !AppUserService.isUserLogin {
            return callBack(LoginError(code: ErrorCode.Login.NotLogin, kind: LoginError.ErrorKind.LoginFailure, localizedDescription: ErrorLocalizedDescription.Login.NotLogin), nil)
        }
        let isLocalRequest = AppNetworkService.networkState == .local
        var find:Bool = false
        DriveAPI.init().startRequestJSONCompletionHandler { (response) in
            if response.error == nil{
                let responseArr = isLocalRequest ? response.value as! NSArray : (response.value as! NSDictionary).object(forKey: "data") as! NSArray
                responseArr.enumerateObjects({ (obj, idx, stop) in
                    let dic = obj as! NSDictionary
                    if let driveModel = DriveModel.deserialize(from: dic) {
                        if driveModel.tag == "home"{
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
    
    // 获取 名为 “上传的照片”（任何name都可以） 的文件夹， 没有就创建
    func getDirUUID(name:String,driveUUID:String,dirUUID:String,callBack:@escaping ((_ error:Error?,_ directoryUUID:String?)->())) {
        let request = DriveDirAPI.init(driveUUID:driveUUID, directoryUUID: dirUUID)
        let isLocalRequest = AppNetworkService.networkState == .local
        request.startRequestJSONCompletionHandler { (response) in
            if response.error == nil{
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
//                        return  complete(BaseError(localizedDescription: ErrorLocalizedDescription.JsonModel.SwitchTOModelFail, code: ErrorCode.JsonModel.SwitchTOModelFail))
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
                                print(array)
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
    func getThumbnail(hash:String,callback:@escaping (Error?,UIImage?)->())->SDWebImageDownloadToken{
        SDWebImageManager.shared().imageDownloader?.headersFilter = { [weak self] (url:URL?,headers:Dictionary<String,String>?) -> Dictionary<String,String>?  in
            var dic = Dictionary<String, String>.init()
            dic.merge(with: headers!)
            dic = [kRequestAuthorizationKey : self?.networkState == .normal ? AppTokenManager.token! : JWTTokenString(token: AppTokenManager.token!)]
            return dic
            }
        let detailURL = "media"
        let frameLength = 200
        let resource = "media/\(hash)".toBase64()
        let param = "\(kRequestImageAltKey)=\(kRequestImageThumbnailValue)&\(kRequestImageWidthKey)=\(frameLength)&\(kRequestImageHeightKey)=\(frameLength)&\(kRequestImageModifierKey)=\(kRequestImageCaretValue)&\(kRequestImageAutoOrientKey)=true"
        SDWebImageManager.shared().imageDownloader?.downloadTimeout = 20000
        let url = self.networkState == .local ? URL.init(string: "\(RequestConfig.sharedInstance.baseURL!)/\(detailURL)/\(hash)?\(param)") : URL.init(string:"\(kCloudCommonPipeUrl)?\(kRequestResourceKey)=\(resource)&\(kRequestMethodKey)=\(RequestMethodValue.GET)&\(param)")
        return SDWebImageDownloader.shared().downloadImage(with: url, options: SDWebImageDownloaderOptions.useNSURLCache, progress: nil, completed: { (image, data, error, finished) in
            if (image != nil) {
            callback(nil, image)
            }else{
            callback(error, nil)
            }
        })!
    }
}

