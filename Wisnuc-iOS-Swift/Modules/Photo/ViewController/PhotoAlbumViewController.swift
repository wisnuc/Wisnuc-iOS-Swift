//
//  PhotoAlbumViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/9/20.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Photos

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
    override func viewDidLoad() {
        super.viewDidLoad()
        getData(animation: true)
//        prepareNavigationBar()
        self.view.addSubview(albumCollectionView)
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
        appBar.headerViewController.headerView.changeContentInsets { [weak self] in
            self?.appBar.headerViewController.headerView.trackingScrollView?.contentInset = UIEdgeInsets(top: (self?.appBar.headerViewController.headerView.trackingScrollView?.contentInset.top)! + kScrollViewTopMargin, left: 0, bottom: 0, right: 0)
        }
        self.albumCollectionView.mj_header = MDCFreshHeader.init(refreshingBlock: { [weak self] in
            self?.dataSource.removeAll()
            self?.getData(animation: false)
        })
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
//            tabbar.setTabBarHidden(false, animated: false)
            }
        }
        appBar.headerViewController.headerView.trackingScrollView = albumCollectionView
        appBar.appBarViewController.headerView.observesTrackingScrollViewScrollEvents = true
    }

    func prepareNavigationBar(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "add_album.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(rightButtonItemTap(_:)))
    }
    
    
    func getData(animation:Bool){
        if animation{
            ActivityIndicator.startActivityIndicatorAnimation()
        }
        allPhotoAlbumData()
    }
    
    func allPhotoAlbumData(){
        getAlbumPhotoData(sclass: SclassType.image.rawValue, closure: {[weak self](hash, asset,count) in
            if let hash = hash{
                self?.setAllPhotoData(hash:hash,count:count)
            }else{
                self?.setAllPhotoData(loacalAsset:asset!,count:count)
            }
            self?.allVideoAlbumData()
        })
    }
        
    func allVideoAlbumData(){
        getAllVideoAlbumData(sclass: SclassType.video.rawValue, closure: {[weak self](hash, asset,models) in
            if let hash = hash{
                self?.setVideoData(hash:hash, models: models)
            }else{
                self?.setVideoData(loacalAsset:asset!,models: models)
            }
        })
    }
    
    func getAlbumPhotoData(sclass:String,closure:@escaping (_ hash:String?,_ localAsset:PHAsset?,_ count:Int?)->()){
        self.searchAny(sClass: sclass) { [weak self](models, error) in
            ActivityIndicator.stopActivityIndicatorAnimation()
            if error == nil && models != nil{
                if let netTime = self?.fetchPhotoTime(model: models?.first),let localDate = PHAsset.latestAsset()?.creationDate{
                    let localTime = localDate.timeIntervalSince1970
                    if netTime > localTime{
                        if let photoHash =  models?.first?.fmhash{
                            return closure(photoHash,nil,models?.count)
                        }
                    }else{
                        return closure(nil,PHAsset.latestAsset()!,models?.count)
                    }
                }
            }else{
                return closure(nil,PHAsset.latestAsset()!,nil)
            }
        }
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
    
    func searchAny(text:String? = nil,types:String? = nil,sClass:String? = nil,complete:@escaping (_ mdoels: [NetAsset]?,_ error:Error?)->()){
        var array:Array<NetAsset> =  Array.init()
        var order:String?
        
        order = !isNilString(types) || !isNilString(sClass) ? nil : SearhOrder.newest.rawValue
        var placesArray:Array<String> = Array.init()
        let uuid = AppUserService.currentUser?.userHome
        placesArray.append(uuid!)
        self.placesArray = placesArray
        let places = placesArray.joined(separator: ".")
        let request = SearchAPI.init(order:order, places: places,class:sClass, types:types, name:text)
        request.startRequestJSONCompletionHandler { (response) in
            if response.error == nil{
                let isLocalRequest = AppNetworkService.networkState == .local
                let result = (isLocalRequest ? response.value as? NSArray : (response.value as! NSDictionary)["data"]) as? NSArray
                if result != nil{
                    let rootArray = result
                    for (_ , value) in (rootArray?.enumerated())!{
                        if value is NSDictionary{
                            let dic = value as! NSDictionary
                            if let model = NetAsset.deserialize(from: dic) {
                                array.append(model)
                            }else{
                              return  complete(nil,BaseError(localizedDescription: ErrorLocalizedDescription.JsonModel.SwitchTOModelFail, code: ErrorCode.JsonModel.SwitchTOModelFail))
                            }
                        }
                    }
                    return complete(array,nil)
                }
            }else{
                return complete(nil,response.error)
            }
        }
    }
    
    func setAllPhotoData(hash:String? = nil,loacalAsset:PHAsset? = nil,count:Int?){
        var collectionAlbumArray = Array<PhotoAlbumModel>.init()
        let photoAlbumModel1 = PhotoAlbumModel.init()
        photoAlbumModel1.type = PhotoAlbumType.collecion
        photoAlbumModel1.name = LocalizedString(forKey: "所有相片")
        if let photoHash = hash{
            photoAlbumModel1.coverThumbnilhash = photoHash
        }
        
        if let loacalAsset = loacalAsset{
            photoAlbumModel1.coverThumbnilAsset = loacalAsset
        }
        
        if let count = count{
            if let allAssets = AppAssetService.allAssets{
                photoAlbumModel1.count = count + allAssets.count
            }else{
                photoAlbumModel1.count = count
            }
        }
    
        if dataSource.count > 0{
            if var array = dataSource.first{
                array.append(photoAlbumModel1)
                dataSource[0] = array
            }
        }else{
            collectionAlbumArray.append(photoAlbumModel1)
            dataSource.append(collectionAlbumArray)
        }
       
        self.albumCollectionView.reloadData()
        self.albumCollectionView.mj_header.endRefreshing()
    }
    
    func setVideoData(hash:String? = nil,loacalAsset:PHAsset? = nil,models:[NetAsset]?){
        let photoAlbumModel = PhotoAlbumModel.init()
        photoAlbumModel.type  = PhotoAlbumType.collecion
        photoAlbumModel.name = LocalizedString(forKey: "Video")
        photoAlbumModel.describe = nil
        photoAlbumModel.dataSource = models
        if let photoHash = hash{
            photoAlbumModel.coverThumbnilhash = photoHash
        }
        if let loacalAsset = loacalAsset{
            photoAlbumModel.coverThumbnilAsset = loacalAsset
        }
        
        if let count = models?.count{
            if let allVideoAssets = AppAssetService.allVideoAssets{
                photoAlbumModel.count = count + allVideoAssets.count
            }else{
                photoAlbumModel.count = count
            }
        }else{
            photoAlbumModel.count = AppAssetService.allVideoAssets?.count
        }
        
        if dataSource.count > 0{
            if var array = dataSource.first{
                array.append(photoAlbumModel)
                dataSource[0] = array
            }
        }else{
            var array:[PhotoAlbumModel] = Array.init()
            array.append(photoAlbumModel)
            dataSource.append(array)
        }
        self.albumCollectionView.reloadData()
        self.albumCollectionView.mj_header.endRefreshing()
    }

    @objc func rightButtonItemTap(_ sender:UIBarButtonItem){
        let photosVC = PhotoRootViewController.init(style: NavigationStyle.select, state: PhotoRootViewControllerState.creat)
        photosVC.delegate = self
        DispatchQueue.global(qos: .default).async {
            let assets = AppAssetService.allAssets!
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
//        collectionViewLayout.itemSize
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
        let model = dataSource[indexPath.section][indexPath.row]
        cell.indexPath = indexPath
        cell.setCoverImage(indexPath: indexPath, hash: model.coverThumbnilhash, asset: model.coverThumbnilAsset)
        cell.nameLabel.text = model.name
        if  let count = model.count{
            cell.countLabel.text = String(describing: count)
        }else{
            cell.countLabel.text = "0"
        }
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let tabbar = retrieveTabbarController(){
            tabbar.setTabBarHidden(true, animated: true)
        }
        let model = dataSource[indexPath.section][indexPath.row]
        if indexPath.section == 0{
            switch indexPath.item {
            case 0:
                let photosVC = PhotoRootViewController.init(style: NavigationStyle.whiteWithoutShadow,state:.normal)
                if let cell = collectionView.cellForItem(at: indexPath) as? PhotoAlbumCollectionViewCell{
                    photosVC.title = cell.nameLabel.text
                }
                DispatchQueue.global(qos: .default).async {
                    let assets = AppAssetService.allAssets!
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
                self.navigationController?.pushViewController(photosVC, animated: true)
                
            case 1:
                let photosVC = PhotoMediaContainerViewController.init(style: NavigationStyle.whiteWithoutShadow,state:.normal)
                if let cell = collectionView.cellForItem(at: indexPath) as? PhotoAlbumCollectionViewCell{
                    photosVC.title = cell.nameLabel.text
                }
                DispatchQueue.global(qos: .default).async {
                    if let assets = AppAssetService.allVideoAssets{
                        DispatchQueue.main.async {
                            photosVC.localAssetDataSources.append(contentsOf:assets)
                            photosVC.localDataSouceSort()
                        }
                    }
                   
                    if let dataSource = model.dataSource{
                        DispatchQueue.main.async {
                            photosVC.addNetAssets(assetsArr: dataSource as! Array<NetAsset>)
                        }
                    }
                    
//                    self.searchAny(sClass: <#T##String?#>, complete: <#T##([NetAsset]?, Error?) -> ()#>)
//                    AppAssetService.getNetAssets { (error, netAssets) in
//                        if error == nil{
//                            DispatchQueue.main.async {
//                                photosVC.addNetAssets(assetsArr: netAssets!)
//                            }
//                        }else{
//                            DispatchQueue.main.async {
//                                photosVC.localDataSouceSort()
//                            }
//                        }
//                    }
                }
                 self.navigationController?.pushViewController(photosVC, animated: true)
            default:
                break
            }
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headView:PhotoAlbumCollectionViewHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: reuseHeaderIdentifier, for: indexPath) as! PhotoAlbumCollectionViewHeaderView
//        headView.setTitleLabelText(string: LocalizedString(forKey: "我的相册"))
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
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return section == 1 ? CGSize(width: __kWidth, height: 30 + MarginsWidth) : CGSize.zero
//    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
//        return CGSize(width: cellContentSize, height: 8 + 14 + 8)
//    }

    
}

extension PhotoAlbumViewController:PhotoRootViewControllerDelegate{
    func selectPhotoComplete(assets: Array<WSAsset>) {
        let newAlbumVC = NewAlbumViewController.init(style: .whiteWithoutShadow,photos:assets)
        newAlbumVC.delegate = self
        newAlbumVC.setState(.editing)
        self.index = (self.dataSource[1].count ) == 0 ? 0 : (self.dataSource[1].count ?? 1) - 1
        self.navigationController?.pushViewController(newAlbumVC, animated: true)
    }
}

extension PhotoAlbumViewController:NewAlbumViewControllerDelegate{
//    func updateNewAlbumFinish(data: Dictionary<String, Any>) {
//        var array = self.dataSource?[1]
//        let albumModel = PhotoAlbumModel.init()
//        albumModel.type = PhotoAlbumType.my
//        albumModel.name = data["name"] as? String
//        albumModel.describe = data["describe"] as? String
//        albumModel.dataSource = data["photoData"] as? [WSAsset]
//        if (array?.count)! == 0{
//            array?.append(albumModel)
//        }else{
//            array?[self.index] = albumModel
//        }
//      
//        self.dataSource?[1] = array!
//        self.albumCollectionView.reloadData()
//    }
    
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

