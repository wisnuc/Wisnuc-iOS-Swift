//
//  PhotoAlbumViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/9/20.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Photos
import Kingfisher

enum SclassType:String {
    case image
    case video
}

enum AlbumType:String {
    case image
    case video
}

class PhotoAlbumViewController: BaseViewController {
    private let reuseIdentifier = "reuseIdentifierPhotoCell"
    private let reuseHeaderIdentifier = "reuseIdentifierPhotoFooter"
    private let cellContentSizeWidth = (__kWidth - MarginsWidth*3)/2
    private let cellContentSizeHeight = (__kWidth - MarginsWidth*3)/2 + 56
    var index:Int = 0
    var placesArray:Array<String>?
    var photosVC:PhotoRootViewController?
    override init(style: NavigationStyle) {
        super.init(style: style)
         getData(animation: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(albumCollectionView)
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)

    }
    
    deinit {
        // Required for pre-iOS 11 devices because we've enabled observesTrackingScrollViewScrollEvents.
        appBar.appBarViewController.headerView.trackingScrollView = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let controller = UIViewController.currentViewController(){
            if !(controller is PhotoAlbumViewController){
                return
            }
        }
        self.setStatusBar(.default)
        if let tabbar = retrieveTabbarController(){
            if tabbar.tabBarHidden {
               tabbar.setTabBarHidden(false, animated: true)
            }
        }
        appBar.headerViewController.headerView.trackingScrollView = albumCollectionView
        appBar.appBarViewController.headerView.observesTrackingScrollViewScrollEvents = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func prepareNavigationBar(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "add_album.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(rightButtonItemTap(_:)))
    }
    
    
    func getData(animation:Bool){
        self.dataSource.removeAll()
        let collectionAlbumArray = Array<PhotoAlbumModel>.init()
        self.dataSource.append(collectionAlbumArray)
        DispatchQueue.global(qos: .userInitiated).async(execute: {
            self.allPhotoAlbumData()
            self.allVideoAlbumData()
            self.getAllBackup()
        })
    }
    
    
    func allPhotoAlbumData(){
        let allAssets = AppAssetService.allAssets ?? [WSAsset]()
        self.setAllPhotoData(models:[WSAsset](), hash:nil, allLocalAssets: allAssets,loacalAsset:allAssets.first?.asset,count:nil)
        getAlbumPhotoData(sclass: SclassType.image.rawValue, closure: {[weak self](hash, asset,count,assets) in
            if let hash = hash{
                if let assets = assets{
                    self?.setAllPhotoData(models:assets, hash:hash, allLocalAssets: allAssets,count:count)
                }
            }else if let asset = asset{
                if let assets = assets{
                    self?.setAllPhotoData(models:assets, allLocalAssets: allAssets, loacalAsset:asset,count:count)
                }
            }
        })
    }
        
    func allVideoAlbumData(){
        let allAssets = AppAssetService.allVideoAssets ?? [WSAsset]()
        self.setVideoData(models: nil,allVideoAssets: allAssets)
        getAllVideoAlbumData(sclass: SclassType.video.rawValue, closure: {[weak self](hash, asset,models) in
            if let hash = hash{
                self?.setVideoData(hash:hash, models: models, allVideoAssets: allAssets)
            }else{
                self?.setVideoData(loacalAsset:asset!,models: models, allVideoAssets: allAssets)
            }
        })
    }
    
    func getAlbumPhotoData(sclass:String,closure:@escaping (_ hash:String?,_ localAsset:PHAsset?,_ count:Int?,_ assets:[WSAsset]?)->()){
        let _ = AppAssetService.getNetAssets(callback: { (error, models) in
            if error == nil && models != nil{
                let sortedModels = models!
                if let netTime =  sortedModels.first?.createDate?.timeIntervalSince1970,let localDate = PHAsset.latestAsset()?.creationDate{
                    let localTime = localDate.timeIntervalSince1970
                    if netTime > localTime{
                        if let photoHash =  models?.first?.fmhash{
                            return closure(photoHash,nil,models?.count,sortedModels)
                        }
                    }else{
                        return closure(nil,PHAsset.latestAsset()!,models?.count,sortedModels)
                    }
                }else if models?.first != nil && PHAsset.latestAsset()?.creationDate == nil{
                    if let photoHash =  models?.first?.fmhash{
                        return closure(photoHash,nil,models?.count,sortedModels)
                    }
                }else if models?.first == nil && PHAsset.latestAsset()?.creationDate != nil{
                    return closure(nil,PHAsset.latestAsset()!,nil,sortedModels)
                }else{
                     return closure(nil,nil,nil,sortedModels)
                }
            }else{
                return closure(nil,PHAsset.latestAsset()!,nil,nil)
            }
        })
    }
    
    func getAllVideoAlbumData(sclass:String,closure:@escaping (_ hash:String?,_ localAsset:PHAsset?,_ models:[NetAsset]?)->()){
        self.searchAny(sClass: sclass) { [weak self](models, error) in
            if error == nil && models != nil{
                if let netTime = self?.fetchPhotoTime(model: models?.first),let localDate = PHAsset.latestVideoAsset()?.creationDate{
                    let localTime = localDate.timeIntervalSince1970
                    if netTime > localTime{
                        if let photoHash =  models?.first?.fmhash{
                            return closure(photoHash,nil,models)
                        }
                    }else{
                        return closure(nil,PHAsset.latestVideoAsset()!,models)
                    }
                }
            }
        }
    }
    
    func fetchPhotoTime(model:NetAsset?)->TimeInterval?{
        guard let emodel = model else{
            return nil
        }
        if  emodel.mtime != nil, let date =  emodel.metadata?.date,let datec = emodel.metadata?.datec{
            guard let datacTimeInterval = TimeTools.dateTimeIntervalUTC(datec),let dataTimeInterval = TimeTools.dateTimeIntervalUTC(date) else{
                return TimeInterval(emodel.mtime!/1000)
            }
            
            if let datacTimeInterval = TimeTools.dateTimeIntervalUTC(datec),TimeTools.dateTimeIntervalUTC(date) == nil{
                return datacTimeInterval
            }
            
            if let dataTimeInterval = TimeTools.dateTimeIntervalUTC(date),TimeTools.dateTimeIntervalUTC(datec) == nil{
                return dataTimeInterval
            }
    
            return  dataTimeInterval > datacTimeInterval ?  dataTimeInterval : datacTimeInterval
        }else if  emodel.mtime != nil, let date = emodel.metadata?.date ,emodel.metadata?.datec == nil{
            if let dataTimeInterval = TimeTools.dateTimeIntervalUTC(date){
                 return dataTimeInterval
            }else{
                 return TimeInterval(emodel.mtime!/1000)
            }
        }else if  let mtime = emodel.mtime{
            return TimeInterval(mtime/1000)
        }
        
        return  nil
    }
    
    func searchAny(places:String? = nil,text:String? = nil,types:String? = nil,sClass:String? = nil,complete:@escaping (_ mdoels: [NetAsset]?,_ error:Error?)->()){
        var array:Array<NetAsset> =  Array.init()
        var order:String?
        
        order = !isNilString(types) || !isNilString(sClass) ? nil : SearhOrder.newest.rawValue
        var place = places
        if places == nil{
            var placesArray:Array<String> = Array.init()
            if let uuid = AppUserService.currentUser?.userHome{
                placesArray.append(uuid)
            }
            self.placesArray = placesArray
            let placesPlaceholder = placesArray.joined(separator: ".")
            place = placesPlaceholder
        }
        let request = SearchAPI.init(order:order, places: place!,class:sClass, types:types, name:text)
        request.startRequestJSONCompletionHandler { (response) in
            if response.error == nil{
                if let errorMessage = ErrorTools.responseErrorData(response.data){
                    let error = NSError(domain: response.response?.url?.absoluteString ?? "", code: ErrorCode.Request.CloudRequstError, userInfo: [NSLocalizedDescriptionKey:errorMessage])
                    return complete(nil,error)
                }
              
                let result =  (response.value as? NSDictionary)?.object(forKey: "data") as? NSArray ??  response.value as? NSArray 
                if result != nil{
                    let rootArray = result
                    for (_ , value) in (rootArray?.enumerated())!{
                        if value is NSDictionary{
                            let dic = value as! NSDictionary
                            let model = NetAsset.init(dict:dic)
                            array.append(model)
                        }
                    }
                    return complete(array,nil)
                }
            }else{
                return complete(nil,response.error)
            }
        }
    }
    
    func setAllPhotoData(models:[WSAsset],hash:String? = nil,allLocalAssets:[WSAsset],loacalAsset:PHAsset? = nil,count:Int?){
        let photoAlbumModel1 = PhotoAlbumModel.init()
        photoAlbumModel1.type = PhotoAlbumType.collecion
        photoAlbumModel1.name = LocalizedString(forKey: "所有相片")
        photoAlbumModel1.detailType = .allPhoto
        if let photoHash = hash{
            photoAlbumModel1.coverThumbnilhash = photoHash
        }
        
        if let loacalAsset = loacalAsset{
            photoAlbumModel1.coverThumbnilAsset = loacalAsset
        }
        
        if let count = count{
            photoAlbumModel1.count = count + allLocalAssets.count
            var assetArray = Array<WSAsset>.init()
            assetArray.append(contentsOf: allLocalAssets)
            assetArray.append(contentsOf: models)
            photoAlbumModel1.dataSource = assetArray
        }else{
            photoAlbumModel1.count =  allLocalAssets.count
            photoAlbumModel1.dataSource = allLocalAssets
        }
        photoAlbumModel1.netDataSource = models as? [NetAsset]
        if var array = dataSource.first{
            if array.count > 0{
                if let index = array.firstIndex(where: {$0.detailType == .allPhoto}){
                    if index < array.count{
                         array[index] = photoAlbumModel1
                    }
                }else{
                    array.insert(photoAlbumModel1, at: 0)
                }
            }else{
                array.append(photoAlbumModel1)
            }
            dataSource[0] = array
        }
      
        DispatchQueue.main.async {
            self.albumCollectionView.reloadData()
        }
        
        //后台获取64*64缩略图并缓存
//        let backgroundDispatchQueue = DispatchQueue.init(label: "64picDownload", qos: .background)
//        backgroundDispatchQueue.async {
//            autoreleasepool {
//            for  model in models{
//                    guard let fmhash =  (model as? NetAsset)?.fmhash else {
//                        return
//                    }
//                    let size = CGSize(width: 64, height: 64)
//                    YYImageCache.shared().getImageData(forKey: fmhash, with: { (data) in
//                        if  data == nil{
//                            let _ = AppNetworkService.getThumbnailBackgroud(hash: fmhash, size: size) { (error, image, url) in
//                            }
//                        }
//                    })
//                }
//            }
//        }
    }
    
    func setVideoData(hash:String? = nil,loacalAsset:PHAsset? = nil,models:[NetAsset]?,allVideoAssets:[WSAsset]){
//        self.albumCollectionView.mj_header.endRefreshing()
        let photoAlbumModel = PhotoAlbumModel.init()
        photoAlbumModel.type  = PhotoAlbumType.collecion
        photoAlbumModel.name = LocalizedString(forKey: "Video")
        photoAlbumModel.detailType = .video
        photoAlbumModel.describe = nil
        if let photoHash = hash{
            photoAlbumModel.coverThumbnilhash = photoHash
        }
        if let loacalAsset = loacalAsset{
            photoAlbumModel.coverThumbnilAsset = loacalAsset
        }
        if let models = models{
            var assetArray = Array<WSAsset>.init()
            assetArray.append(contentsOf: allVideoAssets)
            assetArray.append(contentsOf: models)
            photoAlbumModel.dataSource = assetArray
            photoAlbumModel.count = models.count + allVideoAssets.count
        }else{
            photoAlbumModel.count = allVideoAssets.count
            photoAlbumModel.dataSource = allVideoAssets
        }
        if var array = dataSource.first{
            if array.count >= 2{
                if let index = array.firstIndex(where: {$0.detailType == .video}){
                    if index < array.count{
                        array[index] = photoAlbumModel
                    }
                }else{
                     array.insert(photoAlbumModel, at: 1)
                }
            } else{
                array.append(photoAlbumModel)
            }
            dataSource[0] = array
        }
         DispatchQueue.main.async {
            self.albumCollectionView.reloadData()
        }
    }
    
    func getAllBackup(){
        AppNetworkService.getUserAllBackupDrive { [weak self](error,driveModels) in
            if let error = error{
                Message.message(text: error.localizedDescription)
            }else{
                if driveModels?.count ?? 0 > 0{
                    self?.setBackupData(models: driveModels)
                }
            }
        }
    }
    
    func creatBackupDrive(){
        AppNetworkService.creactBackupDrive(callBack: { [weak self](error, driveModel) in
            if let error = error{
                Message.message(text: error.localizedDescription)
            }else{
                if driveModel != nil{
                  self?.getAllBackup()
                }
            }
        })
    }
    
    func setBackupData(models:[DriveModel]?){
        guard let driveModels = models else {
            return
        }
        var index:Int = 1
        for (i,model) in driveModels.enumerated(){
            guard let place = model.uuid else{
                return
            }
            let types = kMediaTypes.joined(separator: ".")
            self.searchAny(places: place, types: types) { [weak self](assets, error) in
                if let error = error{
                
                }else{
                    guard let assets = assets else{
                        return
                    }
                    let photoAlbumModel = PhotoAlbumModel.init()
                    photoAlbumModel.type  = PhotoAlbumType.collecion
                    photoAlbumModel.name = model.label
                    photoAlbumModel.describe = nil
                    photoAlbumModel.dataSource = assets
                    photoAlbumModel.drive = model.uuid
                    photoAlbumModel.detailType = .backup
                    if let photoHash = assets.first?.fmhash {
                        photoAlbumModel.coverThumbnilhash = photoHash
                    }
                    photoAlbumModel.count = assets.count
                    index = index + i
                    if var array = self?.dataSource.first{
                        if array.count > 0{
                            array.append(photoAlbumModel)
                        }
                        self?.dataSource[0] = array
                    }
                    DispatchQueue.main.async {
                    self?.albumCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    @objc func rightButtonItemTap(_ sender:UIBarButtonItem){
        let photosVC = PhotoRootViewController.init(style: NavigationStyle.select, state: PhotoRootViewControllerState.creat)
        photosVC.delegate = self
        DispatchQueue.global(qos: .default).async {
            guard  let assets = AppAssetService.allAssets else{
                return
            }
            DispatchQueue.main.async {
                photosVC.localAssetDataSources.append(contentsOf:assets)
                photosVC.localDataSouceSort()
            }
            
            let requset = AppAssetService.getNetAssets { (error, netAssets) in
                if error == nil{
                    DispatchQueue.main.async {
                        photosVC.addNetAssets(assetsArr: netAssets!)
                    }
                }else{
                    DispatchQueue.main.async {
                        photosVC.localDataSouceSort()
                    }
                }
            }
            photosVC.requset = requset
        }
        let navigationVC = UINavigationController.init(rootViewController: photosVC)
        self.present(navigationVC, animated: true) {
            
        }
    }
    
    lazy var albumCollectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout.init()
        let collectionView = UICollectionView.init(frame: CGRect(x: 0, y: 0, width: __kWidth, height: __kHeight - TabBarHeight), collectionViewLayout: collectionViewLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoAlbumCollectionViewHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: reuseHeaderIdentifier)
        collectionView.register(UINib.init(nibName: StringExtension.classNameAsString(targetClass: PhotoAlbumCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    lazy var dataSource:[[PhotoAlbumModel]] = [[PhotoAlbumModel]]()
    
}

extension PhotoAlbumViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.dataSource.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:PhotoAlbumCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoAlbumCollectionViewCell
        if dataSource.count > indexPath.section{
            if dataSource[indexPath.section].count > indexPath.row{
                let model = dataSource[indexPath.section][indexPath.row]
                cell.indexPath = indexPath
                cell.imageView.image = UIImage.init(color: UIColor.black.withAlphaComponent(0.04))
              
                cell.nameLabel.text = model.name
                if  let count = model.count{
                    cell.countLabel.text = String(describing: count)
                }else{
                    cell.countLabel.text = "0"
                }
                cell.setCoverImage(indexPath: indexPath, hash: model.coverThumbnilhash, asset: model.coverThumbnilAsset)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let tabbar = retrieveTabbarController(){
            tabbar.setTabBarHidden(true, animated: true)
        }

        let model = dataSource[indexPath.section][indexPath.row]
        if indexPath.section == 0{
            if model.detailType == .allPhoto{
                let photosVC = PhotoRootViewController.init(style: NavigationStyle.whiteWithoutShadow,state:.normal)
                if let dataSource = model.dataSource{
                    photosVC.sort(dataSource)
                }
                photosVC.title = model.name
                if let netDataSource = model.netDataSource{
                    photosVC.netAssetDataSource = netDataSource
                }
                self.navigationController?.pushViewController(photosVC, animated: true)
            }else if model.detailType == .video{
                let photosVC = PhotoRootViewController.init(style: NavigationStyle.whiteWithoutShadow,state: .normal, localDataSource: AppAssetService.allVideoAssets, netDataSource: model.dataSource as? Array<NetAsset>, video: true)
                photosVC.title = model.name
                var dataSource = Array<WSAsset>.init()
                if let allLocalVideoAssets = AppAssetService.allVideoAssets{
                    dataSource.append(contentsOf: allLocalVideoAssets)
                }
                
                if let allNetVideoAssets = model.dataSource{
                    dataSource.append(contentsOf: allNetVideoAssets)
                }
              
                photosVC.sort(dataSource)
                self.navigationController?.pushViewController(photosVC, animated: true)
            }else
            if  model.detailType == .backup  && model.drive != nil{
                let photosVC = PhotoRootViewController.init(style: NavigationStyle.whiteWithoutShadow, state: .normal, netDataSource: model.dataSource as? Array<NetAsset>, backupDriveUUID: model.drive)
                photosVC.title = model.name
                if let backUpDataSource = model.dataSource{
                     photosVC.sort(backUpDataSource)
                }
                self.navigationController?.pushViewController(photosVC, animated: true)
        }else{
            let model = dataSource[indexPath.section][indexPath.row]
            let newAlbumVC = NewAlbumViewController.init(style: NavigationStyle.whiteWithoutShadow, photos: model.dataSource)
            newAlbumVC.delegate = self
            newAlbumVC.setState(NewAlbumViewControllerState.normal)
            newAlbumVC.setContent(title: model.name, describe: model.describe)
            self.navigationController?.pushViewController(newAlbumVC, animated: true)
            self.index = indexPath.row
        }
    }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headView:PhotoAlbumCollectionViewHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: reuseHeaderIdentifier, for: indexPath) as! PhotoAlbumCollectionViewHeaderView
        return headView
    }
}

extension PhotoAlbumViewController :UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      
        return CGSize(width:cellContentSizeWidth , height: cellContentSizeHeight)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return  section == 0 ? UIEdgeInsets.init(top: 0, left: 16, bottom: 0, right: 16) : UIEdgeInsets.init(top: 16, left: 16, bottom: 0, right: 16)
    }
}

extension PhotoAlbumViewController:PhotoRootViewControllerDelegate{
    func selectPhotoComplete(assets: Array<WSAsset>) {
        let newAlbumVC = NewAlbumViewController.init(style: .whiteWithoutShadow,photos:assets)
        newAlbumVC.delegate = self
        newAlbumVC.setState(.editing)
        self.index = (self.dataSource[1].count ) == 0 ? 0 : (self.dataSource[1].count) - 1
        self.navigationController?.pushViewController(newAlbumVC, animated: true)
    }
}

//新建相册-旧设计
extension PhotoAlbumViewController:NewAlbumViewControllerDelegate{
    func creatNewAlbumFinish(data: Dictionary<String, Any>) {
        var array = self.dataSource[1]
        let albumModel = PhotoAlbumModel.init()
        albumModel.type = PhotoAlbumType.my
        albumModel.name = data["name"] as? String
        albumModel.describe = data["describe"] as? String
        albumModel.dataSource = data["photoData"] as? [WSAsset]
        array.append(albumModel)
        self.dataSource[1] = array
        self.albumCollectionView.reloadData()
    }
}

