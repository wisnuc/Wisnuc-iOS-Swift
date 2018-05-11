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

@objc protocol FilesRootCollectionViewControllerDelegate{
    func collectionViewData(_ collectionViewController: MDCCollectionViewController) -> Array<Any>
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    
    func collectionView(_ collectionViewController: MDCCollectionViewController , isSelectModel:Bool)
}

class FilesRootCollectionViewController: MDCCollectionViewController {
    var delegate:FilesRootCollectionViewControllerDelegate?
    var dataSource:Array<Any>?{
        didSet{
           self.collectionView?.reloadData()
        }
    }
    var isSelectModel:Bool?{
        didSet{
            if isSelectModel!{
            
            }else{
                
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
            
            self.collectionView?.performBatchUpdates({

            }, completion: { (finished) in
                if finished {
                  self.collectionView?.reloadData()
                }
            })
        }
    }
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        dataSource = Array.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes

        self.view.backgroundColor = lightGrayBackgroudColor
        self.collectionView?.backgroundColor = lightGrayBackgroudColor
        self.collectionView?.register(CommonCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: reuseIdentifierHeader)
    
        self.collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: reuseIdentifierFooter)

        // Do any additional setup after loading the view.
    
        self.styler.beginCellAppearanceAnimation()
        
        let longPressGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressAction(_ :)))
        
//        longPressGesture.minimumPressDuration = 0.3
//        longPressGesture.delaysTouchesBegan = true
        collectionView?.addGestureRecognizer(longPressGesture)
        isSelectModel = false
        self.collectionView?.allowsMultipleSelection = true
        self.collectionView?.allowsSelection = true
//        ViewTools.automaticallyAdjustsScrollView(scrollView: self.collectionView!, viewController: self)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func longPressAction(_ sender:UIGestureRecognizer){
        if sender.state != UIGestureRecognizerState.ended{
            return
        }
        if isSelectModel! {
            return
        }
        
      
        
    
        let point = sender.location(in:self.collectionView)
        let indexPath = self.collectionView?.indexPathForItem(at: point)
        if (self.collectionView(self.collectionView!, shouldSelectItemAt: indexPath!)) {
            
    
        }
        if indexPath != nil {
            let cell = self.collectionView?.cellForItem(at: indexPath!)
            if let cell = cell as? FilesFolderCollectionViewCell {
                if let delegateOK = delegate{
                    isSelectModel = true
                    delegateOK.collectionView(self, isSelectModel: isSelectModel!)
                }
          
                let sectionArray:Array<FilesModel> = dataSource![indexPath!.section] as! Array
                let model  = sectionArray[(indexPath?.item)!]
                FilesHelper.sharedInstance.addChooseFiles(model: model)
                cell.isSelectModel = isSelectModel
                cell.isSelect = true
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
        let sectionArray:Array<FilesModel> = dataSource![section] as! Array
        return sectionArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if cellStyle == .card{
            if indexPath.section == 0 {
                collectionView.register(FilesFolderCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
                if let cell = cell as? FilesFolderCollectionViewCell {
                    let sectionArray:Array<FilesModel> = dataSource![indexPath.section] as! Array
                    let model  = sectionArray[indexPath.item]
                    cell.titleLabel.text = model.name
                }
                return cell
            }else{
                collectionView.register(FilesFileCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifierSection2)
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierSection2, for: indexPath)
                if let cell = cell as? FilesFileCollectionViewCell {
                    let sectionArray:Array<FilesModel> = dataSource![indexPath.section] as! Array
                    let model  = sectionArray[indexPath.item]
                    cell.titleLabel.text = model.name
                    cell.leftImageView.image = UIImage.init(named: "files_ppt_small.png")
                    cell.mainImageView.image = UIImage.init(named: "files_ppt_normal.png")
        
                }
       
                return cell
            }
        }else{
            collectionView.register(FilesListCollectionViewCell.self, forCellWithReuseIdentifier: reuseListIdentifier)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseListIdentifier, for: indexPath)
            if let cell = cell as? FilesListCollectionViewCell {
                let sectionArray:Array<FilesModel> = dataSource![indexPath.section] as! Array
                let model  = sectionArray[indexPath.item]
                if indexPath.section == 0 {
                    cell.leftImageView.image = UIImage.init(named: "files_files.png")
                    cell.titleLabel.text = model.name
                    cell.detailLabel.text = "2017.06.15 40.4MB"
                }else{
                    cell.leftImageView.image = UIImage.init(named: "files_ppt_small.png")
                    cell.titleLabel.text = model.name
                    cell.detailLabel.text = "2017.06.15 40.4MB"
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
        var reusableView:UICollectionReusableView!
        if (kind == UICollectionElementKindSectionHeader) {
            let header:CommonCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifierHeader, for: indexPath) as! CommonCollectionReusableView
            reusableView = header
            let reusableHeaderView:CommonCollectionReusableView = (reusableView as? CommonCollectionReusableView)!
            if indexPath.section == 0 {
                reusableHeaderView.titleLabel.text = LocalizedString(forKey: "files_folders")
                let image = UIImage.init(named: "files_up.png")
                reusableHeaderView.rightButton.leftImageView.image = image
                reusableHeaderView.rightButton.titleTextLabel.text = LocalizedString(forKey: "files_name")
                reusableHeaderView.rightButton.titleTextLabel.sizeToFit()
                let labelWidth = reusableHeaderView.rightButton.titleTextLabel.width
                let size =  CGSize(width: labelWidth + (image?.size.width)! + MarginsWidth - 4 + MarginsCloseWidth, height: reusableHeaderView.rightButton.height)
                let frame = CGRect(origin: CGPoint(x: reusableHeaderView.width - MarginsWidth - size.width, y: reusableHeaderView.rightButton.origin.y), size: size)
                reusableHeaderView.rightButton.frame = frame
                reusableHeaderView.rightButton.isHidden = false
            }else{
                reusableHeaderView.titleLabel.text = LocalizedString(forKey: "files_files")
                reusableHeaderView.rightButton.isHidden = true
            }
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
            if indexPath.section == 1 {
                return CGSize(width: CellWidth, height: CellWidth)
            }else{
                return CGSize(width: CellWidth, height: CellSmallHeight)
            }
        }else{
            return CGSize(width: __kWidth, height: 64.0)
        }
    }
    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
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
    

    lazy var rightButton: SequenceButton = {
        let text = LocalizedString(forKey: "files_name")
        let labelwidth = labelWidthFrom(title: text, font: SmallTitleFont)
        let image = UIImage.init(named: "files_up.png")
        let buttonWidth = labelwidth + (image?.size.width)! + MarginsWidth - 4 + MarginsCloseWidth
        let button = SequenceButton.init(frame: CGRect(x: self.width - MarginsWidth - buttonWidth, y: self.height/2 - MarginsWidth/2, width: buttonWidth, height: MarginsWidth + 4))
        return button
    }()
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SequenceButton: MDBaseButton{
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
