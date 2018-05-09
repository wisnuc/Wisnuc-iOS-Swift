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
    case list = 0
    case card
}

let colors = [[ "red", "blue", "green", "black", "yellow", "purple" ],[ "red", "blue", "green", "black", "yellow", "purple" ]]
private let reusableIdentifierItem = "itemCellIdentifier"
private let cellFolderHeight:CGFloat = 48
private let cellWidth:CGFloat = (__kWidth - 4)/2
private let cellHeight:CGFloat = 137
private let SearchBarBottom:CGFloat = 77.0

class FilesRootViewController: BaseViewController {
    private var menuButton: IconButton!
    private var moreButton: IconButton!
    private var listStyleButton: IconButton!
    var cellStyle:CellStyle?{
        didSet{
            switch cellStyle {
            case .card?:
                self.collcectionViewController.styler.cellLayoutType = MDCCollectionViewCellLayoutType.grid
                self.collcectionViewController.styler.cellStyle = MDCCollectionViewCellStyle.default
            case .list?:
                self.collcectionViewController.styler.cellLayoutType = MDCCollectionViewCellLayoutType.list
                self.collcectionViewController.styler.cellStyle = MDCCollectionViewCellStyle.grouped
            default:
                break
            }
            
            self.collcectionViewController.collectionView?.performBatchUpdates({
            
            }, completion: { (finished) in
                
           })
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.appBar.headerViewController.headerView.isHidden = true
        self.view.backgroundColor = lightGrayBackgroudColor
        prepareCollectionView()
        prepareSearchBar()
        setCellStyle()
        
        //        self.view.sendSubview(toBack: collcectionViewController.view)
        //       self.appBar.headerViewController.headerView.addSubview(searchBar)
        
        //       self.appBar.headerViewController.headerView.trackingScrollView = self.collcectionViewController.collectionView
        //       self.xx_fixNavBarPenetrable()
        //        self.appBar.headerViewController.headerView.delegate = self
        //         self.appBar.headerViewController.headerView.minMaxHeightIncludesSafeArea = false
        //        self.appBar.headerViewController.headerView.tintColor = UIColor.clear
        //        self.appBar.headerViewController.headerView.shiftBehavior = MDCFlexibleHeaderShiftBehavior.enabled
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Application.statusBarStyle = .default
    }
    
    func setCellStyle(){
        cellStyle = .card
    }
    
    func prepareCollectionView(){
        self.addChildViewController(collcectionViewController)
        collcectionViewController.didMove(toParentViewController: self)
        collcectionViewController.view.frame =  CGRect.init(x: self.view.left, y:0, width: self.view.width, height: self.view.height)
        self.view.addSubview(collcectionViewController.view)
        // self.view.top + searchBar.bottom + MarginsCloseWidth/2
        collcectionViewController.collectionView?.contentInset = UIEdgeInsetsMake(searchBar.bottom + MarginsCloseWidth/2-20, 0, 0 , 0)
        
    }
    
    @objc func listStyleButtonTap(_ sender:IconButton){
//        collcectionViewController.styler.cellLayoutType = MDCCollectionViewCellLayoutType.list
//        collcectionViewController.styler.cellStyle = MDCCollectionViewCellStyle.grouped
//        collcectionViewController.collectionView?.performBatchUpdates({
//
//        }, completion: { (finished) in
//
//        })
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            cellStyle = .list
        }else{
            cellStyle = .card
        }
    }
    

    
    lazy var collcectionViewController : FilesRootCollectionViewController = {
        let layout = MDCCollectionViewFlowLayout()
//        layout.sectionInset = UIEdgeInsets.zero
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
    
    private func prepareSearchBar() {
        self.view.addSubview(searchBar)
        let menuImage = #imageLiteral(resourceName: "menu.png")
        menuButton = IconButton(image: menuImage)
        moreButton = IconButton(image: Icon.cm.moreHorizontal?.byTintColor(LightGrayColor))
        listStyleButton = IconButton(image: #imageLiteral(resourceName: "cardstyle.png"))
        listStyleButton.addTarget(self, action: #selector(listStyleButtonTap(_ :)), for: UIControlEvents.touchUpInside)
        searchBar.leftViews = [menuButton]
        searchBar.rightViews = [listStyleButton,moreButton]
    }
}




extension FilesRootViewController:FilesRootCollectionViewControllerDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(scrollView.contentOffset.y)
        if scrollView.contentOffset.y > -(SearchBarBottom + MarginsCloseWidth/2) {
            self.searchBar.origin.y = -(scrollView.contentOffset.y)-(SearchBarBottom + MarginsCloseWidth/2)+20
        }else{
            self.searchBar.origin.y = 20 + MarginsCloseWidth
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
    
}
