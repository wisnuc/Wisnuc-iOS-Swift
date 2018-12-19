//
//  PhotoRootViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/7/5.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Material
import MaterialComponents.MaterialCollections
import MaterialComponents.MaterialButtons
import NetworkExtension

private var menuButton: IconButton!

@objc protocol PhotoRootViewControllerDelegate {
    func selectPhotoComplete(assets:Array<WSAsset>)
}

enum PhotoRootViewControllerState{
    case normal
    case select
    case creat
    case container
}

class PhotoRootViewController: BaseViewController {
    override func willDealloc() -> Bool {
        return false
    }
    weak var delegate:PhotoRootViewControllerDelegate?
    var driveUUID:String?
    var requset:BaseRequest?
    var timer:Timer?
    var video:Bool = false
    var backupDriveUUID:String?
    var state:PhotoRootViewControllerState?{
        didSet{
            switch state {
            case .normal?:
                normalStateAction()
            case .select?:
                selectStateAction()
            case .creat?:
                creatStateAction()
            default:
                break
            }
        }
    }
    
    var isSelectMode:Bool?{
        didSet{
            if isSelectMode!{
               selectModeAction()
            }else{
               unselectModeAction()
            }
        }
    }
    var sortedAssetsBackupArray:Array<WSAsset>?
    
    override init() {
        super.init()
        setNotification()
    }
    
    init(style: NavigationStyle,state:PhotoRootViewControllerState,localDataSource:Array<WSAsset>? = nil,netDataSource:Array<NetAsset>? = nil,video:Bool? = nil,backupDriveUUID:String? = nil) {
        super.init(style: style)
        self.setState(state: state)
        if let video = video{
             self.video = video
        }
        self.backupDriveUUID = backupDriveUUID
        self.photoCollcectionViewController.drive = backupDriveUUID
        setNotification()
        if localDataSource != nil {
            localAssetDataSources.append(contentsOf: localDataSource!)
        }
        
        if netDataSource != nil {
            netAssetDataSource.append(contentsOf: netDataSource!)
        }
        
        
    }
    
    deinit {
      self.appBar.appBarViewController.headerView.trackingScrollView = nil
    defaultNotificationCenter().removeObserver(self)
      print("\(className()) deinit")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: NavigationStyle) {
        super.init(style: style)
    }
    
