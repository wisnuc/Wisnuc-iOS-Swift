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

private let reuseIdentifier = "Cell"
private let reuseListIdentifier = "CellLsit"
private let reuseIdentifierSection2 = "Celled"
private let reuseListIdentifierSection2 = "CelledList"
private let reuseIdentifierHeader = "HeaderView"
private let reuseIdentifierFooter = "FooterView"
private let CellWidth:CGFloat = CGFloat((__kWidth - 4)/2)
private let CellSmallHeight:CGFloat = 48.0

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
    func sequenceButtonTap(_ sender:UIButton)
    func cellButtonCallBack(_ cell:MDCCollectionViewCell, _ button:UIButton, _ indexPath:IndexPath)
}

class FilesRootCollectionViewController: MDCCollectionViewController {
    weak var delegate:FilesRootCollectionViewControllerDelegate?
    var reusableView:UICollectionReusableView!
    var sortType:SortType?
    var sortIsDown:Bool?
    var state:RootControllerState?
    var dataSource:Array<Any>?{
        didSet{
           self.collectionView?.reloadData()
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

    func isSelectModelAction(){
        self.collectionView?.reloadData()
    }
    
    func normalModelAction(){
        FilesHelper.sharedInstance().removeAllSelectFiles()
        self.collectionView?.reloadData()
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
        let model  = sectionArray[indexPath.item]
        if cellStyle == .card{
//            if indexPath.section == 0 {
                if  model.type == FilesType.directory.rawValue{
                collectionView.register(FilesFolderCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
                if let cell = cell as? FilesFolderCollectionViewCell {
                    cell.moreButton.isEnabled = isSelectModel! ? false : true
                    cell.moreButton.isHidden = self.state == .movecopy ? true : false
                    cell.titleLabel.text = model.name
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
                        if (FilesHelper.sharedInstance().selectFilesArray?.contains(model))!{
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
                    cell.titleLabel.text = model.name
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
                    if (self.isSelectModel)! == NSNumber.init(value: FilesStatus.select.rawValue).boolValue {
                       cell.isSelect = (FilesHelper.sharedInstance().selectFilesArray?.contains(model))! ? true : false
            
                    }
                    
                    if !isNilString(model.name){
                        let exestr = (model.name! as NSString).pathExtension
                        let detailImageName = FileTools.switchFilesFormatType(type: FilesType(rawValue: model.type!), format: FilesFormatType(rawValue: exestr.lowercased()))
                        cell.leftImageView.image = UIImage.init(named: detailImageName)
                        let normalImageName = FileTools.switchFilesFormatTypeNormalImage(type: FilesType(rawValue: model.type!), format: FilesFormatType(rawValue: exestr.lowercased()))
                        cell.mainImageView.image = UIImage.init(named: normalImageName)
                    }
                }
                return cell
            }
        }else{
            collectionView.register(FilesListCollectionViewCell.self, forCellWithReuseIdentifier: reuseListIdentifier)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseListIdentifier, for: indexPath)
            if let cell = cell as? FilesListCollectionViewCell {
                cell.moreButton.isEnabled = isSelectModel! ? false : true
                cell.moreButton.isHidden = self.state == .movecopy ? true : false
                cell.titleLabel.text = model.name
                let time = model.mtime != nil ? timeString(TimeInterval(model.mtime!/1000)) : LocalizedString(forKey: "No time")
                let size = model.size != nil ? sizeString(Int64(model.size!)) : ""
                cell.detailLabel.text = "\(time) \(size)"
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
                if (self.isSelectModel)! == NSNumber.init(value: FilesStatus.select.rawValue).boolValue {
                    cell.isSelect = (FilesHelper.sharedInstance().selectFilesArray?.contains(model))! ? true : false
                }
                
                if !isNilString(model.name){
                    let exestr = (model.name! as NSString).pathExtension
                    
                    let imageName = FileTools.switchFilesFormatType(type: FilesType(rawValue: model.type ?? FilesType.file.rawValue), format: FilesFormatType(rawValue: exestr.lowercased()))

                    cell.leftImageView.image = UIImage.init(named: imageName)
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
            return CGSize(width: __kWidth, height: CellSmallHeight)
    }
  
    override func collectionView(_ collectionView: UICollectionView, shouldHideFooterSeparatorForSection section: Int) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: __kWidth, height: 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == UICollectionElementKindSectionHeader) {
            let header:CommonCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifierHeader, for: indexPath) as! CommonCollectionReusableView
            reusableView = header
            let reusableHeaderView:CommonCollectionReusableView = (reusableView as? CommonCollectionReusableView)!
            let sectionArray:Array<EntriesModel> = dataSource![indexPath.section] as! Array
            let model  = sectionArray[indexPath.row]
            if indexPath.section == 0 {
                var titleText = LocalizedString(forKey: "Folders")
                if model.type == FilesType.file.rawValue {
                    titleText = LocalizedString(forKey: "Files")
                }
                reusableHeaderView.titleLabel.text = titleText
                var imageName = "files_down.png"
                var buttonTitleText = "NAME"
                switch sortType?.rawValue {
                case 0: buttonTitleText = "NAME"
                case 1: buttonTitleText = "Modified time"
                case 2: buttonTitleText = "Created time"
                case 3: buttonTitleText = "Capacity time"
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
            }else{
                reusableHeaderView.titleLabel.text = LocalizedString(forKey: "Files")
                reusableHeaderView.rightButton.isHidden = true
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
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let delegateOK = delegate {
            delegateOK.scrollViewDidEndDecelerating(scrollView)
        }
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
        let model  = sectionArray[indexPath.item]
        var exitSelectModel = false
          if (self.isSelectModel)! == NSNumber.init(value: FilesStatus.select.rawValue).boolValue {
            if (FilesHelper.sharedInstance().selectFilesArray?.contains(model))!{
                FilesHelper.sharedInstance().removeSelectFiles(model: model)
                if FilesHelper.sharedInstance().selectFilesArray?.count == 0{
                    exitSelectModel = true
                }
             }else{
                FilesHelper.sharedInstance().addSelectFiles(model: model)
            }
             self.collectionView?.reloadData()
          }
        if let delegateOK = self.delegate{
            if !exitSelectModel{
             delegateOK.rootCollectionView(collectionView, didSelectItemAt: indexPath, isSelectModel: self.isSelectModel!)
            }
        }
    }
}

class CommonCollectionReusableView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(titleLabel)
        self.addSubview(rightButton)
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.init(x: MarginsWidth, y: 0, width: __kWidth/2, height: self.height))
        label.textColor = LightGrayColor
        label.font = SmallTitleFont
        return label
    }()
    

    lazy var rightButton: SortButton = {
        let text = LocalizedString(forKey: "NAME")
        let labelwidth = labelWidthFrom(title: text, font: SmallTitleFont)
        let image = UIImage.init(named: "files_up.png")
        let buttonWidth = labelwidth + (image?.size.width)! + MarginsWidth - 4 + MarginsCloseWidth
        let button = SortButton.init(frame: CGRect(x: self.width - MarginsWidth - buttonWidth, y: self.height/2 - MarginsWidth/2, width: buttonWidth, height: MarginsWidth + 4))
        return button
    }()
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        let mdcColorScheme = MDCButtonScheme.init()
        MDCTextButtonThemer.applyScheme(mdcColorScheme, to: self)
        self.inkColor = COR1.withAlphaComponent(0.3)
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
