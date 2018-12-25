//
//  FilesRootCollectionViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/7.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialCollections
import MaterialComponents.MaterialCollectionCells
import MaterialComponents.MDCCollectionViewController
import MaterialComponents.MDCCollectionViewCell
import RxSwift

private let reuseIdentifier = "Cell"
private let reuseListIdentifier = "CellLsit"
private let reuseIdentifierSection2 = "Celled"
private let reuseListIdentifierSection2 = "CelledList"
private let reuseIdentifierHeader = "HeaderView"
private let reuseIdentifierFooter = "FooterView"
private let CellWidth:CGFloat = CGFloat((__kWidth - 4)/2)
private let CellSmallHeight:CGFloat = 48.0
private let HeaderSectionHeight:CGFloat = CellSmallHeight + 80 + 8

enum FilesStatus:Int{
    case normal = 0
    case select = 1
}

enum SortType:Int64{
    case name = 0
    case modifiedTime
    case createdTime
    case size
}

@objc protocol FilesRootCollectionViewControllerDelegate{
    func collectionViewData(_ collectionViewController: MDCCollectionViewController) -> Array<Any>
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    
    func collectionView(_ collectionViewController: MDCCollectionViewController , isSelectModel:Bool)
    func rootCollectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath ,isSelectModel:Bool)
    func sequenceButtonTap(_ sender:UIButton?)
    func cellButtonCallBack(_ cell:MDCCollectionViewCell, _ button:UIButton, _ indexPath:IndexPath)
    
    func shareBoxTap()
    func backupBoxTap()
    func usbDeviceTap()
    func transferTaskTap()
}

class FilesRootCollectionViewController: MDCCollectionViewController {
//    override func willDealloc() -> Bool {
//        return false
//    }
    weak var delegate:FilesRootCollectionViewControllerDelegate?
    var reusableView:UICollectionReusableView!
    var sortType:SortType?
    var sortIsDown:Bool?
    var state:RootControllerState?
    var showIndicator:Bool = true
    private let keyPath:String = "sliderState"
    var dispose = DisposeBag()
    var isAnimation = false
    var isDecelerating = false
    var driveUUID:String?
    var dirUUID:String?
    
    var dataSource:Array<Any>?{
        didSet{
//           self.collectionView?.reloadData()
        }
    }
    
    var isSelectModel:Bool?{
        didSet{
            if isSelectModel!{
                isSelectModelAction()
            }else{
                normalModelAction()
            }
        }
    }
    var cellStyle:CellStyle?{
        didSet{
            switch cellStyle {
            case .card?:
                self.styler.cellLayoutType = MDCCollectionViewCellLayoutType.grid
                self.styler.cellStyle = MDCCollectionViewCellStyle.default
                self.styler.gridPadding = 4
                self.styler.gridColumnCount = 2
        
            case .list?:
                self.styler.cellLayoutType = MDCCollectionViewCellLayoutType.list
                self.styler.cellStyle = MDCCollectionViewCellStyle.default
                self.styler.separatorColor = Gray12Color
                self.styler.separatorInset = UIEdgeInsets.init(top: 0, left: MarginsWidth + 24 + MarginsWidth*2, bottom: 0, right: 0)
                self.styler.gridColumnCount = 0
            default:
                break
            }
            
//            self.collectionView?.performBatchUpdates({
////               self.collectionView?.alpha = 0
//            }, completion: { (finished) in
//                if finished {
//                 self.collectionView?.alpha = 1
                  self.collectionView?.reloadData()
//                }
//            })
        }
    }
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
     
    }
    
    deinit {
        print("deinit called")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         dataSource = Array.init()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes

        self.view.backgroundColor = lightGrayBackgroudColor

        self.collectionView?.backgroundColor = lightGrayBackgroudColor
        self.collectionView?.register(CommonCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: reuseIdentifierHeader)
    
        self.collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: reuseIdentifierFooter)

        // Do any additional setup after loading the view.
    
        self.styler.beginCellAppearanceAnimation()
        
//        let longPressGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressAction(_ :)))
        
