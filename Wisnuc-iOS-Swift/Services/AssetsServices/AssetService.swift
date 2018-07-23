//
//  AssetService.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/7/6.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Photos


class AssetService: NSObject,ServiceProtocol,PHPhotoLibraryChangeObserver {
    var userAuth:Bool?
    var lastResult:PHFetchResult<PHAsset>?
    lazy var allNetAssets:Array<NetAsset>? = Array.init()
    var allAssets:Array<WSAsset>?
    {
        get{
            var all:Array<WSAsset> = Array.init()
            PHPhotoLibrary.getAllAsset { [weak self] (result, assets) in
                for (_,value) in (assets?.enumerated())!{
                    let type = value.getWSAssetType()
                    let duration = value.getDurationString()
                    all.append(WSAsset.assetModel(asset: value, type: type, duration: duration))
                }
                self?.lastResult = result
            }
        
            return  all
        }
        set{
          
        }
    }
    
    override init() {
        super.init()
        self.checkAuth { (userAuth) in
            if (userAuth) { PHPhotoLibrary.shared().register(self)}
        }
    }
    
    deinit {
        
    }
    
    func getNetAssets(callback:@escaping (_ error:Error?,_ assets:Array<NetAsset>?)->()){
        let isLocalRequest = AppNetworkService.networkState == .local
        GetMediaAPI.init().startRequestJSONCompletionHandler { [weak self] (response) in
            if response.error == nil{
                let medias:NSArray = (isLocalRequest ? response.value as? NSArray : (response.value as! Dictionary)["data"])!
                DispatchQueue.global(qos: .default).async {
                    var array = Array<NetAsset>.init()
                    medias.enumerateObjects({ (object, idx, stop) in
                        if object is NSDictionary{
                            if let model = NetAsset.deserialize(from: object as? NSDictionary) {
                                array.append(model)
                            }
                        }
                    })
                    DispatchQueue.main.async {
                        self?.allNetAssets = array
                        callback(nil,array)
                    }
                }
            }else{
                if response.data != nil {
                    let errorDict =  dataToNSDictionary(data: response.data!)
                    if errorDict != nil{
                        Message.message(text: errorDict!["message"] != nil ? errorDict!["message"] as! String :  (response.error?.localizedDescription)!)
                    }else{
                        let backToString = String(data: response.data!, encoding: String.Encoding.utf8) as String?
                        print(backToString ?? "error")
                    }
                }
                callback(response.error,nil)
            }
        }
    }
    
    func checkAuth(callback:@escaping ((_ userAuth:Bool)->())){
        userAuth = false
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .denied,.restricted:
            userAuth = false
            callback(userAuth!)
        case .authorized:
            userAuth = true
            callback(userAuth!)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] (authorizationStatus) in
                self?.userAuth = authorizationStatus == .authorized ? true : false
//                if (self?.userAuth!)!{
//                    PHPhotoLibrary.shared().register(self!)
//                }
                defaultNotificationCenter().post(name: NSNotification.Name.Change.PhotoCollectionUserAuthChangeNotiKey, object: status)
                callback((self?.userAuth!)!)
            }
        default:
            break
        }
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
    }
    
    func abort() {
        
    }
    
}