    init(style: NavigationStyle ,state:PhotoRootViewControllerState,driveUUID:String? = nil) {
        super.init(style: style)
        self.setState(state: state)
        self.driveUUID = driveUUID
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        ActivityIndicator.startActivityIndicatorAnimation()
        prepareCollectionView()
        prepareNavigationBar()
//        prepareSearchBar()
//        self.sort(localAssetDataSources)
//        self.photoCollcectionViewController.dataSource = assetDataSources
//        view.addSubview(self.fabButton)
        self.photoCollcectionViewController.collectionView?.mj_header = MDCFreshHeader.init(refreshingBlock: { [weak self] in
            self?.reloadAssetData()
        })
        
       
//        self.timer?.fire()
        self.view.bringSubview(toFront: self.appBar.headerViewController.headerView)
        NotificationCenter.default.addObserver(self, selector: #selector(assetDidChangeHandle(_:)), name: NSNotification.Name.Change.AssetChangeNotiKey, object: nil)
      
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appBar.appBarViewController.headerView.trackingScrollView = self.photoCollcectionViewController.collectionView
        appBar.appBarViewController.headerView.observesTrackingScrollViewScrollEvents = true
        appBar.headerViewController.preferredStatusBarStyle = .default
        appBar.headerViewController.setNeedsStatusBarAppearanceUpdate()
        self.timer = nil
        self.timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        RunLoop.current.add(self.timer!, forMode: RunLoopMode.commonModes)
        self.timer?.fire()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        defaultNotificationCenter().removeObserver(self, name: NSNotification.Name.Change.PhotoCollectionUserAuthChangeNotiKey, object: nil)
        self.requset?.cancel()
        timer?.invalidate()
        timer = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func prepareNavigationBar(){
        
    }
    
    
    
    func reloadAssetData() {
    
      let request = AppAssetService.getNetAssets { [weak self] (error, assetDataSource) in
         self?.photoCollcectionViewController.collectionView?.mj_header.endRefreshing()
            if error == nil{
                if  let assets = AppAssetService.allAssets{
                    self?.localAssetDataSources = assets
                }
                self?.addNetAssets(assetsArr: assetDataSource!)
                    
                self?.isSelectMode = self?.isSelectMode
             
            }else{
                
            }
        
//            self?.photoCollcectionViewController.collectionView?.mj_header.endRefreshing()
//           self?.photoCollcectionViewController.collectionView?.reloadData()
        }
        self.requset = request
    }
    
    func reloadAllAssetData(){
        DispatchQueue.global(qos: .background).async {
        let request = AppAssetService.getNetAssets { [weak self] (error, assetDataSource) in
            if error == nil{
            
                    if let assetDataSource = assetDataSource{
                        //                    var replaceDataSource = assetDataSource
                        //                    for asset in assetDataSource{
                        //                        if let netAsset = self?.netAssetDataSource.first(where: {$0.name = asset.name && $0.uuid = asset.uuid && $0.fmhash = asset.fmhash && $0.pdir == asset.pdir && $0.mtime == asset.mtime && $0.metadata?.date == asset.metadata?.date}){
                        //                            replaceDataSource.removeAll(where: {$0.name == asset.name && $0.uuid == asset.uuid && $0.fmhash == asset.fmhash && $0.pdir == asset.pdir && $0.mtime == asset.mtime && $0.metadata?.date == asset.metadata?.date})
                        //                        }
                        //                        self?.netAssetDataSource.
                        //                    }
                        
                        let requsetHashArray = assetDataSource.map({$0.fmhash})
                        guard let currentHashArray = self?.netAssetDataSource.map({$0.fmhash}) else {
                            return
                        }
                        
                        let set1:Set<String?> = Set(requsetHashArray)
                        let set2:Set<String?> = Set(currentHashArray)
                        
                        let diffSet = set1.subtracting(set2)
                        let resultHashArray = Array(diffSet)
                        var assetArray = Array<WSAsset>.init()
                        for hash in resultHashArray{
                            if let asset = assetDataSource.first(where: {$0.fmhash == hash}){
                                assetArray.append(asset)
                            }
                        }
                        guard let allDataSource = self?.assetDataSources else{
                            return
                        }
                        if assetArray.count > 0{
                            print("😈😈😈😈😈😈😈😈😈😈")
                            self?.netAssetDataSource.append(contentsOf: assetArray as! Array<NetAsset>)
                            if let  allAssets = AppAssetService.allAssets{
                             self?.localAssetDataSources.append(contentsOf:allAssets)
                            }
                            
                            self?.sort(self?.merge() ?? Array<WSAsset>.init())
                            //                        self?.addNetAssets(assetsArr: assetArray)
                            //                        for asset in assetArray{
                            //                            for (i,assetDataArray) in allDataSource.enumerated(){
                            //                                 var replaceArray = assetDataArray
                            //                                if Calendar.current.isDate(asset.createDateB!, inSameDayAs: (assetDataArray.first?.createDateB)!){
                            //                                    replaceArray.append(asset)
                            //                                    self?.assetDataSources[i] = replaceArray
                            //                                }else{
                            //
                            //                                }
                            //                            }
                            //                        }
                            
                            //                        self?.netAssetDataSource.append(contentsOf: assetArray as! Array<NetAsset>)
                            //                        self?.sort(self?.merge() ?? Array<WSAsset>.init())
                            
                            //                        DispatchQueue.main.async {
                            //                            self?.photoCollcectionViewController.dataSource = self?.assetDataSources
                            //                            self?.photoCollcectionViewController.collectionView?.reloadData()
                            //                        }
                        }
                        //                    let assetArray = Array<WSAsset>.init()
                        //                    for asset in assetDataSource{
                        //                        let array =  self?.netAssetDataSource.filter({$0.fmhash == asset.fmhash && $0.uuid == asset.fmhash && $0.pdir == asset.pdir && $0.name == asset.name && $0.mtime == asset.mtime})
                        //                        assetArray.append(contentsOf: array)
                        //                    }
                        
                    }
                
                
                self?.isSelectMode = self?.isSelectMode
                
            }else{
                
            }
            
            //            self?.photoCollcectionViewController.collectionView?.mj_header.endRefreshing()
            //            self?.photoCollcectionViewController.collectionView?.reloadData()
        }
              self.requset = request
        }
      
    }
    
    func reloadVideoAssetData(){
        DispatchQueue.global(qos: .background).async {
            PhotoHelper.searchAny(sClass:SclassType.video.rawValue, complete: { (videoAssets, error) in
                if error == nil{
                    if let videoAssets = videoAssets{
                        let requsetHashArray = videoAssets.map({$0.fmhash})
                        let currentHashArray = self.netAssetDataSource.map({$0.fmhash})
                        
                        let set1:Set<String?> = Set(requsetHashArray)
                        let set2:Set<String?> = Set(currentHashArray)
                        
                        let diffSet = set1.subtracting(set2)
                        let resultHashArray = Array(diffSet)
                        var assetArray = Array<WSAsset>.init()
                        for hash in resultHashArray{
                            if let asset = videoAssets.first(where: {$0.fmhash == hash}){
                                assetArray.append(asset)
                            }
                        }
                        
                        if assetArray.count > 0{
                            print("😈😈😈😈😈😈😈😈😈😈")
                            self.netAssetDataSource.append(contentsOf: assetArray as! Array<NetAsset>)
                            if let  allAssets = AppAssetService.allVideoAssets{
                                self.localAssetDataSources.append(contentsOf:allAssets)
                            }
                            
                            self.sort(self.merge() )
                        }
                    }
                }
            })
        }
    }
    
    func relaodBackUpAssetData(){
        guard let uuid = self.backupDriveUUID else {
            return
        }
        let types = kMediaTypes.joined(separator: ".")
        PhotoHelper.searchAny(places: uuid, types: types) {(assets, error) in
            if  error == nil && assets != nil{
                if let backUpAssets = assets{
                    let requsetHashArray = backUpAssets.map({$0.fmhash})
                    let currentHashArray = self.netAssetDataSource.map({$0.fmhash})
                    
                    let set1:Set<String?> = Set(requsetHashArray)
                    let set2:Set<String?> = Set(currentHashArray)
                    
                    let diffSet = set1.subtracting(set2)
                    let resultHashArray = Array(diffSet)
                    var assetArray = Array<WSAsset>.init()
                    for hash in resultHashArray{
                        if let asset = backUpAssets.first(where: {$0.fmhash == hash}){
                            assetArray.append(asset)
                        }
                    }
                    
                    if assetArray.count > 0{
                        print("😈😈😈😈😈😈😈😈😈😈")
                        self.netAssetDataSource.append(contentsOf: assetArray as! Array<NetAsset>)
                        self.sort(self.merge() )
                    }
                }
            }
        }
    }
    
    func pollingAssetData() {
        if self.video{
            reloadVideoAssetData()
        }else if self.backupDriveUUID != nil{
            relaodBackUpAssetData()
        }else{
            reloadAllAssetData()
        }
    }
    
    func setState(state:PhotoRootViewControllerState){
        self.state = state
    }
    
    func selectStateAction(){
        self.style = .select
         self.isSelectMode = true
         photoCollcectionViewController.isSelectMode = true
         photoCollcectionViewController.state = self.state
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "close_white.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(leftBarButtonItemTap(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: LocalizedString(forKey: "完成"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(rightCreatBarButtonItemTap(_:)))
    }
    
    func creatStateAction(){
        self.style = .select
        self.isSelectMode = true
        photoCollcectionViewController.isSelectMode = true
        photoCollcectionViewController.state = self.state
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "close_white.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(leftBarButtonItemTap(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: LocalizedString(forKey: "创建"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(rightCreatBarButtonItemTap(_:)))
    }
    
    func normalStateAction(){
         self.isSelectMode = false
        photoCollcectionViewController.state = self.state
        photoCollcectionViewController.isSelectMode = false
        self.navigationItem.rightBarButtonItems = nil
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func selectModeAction(){
        self.style = .select
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "close_white.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(leftBarButtonItemTap(_:)))
        let shareButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "share_white.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(rightShareBarButtonItemTap(_:)))
//        let addButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "plus_white.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(rightAddBarButtonItemTap(_:)))
        let deleteButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "delete_photo.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(rightDeleteBarButtonItemTap(_:)))
        self.navigationItem.rightBarButtonItems = [deleteButtonItem,shareButtonItem]
    }
    
    func unselectModeAction(){
        self.style = .whiteWithoutShadow
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItems = nil
        self.navigationItem.rightBarButtonItem = nil
        self.title = LocalizedString(forKey: "所有相片")
        self.photoCollcectionViewController.choosePhotos.removeAll()
        self.photoCollcectionViewController.chooseSection.removeAll()
    }
    
    //!!!!: ASSETS_UPDATE_NOTIFY Handler
    @objc func assetDidChangeHandle(_ notify: Notification?) {
        if let anObject = notify?.object {
            print("changeDic -> \(anObject)")
        }
        if let changeDic = notify?.object as? [String:Array<WSAsset>]{
            let removeArr = changeDic[kAssetsRemovedKey]
            let insertArr = changeDic[kAssetsInsertedKey]
            if removeArr != nil && removeArr?.count != nil {
                localAssetDataSources = localAssetDataSources.filter({ (localAsset) -> Bool in
                    return  !((removeArr?.contains(where: {$0.asset?.localIdentifier == localAsset.asset?.localIdentifier}))!)
                })
            }
            if insertArr != nil && insertArr?.count != nil {
                if let anArr = insertArr {
                    localAssetDataSources.append(contentsOf: anArr)
                }
            }
            sort(merge())
            DispatchQueue.main.async(execute: {
                self.photoCollcectionViewController.collectionView?.reloadData()
            })
        }
    }
    
    @objc func rightShareBarButtonItemTap(_ sender:UIBarButtonItem){
        
    }
    
    @objc func rightAddBarButtonItemTap(_ sender:UIBarButtonItem){
        
    }
    
    @objc func rightDeleteBarButtonItemTap(_ sender:UIBarButtonItem){
        if self.photoCollcectionViewController.choosePhotos.count > 0{
            let title = "\(self.photoCollcectionViewController.choosePhotos.count) 个照片\(LocalizedString(forKey: "将被删除"))"
            alertController(title: title, message: LocalizedString(forKey: "照片删除后将无法恢复"), cancelActionTitle: LocalizedString(forKey: "Cancel"), okActionTitle: LocalizedString(forKey: "Confirm"), okActionHandler: { (AlertAction1) in
                self.deleteSelectPhotos(photos: self.photoCollcectionViewController.choosePhotos)
            }) { (AlertAction2) in
                
            }
        }
    }
    
    @objc func leftBarButtonItemTap(_ sender:UIBarButtonItem){
        if self.state == .select || self.state == .creat{
            if let presentingViewController  = self.presentingViewController{
                var dismissViewController = presentingViewController.childViewControllers.last
                dismissViewController = dismissViewController?.childViewControllers.last
                
                dismissViewController?.dismiss(animated: true, completion: {
                    
                })
            }
//            while presentingViewController.presentingViewController {
//                presentingViewController = presentingViewController.presentingViewController
//            }

            return
        }
        self.isSelectMode = false
        self.photoCollcectionViewController.isSelectMode = self.isSelectMode
        self.photoCollcectionViewController.collectionView?.reloadData()
        
    }
    
    @objc func rightCreatBarButtonItemTap(_ sender:UIBarButtonItem){
        if self.photoCollcectionViewController.choosePhotos.count == 0 {
            return
        }
        self.presentingViewController?.dismiss(animated: true, completion: { [weak self] in
            self?.delegate?.selectPhotoComplete(assets: (self?.photoCollcectionViewController.choosePhotos)!)
        })
    }
    
    @objc func menuButtonTap(_ sender:IconButton){
        self.navigationDrawerController?.toggleLeftView()
    }
    
    @objc func moreButtonTap(_ sender:IconButton){
//        let bottomSheet = AppBottomSheetController.init(contentViewController: self.filesSearchMoreBottomVC)
//        bottomSheet.trackingScrollView = filesSearchMoreBottomVC.tableView
//        self.present(bottomSheet, animated: true, completion: {
//        })
    }
    
//    @objc func fabButtonDidTap(_ sender:MDCFloatingButton){
//        self.fabButton.collapse(true) { [weak self] in
//            let fabBottomVC = FilesFABBottomSheetDisplayViewController()
//            fabBottomVC.preferredContentSize = CGSize(width: __kWidth, height: 148.0)
//            fabBottomVC.transitioningDelegate = self?.transitionController
//            fabBottomVC.delegate =  self
//            let bottomSheet = AppBottomSheetController.init(contentViewController: fabBottomVC)
//            bottomSheet.delegate = self
//            self?.present(bottomSheet, animated: true, completion: {
//            })
//        }
//    }
    
    @objc func timerAction(){
        self.pollingAssetData()
    }
    
    func deleteSelectPhotos(photos:[WSAsset]){
        self.isSelectMode = false
        self.photoCollcectionViewController.isSelectMode = false
        self.photoCollcectionViewController.collectionView?.reloadData()
        var localAssets:Array<PHAsset> = Array.init()
        var netAssets:Array<NetAsset> = Array.init()
        for asset in photos{
            if asset is NetAsset{
                #warning("删除NAS照片")
                if let netAsset = asset as? NetAsset{
                    netAssets.append(netAsset)
                }
            }else{
                if let localAsset = asset.asset{
                    localAssets.append(localAsset)
                }
            }
        }
        
        if netAssets.count > 0{
            photoRemoveOptionRequest(photos:netAssets)
        }
        
        if localAssets.count > 0{
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets(localAssets as NSFastEnumeration)
            }) { (finish, error) in
                if error != nil{
                    print(error as Any)
                }
            }
            self.photoCollcectionViewController.collectionView?.reloadData()
        }
    }
//
    func photoRemoveOptionRequest(photos:[NetAsset]){
        var index:Int = 0
        ActivityIndicator.startActivityIndicatorAnimation()
        for photo in photos {
            self.photoRemoveOptionRequest(photo: photo) { [weak self] in
                index = index + 1
//                print("🌶\(index)")
                if index == photos.count{
                    ActivityIndicator.stopActivityIndicatorAnimation()
                    self?.photoCollcectionViewController.dataSource  = self?.assetDataSources
                    self?.photoCollcectionViewController.collectionView?.reloadData()
                }
            }
        }
    }

    func photoRemoveOptionRequest(photo: NetAsset,closure:@escaping ()->()){
        let drive = self.driveUUID != nil ? self.driveUUID! : photo.place == 0 ? AppUserService.currentUser?.userHome : AppUserService.currentUser?.shareSpace ?? ""
        let dir = photo.pdir ?? ""
        DirOprationAPI.init(driveUUID: drive ?? "", directoryUUID: dir).startFormDataRequestJSONCompletionHandler(multipartFormData: { (formData) in
            var dic = [kRequestOpKey: FilesOptionType.remove.rawValue]
            if let uuid = photo.uuid,let hash = photo.fmhash{
              dic = [kRequestOpKey: FilesOptionType.remove.rawValue,"uuid":uuid,"hash":hash]
            }
            do {
                let data = try JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions.prettyPrinted)
                formData.append(data, withName: photo.name ?? "")
            }catch{
                Message.message(text: LocalizedString(forKey: ErrorLocalizedDescription.JsonModel.SwitchTODataFail))
                 return closure()
            }
        }, { [weak self] (response) in
            mainThreadSafe {
                if response.error == nil{
                    if let errorMessage = ErrorTools.responseErrorData(response.data){
                        Message.message(text: errorMessage)
                        return closure()
                    }
                    if let time = PhotoHelper.fetchPhotoTime(model: photo),let assetDataSources =  self?.assetDataSources {
                        let date = Date.init(timeIntervalSince1970: time)
                        for (i,assetArray) in assetDataSources.enumerated(){
                            if let creatDate = assetArray.first?.createDate {
                                if  Calendar.current.isDate(creatDate , inSameDayAs: date){
                                    var removeArray = assetArray
                                    removeArray.removeAll(where: { (asset) -> Bool in
                                        if let netAsset = asset as? NetAsset{
                                            return netAsset.fmhash == photo.fmhash && netAsset.uuid == photo.uuid
                                        }else{
                                            return false
                                        }
                                    })
                                    self?.assetDataSources[i] = removeArray
                                    return closure()
                                }
                            }
                        }
                    }
                }else{
                    if response.data != nil {
                        let errorDict =  dataToNSDictionary(data: response.data!)
                        if errorDict != nil{
                            Message.message(text: errorDict!["message"] != nil ? errorDict!["message"] as! String :  (response.error?.localizedDescription)!)
                            return closure()
                        }else{
                            let backToString = String(data: response.data!, encoding: String.Encoding.utf8) as String?
                            Message.message(text: backToString ?? "error")
                            return closure()
                        }
                    }else{
                        Message.message(text: (response.error?.localizedDescription)!)
                        return closure()
                    }
                }
            }
            }, errorHandler: { (error) -> (Void) in
                Message.message(text: error.localizedDescription)
                return closure()
        })
    }
    
