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
private let cellHeight:CGFloat = 137
private let SearchBarBottom:CGFloat = 77.0
private let moveButtonWidth:CGFloat = 64.0
private let moveButtonHeight:CGFloat = 36.0

class FilesRootViewController: BaseViewController{
    private var menuButton: IconButton!
    var  dataSource:Array<Any>?
    var  driveUUID:String?
    var  directoryUUID:String?
    var sortType:SortType?
    var isListStyle:Bool?
    var sortIsDown:Bool?
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
            case .movecopy?:break
            case .next?: break
            default:
                break
            }
        }
    }
    
    deinit {
       print("deinit called")
       removeCollectionView()
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
        default:
            break
        }
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationDrawerController?.isLeftPanGestureEnabled = false
        self.view.endEditing(true)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
   
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
    }
    
    func gridCellStyleAction(){
        self.listStyleButton.isSelected = false
        self.collcectionViewController.cellStyle = cellStyle
        AppUserService.currentUser?.isListStyle = NSNumber.init(value:(cellStyle?.rawValue)!)
        AppUserService.synchronizedCurrentUser()
    }
    
    func prepareData() {
        ActivityIndicator.startActivityIndicatorAnimation()
        let queue = DispatchQueue.init(label: "com.backgroundQueue.api", qos: .background, attributes: .concurrent)
        DriveDirAPI.init(driveUUID: driveUUID!, directoryUUID: directoryUUID!).startRequestJSONCompletionHandler(queue) {[weak self] (response) in
            if response.error == nil{
                let isLocalRequest = AppNetworkService.networkState == .local
                let responseDic = isLocalRequest ? response.value as! NSDictionary: (response.value as! NSDictionary).object(forKey: "data") as! NSDictionary
                if let model = FilesModel.deserialize(from: responseDic){
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
//                    filesArray.sort(by: { (model1, model2) -> Bool in
//                        model1.name! < model2.name!
//                    })
//                    directoryArray.sort(by: { (model1, model2) -> Bool in
//                        model1.name! < model2.name!
//                    })
                    
                    if filesArray.count != 0{
                        finishArray.append(filesArray)
                    }
                    
                    if directoryArray.count != 0{
                        finishArray.append(directoryArray)
                    }
                    DispatchQueue.main.async {
                        if finishArray.count > 0{
                            self?.dataSource = finishArray
                            self?.collcectionViewController.dataSource = self?.dataSource
                            let sortType = AppUserService.currentUser?.sortType == nil ? SortType(rawValue: 0) : SortType(rawValue: (AppUserService.currentUser?.sortType?.int64Value)!)
                            let sortIsDown = AppUserService.currentUser?.sortIsDown == nil ? true : AppUserService.currentUser?.sortIsDown?.boolValue
                            self?.setSortParameters(sortType: sortType!, sortIsDown: sortIsDown!)
                        }
                    }
                }
                ActivityIndicator.stopActivityIndicatorAnimation()
            }else{
                Message.message(text: (response.error?.localizedDescription)!)
                ActivityIndicator.stopActivityIndicatorAnimation()
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
        
        selectNumberAppNaviLabel.text = "\(String(describing: (FilesHelper.sharedInstance().selectFilesArray?.count)!))"
        Application.statusBarStyle = .lightContent
        fabButton.collapse(true) {

        }
        let tab = self.navigationDrawerController?.rootViewController as! WSTabBarController
        tab.setTabBarHidden(true, animated: true)
    }
    
    func selectModelCloseAction(){
        self.appBar.headerViewController.headerView.isHidden = false
//        if searchBar.bottom <= 0{
            DispatchQueue.main.async {
                self.unselectSearchBarAction()
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.searchBar.top = 20 + MarginsCloseWidth
            })
    
        collcectionViewController.isSelectModel = isSelectModel
        Application.statusBarStyle = .default
        fabButton.expand(true) {

        }
        let tab = self.navigationDrawerController?.rootViewController as! WSTabBarController
        tab.setTabBarHidden(false, animated: true)
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
        if (self.navigationDrawerController?.rootViewController) != nil {
            let tab = self.navigationDrawerController?.rootViewController as! WSTabBarController
            tab.setTabBarHidden(false, animated: true)
        }
        self.view.endEditing(true)
    }
    
    func selfStateOtherWillAppearAction(){
        self.appBar.headerViewController.headerView.isHidden = false
        self.view.bringSubview(toFront: self.appBar.headerViewController.headerView)
        Application.statusBarStyle = .default
        if (self.navigationDrawerController?.rootViewController) != nil {
            let tab = self.navigationDrawerController?.rootViewController as! WSTabBarController
            tab.setTabBarHidden(true, animated: true)
        }
    }
    
    func prepareRootAppNavigtionBar(){
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
        self.title = ""
        let leftItem = UIBarButtonItem.init(image: Icon.close?.byTintColor(.white), style: UIBarButtonItemStyle.done, target: self, action: #selector(closeSelectModelButtonTap(_ :)))
        let paceItem = UIBarButtonItem.init(customView: UIView.init(frame: CGRect(x: 0, y: 0, width: 32, height: 20)))
        let labelBarButtonItem = UIBarButtonItem.init(customView: selectNumberAppNaviLabel)
        self.navigationItem.leftBarButtonItems = [leftItem,paceItem,labelBarButtonItem]
        self.navigationItem.rightBarButtonItems = [moreBarButtonItem,downloadBarButtonItem,moveBarButtonItem]
    }
    
    func prepareMoveCopyAppNavigtionBar(){
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
        let rightItem = UIBarButtonItem.init(image: UIImage.init(named: "files_new_folder_gray.png"), style: UIBarButtonItemStyle.done, target: self, action: #selector(newFolderButtonTap(_ :)))
        self.navigationItem.rightBarButtonItem = rightItem
        appBar.navigationBar.title = LocalizedString(forKey: "Move to...")
    }
    
    func preparenNextAppNavigtionBar(){
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
        let moreItem = UIBarButtonItem.init(image: UIImage.init(named: "more_gray_horizontal.png"), style: UIBarButtonItemStyle.done, target: self, action: #selector(moreButtonTap(_ :)))
//        let button = IconButton(image:UIImage.init(named:"liststyle.png"))
//        button.setImage(UIImage.init(named:"liststyle.png"), for: UIControlState.normal)
//        button.setImage(UIImage.init(named:"gridstyle.png"), for: UIControlState.selected)
//        button.addTarget(self, action: #selector(listStyleButtonTap(_ :)), for: UIControlEvents.touchUpInside)
        let styleItem = UIBarButtonItem.init(image: UIImage.init(named: "liststyle.png"), style: UIBarButtonItemStyle.done, target: self, action: #selector(moreButtonTap(_ :)))
        self.navigationItem.rightBarButtonItems = [moreItem,styleItem]
    }
    
    
    private func prepareSearchBar() {
        self.view.addSubview(searchBar)
        let menuImage = UIImage.init(named:"menu.png")
        menuButton = IconButton(image: menuImage)
        menuButton.addTarget(self, action: #selector(menuButtonTap(_:)), for: UIControlEvents.touchUpInside)
      
        if self.cellStyle == .list{
             listStyleButton.isSelected = true
        }else{
             listStyleButton.isSelected = false
        }
        searchBar.leftViews = [menuButton]
        searchBar.rightViews = [listStyleButton,moreButton]
        searchBar.textField.delegate = self
    }
    
    // ojbc function (Selector)
    @objc func moveBarButtonItemTap(_ sender:UIBarButtonItem){
        let filesRootViewController = FilesRootViewController.init(style: NavigationStyle.whiteStyle)
        filesRootViewController.selfState = .movecopy
        self.navigationController?.pushViewController(filesRootViewController, animated: true)
    }
    
    @objc func downloadBarButtonItemTap(_ sender:UIBarButtonItem){
        
    }
    
    @objc func moreBarButtonItemTap(_ sender:UIBarButtonItem){
        
    }
    
    @objc func fabButtonDidTap(_ sender:MDCFloatingButton){
        self.fabButton.collapse(true) {
            let bottomSheet = AppBottomSheetController.init(contentViewController: self.fabBottomVC)
            bottomSheet.delegate = self
            self.present(bottomSheet, animated: true, completion: {
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
    
    @objc func menuButtonTap(_ sender:IconButton){
        navigationDrawerController?.toggleLeftView()
        let drawerController:DrawerViewController = navigationDrawerController?.leftViewController as! DrawerViewController
        drawerController.filsDrawerVC.delegate = self
    }
    
    @objc func moreButtonTap(_ sender:IconButton){
        let bottomSheet = AppBottomSheetController.init(contentViewController: self.filesSearchMoreBottomVC)
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
        
    }
    
    @objc func cancelMovetoButtonTap(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK : Lazy Property
    
    lazy var collcectionViewController : FilesRootCollectionViewController = {
        let layout = MDCCollectionViewFlowLayout()
        //        layout.itemSize = CGSize(width: size.width, height:CellHeight)
        let collectVC = FilesRootCollectionViewController.init(collectionViewLayout: layout)
        collectVC.collectionView?.isScrollEnabled = true
        collectVC.delegate = self
        return collectVC
    }()
    
    lazy var searchBar: BaseSearchBar = {
        let searchBar = BaseSearchBar.init(frame: CGRect(x: MarginsCloseWidth, y: 20 + MarginsCloseWidth, width: __kWidth - MarginsWidth, height: cellHeight))
        searchBar.delegate = self
        return searchBar
    }()
    
    lazy var selectNumberAppNaviLabel: UILabel = {
        let label = UILabel.init()
        label.frame = CGRect(x: 0, y: 0, width: 50, height: 20)
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
        button.setTitle(LocalizedString(forKey: "Move"), for: UIControlState.normal)
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
    
    lazy var fabBottomVC: FilesFABBottomSheetDisplayViewController = {
        let fabBottom = FilesFABBottomSheetDisplayViewController()
        fabBottom.preferredContentSize = CGSize(width: __kWidth, height: 148.0)
        fabBottom.delegate = self
        return fabBottom
    }()
    
    lazy var sequenceBottomVC: FilesSequenceBottomSheetContentTableViewController = {
        let bottomVC = FilesSequenceBottomSheetContentTableViewController()
        bottomVC.delegate = self
        return bottomVC
    }()
    
    lazy var filesBottomVC: FilesFilesBottomSheetContentTableViewController = {
        let bottomVC = FilesFilesBottomSheetContentTableViewController.init(style: UITableViewStyle.plain)
        bottomVC.delegate = self
        return bottomVC
    }()
    
    lazy var filesSearchMoreBottomVC: FilesSearchMoreBottomSheetContentTableViewController = {
        let bottomVC = FilesSearchMoreBottomSheetContentTableViewController.init(style: UITableViewStyle.plain)
        bottomVC.delegate = self
        return bottomVC
    }()

}

extension FilesRootViewController:FilesRootCollectionViewControllerDelegate{
    func rootCollectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath, isSelectModel: Bool) {
        if isSelectModel == NSNumber.init(value: FilesStatus.select.rawValue).boolValue{
            selectNumberAppNaviLabel.text = "\(String(describing: (FilesHelper.sharedInstance().selectFilesArray?.count)!))"
        }else{
            let sectionArray:Array<EntriesModel> = dataSource![indexPath.section] as! Array
            let model  = sectionArray[indexPath.item]
            if model.type == FilesType.directory.rawValue{
                let nextViewController = FilesRootViewController.init(driveUUID: (AppUserService.currentUser?.userHome!)!, directoryUUID: model.uuid!,style:.whiteStyle)
                let tab = self.navigationDrawerController?.rootViewController as! WSTabBarController
                tab.setTabBarHidden(true, animated: true)
                nextViewController.title = model.name ?? ""
                self.navigationController?.pushViewController(nextViewController, animated: true)
            }
        }
    }
    
    func cellButtonCallBack(_ cell: MDCCollectionViewCell, _ button: UIButton, _ indexPath: IndexPath) {
        let bottomSheet = AppBottomSheetController.init(contentViewController: self.filesBottomVC)
        bottomSheet.trackingScrollView = filesBottomVC.tableView
        self.present(bottomSheet, animated: true, completion: {
        })
    }
    
    func sequenceButtonTap(_ sender: UIButton) {
        let bottomSheet = AppBottomSheetController.init(contentViewController: self.sequenceBottomVC)
        self.present(bottomSheet, animated: true, completion: {
        })
    }
    
    func collectionView(_ collectionViewController: MDCCollectionViewController, isSelectModel: Bool) {
        self.isSelectModel = isSelectModel
    }
    
    func collectionViewData(_ collectionViewController: MDCCollectionViewController) -> Array<Any> {
        return dataSource!
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(scrollView.contentOffset.y)
        if isSelectModel == nil || !isSelectModel!{
//            if scrollView.contentOffset.y > -(SearchBarBottom + MarginsCloseWidth/2) {
//            }else{
//            }
            let translatedPoint = scrollView.panGestureRecognizer.translation(in: scrollView)
            if translatedPoint.y < 0 {
//                if searchBar.bottom > 0{
                self.searchBar.origin.y = -(scrollView.contentOffset.y)-(SearchBarBottom + MarginsCloseWidth/2)+20
//            }else{
//                self.searchBar.origin.y = -(scrollView.contentOffset.y)
//            }
        }
            
            if(translatedPoint.y > 0){
//                print("mimimi")
                UIView.animate(withDuration: 0.3) {
                    self.searchBar.origin.y = 20 + MarginsCloseWidth
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let headerView = self.appBar.headerViewController.headerView
        if scrollView == headerView.trackingScrollView {
            headerView.trackingScrollDidEndDraggingWillDecelerate(decelerate)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let headerView = self.appBar.headerViewController.headerView
        if scrollView == headerView.trackingScrollView {
            headerView.trackingScrollWillEndDragging(withVelocity: velocity, targetContentOffset: targetContentOffset)
        }
    }
    
    
}

extension FilesRootViewController:SearchBarDelegate{
    func searchBar(searchBar: SearchBar, didClear textField: UITextField, with text: String?) {
        
    }
    
    func searchBar(searchBar: SearchBar, willClear textField: UITextField, with text: String?) {
        
    }
    
    func searchBar(searchBar: SearchBar, didChange textField: UITextField, with text: String?) {
        
    }
    
}

extension FilesRootViewController:FilesDrawerViewControllerDelegate{
    func settingButtonTap(_ sender: UIButton) {
        navigationDrawerController?.closeLeftView()
        let settingVC = SettingViewController.init(style: NavigationStyle.whiteStyle)
        let tab = self.navigationDrawerController?.rootViewController as! WSTabBarController
        tab.setTabBarHidden(true, animated: true)
        self.navigationController?.pushViewController(settingVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationDrawerController?.closeLeftView()
        switch indexPath.row {
        case 0:
            let transferTaskTableViewController = TransferTaskTableViewController.init(style:.whiteStyle)
            let tab = self.navigationDrawerController?.rootViewController as! WSTabBarController
            tab.setTabBarHidden(true, animated: true)
            self.navigationController?.pushViewController(transferTaskTableViewController, animated: true)
        case 1:
            let shareVC = FileShareFolderViewController.init(style:.whiteStyle)
            let tab = self.navigationDrawerController?.rootViewController as! WSTabBarController
            tab.setTabBarHidden(true, animated: true)
            self.navigationController?.pushViewController(shareVC, animated: true)
        case 2:
            let offlineVC = FilesOfflineViewController.init(style:.whiteStyle)
            let tab = self.navigationDrawerController?.rootViewController as! WSTabBarController
            tab.setTabBarHidden(true, animated: true)
            self.navigationController?.pushViewController(offlineVC, animated: true)
        case 3:
            break
        default:
            break
        }
    }
}

extension FilesRootViewController:MDCBottomSheetControllerDelegate{
    func bottomSheetControllerDidDismissBottomSheet(_ controller: MDCBottomSheetController) {
        self.fabButton.expand(true, completion: {
        })
    }
}

extension FilesRootViewController:FABBottomSheetDisplayVCDelegte{
    func cllButtonTap(_ sender: UIButton) {
        self.fabBottomVC.dismiss(animated: true) {
            self.fabButton.expand(true, completion: {
            })
        }
    }
    
    func folderButtonTap(_ sender: UIButton) {
        self.fabBottomVC.dismiss(animated: true) {
            self.fabButton.expand(true, completion: {
            })
        }
    }
    
    func uploadButtonTap(_ sender: UIButton) {
        self.fabBottomVC.dismiss(animated: true) {
            self.fabButton.expand(true, completion: {
            })
        }
    }
}

extension FilesRootViewController:SequenceBottomSheetContentVCDelegate{
    func sequenceBottomtableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, isDown: Bool) {
        self.setSortParameters(sortType:SortType(rawValue: Int64(indexPath.row))!, sortIsDown: isDown)
    }
}


extension FilesRootViewController:SearchMoreBottomSheetVCDelegate{
    func searchMoreBottomSheettableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         filesSearchMoreBottomVC.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension FilesRootViewController:FilesBottomSheetContentVCDelegate{
    func filesBottomSheetContentInfoButtonTap(_ sender: UIButton) {
        filesBottomVC.presentingViewController?.dismiss(animated: true, completion:{
            let tab = self.navigationDrawerController?.rootViewController as! WSTabBarController
            tab.setTabBarHidden(true, animated: true)
            let filesInfoVC = FilesFileInfoTableViewController.init(style: NavigationStyle.imageryStyle)
            self.navigationController?.pushViewController(filesInfoVC, animated: true)
        })
    }
    
    func filesBottomSheetContentTableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        filesBottomVC.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension FilesRootViewController:UINavigationControllerDelegate{
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = SearchTransition()
        if operation == .push {
            if toVC.isKind(of: SearchFilesViewController.self){
                return transition
            }else{
                return nil
            }
        }else{
            if fromVC.isKind(of: SearchFilesViewController.self){
                return transition
            }else{
                return nil
            }
        }
    }
}

extension FilesRootViewController:TextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let searchVC = SearchFilesViewController.init(style: NavigationStyle.whiteStyle)
        searchVC.modalPresentationStyle = .custom
        searchVC.modalTransitionStyle = .crossDissolve
        let tab = self.navigationDrawerController?.rootViewController as! WSTabBarController
        tab.setTabBarHidden(true, animated: true)
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
}
