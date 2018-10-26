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

private var menuButton: IconButton!

@objc protocol PhotoRootViewControllerDelegate {
    func selectPhotoComplete(assets:Array<WSAsset>)
}

enum PhotoRootViewControllerState{
    case normal
    case select
    case creat
}

class PhotoRootViewController: BaseViewController {
//    override func willDealloc() -> Bool {
//        return false
//    }
    weak var delegate:PhotoRootViewControllerDelegate?
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
    
    init(state:PhotoRootViewControllerState,localDataSource:Array<WSAsset>?) {
        super.init()
        self.state = state
        setNotification()
        if localDataSource != nil {
            localAssetDataSources.append(contentsOf: localDataSource!)
        }
    }
    
    deinit {
      self.appBar.appBarViewController.headerView.trackingScrollView = nil
      print("\(className()) deinit")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: NavigationStyle) {
        super.init(style: style)
    }
    
    init(style: NavigationStyle ,state:PhotoRootViewControllerState) {
        super.init(style: style)
        self.setState(state: state)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ActivityIndicator.startActivityIndicatorAnimation()
        prepareCollectionView()
        prepareNavigationBar()
//        prepareSearchBar()
//        self.sort(localAssetDataSources)
//        self.photoCollcectionViewController.dataSource = assetDataSources
//        view.addSubview(self.fabButton)
        self.photoCollcectionViewController.collectionView?.mj_header = MDCFreshHeader.init(refreshingBlock: { [weak self] in
            self?.reloadAssetData()
        })
        self.view.bringSubview(toFront: self.appBar.headerViewController.headerView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appBar.appBarViewController.headerView.trackingScrollView = self.photoCollcectionViewController.collectionView
        appBar.appBarViewController.headerView.observesTrackingScrollViewScrollEvents = true
        appBar.headerViewController.preferredStatusBarStyle = .default
        appBar.headerViewController.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        defaultNotificationCenter().removeObserver(self, name: NSNotification.Name.Change.PhotoCollectionUserAuthChangeNotiKey, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func prepareNavigationBar(){
        
    }
    
    func reloadAssetData() {
        AppAssetService.getNetAssets { [weak self] (error, assetDataSource) in
            if error == nil{
                self?.localAssetDataSources = AppAssetService.allAssets!
                self?.addNetAssets(assetsArr: assetDataSource!)
                self?.isSelectMode = self?.isSelectMode
             
            }else{
                
            }
            self?.photoCollcectionViewController.collectionView?.reloadData()
            self?.photoCollcectionViewController.collectionView?.mj_header.endRefreshing()
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
    }
    
    func selectModeAction(){
        self.style = .select
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "close_white.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(leftBarButtonItemTap(_:)))
    }
    
    func unselectModeAction(){
       self.style = .whiteWithoutShadow
       self.navigationItem.leftBarButtonItem = nil

    }
    
    @objc func leftBarButtonItemTap(_ sender:UIBarButtonItem){
        if self.state == .select || self.state == .creat{
            self.presentingViewController?.dismiss(animated: true, completion: {
                
            })
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

    func setNotification(){
        defaultNotificationCenter().addObserver(forName: Notification.Name.Change.PhotoCollectionUserAuthChangeNotiKey, object: nil, queue: nil) {  [weak self] (noti) in
            var allPhotos = Array<WSAsset>.init()
            allPhotos.append(contentsOf: AppAssetService.allAssets!)
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
            var array:Array<WSAsset>  = Array.init()
            array.append(contentsOf: assetsArray)
            array.sort { (item1, item2) -> Bool in
                let t1 = item1.createDate ?? Date.distantPast
                let t2 = item2.createDate ?? Date.distantPast
                return t1 > t2
            }
            sortedAssetsBackupArray = array
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
            
            self.assetDataSources = photoGroupArray as! Array<Array<WSAsset>>
            self.photoCollcectionViewController.dataSource = self.assetDataSources
            self.photoCollcectionViewController.sortedAssetsBackupArray = self.sortedAssetsBackupArray
        }

    }
    
    func merge()->Array<WSAsset> {
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
        return mergedAssets as! Array<WSAsset>
    }
    
    func addNetAssets(assetsArr:Array<NetAsset>) {
//        DispatchQueue.global(qos: .default).async {
           self.netAssetDataSource = assetsArr
            self.sort(self.merge())
            ActivityIndicator.stopActivityIndicatorAnimation()
//            DispatchQueue.main.async {
        
//            }
//        }
    }
    
    
    func localDataSouceSort() {
        self.sort(self.merge())
        ActivityIndicator.stopActivityIndicatorAnimation()
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