    func setNotification(){
        defaultNotificationCenter().addObserver(forName: Notification.Name.Change.PhotoCollectionUserAuthChangeNotiKey, object: nil, queue: nil) {  [weak self] (noti) in
            var allPhotos = Array<WSAsset>.init()
            if  let assets = AppAssetService.allAssets{
                 allPhotos.append(contentsOf: assets)
            }
            self?.localAssetDataSources = allPhotos;
            self?.sort((self?.merge())!)
            self?.photoCollcectionViewController.dataSource  = self?.assetDataSources
            mainThreadSafe({
                self?.photoCollcectionViewController.collectionView?.reloadData()
            })
        }
        
        defaultNotificationCenter().addObserver(forName:  Notification.Name.Change.AssetChangeNotiKey, object: nil, queue: nil) { [weak self] (noti) in
            let changeDic = noti.object
//            let removeArray = (changeDic as! Dictionary<String,Array<WSAsset>>)[kAssetsRemovedKey]
//            let insertArraay = (changeDic as! Dictionary<String,Array<WSAsset>>)[kAssetsInsertedKey]
//            if removeArray != nil && removeArray?.count != 0{
//                self?.localAssetDataSources = (self?.localAssetDataSources.filter { !(removeArray?.contains($0))! })!
//            }
//            if insertArraay != nil && insertArraay?.count != 0{
//                self?.localAssetDataSources.append(contentsOf: insertArraay!)
//            }
            self?.localAssetDataSources = changeDic as! Array<WSAsset>
            self?.sort((self?.merge())!)
//            mainThreadSafe {
//               self?.photoCollcectionViewController.collectionView?.reloadData()
//            }
        }
    }
    
