//
//  FilesRootViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/3.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents
import Material
import RxSwift


enum CellStyle:Int {
    case card = 0
    case list
}

//enum CollectState:Int {
//    case normal = 0
//    case select
//    case unselect
//}

enum RootControllerState:Int {
    case root = 0
    case movecopy
    case share
    case next
}

private let reusableIdentifierItem = "itemCellIdentifier"
private let cellFolderHeight:CGFloat = 48
private let cellWidth:CGFloat = (__kWidth - 4)/2
public let searchBarHeight:CGFloat = 137
internal let SearchBarBottom:CGFloat = 77.0
private let moveButtonWidth:CGFloat = 40
private let moveButtonHeight:CGFloat = 36.0

class FilesRootViewController: BaseViewController{
//    override func willDealloc() -> Bool {
//        return false
//    }
    static let downloadManager =  TRManager.init("Downloads", MaximumRunning: LONG_MAX, isStoreInfo: true)
    private var menuButton: IconButton!
    var isLoadingViewController = false
    var dataSource:Array<Any>?
    var originDataSource:Array<EntriesModel>?
    var driveUUID:String?
    var directoryUUID:String?
    var sortType:SortType?
    var isListStyle:Bool?
    var sortIsDown:Bool?
    var isRequesting:Bool?
    var navigationTitle:String?
    var srcDictionary: Dictionary<String, String>?
    var moveModelArray: Array<EntriesModel>?
    var isCopy:Bool = false
    var model:EntriesModel?
    var backupRoot:Bool = false
    var cellStyle:CellStyle?{
        didSet{
            switch cellStyle {
            case .list?:
                listCellStyleAction()
            case .card?:
                gridCellStyleAction()
            default:
                gridCellStyleAction()
            }
        }
    }
    var isSelectModel:Bool?{
        didSet{
            if isSelectModel!{
                selectAction()
            }else{
                selectModelCloseAction()
            }
        }
    }
    
    var selfState:RootControllerState?{
        didSet{
            switch selfState {
            case .root?:
                self.directoryUUID = AppUserService.currentUser?.userHome
                self.driveUUID = AppUserService.currentUser?.userHome
            case .movecopy?:
                let drive = self.driveUUID ?? AppUserService.currentUser?.userHome ?? ""
                let dir = self.directoryUUID ?? AppUserService.currentUser?.userHome ?? ""
                let title = isCopy ? LocalizedString(forKey: "复制到") : LocalizedString(forKey: "移动到")
                self.movetoButton.setTitle(title, for: UIControlState.normal)
                if drive ==  self.srcDictionary![kRequestTaskDriveKey]! && dir == self.srcDictionary![kRequestTaskDirKey]!{
                   self.movetoButton.isEnabled = false
                }
                if  (self.moveModelArray?.contains(where: {$0.uuid == model?.uuid}))!{
                    self.movetoButton.isEnabled = false
                }
                
            case .share?:
                let title =  LocalizedString(forKey: "分享到")
                self.movetoButton.setTitle(title, for: UIControlState.normal)
                self.movetoButton.isEnabled = true
                if  (self.moveModelArray?.contains(where: {$0.uuid == model?.uuid}))!{
                    self.movetoButton.isEnabled = false
                }

            case .next?:
               break
            default:
                break
            }
            self.collcectionViewController?.state = selfState
        }
    }
    
    deinit {
        print("\(className()) deinit")
        self.collcectionViewController = nil
        removeCollectionView()
//        FilesRootViewController.downloadManager.invalidate()
        defaultNotificationCenter().removeObserver(self, name: NSNotification.Name.Refresh.MoveRefreshNotiKey, object: nil)
    }
    
    override init(style: NavigationStyle) {
        super.init(style: style)
          prepareData(animation: true)
    }
    
    override init() {
        super.init()
        self.setState(state: .root)
        prepareData(animation: true)
    }
    
    init(driveUUID:String,directoryUUID:String,style: NavigationStyle,backupRoot:Bool? = nil) {
        super.init(style: style)
        self.setState(state: .next)
        self.directoryUUID = directoryUUID
        self.driveUUID = driveUUID
        if let backupRoot = backupRoot{
           self.backupRoot = backupRoot
        }
        prepareData(animation: true)
    }
    
