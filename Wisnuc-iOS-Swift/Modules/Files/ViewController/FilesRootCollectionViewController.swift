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
private let reuseIdentifierSection2 = "Celled"
private let reuseIdentifierHeader = "HeaderView"
private let reuseIdentifierFooter = "FooterView"
private let CellWidth:CGFloat = CGFloat((__kWidth - 4)/2)
private let CellSmallHeight:CGFloat = 48.0

@objc protocol FilesRootCollectionViewControllerDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
}

class FilesRootCollectionViewController: MDCCollectionViewController {
    let colors = [ "red", "blue", "green", "black", "yellow", "purple" ]
    var delegate:FilesRootCollectionViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
      
//        self.styler.cellStyle = .card
        self.styler.cellLayoutType = MDCCollectionViewCellLayoutType.grid
        self.styler.gridPadding = 4
        self.styler.gridColumnCount = 2
        self.view.backgroundColor = lightGrayBackgroudColor
        self.collectionView?.backgroundColor = lightGrayBackgroudColor
        self.collectionView?.register(CommonCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: reuseIdentifierHeader)
    
        self.collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: reuseIdentifierFooter)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return colors.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            collectionView.register(FilesFolderCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
            if let cell = cell as? FilesFolderCollectionViewCell {
                cell.titleLabel.text = colors[indexPath.item]
            }
            return cell
        }else{
            collectionView.register(FilesFileCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifierSection2)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierSection2, for: indexPath)
            if let cell = cell as? FilesFileCollectionViewCell {
                cell.titleLabel.text = colors[indexPath.item]
                cell.leftImageView.image = UIImage.init(named: "files_ppt_small.png")
                cell.mainImageView.image = UIImage.init(named: "files_ppt_normal.png")
            }
            return cell
        }
       
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: __kWidth, height: CellSmallHeight)
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
                let size =  CGSize(width: labelWidth + (image?.size.width)! + MarginsWidth - 4 + MarginsCloseWidth, height: reusableHeaderView.rightButton.titleTextLabel.height)
                let frame = CGRect(origin: CGPoint(x: reusableHeaderView.width - MarginsWidth - size.width, y: reusableHeaderView.rightButton.origin.y), size: size)
                reusableHeaderView.rightButton.frame = frame
                
            }else{
                reusableHeaderView.titleLabel.text = LocalizedString(forKey: "files_files")
                reusableHeaderView.rightButton.isHidden = true
            }
        }
        reusableView.backgroundColor = UIColor.clear
        if (kind == UICollectionElementKindSectionFooter)
        {
            let footerview = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifierFooter, for: indexPath)
            footerview.backgroundColor = UIColor.purple
            reusableView = footerview
        }
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
        if indexPath.section == 1 {
            return CGSize(width: CellWidth, height: CellWidth)
        }else{
            return CGSize(width: CellWidth, height: 48.0)
        }
    }                                                                                                       

   

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

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
        let button = SequenceButton.init(frame: CGRect(x: self.width - MarginsWidth - buttonWidth, y: self.height/2 - MarginsWidth/2, width: buttonWidth, height: MarginsWidth))
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
        self.backgroundColor = UIColor.clear
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