    func sort(_ assetsArray:Array<WSAsset>){
        autoreleasepool {
            DispatchQueue.global(qos: .default).async {
            let start = CFAbsoluteTimeGetCurrent();
            var array:Array<WSAsset>  = Array.init()
            array.append(contentsOf: assetsArray)
                  let s = CFAbsoluteTimeGetCurrent();
                array = array.filter({$0.createDate != nil})
                array.sort(by: {$0.createDate!>$1.createDate!})
//                array.sort(by: { (item1, item2) -> Bool in
//                    return item1.createDate! >  item2.createDate!{
////                        return t1 > t2
//                })
    
                let l = CFAbsoluteTimeGetCurrent();
                print("😆\(l - s)")
            self.sortedAssetsBackupArray = array
            let timeArray:NSMutableArray = NSMutableArray.init()
            let photoGroupArray:NSMutableArray = NSMutableArray.init()
            if array.count>0 {
                let firstAsset = array.first
                firstAsset?.indexPath = IndexPath.init(row: 0, section: 0)
                let photoDateGroup1:NSMutableArray = NSMutableArray.init() //第一组照片
                photoDateGroup1.add(firstAsset!)
                photoGroupArray.add(photoDateGroup1)
                if firstAsset?.createDate != nil{
                    timeArray.add(firstAsset!.createDate!)
                }
                if array.count == 1{
                    self.assetDataSources = photoGroupArray as! Array<Array<WSAsset>>
                    return
                }
                var photoDateGroup2:NSMutableArray? = photoDateGroup1 //最近的一组
              
                for i in 1..<array.count {
                    let photo1 =  array[i]
                    let photo2 = array[i-1]
                    if Calendar.current.isDate(photo1.createDate! , inSameDayAs: photo2.createDate!){
                        photo1.indexPath = IndexPath.init(row: ((photoGroupArray[photoGroupArray.count - 1]) as! NSMutableArray).count, section: photoGroupArray.count - 1)
                        photoDateGroup2!.add(photo1)
                    }else{
                        photo1.indexPath = IndexPath.init(row: 0, section: photoGroupArray.count)
                        if photo1.createDate != nil{
                            timeArray.add(photo1.createDate!)
                        }
                        photoDateGroup2 = nil
                        photoDateGroup2 = NSMutableArray.init()
                        photoDateGroup2!.add(photo1)
                        photoGroupArray.add(photoDateGroup2!)
                    }
                }

            }
                let last = CFAbsoluteTimeGetCurrent()
                print("🌶\(last - start)")
                self.assetDataSources = photoGroupArray as! Array<Array<WSAsset>>
                
                DispatchQueue.main.async {
                    self.photoCollcectionViewController.dataSource = self.assetDataSources
                    UIView.performWithoutAnimation({
                        //刷新界面
                        self.photoCollcectionViewController.collectionView?.reloadData()
                    })
                   
//                    CATransaction.commit()
                    self.photoCollcectionViewController.sortedAssetsBackupArray = self.sortedAssetsBackupArray
                }
            }
        }
    }
    
