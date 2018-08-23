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
    case next
}

private let reusableIdentifierItem = "itemCellIdentifier"
private let cellFolderHeight:CGFloat = 48
private let cellWidth:CGFloat = (__kWidth - 4)/2
public let searchBarHeight:CGFloat = 137
internal let SearchBarBottom:CGFloat = 77.0
private let moveButtonWidth:CGFloat = 64.0
private let moveButtonHeight:CGFloat = 36.0

class FilesRootViewController: BaseViewController{
    override func willDealloc() -> Bool {
        return false
    }
    static let downloadManager =  TRManager.init("Downloads", MaximumRunning: LONG_MAX, isStoreInfo: true)
    private var menuButton: IconButton!
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
    var model:EntriesModel?
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
                if drive ==  self.srcDictionary![kRequestTaskDriveKey]! &&  dir == self.srcDictionary![kRequestTaskDirKey]!{
                   self.movetoButton.isEnabled = false
                }
                if  ((FilesHelper.sharedInstance().selectFilesArray?.contains(where: {$0.uuid == model?.uuid})!))!{
                    self.movetoButton.isEnabled = false
                }
            case .next?:
               break
            default:
                break
            }
            self.collcectionViewController.state = selfState
        }
    }
    
    deinit {
        print("\(className()) deinit")

        removeCollectionView()
//        FilesRootViewController.downloadManager.invalidate()
        defaultNotificationCenter().removeObserver(self, name: NSNotification.Name.Refresh.MoveRefreshNotiKey, object: nil)
    }
    
    override init(style: NavigationStyle) {
        super.init(style: style)
    }
    
    override init() {
        super.init()
        selfState = .root
    }
    
    init(driveUUID:String,directoryUUID:String,style: NavigationStyle) {
        super.init(style: style)
        selfState = .next
        self.directoryUUID = directoryUUID
        self.driveUUID = driveUUID
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = lightGrayBackgroudColor
        prepareData()
        prepareCollectionView()
        setCellStyle()
        switch selfState {
        case .root?:
            prepareRootAppNavigtionBar()
            prepareSearchBar()
            self.view.addSubview(fabButton)
        case .movecopy?:
            prepareMoveCopyAppNavigtionBar()
            setMoveToCollectionViewFrame()
            self.view.addSubview(moveFilesBottomBar)
            moveFilesBottomBar.addSubview(movetoButton)
            moveFilesBottomBar.addSubview(cancelMovetoButton)
        case .next?:
            preparenNextAppNavigtionBar()
            self.view.addSubview(fabButton)
        default:
            break
        }
        FilesRootViewController.downloadManager.isStartDownloadImmediately = false
        self.navigationTitle = title
        self.collcectionViewController.collectionView?.mj_header = MDCFreshHeader.init(refreshingBlock: { [weak self] in
           self?.prepareData()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
            self.collcectionViewController.collectionView?.reloadData()
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
    
    func popBackRefresh(){
        let fromViewController = self.navigationController?.transitionCoordinator?.viewController(forKey: UITransitionContextViewControllerKey.from)
        if fromViewController != nil{
            if !(self.navigationController?.viewControllers.contains(fromViewController!))! && self.presentedViewController == nil
            {//Something is being popped and we are being revealed
                self.prepareData()
            }
        }
    }
    
    func setCellStyle(){
        if AppUserService.currentUser?.isListStyle != nil {
            self.cellStyle = (AppUserService.currentUser?.isListStyle?.boolValue)! ? CellStyle.list : CellStyle.card
        }else{
                cellStyle = .card
        }
        self.collcectionViewController.cellStyle = cellStyle
        AppUserService.currentUser?.isListStyle = NSNumber.init(value:(cellStyle?.rawValue)!)
        AppUserService.synchronizedCurrentUser()
    }
    
    func setMoveToCollectionViewFrame(){
        collcectionViewController.view.frame =  CGRect.init(x: self.view.left, y:0, width: self.view.width, height: self.view.height - moveFilesBottomBar.height)
    }
    
    func setSelectModel(){
        isSelectModel = false
    }
    
    func listCellStyleAction(){
        self.listStyleButton.isSelected = true
        self.collcectionViewController.cellStyle = cellStyle
        AppUserService.currentUser?.isListStyle = NSNumber.init(value:(cellStyle?.rawValue)!)
        AppUserService.synchronizedCurrentUser()
        styleItem.image  = UIImage.init(named: "gridstyle.png")
    }
    
    func gridCellStyleAction(){
        self.listStyleButton.isSelected = false
        self.collcectionViewController.cellStyle = cellStyle
        AppUserService.currentUser?.isListStyle = NSNumber.init(value:(cellStyle?.rawValue)!)
        AppUserService.synchronizedCurrentUser()
        styleItem.image = UIImage.init(named: "liststyle.png")
    }
     
    func prepareData() {
        self.dataSource = Array.init()
        isRequesting = true
        ActivityIndicator.startActivityIndicatorAnimation()
        self.collcectionViewController.collectionView?.reloadEmptyDataSet()
        let queue = DispatchQueue.init(label: "com.backgroundQueue.api", qos: .background, attributes: .concurrent)
        let requestDriveUUID = self.driveUUID ?? AppUserService.currentUser?.userHome ?? ""
        let requestDirectoryUUID = self.directoryUUID ?? AppUserService.currentUser?.userHome ?? ""
        DriveDirAPI.init(driveUUID: requestDriveUUID, directoryUUID: requestDirectoryUUID).startRequestJSONCompletionHandler(queue) {[weak self] (response) in
            if response.error == nil{
                let isLocalRequest = AppNetworkService.networkState == .local
                let responseDic = isLocalRequest ? response.value as! NSDictionary: (response.value as! NSDictionary).object(forKey: "data") as! NSDictionary
                if responseDic.value(forKey: "code") != nil{
                    let code = responseDic["code"] as! NSNumber
                    let message = responseDic["message"] as! NSString
                    if code.intValue != 1 && code.intValue > 200 {
                        let error = BaseError.init(localizedDescription: message as String, code: Int(code.int64Value))
                        let messageText = error.localizedDescription
                        Message.message(text: messageText)
                        ActivityIndicator.stopActivityIndicatorAnimation()
                        self?.collcectionViewController.collectionView?.reloadData()
                        self?.collcectionViewController.collectionView?.reloadEmptyDataSet()
                        self?.isRequesting = false
                        return
                    }
                }
                   let data = jsonToData(jsonDic: responseDic)
                do{
                    let model = try JSONDecoder().decode(FilesModel.self, from: data!)
                    self?.originDataSource = model.entries
//                if let model = FilesModel.deserialize(from: responseDic){
                    var filesArray = Array<EntriesModel>.init()
                    var directoryArray = Array<EntriesModel>.init()
                    var finishArray = Array<Any>.init()
                    for (_,value) in (model.entries?.enumerated())!{
                        if value.type == FilesType.directory.rawValue{
                            filesArray.append(value)
                        }else if value.type == FilesType.file.rawValue{
                            directoryArray.append(value)
                        }
                    }
                    if filesArray.count != 0{
                        finishArray.append(filesArray)
                    }
                    
                    if directoryArray.count != 0{
                        finishArray.append(directoryArray)
                    }
                    DispatchQueue.main.async {
                        self?.dataSource = finishArray
                        self?.collcectionViewController.dataSource = self?.dataSource
                        let sortType = AppUserService.currentUser?.sortType == nil ? SortType(rawValue: 0) : SortType(rawValue: (AppUserService.currentUser?.sortType?.int64Value)!)
                        let sortIsDown = AppUserService.currentUser?.sortIsDown == nil ? true : AppUserService.currentUser?.sortIsDown?.boolValue
                        self?.setSortParameters(sortType: sortType!, sortIsDown: sortIsDown!)
                        self?.isRequesting = false
                        self?.collcectionViewController.collectionView?.reloadEmptyDataSet()
                    }
                }catch{
                    print(error.localizedDescription)
                }
//                }
                ActivityIndicator.stopActivityIndicatorAnimation()
            }else{
                mainThreadSafe {
                    var messageText = response.error?.localizedDescription
                    if response.error is BaseError{
                       messageText =  (response.error as! BaseError).localizedDescription
                    }
                    self?.isRequesting = false
                    Message.message(text: messageText!)
                    ActivityIndicator.stopActivityIndicatorAnimation()
                    self?.collcectionViewController.collectionView?.reloadData()
                    self?.collcectionViewController.collectionView?.reloadEmptyDataSet()
                }
            }
            if self?.collcectionViewController.collectionView?.mj_header != nil {
            self?.collcectionViewController.collectionView?.mj_header.endRefreshing()
            }
        }
    }
    
    func setSortParameters(sortType:SortType,sortIsDown:Bool){
        self.sortType = sortType
        self.sortIsDown = sortIsDown
        sortData(sortType: sortType, sortIsDown: sortIsDown)
        self.collcectionViewController.sortType = sortType
        self.collcectionViewController.sortIsDown = sortIsDown
        self.collcectionViewController.dataSource = dataSource
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
                folderArray?.sort { $0.size! < $1.size! }
                filesArray?.sort { $0.size! < $1.size! }
            }else{
                folderArray?.sort { $0.size! > $1.size! }
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
        Application.statusBarStyle = .lightContent
        fabButton.collapse(true) {

        }
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
        
        Application.statusBarStyle = .default
        collcectionViewController.isSelectModel = isSelectModel
        fabButton.expand(true) {
        }
        
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
        Application.statusBarStyle = .default
        self.appBar.headerViewController.headerView.isHidden = true
        self.navigationDrawerController?.isLeftPanGestureEnabled = true
        navigationController?.delegate = self
//        if (self.navigationDrawerController?.rootViewController) != nil {
            let tab = retrieveTabbarController()
            tab?.setTabBarHidden(false, animated: true)
//            let drawerController:FilesDrawerTableViewController = self.navigationDrawerController?.leftViewController as! FilesDrawerTableViewController
//            drawerController.delegate = self
//        }
        self.view.endEditing(true)
    }
    
    func selfStateOtherWillAppearAction(){
        self.appBar.headerViewController.headerView.isHidden = false
        self.view.bringSubview(toFront: self.appBar.headerViewController.headerView)
        Application.statusBarStyle = .default
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
        return self.directoryUUID ?? AppUserService.currentUser?.userHome ?? ""
    }
    
    func existDir()->String{
        return self.driveUUID ?? AppUserService.currentUser?.userHome ?? ""
    }
    
    func localNetStateFilesRemoveOptionRequest(name:String){
        let drive = self.driveUUID ?? AppUserService.currentUser?.userHome ?? ""
        let dir = self.directoryUUID ?? AppUserService.currentUser?.userHome ?? ""
        DirOprationAPI.init(driveUUID: drive, directoryUUID: dir, name: name, op: FilesOptionType.remove.rawValue).startFormDataRequestJSONCompletionHandler(multipartFormData: { (formData) in
            let dic = [kRequestOpKey: FilesOptionType.remove.rawValue]
            do {
                let data = try JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions.prettyPrinted)
//                mainThreadSafe {
//                DispatchQueue.main.async {
                    formData.append(data, withName: name)
//                }
            }catch{
                Message.message(text: LocalizedString(forKey: ErrorLocalizedDescription.JsonModel.SwitchTODataFail))
            }
        }, { [weak self] (response) in
            mainThreadSafe {
                if response.error == nil{
                    Message.message(text: LocalizedString(forKey: "Folder removed"))
                    self?.prepareData()
                }else{
                    if response.data != nil {
                        let errorDict =  dataToNSDictionary(data: response.data!)
                        if errorDict != nil{
                            Message.message(text: errorDict!["message"] != nil ? errorDict!["message"] as! String :  (response.error?.localizedDescription)!)
                        }else{
                            let backToString = String(data: response.data!, encoding: String.Encoding.utf8) as String?
                            Message.message(text: backToString ?? "error")
                        }
                    }else{
                        Message.message(text: (response.error?.localizedDescription)!)
                    }
                }
            }
        }, errorHandler: { (error) -> (Void) in
            Message.message(text: error.localizedDescription)
        })
    }
    
    func normalNetStateFilesRemoveOptionRequest(name:String){
        let drive = self.driveUUID ?? AppUserService.currentUser?.userHome ?? ""
        let dir = self.directoryUUID ?? AppUserService.currentUser?.userHome ?? ""
        DirOprationAPI.init(driveUUID: drive, directoryUUID: dir, name: name, op: FilesOptionType.remove.rawValue).startRequestJSONCompletionHandler { [weak self] (response) in
            if response.error == nil{
                Message.message(text: LocalizedString(forKey: "Folder removed"))
                 self?.prepareData()
            }else{
                if response.data != nil {
                    let errorDict =  dataToNSDictionary(data: response.data!)
                    if errorDict != nil{
                        Message.message(text: errorDict!["message"] != nil ? errorDict!["message"] as! String :  (response.error?.localizedDescription)!)
                    }else{
                        let backToString = String(data: response.data!, encoding: String.Encoding.utf8) as String?
                        Message.message(text: backToString ?? "error")
                    }
                }else{
                    Message.message(text: (response.error?.localizedDescription)!)
                }
            }
        }
    }
    
    @objc func refreshNotification(_ notifa:Notification){
      self.prepareData()
    }
    
    @objc func enterSearch(){
        let searchVC = SearchFilesViewController.init(style: NavigationStyle.whiteStyle)
        searchVC.modalPresentationStyle = .custom
        searchVC.modalTransitionStyle = .crossDissolve
        searchVC.uuid = directoryUUID
        let tab = retrieveTabbarController()
        tab?.setTabBarHidden(true, animated: true)
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    
    private func prepareSearchBar() {
        self.view.addSubview(searchBar)
//        let menuImage = UIImage.init(named:"menu.png")
//        menuButton = IconButton(image: menuImage)
//        menuButton.addTarget(self, action: #selector(menuButtonTap(_:)), for: UIControlEvents.touchUpInside)
      
        if self.cellStyle == .list{
             listStyleButton.isSelected = true
        }else{
             listStyleButton.isSelected = false
        }
        let view = IconButton.init(image: Icon.search?.byTintColor(LightGrayColor))
        searchBar.leftViews = [view]
        searchBar.rightViews = [listStyleButton,moreButton]
        searchBar.textField.delegate = self
    }
    
    func downloadRequestURL(model:EntriesModel) -> String{
        let resource = "/drives/\(String(describing: driveUUID!))/dirs/\(String(describing: directoryUUID!))/entries/\(String(describing: model.uuid!))"
        let localUrl = "\(String(describing: RequestConfig.sharedInstance.baseURL!))/drives/\(String(describing: driveUUID!))/dirs/\(String(describing: directoryUUID!))/entries/\(String(describing: model.uuid!))?name=\(String(describing: model.name!))"
        var requestURL = AppNetworkService.networkState == .normal ? "\(kCloudBaseURL)\(kCloudCommonPipeUrl)?resource=\(resource.toBase64())&method=\(RequestMethodValue.GET)&name=\(model.name!)" : localUrl
        requestURL = requestURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        return requestURL
    }
    
    // ojbc function (Selector)
    @objc func moveBarButtonItemTap(_ sender:UIBarButtonItem){
        let filesMoveToRootViewController = FilesMoveToRootViewController.init(style: NavigationStyle.whiteStyle)
        let drive = self.driveUUID ?? AppUserService.currentUser?.userHome ?? ""
        let dir = self.directoryUUID ?? AppUserService.currentUser?.userHome ?? ""
        filesMoveToRootViewController.srcDictionary = [kRequestTaskDriveKey : drive,kRequestTaskDirKey:dir]
        filesMoveToRootViewController.moveModelArray =  FilesHelper.sharedInstance().selectFilesArray
        self.registerNotification()
        let navi = UINavigationController.init(rootViewController: filesMoveToRootViewController)
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
            let resource = "/drives/\(String(describing: driveUUID!))/dirs/\(String(describing: directoryUUID!))/entries/\(String(describing: model.uuid!))"
            let localUrl = "\(String(describing: RequestConfig.sharedInstance.baseURL!))/drives/\(String(describing: driveUUID!))/dirs/\(String(describing: directoryUUID!))/entries/\(String(describing: model.uuid!))?name=\(String(describing: model.name!))"
            let requestURL = AppNetworkService.networkState == .normal ? "\(kCloudBaseURL)\(kCloudCommonPipeUrl)?resource=\(resource.toBase64())&method=\(RequestMethodValue.GET)&name=\(model.name!)" : localUrl
            urlStrings.append(requestURL)
            nameStrings.append(model.name!)
            fileModels.append(model)
        }
        if urlStrings.count > 0 {
            FilesRootViewController.downloadManager.multiDownload(urlStrings, fileNames: nameStrings, filesModels: fileModels)
        }
        self.isSelectModel = false
        Message.message(text: LocalizedString(forKey: "\(urlStrings.count)个文件已加入下载队列"), duration: 1.6)
    }
    
    @objc func moreBarButtonItemTap(_ sender:UIBarButtonItem){
        
    }
    
    @objc func fabButtonDidTap(_ sender:MDCFloatingButton){
        self.fabButton.collapse(true) { [weak self] in
            let fabBottomVC = FilesFABBottomSheetDisplayViewController()
            fabBottomVC.preferredContentSize = CGSize(width: __kWidth, height: 148.0)
            fabBottomVC.transitioningDelegate = self?.transitionController
            fabBottomVC.delegate =  self
            let bottomSheet = AppBottomSheetController.init(contentViewController: fabBottomVC)
            bottomSheet.delegate = self
            self?.present(bottomSheet, animated: true, completion: {
            
            })
        }
    }
    
    @objc func listStyleButtonTap(_ sender:IconButton){
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            cellStyle = .list
        }else{
            cellStyle = .card
        }
        self.collcectionViewController.cellStyle = cellStyle
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
        
    }
    
    @objc func movetoButtonTap(_ sender:UIButton){
        if self.moveModelArray?.count == 0 || self.moveModelArray == nil || self.srcDictionary == nil{return}
        let names:Array<String> = self.moveModelArray!.map{$0.name!}
        let drive = self.driveUUID ?? AppUserService.currentUser?.userHome ?? ""
        let dir = self.directoryUUID ?? AppUserService.currentUser?.userHome ?? ""
        if drive ==  self.srcDictionary![kRequestTaskDriveKey]! &&  dir == self.srcDictionary![kRequestTaskDirKey]!{
            Message.message(text: LocalizedString(forKey: "无法完成此操作"))
            return
        }
        let task = TasksAPI.init(type: FilesTasksType.move.rawValue, names: names, srcDrive: self.srcDictionary![kRequestTaskDriveKey]!, srcDir: self.srcDictionary![kRequestTaskDirKey]!, dstDrive: drive, dstDir: dir)
        task.startRequestJSONCompletionHandler { (response) in
            if response.error == nil{
                self.dismiss(animated: true, completion: {
                    let message = names.count > 0 ?  LocalizedString(forKey: "\(names.first!) moved to \(self.title ?? "files")") : LocalizedString(forKey: "\(names.count) files moved to \(self.title ?? "files")")
                     Message.message(text: message)
                     defaultNotificationCenter().post(name: NSNotification.Name.Refresh.MoveRefreshNotiKey, object: nil)
                })
            }else{
                if response.data != nil {
                    let errorDict =  dataToNSDictionary(data: response.data!)
                    if errorDict != nil{
                        Message.message(text: errorDict!["message"] != nil ? errorDict!["message"] as! String :  (response.error?.localizedDescription)!)
                    }else{
                        Message.message(text: (response.error?.localizedDescription)!)
                    }
                }else{
                     Message.message(text: (response.error?.localizedDescription)!)
                }
            }
        }
    }
    
    @objc func cancelMovetoButtonTap(_ sender:UIButton){
        self.dismiss(animated: true) {
            
        }
    }
    
    //MARK : Lazy Property
    
    lazy var collcectionViewController : FilesRootCollectionViewController = {
        let layout = MDCCollectionViewFlowLayout()
        //        layout.itemSize = CGSize(width: size.width, height:CellHeight)
        let collectVC = FilesRootCollectionViewController.init(collectionViewLayout: layout)
        collectVC.collectionView?.isScrollEnabled = true
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

    lazy var fabButton: MDCFloatingButton = {
        let plusImage = #imageLiteral(resourceName: "Plus")
        let buttonWidth:CGFloat = 56
        let defaultFloatingButton = MDCFloatingButton.init(frame: CGRect.init(x: __kWidth - 30 - buttonWidth, y: __kHeight - TabBarHeight - 16 - buttonWidth, width: buttonWidth, height: buttonWidth))
        
        let plusImage36 = UIImage(named: "plus_white_36", in: Bundle(for: type(of: self)),
                                  compatibleWith: traitCollection)
        
//        defaultFloatingButton.sizeToFit()
//        defaultFloatingButton.translatesAutoresizingMaskIntoConstraints = false
        defaultFloatingButton.setImage(plusImage, for: .normal)
        let mdcColorScheme = MDCButtonScheme.init()
        MDCButtonColorThemer.apply(appDelegate.colorScheme, to: defaultFloatingButton)
        defaultFloatingButton.addTarget(self, action: #selector(fabButtonDidTap(_ :)), for: UIControlEvents.touchUpInside)
        return defaultFloatingButton
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
    
    lazy var movetoButton: MDCFlatButton = {
        let button = MDCFlatButton.init(frame: CGRect(x: self.moveFilesBottomBar.width - moveButtonWidth - MarginsWidth, y: self.moveFilesBottomBar.height/2 - moveButtonHeight/2, width: moveButtonWidth, height: moveButtonHeight))
        button.setTitle(LocalizedString(forKey: "Save Here"), for: UIControlState.normal)
        button.setTitleColor(COR1, for: UIControlState.normal)
        button.setTitleColor(LightGrayColor, for: UIControlState.disabled)
        button.addTarget(self, action: #selector(movetoButtonTap(_ :)), for: UIControlEvents.touchUpInside)
        button.sizeToFit()
        button.frame = CGRect(x: self.moveFilesBottomBar.width - button.width - MarginsWidth, y: self.moveFilesBottomBar.height/2 - button.height/2, width: button.width, height: button.height)
        return button
    }()
    
    lazy var cancelMovetoButton: MDCFlatButton = {
        let button = MDCFlatButton.init(frame: CGRect(x: self.moveFilesBottomBar.width - movetoButton.left - MarginsCloseWidth, y: movetoButton.top, width: moveButtonWidth, height: moveButtonHeight))
        button.setTitle(LocalizedString(forKey: "Cancel"), for: UIControlState.normal)
        button.setTitleColor(COR1, for: UIControlState.normal)
        button.addTarget(self, action: #selector(cancelMovetoButtonTap(_ :)), for: UIControlEvents.touchUpInside)
        button.sizeToFit()
        button.frame = CGRect(x: self.moveFilesBottomBar.width - ( MarginsCloseWidth + button.width*2 + MarginsWidth), y: self.moveFilesBottomBar.height/2 - button.height/2, width: button.width, height: button.height)
        return button
    }()
    
//    lazy var fabBottomVC: FilesFABBottomSheetDisplayViewController = {
//        let fabBottom = FilesFABBottomSheetDisplayViewController()
//        fabBottom.preferredContentSize = CGSize(width: __kWidth, height: 148.0)
//        fabBottom.transitioningDelegate = self.transitionController
//        fabBottom.delegate =  self
//        return fabBottom
//    }()
    
//    lazy var sequenceBottomVC: FilesSequenceBottomSheetContentTableViewController = {
//        let bottomVC = FilesSequenceBottomSheetContentTableViewController()
//        bottomVC.delegate = self
//        return bottomVC
//    }()
    
    
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

//    lazy var documentController: UIDocumentInteractionController = {
//        let doucumentController = UIDocumentInteractionController.init()
//        doucumentController.delegate = self
//        return doucumentController
//    }()
}