//        longPressGesture.minimumPressDuration = 0.3
//        longPressGesture.delaysTouchesBegan = true
//        collectionView?.addGestureRecognizer(longPressGesture)
        isSelectModel = Bool(truncating: (FilesStatus.normal).rawValue as NSNumber)
        self.collectionView?.allowsMultipleSelection = true
        self.collectionView?.allowsSelection = true
        
//       self.collectionView?.mj_header.beginRefreshing()
//        ViewTools.automaticallyAdjustsScrollView(scrollView: self.collectionView!, viewController: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        defaultNotificationCenter().removeObserver(self, name: NSNotification.Name.Cell.SelectNotiKey, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        defaultNotificationCenter().addObserver(forName: NSNotification.Name.Cell.SelectNotiKey, object: self, queue: OperationQueue.main) { [weak self] (sender) in
//
//        }
        defaultNotificationCenter().addObserver(self, selector: #selector(cellNotification(_ :)), name: NSNotification.Name.Cell.SelectNotiKey, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getMatchVC(model:EntriesModel,array:Array<EntriesModel>,indexPath:IndexPath) -> UIViewController?{
        let arr = array
        if let index = arr.firstIndex(where: {$0.hash == model.hash}) {
            return self.getBigImageVC(data: arr, index:index, indexPath: indexPath)
        }else{
           return nil
        }
    }
    
    func getBigImageVC(data:Array<EntriesModel>,index:Int,indexPath:IndexPath) -> UIViewController{
        let vc = WSShowBigimgViewController.init()
        vc.delegate = self
        vc.models = data
        vc.drive = self.driveUUID
        vc.dir = self.dirUUID
        vc.selectIndex = index
        if let cell = self.collectionView?.cellForItem(at: indexPath) as? FilesFileCollectionViewCell{
             vc.senderViewForAnimation = cell
             vc.scaleImage = cell.image
        }else if let cell = self.collectionView?.cellForItem(at: indexPath) as? FilesListCollectionViewCell{
            vc.senderViewForAnimation = cell
        }
        return vc
    }
    
    @objc func sequenceButtonTap(_ sender: UIButton){
        if let delegateOK = self.delegate {
            delegateOK.sequenceButtonTap(sender)
        }
    }
    
    @objc func cellNotification(_ sender:Notification){
        let number:NSNumber = sender.object as! NSNumber
        isSelectModel = number.boolValue
        if let delegateOK = delegate{
            delegateOK.collectionView(self, isSelectModel: isSelectModel!)
        }
    }
    
    func metadataType(metadata:Metadata?)->FilesFormatType?{
       if let type = metadata?.type{
        return FilesFormatType(rawValue:type)
       }
       return nil
    }

    func isSelectModelAction(){
        self.collectionView?.reloadData()
    }
    
    func normalModelAction(){
        FilesHelper.sharedInstance().removeAllSelectFiles()
        self.collectionView?.reloadData()
    }

    func indictorObserve(){
        isDecelerating = true
        if self.showIndicator {
            if self.collectionView?.indicator == nil {
                //导航按钮
                self.collectionView?.registerILSIndicator()
                if self.collectionView?.indicator == nil{
                    return
                }
                //
                self.collectionView?.indicator.slider.timeLabel.isHidden = true
                self.collectionView?.indicator.slider.rx.observe(String.self, keyPath)
                    .subscribe(onNext: { [weak self] (newValue) in
                        if (self?.showIndicator)! {
                            if (self?.collectionView?.indicator.slider.sliderState == UIControlState.normal && (self?.collectionView?.indicator.transform)!.isIdentity) {
                                self?.isDecelerating = false
                                DispatchQueue.global(qos: .default).asyncAfter(deadline: DispatchTime.now() + 1.5) {
                                    if let isDecelerating = self?.isDecelerating{
                                        if isDecelerating {
                                            self?.isAnimation = false
                                            DispatchQueue.main.async {
                                                UIView.animate(withDuration: 0.5, animations: {
                                                    self?.collectionView?.indicator.transform = CGAffineTransform(translationX: 40, y: 0)
                                                }, completion: { (finished) in
                                                    self?.isAnimation = false
                                                    self?.isDecelerating = false
                                                })
                                            }
                                        }
                                    }
                                }
                            }else{
                                self?.isDecelerating = true
                            }
                        }
                    })
                    .disposed(by: dispose)
            }else {
                if (!isAnimation) {
                    self.collectionView?.indicator.transform = CGAffineTransform.identity
                }else{
                    DispatchQueue.global(qos: .default).asyncAfter(deadline: DispatchTime.now() + 0.3) {
                        DispatchQueue.main.async {
                            self.collectionView?.indicator.transform = CGAffineTransform.identity
                        }
                    }
                }
            }
        }
    }
    
    func hiddenIndicator(){
        if self.showIndicator {
            if self.collectionView?.indicator == nil {
                //导航按钮
                self.collectionView?.registerILSIndicator()
                if self.collectionView?.indicator == nil{
                    return
                }
            }
            if (self.collectionView?.indicator.slider.sliderState == UIControlState.normal)  {
                if let isIdentity = self.collectionView?.indicator.transform.isIdentity{
                    if isIdentity{
                        isDecelerating = false
                        DispatchQueue.global(qos: .default).asyncAfter(deadline: DispatchTime.now() + 1) {
                            if !self.isDecelerating{
                                self.isAnimation = false
                                DispatchQueue.main.async {
                                    UIView.animate(withDuration: 0.5, animations: {
                                        self.collectionView?.indicator.transform = CGAffineTransform(translationX: 40, y: 0)
                                    }, completion: { (finished) in
                                        self.isAnimation = false
                                        self.isDecelerating = false
                                    })
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return dataSource!.count
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        let sectionArray:Array<Any> = dataSource![section] as! Array
        return sectionArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionArray:Array<EntriesModel> = dataSource![indexPath.section] as! Array
        var model  = sectionArray[indexPath.item]
        model.indexPath = indexPath
        if cellStyle == .card{
//            if indexPath.section == 0 {
                if  model.type == FilesType.directory.rawValue{
                collectionView.register(FilesFolderCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
                if let cell = cell as? FilesFolderCollectionViewCell {
                    cell.moreButton.isEnabled = isSelectModel! ? false : true
                    cell.moreButton.isHidden = self.state == .movecopy ? true : false
                    cell.titleLabel.text = model.backupRoot ? model.bname ??  model.name ?? "" : model.name
                    cell.cellCallBack = { [weak self] (callbackCell,callbackButton) in
                        if let delegateOK = self?.delegate{
                            delegateOK.cellButtonCallBack(callbackCell, callbackButton,indexPath)
                        }
                    }
                   
                    cell.longPressCallBack = { [weak self](callbackCell) in
                        if self?.state != .movecopy {
                            if (self?.isSelectModel)! == NSNumber.init(value: FilesStatus.normal.rawValue).boolValue {
                                FilesHelper.sharedInstance().addSelectFiles(model: model)
                            }
                        }
                    }
                  
                    cell.isSelectModel = isSelectModel
                    if (self.isSelectModel)! == NSNumber.init(value: FilesStatus.select.rawValue).boolValue {
                        let name = model.backupRoot ? model.bname ??  model.name ?? "" : model.name ?? ""
                        if (FilesHelper.sharedInstance().selectFilesArray?.contains(where:{$0.uuid == model.uuid}))! && (FilesHelper.sharedInstance().selectFilesArray?.contains(where:{$0.name == name}))!{
                            cell.isSelect = true
                        }else{
                            cell.isSelect = false
                        }
                    }
                }
                return cell
            }else{
                collectionView.register(FilesFileCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifierSection2)
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierSection2, for: indexPath)
                if let cell = cell as? FilesFileCollectionViewCell {
                    cell.moreButton.isEnabled = isSelectModel! ? false : true
                    cell.moreButton.isHidden = self.state == .movecopy ? true : false
                    cell.titleLabel.text = model.backupRoot ? model.bname ??  model.name ?? "" : model.name
                    cell.cellCallBack = { [weak self] (callbackCell,callbackButton) in
                        if let delegateOK = self?.delegate{
                            delegateOK.cellButtonCallBack(callbackCell, callbackButton,indexPath)
                        }
                    }
                    
                    if self.state == .movecopy {
                        cell.alpha = 0.5
                        cell.moreButton.isHidden = true
                        cell.isUserInteractionEnabled = false
                    }else{
                        cell.alpha = 1
                        cell.moreButton.isHidden = false
                        cell.isUserInteractionEnabled = true
                    }
                    
                    cell.longPressCallBack = { [weak self] (callbackCell) in
                        if self?.state != .movecopy {
                            if (self?.isSelectModel)! == NSNumber.init(value: FilesStatus.normal.rawValue).boolValue {
                                FilesHelper.sharedInstance().addSelectFiles(model: model)
                            }
                        }
                    }
                    
                    cell.isSelectModel = isSelectModel
                    let name = model.backupRoot ? model.bname ?? model.name ?? "" : model.name ?? ""
                    if (self.isSelectModel)! == NSNumber.init(value: FilesStatus.select.rawValue).boolValue {
                       cell.isSelect = (FilesHelper.sharedInstance().selectFilesArray?.contains(where:{$0.uuid == model.uuid}))! && (FilesHelper.sharedInstance().selectFilesArray?.contains(where:{$0.name == name}))! ? true : false
            
                    }
             
                    cell.setImage(collectionView:collectionView,indexPath: indexPath, type: self.metadataType(metadata: model.metadata),hash:model.hash)
//                    if !isNilString(model.name){
//                        let exestr = (model.name! as NSString).pathExtension
//                     
                }
                return cell
            }
        }else{
            collectionView.register(FilesListCollectionViewCell.self, forCellWithReuseIdentifier: reuseListIdentifier)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseListIdentifier, for: indexPath)
            if let cell = cell as? FilesListCollectionViewCell {
                cell.moreButton.isEnabled = isSelectModel! ? false : true
                cell.moreButton.isHidden = self.state == .movecopy ? true : false
                cell.titleLabel.text = model.backupRoot ? model.bname ??  model.name ?? "" : model.name
                let time = model.mtime != nil ? TimeTools.timeString(TimeInterval(model.mtime!/1000),formatterString:"yyyy.MM.dd") : LocalizedString(forKey: "No time")
                let size = model.size != nil ? sizeString(Int64(model.size!)) : ""
                if let  mtime = time{
                    cell.detailLabel.text = "\(String(describing: mtime)) \(size)"
                }
                cell.cellCallBack = { [weak self] (callbackCell,callbackButton) in
                    if let delegateOK = self?.delegate{
                        delegateOK.cellButtonCallBack(callbackCell, callbackButton,indexPath)
                    }
                }
                
                cell.longPressCallBack = { [weak self](callbackCell) in
                    if self?.state != .movecopy {
                        if (self?.isSelectModel)! == NSNumber.init(value: FilesStatus.normal.rawValue).boolValue {
                            FilesHelper.sharedInstance().addSelectFiles(model: model)
                        }
                    }
                }
                
                cell.isSelectModel = self.isSelectModel
                let name = model.backupRoot ? model.bname ?? model.name ?? "" : model.name ?? ""
                if (self.isSelectModel)! == NSNumber.init(value: FilesStatus.select.rawValue).boolValue {
                    cell.isSelect = (FilesHelper.sharedInstance().selectFilesArray?.contains(where:{$0.uuid == model.uuid}))! && (FilesHelper.sharedInstance().selectFilesArray?.contains(where:{$0.name == name}))! ? true : false
                }
                if model.backupRoot {
                    if !isNilString(model.bname){
                        let imageName = FileTools.switchFilesFormatType(type: FilesType(rawValue: model.type ?? FilesType.file.rawValue), format: self.metadataType(metadata: model.metadata))
                        
                        cell.leftImageView.image = UIImage.init(named: imageName)
                    }else{
                        if !isNilString(model.name){
                          
                            let imageName = FileTools.switchFilesFormatType(type: FilesType(rawValue: model.type ?? FilesType.file.rawValue), format: self.metadataType(metadata: model.metadata))
                            
                            cell.leftImageView.image = UIImage.init(named: imageName)
                        }
                    }
                }else{
                    if !isNilString(model.name){
    
                        let imageName = FileTools.switchFilesFormatType(type: FilesType(rawValue: model.type ?? FilesType.file.rawValue), format: self.metadataType(metadata: model.metadata))
                        
                        cell.leftImageView.image = UIImage.init(named: imageName)
                    }
                }
                if  model.type == FilesType.file.rawValue{
                    if self.state == .movecopy {
                        cell.alpha = 0.5
                        cell.isUserInteractionEnabled = false
                    }else{
                        cell.alpha = 1.0
                        cell.isUserInteractionEnabled = true
                    }
                   
                }else{
                    cell.alpha = 1.0
                    cell.isUserInteractionEnabled = true
                }
            }
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0{
            if self.state == .root{
                return CGSize(width: __kWidth, height: HeaderSectionHeight)
            }else{
                return CGSize(width: __kWidth, height: CellSmallHeight)
            }
        }else{
             return CGSize(width: __kWidth, height: CellSmallHeight)
        }
        
    }
  
    override func collectionView(_ collectionView: UICollectionView, shouldHideFooterSeparatorForSection section: Int) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: __kWidth, height: 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if (elementKind == UICollectionElementKindSectionHeader) {
            let reusableHeaderView:CommonCollectionReusableView = (view as? CommonCollectionReusableView)!
            if indexPath.section == 0 {
                if self.state != .root{
                    reusableHeaderView.state = .normal
                }else{
                    reusableHeaderView.state = .convenientHeader
                }
            }else{
                reusableHeaderView.state = .normal
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == UICollectionElementKindSectionHeader) {
            let header:CommonCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifierHeader, for: indexPath) as! CommonCollectionReusableView
            reusableView = header
            let reusableHeaderView:CommonCollectionReusableView = (reusableView as? CommonCollectionReusableView)!
            let sectionArray:Array<EntriesModel> = dataSource![indexPath.section] as? Array ?? Array.init()
            
            var model:EntriesModel?
            if sectionArray.count>0{
                model  = sectionArray[indexPath.row]
            }
            
            if indexPath.section == 0 {
                header.shareBoxCallback = { () in
                    self.delegate?.shareBoxTap()
                }
                header.backupBoxCallback = { () in
                    self.delegate?.backupBoxTap()
                }
                header.usbDeviceCallback = { () in
                    self.delegate?.usbDeviceTap()
                }
                header.transferTaskCallback = { () in
                    self.delegate?.transferTaskTap()
                }
                var titleText = LocalizedString(forKey: "Folders")
                if model?.type == FilesType.file.rawValue {
                    titleText = LocalizedString(forKey: "Files")
                }
                
                reusableHeaderView.titleLabel.text = titleText
              
                
                var imageName = "files_down.png"
                var buttonTitleText = "NAME"
                switch sortType?.rawValue {
                case 0: buttonTitleText = "NAME"
                case 1: buttonTitleText = "Modified time"
                case 2: buttonTitleText = "Created time"
                case 3: buttonTitleText = "Capacity"
                default:
                    break
                }
                if sortIsDown != nil && !sortIsDown!{
                    imageName = "files_up.png"
                }
                let image = UIImage.init(named: imageName)
                reusableHeaderView.rightButton.leftImageView.image = image
                reusableHeaderView.rightButton.titleTextLabel.text = LocalizedString(forKey: buttonTitleText)
                reusableHeaderView.rightButton.titleTextLabel.sizeToFit()
                let labelWidth = reusableHeaderView.rightButton.titleTextLabel.width
                let size =  CGSize(width: labelWidth + (image?.size.width)! + MarginsWidth - 4 + MarginsCloseWidth, height: reusableHeaderView.rightButton.height)
                let frame = CGRect(origin: CGPoint(x: reusableHeaderView.width - MarginsWidth - size.width, y: reusableHeaderView.rightButton.origin.y), size: size)
                reusableHeaderView.rightButton.frame = frame
                reusableHeaderView.rightButton.isHidden = false
                reusableHeaderView.convenientEntranceView.isHidden = false
            }else{
                reusableHeaderView.titleLabel.text = LocalizedString(forKey: "文件")
                reusableHeaderView.rightButton.isHidden = true
                reusableHeaderView.convenientEntranceView.isHidden = true
            }
                reusableHeaderView.rightButton.addTarget(self, action: #selector(sequenceButtonTap(_ :)), for: UIControlEvents.touchUpInside)
        }else
   
        if (kind == UICollectionElementKindSectionFooter)
        {
            let footerview = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifierFooter, for: indexPath)
            footerview.backgroundColor = UIColor.purple
            reusableView = footerview
        }
        
        reusableView.backgroundColor = UIColor.clear
        return reusableView
        
       }
    
    //    extension FilesRootCollectionViewController:UIScrollViewDelegate{
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let delegateOK = delegate {
            delegateOK.scrollViewDidScroll(scrollView)
        }
        indictorObserve()
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let delegateOK = delegate {
            delegateOK.scrollViewDidEndDecelerating(scrollView)
        }
        hiddenIndicator()
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let delegateOK = delegate {
            delegateOK.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
        }
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let delegateOK = delegate {
            delegateOK.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if cellStyle == .card{
            let sectionArray:Array<EntriesModel> = dataSource![indexPath.section] as! Array
            let model  = sectionArray[indexPath.item]
            return model.type == FilesType.file.rawValue ? CGSize(width: CellWidth, height: CellWidth) : CGSize(width: CellWidth, height: CellSmallHeight)
        }else{
            return CGSize(width: __kWidth, height: 64.0)
        }
    }
    
    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        let sectionArray:Array<EntriesModel> = dataSource![indexPath.section] as! Array
        var model  = sectionArray[indexPath.item]
        var exitSelectModel = false
          if (self.isSelectModel)! == NSNumber.init(value: FilesStatus.select.rawValue).boolValue {
            let name = model.backupRoot ? model.bname ?? model.name ?? "" : model.name ?? ""
            if (FilesHelper.sharedInstance().selectFilesArray?.contains(where:{$0.uuid == model.uuid}))! && (FilesHelper.sharedInstance().selectFilesArray?.contains(where:{$0.name == name}))!{
                FilesHelper.sharedInstance().removeSelectFiles(model: model)
                if FilesHelper.sharedInstance().selectFilesArray?.count == 0{
                    exitSelectModel = true
                }
             }else{
                FilesHelper.sharedInstance().addSelectFiles(model: model)
            }
             self.collectionView?.reloadData()
          }else{
            if let metadata = metadataType(metadata: model.metadata){
                if kMediaTypes.contains(metadata.rawValue) {
                    let array = sectionArray.map { (model) -> EntriesModel in
                        var result = model
                        let modelIndexPath = IndexPath(item: sectionArray.firstIndex(where: {$0.hash == model.hash}) ?? 0, section: indexPath.section)
                        result.indexPath = modelIndexPath
                        return result
                    }
                    
                    let resultArray = array.filter { (model) -> Bool in
                        if let type = model.metadata?.type{
                        return kMediaTypes.contains(where: {$0.caseInsensitiveCompare(type) == .orderedSame})
                         
                        }
                        return false
                    }
                    //                for (i,value) in sectionArray.enumerated(){
                    //                    let modelIndexPath = IndexPath(item: i, section: indexPath.section)
                    //                    value.indexPath = modelIndexPath
                    //                }
                    model.indexPath = IndexPath(row: indexPath.row, section: indexPath.section)
                    let vc = self.getMatchVC(model: model,array: resultArray,indexPath:indexPath)
                    
                    if let presentVC = vc{
                        self.present(presentVC, animated: true) {
                        }
                    }
                    return
                }
            }
        }
       
        if let delegateOK = self.delegate{
            if !exitSelectModel{
             delegateOK.rootCollectionView(collectionView, didSelectItemAt: indexPath, isSelectModel: self.isSelectModel!)
            }
        }
    }
}

extension FilesRootCollectionViewController:WSShowBigImgViewControllerDelegate{
    func photoBrowser(browser: WSShowBigimgViewController, indexPath: IndexPath) {
        self.collectionView?.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredVertically, animated: false)
        self.collectionView?.layoutIfNeeded()
    }
    
    func photoBrowser(browser: WSShowBigimgViewController, willDismiss indexPath: IndexPath) -> UIView? {
        let cell = self.collectionView?.cellForItem(at: indexPath)
        return cell
    }
    
    
}

enum CommonCollectionReusableViewState {
    case convenientHeader
    case normal
}

class CommonCollectionReusableView: UICollectionReusableView {
    var shareBoxCallback:(()->())?
    var backupBoxCallback:(()->())?
    var usbDeviceCallback:(()->())?
    var transferTaskCallback:(()->())?
    var state:CommonCollectionReusableViewState?{
        didSet{
            switch state {
            case .convenientHeader?:
                convenientHeaderStateAction()
            case .normal?:
                normalStateAction()
            default: break
                
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        convenientEntranceView.viewDelegate = self
        self.addSubview(titleLabel)
        self.addSubview(rightButton)
    }
    

    override func layoutSubviews() {
        super.layoutSubviews()
       
    }
    
    deinit {
        print("dismiss")
    }
    
    func convenientHeaderStateAction(){
        self.addSubview(convenientEntranceView)
        self.titleLabel.center = CGPoint(x: self.titleLabel.center.x, y: (HeaderSectionHeight - CellSmallHeight) + CellSmallHeight/2)
        self.rightButton.center = CGPoint(x: self.rightButton.center.x, y: self.titleLabel.center.y)
    }
    
    func normalStateAction(){
        convenientEntranceView.removeFromSuperview()
        self.titleLabel.center = CGPoint(x: self.titleLabel.center.x, y: CellSmallHeight/2)
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.init(x: MarginsWidth, y: 0, width: __kWidth/2, height: CellSmallHeight))
        label.textColor = LightGrayColor
        label.font = SmallTitleFont
        return label
    }()

    lazy var rightButton: SortButton = { [weak self] in
        let text = LocalizedString(forKey: "NAME")
        let labelwidth = labelWidthFrom(title: text, font: SmallTitleFont)
        let image = UIImage.init(named: "files_up.png")
        let buttonWidth = labelwidth + (image?.size.width)! + MarginsWidth - 4 + MarginsCloseWidth
        let button = SortButton.init(frame: CGRect(x: self?.width ?? __kWidth - MarginsWidth - buttonWidth, y: (self?.height)!/2 - MarginsWidth/2, width: buttonWidth, height: MarginsWidth + 4))
        button.backgroundColor = .clear
        return button
    }()
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var convenientEntranceView: FilesConvenientEntranceView = FilesConvenientEntranceView.init(frame: CGRect(x: 0, y: 4, width: __kWidth, height: 80))
}

extension CommonCollectionReusableView:FilesConvenientEntranceViewDelegate{
    func shareBoxTap() {
        if shareBoxCallback != nil{
            self.shareBoxCallback!()
        }
    }
    
    func backupBoxTap() {
        if backupBoxCallback != nil{
            self.backupBoxCallback!()
        }
    }
    
    func usbDeviceTap() {
        if usbDeviceCallback != nil{
            self.usbDeviceCallback!()
        }
    }
    
    func transferTaskTap() {
        if transferTaskCallback != nil{
            self.transferTaskCallback!()
        }
    }
}

class SortButton: MDBaseButton{
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(leftImageView)
        let image = UIImage.init(named: "files_up.png")
        leftImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(MarginsCloseWidth/2)
            make.centerY.equalTo(self.snp.centerY)
            make.size.equalTo(CGSize(width: (image?.size.width)!, height: (image?.size.height)!))
        }
        
        self.addSubview(titleTextLabel)
        titleTextLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.leftImageView.snp.right).offset(MarginsWidth-4)
            make.centerY.equalTo(self.snp.centerY)
            make.right.equalTo(self.snp.right).offset(MarginsCloseWidth/2)
        }
        self.inkColor = COR1.withAlphaComponent(0.3)
    }
    
    deinit {
        print("dismiss")
    }
    
    lazy var leftImageView: UIImageView = {
        let imageView = UIImageView.init()
        return imageView
    }()
    
    lazy var titleTextLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = COR1
        label.font = SmallTitleFont
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