    func merge()->Array<WSAsset> {
    let start = CFAbsoluteTimeGetCurrent()
    let localHashs = NSMutableArray.init(capacity: 0)
        
        for asset in self.localAssetDataSources {
            if !isNilString(asset.digest){
                localHashs.add(asset.digest!)
            }
        }
  
    let netTmpArr = NSMutableArray.init(capacity: 0)
        for asset in self.netAssetDataSource {
            if asset.fmhash != nil {
                if !localHashs.contains(asset.fmhash!){
                    netTmpArr.add(asset)
                }
            }
        }
   
        let mergedAssets =  NSMutableArray.init(array: self.localAssetDataSources)
        mergedAssets.addObjects(from: netTmpArr as! [Any])
        let last = CFAbsoluteTimeGetCurrent()
        print("😈\(last - start)")
        return mergedAssets as! Array<WSAsset>
    }
    
    func addNetAssets(assetsArr:Array<NetAsset>) {
//        DispatchQueue.global(qos: .default).async {
           self.netAssetDataSource = assetsArr
            self.sort(self.merge())
//            ActivityIndicator.stopActivityIndicatorAnimation()
//            DispatchQueue.main.async {
        
//            }
//        }
    }
    
    
    func localDataSouceSort() {
        self.sort(self.merge())
//        ActivityIndicator.stopActivityIndicatorAnimation()
    }
    