    init(style: NavigationStyle,srcDictionary:Dictionary<String, String>?,moveModelArray:Array<EntriesModel>?,isCopy:Bool?,isShare:Bool = false,driveUUID:String? = nil,directoryUUID:String? = nil) {
        super.init(style: style)
        self.directoryUUID = directoryUUID
        self.driveUUID = driveUUID
        self.srcDictionary = srcDictionary
        self.moveModelArray = moveModelArray
        self.isCopy = isCopy ?? false
        if isShare{
            self.setState(state: .share)
        }else{
             self.setState(state: .movecopy)
        }
        prepareData(animation: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = lightGrayBackgroudColor
        prepareCollectionView()
        setCellStyle()
        switch selfState {
        case .root?:
            prepareRootAppNavigtionBar()
            prepareSearchBar()
            self.driveUUID = AppUserService.currentUser?.userHome
            self.directoryUUID = AppUserService.currentUser?.userHome
//            self.view.addSubview(fabButton)
        case .movecopy?,.share?:
            prepareMoveCopyAppNavigtionBar()
            setMoveToCollectionViewFrame()
            self.view.addSubview(moveFilesBottomBar)
            moveFilesBottomBar.addSubview(movetoButton)
            moveFilesBottomBar.addSubview(cancelMovetoButton)
        case .next?:
            preparenNextAppNavigtionBar()
//            self.view.addSubview(fabButton)
        default:
            break
        }
        FilesRootViewController.downloadManager.isStartDownloadImmediately = false
        self.navigationTitle = title
        self.collcectionViewController?.collectionView?.mj_header = MDCFreshHeader.init(refreshingBlock: { [weak self] in
            self?.prepareData(animation: false)
        })
        self.appBar.headerViewController.inferPreferredStatusBarStyle = false
        self.appBar.headerViewController.preferredStatusBarStyle = .default
        self.appBar.headerViewController.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let controller = UIViewController.currentViewController(){
            if !(controller is FilesRootViewController){
               return
            }
        }
    
        switch selfState {
        case .root?:
            selfStateRootWillAppearAction()
        default:
            selfStateOtherWillAppearAction()
        }
        if isSelectModel != nil && isSelectModel!{
            isSelectModel = false
        }
        let sortType = AppUserService.currentUser?.sortType == nil ? SortType(rawValue: 0) : SortType(rawValue: (AppUserService.currentUser?.sortType?.int64Value)!)
        let sortIsDown = AppUserService.currentUser?.sortIsDown == nil ? true : AppUserService.currentUser?.sortIsDown?.boolValue
        if dataSource != nil {
            self.setSortParameters(sortType: sortType!, sortIsDown: sortIsDown!)
            self.collcectionViewController?.collectionView?.reloadData()
        }
        
        let isListStyle = AppUserService.currentUser?.isListStyle == nil ? CellStyle(rawValue: 0) : CellStyle(rawValue: (AppUserService.currentUser?.isListStyle?.intValue)!)
        self.cellStyle = isListStyle
        popBackRefresh()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationDrawerController?.isLeftPanGestureEnabled = false
        self.view.endEditing(true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
   
    }
    
    func setState(state:RootControllerState){
         selfState = state
    }
    
    func popBackRefresh(){
        let fromViewController = self.navigationController?.transitionCoordinator?.viewController(forKey: UITransitionContextViewControllerKey.from)
        if fromViewController != nil{
            if !(self.navigationController?.viewControllers.contains(fromViewController!))! && self.presentedViewController == nil
            {//Something is being popped and we are being revealed
                self.prepareData(animation: false)
            }
        }
    }
    
    func setCellStyle(){
        if AppUserService.currentUser?.isListStyle != nil {
            self.cellStyle = (AppUserService.currentUser?.isListStyle?.boolValue)! ? CellStyle.list : CellStyle.card
        }else{
                cellStyle = .card
        }
        self.collcectionViewController?.cellStyle = cellStyle
        AppUserService.currentUser?.isListStyle = NSNumber.init(value:(cellStyle?.rawValue)!)
        AppUserService.synchronizedCurrentUser()
    }
    
    func setMoveToCollectionViewFrame(){
        collcectionViewController?.view.frame =  CGRect.init(x: self.view.left, y:0, width: self.view.width, height: self.view.height - moveFilesBottomBar.height)
    }
    
    func setSelectModel(){
        isSelectModel = false
    }
    
    func listCellStyleAction(){
        self.listStyleButton.isSelected = true
        self.collcectionViewController?.cellStyle = cellStyle
        AppUserService.currentUser?.isListStyle = NSNumber.init(value:(cellStyle?.rawValue)!)
        AppUserService.synchronizedCurrentUser()
        styleItem.image  = UIImage.init(named: "gridstyle.png")
    }
    
    func gridCellStyleAction(){
        self.listStyleButton.isSelected = false
        self.collcectionViewController?.cellStyle = cellStyle
        AppUserService.currentUser?.isListStyle = NSNumber.init(value:(cellStyle?.rawValue)!)
        AppUserService.synchronizedCurrentUser()
        styleItem.image = UIImage.init(named: "liststyle.png")
    }
     
    func prepareData(animation:Bool) {
        isRequesting = true
        if animation{
            self.startActivityIndicator()
        }
        let requestDriveUUID = self.driveUUID ?? AppUserService.currentUser?.userHome ?? ""
        let requestDirectoryUUID = self.directoryUUID ?? AppUserService.currentUser?.userHome ?? ""
        DriveDirAPI.init(driveUUID: requestDriveUUID, directoryUUID: requestDirectoryUUID).startRequestJSONCompletionHandler {[weak self] (response) in
            self?.isRequesting = false
            self?.dataSource = Array.init()
            if let mj_header = self?.collcectionViewController?.collectionView?.mj_header  {
                mj_header.endRefreshing()
            }
            self?.stopActivityIndicator()
            if response.error == nil{
                if let errorMessage = ErrorTools.responseErrorData(response.data){
                    Message.message(text: errorMessage)
                    self?.isRequesting = false
                    return
                }
                let responseDic =  response.value as? NSDictionary ?? (response.value as? NSDictionary)?.object(forKey: "data") as? NSDictionary ?? NSDictionary.init()
                let data = jsonToData(jsonDic: responseDic)
                do{
                    let model = try JSONDecoder().decode(FilesModel.self, from: data!)
                    self?.originDataSource = model.entries
                    self?.dataSource = self?.displayDataSource(model:model)
                    self?.loadDataSouce()
                }catch{
                    Message.message(text: LocalizedString(forKey: "error"))
                }
            }else{
                if let messageText = response.error?.localizedDescription{
                    Message.message(text: messageText)
                }
            }
        }
    }
    
    func displayDataSource(model:FilesModel)->Array<Any>{
        var filesArray = Array<EntriesModel>.init()
        var directoryArray = Array<EntriesModel>.init()
        var finishArray = Array<Any>.init()
        guard let entries = model.entries else { return Array<Any>.init()}
        for value in entries{
            var filesModel = value
            filesModel.backupRoot = backupRoot
            if value.type == FilesType.directory.rawValue{
                filesArray.append(filesModel)
            }else if value.type == FilesType.file.rawValue{
                directoryArray.append(filesModel)
            }
        }
        if filesArray.count != 0{
            finishArray.append(filesArray)
        }
        
        if directoryArray.count != 0{
            finishArray.append(directoryArray)
        }
        return finishArray
    }
    
    func loadDataSouce(){
        self.collcectionViewController?.dataSource = self.dataSource
        self.collcectionViewController?.driveUUID = self.driveUUID
        self.collcectionViewController?.dirUUID = self.directoryUUID
        let sortType = AppUserService.currentUser?.sortType == nil ? SortType(rawValue: 0) : SortType(rawValue: (AppUserService.currentUser?.sortType?.int64Value)!)
        let sortIsDown = AppUserService.currentUser?.sortIsDown == nil ? true : AppUserService.currentUser?.sortIsDown?.boolValue
        self.setSortParameters(sortType: sortType!, sortIsDown: sortIsDown!)
        self.isRequesting = false
        self.collcectionViewController?.collectionView?.reloadData()
        self.collcectionViewController?.collectionView?.reloadEmptyDataSet()
    }
    
    func setSortParameters(sortType:SortType,sortIsDown:Bool){
        self.sortType = sortType
        self.sortIsDown = sortIsDown
        sortData(sortType: sortType, sortIsDown: sortIsDown)
        self.collcectionViewController?.sortType = sortType
        self.collcectionViewController?.sortIsDown = sortIsDown
        self.collcectionViewController?.dataSource = dataSource
    }
    
    func sortData(sortType:SortType,sortIsDown:Bool) {
        AppUserService.currentUser?.sortType =  NSNumber.init(value: Int8(sortType.rawValue))
        AppUserService.currentUser?.sortIsDown = NSNumber.init(value: sortIsDown)
        AppUserService.synchronizedCurrentUser()
        var folderArray:Array<EntriesModel>? = dataSource?[safe: 0] as? Array
        var filesArray:Array<EntriesModel>? = dataSource?[safe: 1] as? Array<EntriesModel>
        switch sortType.rawValue {
        case 0:
            if sortIsDown{
                folderArray?.sort { $0.name! < $1.name! }
                filesArray?.sort { $0.name! < $1.name! }
            }else{
                folderArray?.sort { $0.name! > $1.name! }
                filesArray?.sort { $0.name! > $1.name! }
            }
        case 1:
            if sortIsDown{
                folderArray?.sort { $0.mtime! < $1.mtime! }
                filesArray?.sort { $0.mtime! < $1.mtime! }
            }else{
                folderArray?.sort { $0.mtime! > $1.mtime! }
                filesArray?.sort { $0.mtime! > $1.mtime! }
            }
        case 2:
            if sortIsDown{
                folderArray?.sort { $0.mtime! < $1.mtime! }
                filesArray?.sort { $0.mtime! < $1.mtime! }
            }else{
                folderArray?.sort { $0.mtime! > $1.mtime! }
                filesArray?.sort { $0.mtime! > $1.mtime! }
            }
        case 3:
            if sortIsDown{
//                folderArray?.sort { $0.size! < $1.size! }
                filesArray?.sort { $0.size! < $1.size! }
            }else{
//                folderArray?.sort { $0.size! > $1.size! }
                filesArray?.sort { $0.size! > $1.size! }
            }
        default:
            break
        }
        var finishArray:Array<Any> = Array.init()
        if  folderArray != nil {
            finishArray.append(folderArray!)
        }
        if  filesArray != nil {
            finishArray.append(filesArray!)
        }
        dataSource = finishArray
    }
    
    func prepareCollectionView(){
        guard let collcectionViewController = collcectionViewController else {
            return
        }
        self.addChildViewController(collcectionViewController)
        collcectionViewController.view.frame =  CGRect.init(x: self.view.left, y:0, width: self.view.width, height: self.view.height)
        self.view.addSubview(collcectionViewController.view)
        collcectionViewController.didMove(toParentViewController: self)
        // self.view.top + searchBar.bottom + MarginsCloseWidth/2
        let topEdgeInsets:CGFloat = kCurrentSystemVersion >= 11.0 ? searchBar.bottom + MarginsCloseWidth/2-20 : searchBar.bottom + MarginsCloseWidth/2
        collcectionViewController.collectionView?.contentInset = UIEdgeInsetsMake(topEdgeInsets, 0, 0 , 0)
    }
    
    func removeCollectionView(){
        if self.childViewControllers.count > 0{
            let viewControllers:[UIViewController] = self.childViewControllers
            for viewContoller in viewControllers{
                viewContoller.willMove(toParentViewController: nil)
                viewContoller.view.removeFromSuperview()
                viewContoller.removeFromParentViewController()
            }
        }
    }
    
    func selectAction(){
        //        print(searchBar.bottom)
        DispatchQueue.main.async {
            self.selectSearchBarAction()
        }
        if searchBar.bottom >= 0{
            UIView.animate(withDuration: 0.3, animations: {
                self.searchBar.bottom = 0
            })
        }else{
            
        }
        
        self.title = "\(String(describing: (FilesHelper.sharedInstance().selectFilesArray?.count)!))"
        self.appBar.headerViewController.preferredStatusBarStyle = .lightContent
        self.appBar.headerViewController.setNeedsStatusBarAppearanceUpdate()
//        fabButton.collapse(true) {
//
//        }
        let tab = retrieveTabbarController()
        tab?.setTabBarHidden(true, animated: true)
        
        if selfState != .root{
            selectedNavigationBarView.addSubviewsToParent()
            selectedNavigationBarView.headerViewController.didMove(toParentViewController: self)
            self.selectedNavigationBarView.headerViewController.headerView.top = -MDCAppNavigationBarHeight
            self.prepareSelectModelNextAppNavigtionBar()
            self.view.addSubview(selectedNavigationBarView.headerViewController.headerView)
            self.view.bringSubview(toFront: selectedNavigationBarView.headerViewController.headerView)
            self.transition(from: appBar.headerViewController, to: selectedNavigationBarView.headerViewController, duration: 0.3, options: UIViewAnimationOptions.beginFromCurrentState, animations: { [weak self] in
                self?.selectedNavigationBarView.headerViewController.headerView.top = 0
                self?.appBar.headerViewController.headerView.removeFromSuperview()
                self?.appBar.headerViewController.removeFromParentViewController()
//                self?.title =  self?.navigationTitle
            }) {(finish) in
            }
        }
    }
    
    func selectModelCloseAction(){
        self.appBar.headerViewController.headerView.isHidden = false
//        if searchBar.bottom <= 0{
        
        self.appBar.headerViewController.preferredStatusBarStyle = .default
        self.appBar.headerViewController.setNeedsStatusBarAppearanceUpdate()
        collcectionViewController?.isSelectModel = isSelectModel
//        fabButton.expand(true) {
//        }
        
        if selfState == .root{
            let tab = retrieveTabbarController()
            tab?.setTabBarHidden(false, animated: true)
            DispatchQueue.main.async {
                self.unselectSearchBarAction()
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.searchBar.top = 20 + MarginsCloseWidth
            })
        }else{
            self.addChildViewController(appBar.headerViewController)
            appBar.headerViewController.didMove(toParentViewController: self)
            self.transition(from: selectedNavigationBarView.headerViewController,  to: appBar.headerViewController, duration: 0.3, options: UIViewAnimationOptions.beginFromCurrentState, animations: { [weak self] in
                self?.selectedNavigationBarView.headerViewController.headerView.top = -MDCAppNavigationBarHeight
            }) {  (finish) in
                
            }
            
        }
        self.title =  self.navigationTitle
    }
    
    func selectSearchBarAction(){
        self.appBar.headerViewController.headerView.isHidden = false
    }
    
    func unselectSearchBarAction(){
        self.appBar.headerViewController.headerView.isHidden = true
    }
    
    func selfStateRootWillAppearAction(){
        self.appBar.headerViewController.preferredStatusBarStyle = .default
        self.appBar.headerViewController.setNeedsStatusBarAppearanceUpdate()
        self.appBar.headerViewController.headerView.isHidden = true
        self.navigationDrawerController?.isLeftPanGestureEnabled = true
        navigationController?.delegate = self
//        if (self.navigationDrawerController?.rootViewController) != nil {
//        if let controller = UIViewController.currentViewController(){
//            if  controller.isKind(of: FilesRootCollectionViewController.self) || controller.isKind(of: FilesRootViewController.self) {
                let tab = retrieveTabbarController()
                tab?.setTabBarHidden(false, animated: true)
//            }
//        }
        
//            let drawerController:FilesDrawerTableViewController = self.navigationDrawerController?.leftViewController as! FilesDrawerTableViewController
//            drawerController.delegate = self
//        }
        self.view.endEditing(true)
    }
    
    func selfStateOtherWillAppearAction(){
        self.appBar.headerViewController.headerView.isHidden = false
        self.view.bringSubview(toFront: self.appBar.headerViewController.headerView)
        self.appBar.headerViewController.preferredStatusBarStyle = .default
        self.appBar.headerViewController.setNeedsStatusBarAppearanceUpdate()
        let tab = retrieveTabbarController()
        tab?.setTabBarHidden(true, animated: true)
    }
    
    func prepareRootAppNavigtionBar(){
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
        let leftItem = UIBarButtonItem.init(image: Icon.close?.byTintColor(.white), style: UIBarButtonItemStyle.done, target: self, action: #selector(closeSelectModelButtonTap(_ :)))
//        let paceItem = UIBarButtonItem.init(customView: UIView.init(frame: CGRect(x: 0, y: 0, width: 32, height: 20)))
//        let labelBarButtonItem = UIBarButtonItem.init(customView: selectNumberAppNaviLabel)
        self.navigationItem.leftBarButtonItems = [leftItem]
        self.navigationItem.rightBarButtonItems = [moreBarButtonItem,downloadBarButtonItem,moveBarButtonItem]
    }
    
    func prepareSelectModelNextAppNavigtionBar(){
        let leftItem = UIBarButtonItem.init(image: Icon.close?.byTintColor(.white), style: UIBarButtonItemStyle.done, target: self, action: #selector(closeSelectModelButtonTap(_ :)))
//        let paceItem = UIBarButtonItem.init(customView: UIView.init(frame: CGRect(x: 0, y: 0, width: 32, height: 20)))
//        let labelBarButtonItem = UIBarButtonItem.init(customView: selectNumberAppNaviLabel)
        self.selectedNavigationBarView.navigationBar.leftBarButtonItems = [leftItem]
        self.selectedNavigationBarView.navigationBar.rightBarButtonItems = [moreBarButtonItem,downloadBarButtonItem,moveBarButtonItem]
    }
    
    func prepareMoveCopyAppNavigtionBar(){
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
        let rightItem = UIBarButtonItem.init(image: UIImage.init(named: "files_new_folder_gray.png"), style: UIBarButtonItemStyle.done, target: self, action: #selector(newFolderButtonTap(_ :)))
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    func preparenNextAppNavigtionBar(){
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
        let moreItem = UIBarButtonItem.init(image: UIImage.init(named: "more_gray_horizontal.png"), style: UIBarButtonItemStyle.done, target: self, action: #selector(moreButtonTap(_ :)))
        let searchItem = UIBarButtonItem.init(image: UIImage.init(named: "search.png"), style: UIBarButtonItemStyle.done, target: self, action: #selector(enterSearch))
        if self.cellStyle == .list {
            styleItem.image = UIImage.init(named: "gridstyle.png")
        }
        self.navigationItem.rightBarButtonItems = [moreItem,styleItem,searchItem]
    }
    
    func registerNotification(){
        defaultNotificationCenter().removeObserver(self, name: NSNotification.Name.Refresh.MoveRefreshNotiKey, object: nil)
        defaultNotificationCenter().addObserver(self, selector: #selector(refreshNotification(_ :)), name: NSNotification.Name.Refresh.MoveRefreshNotiKey, object: nil)
    }
    
    func readFile(filePath:String){
        let documentController = UIDocumentInteractionController.init()
        documentController.delegate = self
        documentController.url = URL.init(fileURLWithPath: filePath)
        let  canOpen = documentController.presentPreview(animated: true)
        if (!canOpen) {
            Message.message(text: LocalizedString(forKey: "File preview failed"))
            documentController.presentOptionsMenu(from: self.view.bounds, in: self.view, animated: true)
        }
    }
    
    func existDrive()->String{
        return self.driveUUID ?? AppUserService.currentUser?.userHome ?? ""
    }
    
    func existDir()->String{
        return self.directoryUUID ?? AppUserService.currentUser?.userHome ?? ""
    }
    
    func filesRemoveOptionRequest(models:[EntriesModel]){
        for model in models {
            filesRemoveOptionRequest(model: model)
        }
    }
    
    func filesRemoveOptionRequest(model:EntriesModel){
        let drive = self.driveUUID ?? AppUserService.currentUser?.userHome ?? ""
        let dir = self.directoryUUID ?? AppUserService.currentUser?.userHome ?? ""
        DirOprationAPI.init(driveUUID: drive, directoryUUID: dir).startFormDataRequestJSONCompletionHandler(multipartFormData: { (formData) in
            var dic = [kRequestOpKey: FilesOptionType.remove.rawValue]
            if let uuid = model.uuid,let hash = model.hash {
                dic = [kRequestOpKey: FilesOptionType.remove.rawValue,"uuid":uuid,"hash":hash]
            }
            do {
                let data = try JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions.prettyPrinted)
                let placeholder = LocalizedString(forKey: "未命名文件")
                let name = model.backupRoot ? model.bname ?? model.name ?? placeholder : model.name ?? placeholder
                formData.append(data, withName: name)
            }catch{
                Message.message(text: LocalizedString(forKey: ErrorLocalizedDescription.JsonModel.SwitchTODataFail))
            }
        }, { [weak self] (response) in
            if let errorMessage = ErrorTools.responseErrorData(response.data){
                Message.message(text: errorMessage)
                return
            }
            
            if let error = response.error{
                Message.message(text: error.localizedDescription)
                return
            }
            
            Message.message(text: LocalizedString(forKey: "文件/文件夹已删除"))
            self?.prepareData(animation: false)
            }, errorHandler: { (error) -> (Void) in
                Message.message(text: error.localizedDescription)
        })
    }
    
    @objc func refreshNotification(_ notifa:Notification){
        self.prepareData(animation: false)
    }
    
    @objc func enterSearch(){
        let searchVC = SearchFilesViewController.init(style: NavigationStyle.white)
        searchVC.modalPresentationStyle = .custom
        searchVC.modalTransitionStyle = .crossDissolve
        if self.selfState != .root{
          searchVC.uuid = directoryUUID
        }
        let tab = retrieveTabbarController()
        tab?.setTabBarHidden(true, animated: true)
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    private func prepareSearchBar() {
        self.view.addSubview(searchBar)
        if self.cellStyle == .list{
             listStyleButton.isSelected = true
        }else{
             listStyleButton.isSelected = false
        }
        let view = IconButton.init(image: Icon.search?.byTintColor(LightGrayColor))
        view.addTarget(self, action: #selector(enterSearch), for: UIControlEvents.touchUpInside)
        searchBar.leftViews = [view]
        searchBar.rightViews = [newCreatButton,listStyleButton,moreButton]
        searchBar.textField.delegate = self
    }
    
    func downloadRequestURL(model:EntriesModel) -> String?{
        guard let driveUUID = self.driveUUID else {
            return nil
        }
        
        guard let directoryUUID = self.directoryUUID else {
            return nil
        }
        
        guard let uuid = model.uuid else {
            return nil
        }
        
        
        let name = model.backupRoot ? model.bname ?? model.name ?? "" : model.name ?? ""
        
        switch AppNetworkService.networkState {
        case .normal?:
              let urlPath = "/drives/\(String(describing: driveUUID))/dirs/\(String(describing: directoryUUID))/entries/\(String(describing: uuid))"
              var params = ["name":name]
              if let hash = model.hash, model.bname != nil{
                    params = ["hash":hash]
              }
              let dataDic = [kRequestUrlPathKey:urlPath,kRequestVerbKey:RequestMethodValue.GET,"params":params] as [String : Any]
              guard let data = jsonToData(jsonDic: dataDic as NSDictionary) else {
                return nil
              }
              
              guard let dataString = String.init(data: data, encoding: .utf8) else {
                return nil
              }
              
              guard let urlString = String.init(describing:"\(kCloudBaseURL)\(kCloudCommonPipeUrl)?data=\(dataString)").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
                return nil
            }
            
            return urlString
        case .local?:
            guard let baseURL = RequestConfig.sharedInstance.baseURL else {
                return nil
            }
           
            var localUrl = "\(String(describing: baseURL))/drives/\(String(describing: driveUUID))/dirs/\(String(describing: directoryUUID))/entries/\(String(describing: uuid))?name=\(String(describing: name))"
            if let hash = model.hash, model.bname != nil{
                localUrl = "\(String(describing: baseURL))/drives/\(driveUUID)/dirs/\( directoryUUID)/entries/\(uuid)?hash=\(hash)"
            }
            return localUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        default:
            break
        }
        return nil
    }
    
    // ojbc function (Selector)
    @objc func moveBarButtonItemTap(_ sender:UIBarButtonItem){
        let drive = self.driveUUID ?? AppUserService.currentUser?.userHome ?? ""
        let dir = self.directoryUUID ?? AppUserService.currentUser?.userHome ?? ""
        let filesRootViewController = FilesRootViewController.init(style: NavigationStyle.white, srcDictionary: [kRequestTaskDriveKey : drive,kRequestTaskDirKey:dir], moveModelArray: FilesHelper.sharedInstance().selectFilesArray, isCopy: false)
        filesRootViewController.title = LocalizedString(forKey: "My Drive")
        self.registerNotification()
        let navi = UINavigationController.init(rootViewController: filesRootViewController)
        self.present(navi, animated: true, completion: nil)
    }
    
    @objc func downloadBarButtonItemTap(_ sender:UIBarButtonItem){
        FilesRootViewController.downloadManager.isStartDownloadImmediately = true
        let driveUUID = self.driveUUID != nil ? self.driveUUID! : AppUserService.currentUser?.userHome
        let directoryUUID = self.directoryUUID != nil ? self.directoryUUID! : AppUserService.currentUser?.userHome
        var urlStrings:Array<String> = Array.init()
        var nameStrings:Array<String> = Array.init()
        var fileModels:Array<EntriesModel> = Array.init()
        TRManager.logLevel = .high
        for value in  FilesHelper.sharedInstance().selectFilesArray!{
            let model = value
            if let  requestURL = self.downloadRequestURL(model: model){
                
            let placeholder = LocalizedString(forKey: "未命名文件")
            let name = model.backupRoot ? model.bname ?? model.name ?? placeholder : model.name ?? placeholder

            var paramKey = "name"
            var paramValue = name
            if let hash = model.hash,model.bname != nil{
                paramKey = "hash"
                paramValue = hash
            }
                let localUrl = "\(String(describing: RequestConfig.sharedInstance.baseURL!))/drives/\(String(describing: driveUUID!))/dirs/\(String(describing: directoryUUID!))/entries/\(String(describing: model.uuid!))?\(paramKey)=\(paramValue)"
                if AppNetworkService.networkState == .local{
                    urlStrings.append(localUrl)
                }else{
                    urlStrings.append(requestURL)
                }
            nameStrings.append(name)
            fileModels.append(model)
            }
        }
        if urlStrings.count > 0 {
            FilesRootViewController.downloadManager.multiDownload(urlStrings, fileNames: nameStrings, filesModels: fileModels)
        }
        self.isSelectModel = false
        Message.message(text: LocalizedString(forKey: "\(urlStrings.count)个文件已加入下载队列"), duration: 1.6)
    }
    
    @objc func moreBarButtonItemTap(_ sender:UIBarButtonItem){
        let filesBottomVC = FilesFilesBottomSheetContentTableViewController.init(style: UITableViewStyle.plain, type: FilesBottomSheetContentType.selectMore)
        filesBottomVC.delegate = self
        let bottomSheet = AppBottomSheetController.init(contentViewController: filesBottomVC)
        bottomSheet.trackingScrollView = filesBottomVC.tableView
        filesBottomVC.filesModelArray = FilesHelper.sharedInstance().selectFilesArray
        self.present(bottomSheet, animated: true, completion: {
        })
    }
    
    @objc func fabButtonDidTap(_ sender:MDCFloatingButton){
//        self.fabButton.collapse(true) { [weak self] in
            let fabBottomVC = FilesFABBottomSheetDisplayViewController()
            fabBottomVC.preferredContentSize = CGSize(width: __kWidth, height: 148.0)
            fabBottomVC.transitioningDelegate = self.transitionController
            fabBottomVC.delegate =  self
            let bottomSheet = AppBottomSheetController.init(contentViewController: fabBottomVC)
            bottomSheet.delegate = self
            self.present(bottomSheet, animated: true, completion: {})
//        }
    }
    
    @objc func listStyleButtonTap(_ sender:IconButton){
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            cellStyle = .list
        }else{
            cellStyle = .card
        }
        self.collcectionViewController?.cellStyle = cellStyle
        AppUserService.currentUser?.isListStyle = NSNumber.init(value:(cellStyle?.rawValue)!)
        AppUserService.synchronizedCurrentUser()
    }
    
    @objc func listStyleBarButtonItemTap(_ sender:UIBarButtonItem){
        if cellStyle == .list {
            cellStyle = .card
        }else{
            cellStyle = .list
        }
    }
    
    @objc func menuButtonTap(_ sender:IconButton){
        self.navigationDrawerController?.toggleLeftView()
    }
    
    @objc func moreButtonTap(_ sender:IconButton){
        let filesSearchMoreBottomVC = FilesSearchMoreBottomSheetContentTableViewController.init(style: UITableViewStyle.plain)
        filesSearchMoreBottomVC.delegate = self
        let bottomSheet = AppBottomSheetController.init(contentViewController: filesSearchMoreBottomVC)
        bottomSheet.trackingScrollView = filesSearchMoreBottomVC.tableView
        self.present(bottomSheet, animated: true, completion: {
        })
    }
    
    
    @objc func closeSelectModelButtonTap(_ sender:IconButton){
        isSelectModel = false
    }
    
    @objc func newFolderButtonTap(_ sender:UIBarButtonItem){
        let bundle = Bundle.init(for: NewFolderViewController.self)
        let storyboard = UIStoryboard.init(name: "NewFolderViewController", bundle: bundle)
        let identifier = "inputNewFolderDialogID"
        
        let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
        viewController.modalPresentationStyle = UIModalPresentationStyle.custom
        viewController.transitioningDelegate = self.transitionController
        
        let vc =  viewController as! NewFolderViewController
        vc.type = InputAlertType.creatNewFolder
        vc.titleString = LocalizedString(forKey:"New folder")
        vc.inputString =  LocalizedString(forKey: "Untitled folder")
        vc.inputPlaceholder =  LocalizedString(forKey: "Folder name")
        vc.confirmButtonName =  LocalizedString(forKey: "Create")
        vc.delegate = self
        self.present(viewController, animated: true, completion: {
            vc.inputTextField.becomeFirstResponder()
        })
        let presentationController =
            viewController.mdc_dialogPresentationController
        if presentationController != nil{
            presentationController?.dismissOnBackgroundTap = false
        }
    }
    
    @objc func movetoButtonTap(_ sender:UIButton){
        if self.moveModelArray?.count == 0 || self.moveModelArray == nil || self.srcDictionary == nil{return}
        let names:Array<String> = self.moveModelArray!.map{$0.name!}
        let drive =  self.driveUUID ?? AppUserService.currentUser?.userHome ?? ""
        let dir = self.directoryUUID ?? AppUserService.currentUser?.userHome ?? ""
        
        if drive ==  self.srcDictionary![kRequestTaskDriveKey]! &&  dir == self.srcDictionary![kRequestTaskDirKey]! && self.selfState != .share{
                Message.message(text: LocalizedString(forKey: "无法完成此操作"))
                return
        }
        let type = isCopy ? FilesTasksType.copy.rawValue : FilesTasksType.move.rawValue
        let copy = isCopy == true ? true : false
        let task = TasksAPI.init(type: type, names: names, srcDrive: self.srcDictionary![kRequestTaskDriveKey]!, srcDir: self.srcDictionary![kRequestTaskDirKey]!, dstDrive: drive, dstDir: dir)
        self.startActivityIndicator()
        task.startRequestJSONCompletionHandler { [weak self](response) in
            if response.error == nil{
                let messageDetail = self?.selfState == .share ? LocalizedString(forKey: "已分享到") : (self?.isCopy)! ? LocalizedString(forKey: "已复制到") : LocalizedString(forKey: "已移动到")
                let message = names.count > 0 ?  LocalizedString(forKey: "\(names.first!) \(messageDetail) \(self?.title ?? "files")") : LocalizedString(forKey: "\(names.count) 个文件 \(messageDetail) \(self?.title ?? "files")")
                
                guard let dic = ((response.value) as? NSDictionary)?.object(forKey: "data") as? NSDictionary ?? (response.value) as? NSDictionary else {
                    return
                }
                if let model = FilesTasksModel.deserialize(from: dic){
                   
                    self?.taskHandle(isCopy:copy,taskModel: model, callback: {[weak self](error) in
                        if let error = error{
                            self?.presentingViewController?.dismiss(animated: true, completion: {
                                Message.message(text:error.localizedDescription)
                            })
                            return
                        }
                        
                        defaultNotificationCenter().post(name: NSNotification.Name.Refresh.MoveRefreshNotiKey, object: nil)
                        self?.stopActivityIndicator()
                        self?.presentingViewController?.dismiss(animated: true, completion: {
                           Message.message(text: message)
                        })
                    })
                }
            }else{
                 Message.message(text: (response.error?.localizedDescription)!)
                self?.presentingViewController?.dismiss(animated: true, completion: {
                    
                })
            }
        }
    }
    
    @objc func cancelMovetoButtonTap(_ sender:UIButton){
        self.presentingViewController?.dismiss(animated: true) {
            
        }
    }
    
    //MARK : Lazy Property
    private var _collcectionViewController: FilesRootCollectionViewController? = nil
    var collcectionViewController: FilesRootCollectionViewController?{
        get{
            if self._collcectionViewController == nil {
                let layout = MDCCollectionViewFlowLayout()
                //        layout.itemSize = CGSize(width: size.width, height:CellHeight)
                _collcectionViewController = FilesRootCollectionViewController.init(collectionViewLayout: layout)
                _collcectionViewController?.collectionView?.isScrollEnabled = true
                _collcectionViewController?.collectionView?.emptyDataSetSource = self
                _collcectionViewController?.collectionView?.emptyDataSetDelegate = self
                _collcectionViewController?.delegate = self
                return _collcectionViewController
            }
            return  _collcectionViewController
        }
        
        set(newValue){
            self._collcectionViewController = newValue
        }
    }
    
    lazy var searchBar: BaseSearchBar = { [weak self] in

        let searchBar = BaseSearchBar.init(frame: CGRect(x: MarginsCloseWidth, y: kStatusBarHeight + MarginsCloseWidth, width: __kWidth - MarginsWidth, height: searchBarHeight))
        searchBar.delegate = self
        return searchBar
    }()
    
    lazy var selectNumberAppNaviLabel: UILabel = {
        let label = UILabel.init()
        label.frame = CGRect(x: 0, y: 0, width: 80, height: 20)
        label.textColor = UIColor.white
        label.font = TitleFont18.withBold()
        label.text =  "\(String(describing: (FilesHelper.sharedInstance().selectFilesArray?.count)!))"
        return label
    }()
    
    lazy var moveBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "files_move.png")?.withRenderingMode(.alwaysTemplate), style: UIBarButtonItemStyle.done, target: self, action: #selector(moveBarButtonItemTap(_ :)))
        return barButtonItem
    }()
    
    lazy var downloadBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "files_download.png")?.withRenderingMode(.alwaysTemplate), style: UIBarButtonItemStyle.done, target: self, action: #selector(downloadBarButtonItemTap(_ :)))
        return barButtonItem
    }()
    
    lazy var moreBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem.init(image: Icon.moreHorizontal?.byTintColor(.white), style: UIBarButtonItemStyle.done, target: self, action: #selector(moreBarButtonItemTap(_ :)))
        return barButtonItem
    }()

    lazy var moveFilesBottomBar: UIView = {
        let height:CGFloat = 56.0
        let view = UIView.init(frame: CGRect(x: 0, y: __kHeight - height, width: __kWidth, height: height))
        view.backgroundColor = UIColor.white
        view.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        view.layer.shadowRadius = 1
        view.layer.shadowOpacity = 0.5
        view.layer.shadowColor = DarkGrayColor.cgColor
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 2
        view.clipsToBounds = false
        return view
    }()
    
    lazy var listStyleButton: IconButton = {
        let button = IconButton(image:UIImage.init(named:"liststyle.png"))
        button.setImage(UIImage.init(named:"liststyle.png"), for: UIControlState.normal)
        button.setImage(UIImage.init(named:"gridstyle.png"), for: UIControlState.selected)
        button.addTarget(self, action: #selector(listStyleButtonTap(_ :)), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    lazy var moreButton: IconButton = {
        let button = IconButton(image: Icon.cm.moreHorizontal?.byTintColor(LightGrayColor))
        button.addTarget(self, action: #selector(moreButtonTap(_:)), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    lazy var newCreatButton: IconButton = {
        let button = IconButton(image: UIImage.init(named: "add_gray.png"))
        button.addTarget(self, action: #selector(fabButtonDidTap(_:)), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    lazy var movetoButton: MDCFlatButton = { [weak self] in
        let button = MDCFlatButton.init(frame: CGRect(x: self!.moveFilesBottomBar.width - moveButtonWidth - MarginsWidth, y: self!.moveFilesBottomBar.height/2 - moveButtonHeight/2, width: moveButtonWidth, height: moveButtonHeight))
        button.setTitle(LocalizedString(forKey: "Save Here"), for: UIControlState.normal)
        button.setTitleColor(COR1, for: UIControlState.normal)
        button.setTitleColor(LightGrayColor, for: UIControlState.disabled)
        button.addTarget(self, action: #selector(movetoButtonTap(_ :)), for: UIControlEvents.touchUpInside)
        button.sizeToFit()
        button.frame = CGRect(x: self!.moveFilesBottomBar.width - button.width - MarginsWidth, y: self!.moveFilesBottomBar.height/2 - button.height/2, width: button.width, height: button.height)
        return button
    }()
    
    lazy var cancelMovetoButton: MDCFlatButton = { [weak self] in
        let button = MDCFlatButton.init(frame: CGRect(x: self!.moveFilesBottomBar.width - movetoButton.left - MarginsCloseWidth, y: movetoButton.top, width: moveButtonWidth, height: moveButtonHeight))
        button.setTitle(LocalizedString(forKey: "Cancel"), for: UIControlState.normal)
        button.setTitleColor(COR1, for: UIControlState.normal)
        button.addTarget(self, action: #selector(cancelMovetoButtonTap(_ :)), for: UIControlEvents.touchUpInside)
        button.sizeToFit()
        button.frame = CGRect(x: self!.moveFilesBottomBar.width - ( MarginsCloseWidth + button.width*2 + MarginsWidth), y: self!.moveFilesBottomBar.height/2 - button.height/2, width: button.width, height: button.height)
        return button
    }()
    
    lazy var transitionController: MDCDialogTransitionController = {
        let controller = MDCDialogTransitionController.init()
        return controller
    }()
    
    lazy var moveButton: MDCFlatButton = {
        let button = MDCFlatButton.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        return button
    }()

    lazy var selectedNavigationBarView: MDCAppBar = {
        let appBar = MDCAppBar()
        self.addChildViewController(appBar.headerViewController)
        appBar.headerViewController.headerView.backgroundColor = COR1
        appBar.navigationBar.tintColor = UIColor.white
        appBar.navigationBar.titleAlignment = MDCNavigationBarTitleAlignment.leading
        appBar.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        return appBar
    }()
    
    lazy var styleItem: UIBarButtonItem = {
          let barItem = UIBarButtonItem.init(image: UIImage.init(named: "liststyle.png"), style: UIBarButtonItemStyle.done, target: self, action: #selector(listStyleBarButtonItemTap(_ :)))
        return barItem
    }()
}
