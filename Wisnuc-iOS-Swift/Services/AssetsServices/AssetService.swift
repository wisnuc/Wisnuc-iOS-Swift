  //
//  AssetService.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/7/6.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Photos
import MagicalRecord

class AssetService: NSObject,ServiceProtocol,PHPhotoLibraryChangeObserver {
    var userAuth:Bool?
    var lastResult:PHFetchResult<PHAsset>?
    lazy var allNetAssets:Array<NetAsset>? = Array.init()
    var assetChangeBlock: ((_ removeObjs: [WSAsset]?, _ insertObjs: [WSAsset]?) -> Void)?
    var allAssets:Array<WSAsset>?
    
    var allVideoAssets:Array<WSAsset>?
    {
        get{
            var all:Array<WSAsset> = Array.init()
            let assets = PHPhotoLibrary.getAllVideoAssets()
            for (_,value) in assets.enumerated(){
                let type = value.getWSAssetType()
                let duration = value.getDurationString()
                let asset = WSAsset.init(asset: value, type: type, duration: duration)
                all.append(asset)
            }
            return  all
        }
        set{
            
        }
    }
    
    override init() {
        super.init()
        self.checkAuth { (userAuth) in
            if (userAuth) {
                PHPhotoLibrary.shared().register(self)
            }
        }
    }
    
    deinit {
       PHPhotoLibrary.shared().unregisterChangeObserver(self)
        print("\(className()) deinit")
    }
    
    func getNetAssets(callback:@escaping (_ error:Error?,_ assets:Array<NetAsset>?)->()) -> BaseRequest? {
        if AppUserService.currentUser?.userHome == nil{
            return nil
        }
        
        var places = [String]()
        if let userHome = AppUserService.currentUser?.userHome{
            places.append(userHome)
        }
        
        if let shareSpace = AppUserService.currentUser?.shareSpace{
            places.append(shareSpace)
        }
        
        if AppUserService.backupArray.count > 0 {
          let array = AppUserService.backupArray.map({$0.uuid})
            for uuid in array{
                if let uuid = uuid{
                    places.append(uuid)
                }
            }
        }
        let placesUUID = places.joined(separator: ".")
        let types = kMediaTypes.joined(separator: ".")
       let request = GetMediaAPI.init(placesUUID: placesUUID,types: types)
       let start = CFAbsoluteTimeGetCurrent()
       request.startRequestJSONCompletionHandler { [weak self] (response) in
        let last = CFAbsoluteTimeGetCurrent()
        print("🍄\(last - start)")
            if response.error == nil{
//                print("😆\(String(describing: sizeString(Int64(response.data!.count))))")
                
                var medias:NSArray = NSArray.init()
                if let datas = (response.value as? NSDictionary)?.object(forKey: "data") as? NSArray{
                    medias = datas
                }else if let dataValues = response.value as? NSArray{
                    medias = dataValues
                }
              
                DispatchQueue.global(qos: .default).async {
                    var array = Array<NetAsset>.init()
                   
                    medias.enumerateObjects({ (object, idx, stop) in
                        if object is NSDictionary{
                            let dict =  object as! NSDictionary
                            let model = NetAsset.init(dict:dict)
                            array.append(model)
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
//                        print(backToString ?? "error")
                    }
                }
                callback(response.error,nil)
            }
        }
        return request
    }

    
    func getNetAssetsMetadata(callback:@escaping (_ error:Error?,_ assets:Array<NetAsset>?)->()) -> BaseRequest? {
        if AppUserService.currentUser?.userHome == nil{
            return nil
        }
        
        var places = [String]()
        if let userHome = AppUserService.currentUser?.userHome{
            places.append(userHome)
        }
        
        if let shareSpace = AppUserService.currentUser?.shareSpace{
            places.append(shareSpace)
        }
        
        if AppUserService.backupArray.count > 0 {
            let array = AppUserService.backupArray.map({$0.uuid})
            for uuid in array{
                if let uuid = uuid{
                    places.append(uuid)
                }
            }
        }
        let placesUUID = places.joined(separator: ".")
        let types = kMediaTypes.joined(separator: ".")
        let request = GetMediaAPI.init(placesUUID: placesUUID,types: types,metadata:true)
        request.startRequestJSONCompletionHandler { [weak self] (response) in
            if response.error == nil{
               
            }else{
                if response.data != nil {
                    let errorDict =  dataToNSDictionary(data: response.data!)
                    if errorDict != nil{
                        Message.message(text: errorDict!["message"] != nil ? errorDict!["message"] as! String :  (response.error?.localizedDescription)!)
                    }else{
                        let backToString = String(data: response.data!, encoding: String.Encoding.utf8) as String?
                        //                        print(backToString ?? "error")
                    }
                }
                callback(response.error,nil)
            }
        }
        return request
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
    
    
    func saveAsset(localId:String,digest:String){
        var oldAsset = self.getAsset(localId: localId)
        AppDBService.saveQueue.async {
            if oldAsset == nil {
            let context = NSManagedObjectContext.mr_default()
                context.perform({
                    oldAsset = LocalAsset.mr_createEntity(in: context)
                    oldAsset?.localId = localId
                    oldAsset?.digest = digest
                    context.mr_saveToPersistentStoreAndWait()
                })
            }else {
                oldAsset?.digest = digest
              NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
            }
        }
    }
    
    func getAsset(localId:String) ->LocalAsset? {
        let predicate = NSPredicate.init(format: "localId = %@", localId)
        let asset = LocalAsset.mr_findFirst(with: predicate)
        return asset
    }
    
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        autoreleasepool {
//            if let currentAssets = lastResult{
//                var tmpDic = Dictionary<String,WSAsset>.init()
//                for  asset in allAssets ?? [] {
//                    tmpDic[asset.asset!.localIdentifier] = asset
//                }
                
                var changeDic = Dictionary<String,Array<WSAsset>>.init()
                
                if lastResult != nil {
                    let detail = changeInstance.changeDetails(for: lastResult!)
                    if detail == nil || (detail!.removedObjects.count == 0 && detail!.insertedObjects.count == 0){
                        return
                    }
                    var removes = Array<WSAsset>.init()
                    var inserts = Array<WSAsset>.init()
                    if detail != nil && detail?.removedObjects != nil{
                        for asset in  (detail?.removedObjects)!{
//                            if Array(tmpDic.keys).contains(asset.localIdentifier){
                            let type = asset.getWSAssetType()
                            let duration = asset.getDurationString()
                            let localAsset = WSAsset.init(asset: asset, type: type, duration: duration)
                            removes.append(localAsset)
//                                tmpDic.removeValue(forKey: asset.localIdentifier)
//                            }
                        }
                    }
                    changeDic[kAssetsRemovedKey] = removes
                    if detail != nil && detail?.insertedObjects != nil{
                        for asset in  (detail?.insertedObjects)!{
                            let type = asset.getWSAssetType()
                            let duration = asset.getDurationString()
                            let localAsset = WSAsset.init(asset: asset, type: type, duration: duration)
                            inserts.append(localAsset)
                        }
                    }
                    
                    changeDic[kAssetsInsertedKey] = inserts
                    
                    if detail?.fetchResultAfterChanges.count != nil {// record new fetchResult
                        lastResult = detail?.fetchResultAfterChanges
                    }
                    defaultNotificationCenter().post(name: NSNotification.Name.Change.AssetChangeNotiKey, object: changeDic)
                }
                if assetChangeBlock != nil{
                    assetChangeBlock!(changeDic[kAssetsRemovedKey], changeDic[kAssetsInsertedKey])
                }
//            }
        }
    }
    
    func abort() {
        
    }
}
