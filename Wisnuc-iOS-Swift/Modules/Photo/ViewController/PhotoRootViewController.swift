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
import DZNEmptyDataSet

private var menuButton: IconButton!
class PhotoRootViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCollectionView()
        prepareSearchBar()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.appBar.headerViewController.headerView.isHidden = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
   

    func prepareCollectionView(){
        self.addChildViewController(photoCollcectionViewController)
        photoCollcectionViewController.view.frame =  CGRect.init(x: self.view.left, y:0, width: self.view.width, height: self.view.height)
        self.view.addSubview(photoCollcectionViewController.view)
        photoCollcectionViewController.didMove(toParentViewController: self)
        // self.view.top + searchBar.bottom + MarginsCloseWidth/2
        let topEdgeInsets:CGFloat = kCurrentSystemVersion >= 11.0 ? searchBar.bottom + MarginsCloseWidth/2-20 : searchBar.bottom + MarginsCloseWidth/2
        photoCollcectionViewController.collectionView?.contentInset = UIEdgeInsetsMake(topEdgeInsets, 0, 0 , 0)
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
    
}

extension PhotoRootViewController:DZNEmptyDataSetSource,DZNEmptyDataSetDelegate{
    
}

extension PhotoRootViewController:PhotoCollectionViewControllerDelegate{
    
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