    func prepareCollectionView(){
     
        self.addChildViewController(photoCollcectionViewController)
        photoCollcectionViewController.view.frame =  CGRect.init(x: self.view.left, y:0, width: self.view.width, height: self.view.height)
        self.view.addSubview(photoCollcectionViewController.view)
        photoCollcectionViewController.didMove(toParentViewController: self)
        // self.view.top + searchBar.bottom + MarginsCloseWidth/2
//        let topEdgeInsets:CGFloat = kCurrentSystemVersion >= 11.0 ? MDCAppNavigationBarHeight + MarginsCloseWidth/2-20 : MDCAppNavigationBarHeight + MarginsCloseWidth/2
//        photoCollcectionViewController.collectionView?.contentInset = UIEdgeInsetsMake(topEdgeInsets, 0, 0 , 0)
    }
    
    private func prepareSearchBar() {
        self.view.addSubview(searchBar)
        let menuImage = UIImage.init(named:"menu.png")
        menuButton = IconButton(image: menuImage)
        menuButton.addTarget(self, action: #selector(menuButtonTap(_:)), for: UIControlEvents.touchUpInside)
        
        searchBar.leftViews = [menuButton]
        searchBar.rightViews = [moreButton]
        searchBar.textField.delegate = self
    }
    
    lazy var photoCollcectionViewController : PhotoCollectionViewController = {
        let layout = MDCCollectionViewFlowLayout()
       //     layout.itemSize = CGSize(width: size.width, height:CellHeight)
        let collectVC = PhotoCollectionViewController.init(collectionViewLayout: layout)
        collectVC.collectionView?.emptyDataSetSource = self
        collectVC.collectionView?.emptyDataSetDelegate = self
        collectVC.delegate = self
        return collectVC
    }()
    
    lazy var searchBar: BaseSearchBar = {
        let searchBar = BaseSearchBar.init(frame: CGRect(x: MarginsCloseWidth, y: 20 + MarginsCloseWidth, width: __kWidth - MarginsWidth, height: searchBarHeight))
        searchBar.delegate = self
        return searchBar
    }()
    
    
    lazy var moreButton: IconButton = {
        let button = IconButton(image: Icon.cm.moreHorizontal?.byTintColor(LightGrayColor))
        button.addTarget(self, action: #selector(moreButtonTap(_:)), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    lazy var localAssetDataSources: Array<WSAsset> = {
        let array:Array<WSAsset> = Array.init()
        return array
    }()
    
    lazy var netAssetDataSource: Array<NetAsset> = {
        let array:Array<NetAsset> = Array.init()
        return array
    }()
    
    lazy var assetDataSources: Array<Array<WSAsset>> = {
        let array:Array<Array<WSAsset>> = Array.init()
        return array
    }()
    
//    lazy var fabButton: MDCFloatingButton = {
//        let plusImage = #imageLiteral(resourceName: "Plus")
//        let buttonWidth:CGFloat = 56
//        let defaultFloatingButton = MDCFloatingButton.init(frame: CGRect.init(x: __kWidth - 30 - buttonWidth, y: __kHeight - TabBarHeight - 16 - buttonWidth, width: buttonWidth, height: buttonWidth))
//
//        let plusImage36 = UIImage(named: "plus_white_36", in: Bundle(for: type(of: self)),
//                                  compatibleWith: traitCollection)
//
//        //        defaultFloatingButton.sizeToFit()
//        //        defaultFloatingButton.translatesAutoresizingMaskIntoConstraints = false
//        defaultFloatingButton.setImage(plusImage, for: .normal)
//        let mdcColorScheme = MDCButtonScheme.init()
//        MDCButtonColorThemer.apply(appDelegate.colorScheme, to: defaultFloatingButton)
//        defaultFloatingButton.addTarget(self, action: #selector(fabButtonDidTap(_ :)), for: UIControlEvents.touchUpInside)
//        return defaultFloatingButton
//    }()
    
    lazy var transitionController: MDCDialogTransitionController = {
        let controller = MDCDialogTransitionController.init()
        return controller
    }()
}

extension PhotoRootViewController:PhotoCollectionViewControllerDelegate{
    func collectionView(_ collectionView: UICollectionView, selectArray: Array<WSAsset>) {
        self.title = "已选择\(selectArray.count)张照片"
    }
    
    func collectionView(_ collectionView: UICollectionView, isSelectMode: Bool) {
         self.isSelectMode = isSelectMode
    }
}

extension PhotoRootViewController:DZNEmptyDataSetSource,DZNEmptyDataSetDelegate{
    
}

extension PhotoRootViewController:SearchBarDelegate{
    func searchBar(searchBar: SearchBar, didClear textField: UITextField, with text: String?) {
        
    }
    
    func searchBar(searchBar: SearchBar, willClear textField: UITextField, with text: String?) {
        
    }
    
    func searchBar(searchBar: SearchBar, didChange textField: UITextField, with text: String?) {
        
    }
}

extension PhotoRootViewController:TextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        self.enterSearch()
    }
}

extension PhotoRootViewController:FABBottomSheetDisplayVCDelegte{
    func cllButtonTap(_ sender: UIButton) {
        
    }
    
    func folderButtonTap(_ sender: UIButton) {
        
    }
    
    func uploadButtonTap(_ sender: UIButton) {
    
    }
    
    
}

extension PhotoRootViewController:MDCBottomSheetControllerDelegate{
    func bottomSheetControllerDidDismissBottomSheet(_ controller: MDCBottomSheetController) {
        
    }
}

extension Array {
    var decompose : (head: Element, tail: [Element])? {
        return (count > 0) ? (self[0], Array(self[1..<count])) : nil
    }
}

func qsortDemo(input: [WSAsset]) -> [WSAsset] {
    if let (pivot, rest) = input.decompose {
        let lesser = rest.filter { $0.createDate! < pivot.createDate!  }//这里是小于于pivot基数的分成一个数组
        let greater = rest.filter { $0.createDate! >= pivot.createDate!}//这里是大于等于pivot基数的分成一个数组
        return qsortDemo(input: lesser) + [pivot] + qsortDemo(input: greater)//递归 拼接数组
    } else {
        return []
    }
}
