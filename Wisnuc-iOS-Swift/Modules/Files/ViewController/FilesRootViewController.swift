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

enum CollectState:Int {
    case normal = 0
    case select
    case unselect
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
    var  dataSource:Array<Any>?
    var cellStyle:CellStyle?
    var isSelectModel:Bool?{
        didSet{
            if isSelectModel!{
              selectAction()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = lightGrayBackgroudColor
        prepareData()
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
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
        self.appBar.headerViewController.headerView.hide(whenShifted: appBar.headerStackView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Application.statusBarStyle = .default
    }
    
    func setCellStyle(){
        cellStyle = .card
        self.collcectionViewController.cellStyle = cellStyle
    }
    
    func prepareData() {
        dataSource = colors
    }
    
    func prepareCollectionView(){
        self.addChildViewController(collcectionViewController)
        collcectionViewController.didMove(toParentViewController: self)
        collcectionViewController.view.frame =  CGRect.init(x: self.view.left, y:0, width: self.view.width, height: self.view.height)
        self.view.addSubview(collcectionViewController.view)
        // self.view.top + searchBar.bottom + MarginsCloseWidth/2
        collcectionViewController.collectionView?.contentInset = UIEdgeInsetsMake(searchBar.bottom + MarginsCloseWidth/2-20, 0, 0 , 0)
        
    }
    
    func selectAction(){
        print(searchBar.bottom)
        if searchBar.bottom >= 0{
            UIView.animate(withDuration: 0.3, animations: {
                self.searchBar.bottom = 0
            }) { (finish) in
                if finish{
                    DispatchQueue.main.async {
                       
                    }

                }
            }
        }else{
            
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
    }

    @objc func menuButtonTap(_ sender:IconButton){
         navigationDrawerController?.toggleLeftView()
    }
    
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
    
    private func prepareSearchBar() {
        self.view.addSubview(searchBar)
        let menuImage = UIImage.init(named:"menu.png")
        menuButton = IconButton(image: menuImage)
        menuButton.addTarget(self, action: #selector(menuButtonTap(_:)), for: UIControlEvents.touchUpInside)
        moreButton = IconButton(image: Icon.cm.moreHorizontal?.byTintColor(LightGrayColor))
        listStyleButton = IconButton(image: #imageLiteral(resourceName: "cardstyle.png"))
        listStyleButton.addTarget(self, action: #selector(listStyleButtonTap(_ :)), for: UIControlEvents.touchUpInside)
        searchBar.leftViews = [menuButton]
        searchBar.rightViews = [listStyleButton,moreButton]
    }
}

extension FilesRootViewController:FilesRootCollectionViewControllerDelegate{
    func collectionView(_ collectionViewController: MDCCollectionViewController, isSelectModel: Bool) {
        self.isSelectModel = isSelectModel
    }
    
    func collectionViewData(_ collectionViewController: MDCCollectionViewController) -> Array<Any> {
        return dataSource!
    }

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
