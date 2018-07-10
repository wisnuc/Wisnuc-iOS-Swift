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


private var menuButton: IconButton!

class PhotoRootViewController: BaseViewController {
    var isSelectMode:Bool?
    init(localDataSource:Array<WSAsset>?) {
        super.init()
        if localDataSource != nil {
            localAssetDataSources.append(contentsOf: localDataSource!)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCollectionView()
        prepareSearchBar()
        self.sort(localAssetDataSources)
        self.photoCollcectionViewController.dataSource = assetDataSources
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
    func isSameDay(date1:Date,date2:Date ) -> Bool {
       let calendar = Calendar.current
       let comp1 = calendar.dateComponents([.year,.month,.day], from: date1)
       let comp2 = calendar.dateComponents([.year,.month,.day], from: date2)
        //开始比较
        return comp1.year == comp2.year && comp1.month == comp2.month && comp1.day == comp2.day
    }
//    - (BOOL)isSameDay:(NSDate *)date1 date2:(NSDate *)date2 {
//
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//
//    unsigned unitFlag = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
//
//    NSDateComponents *comp1 = [calendar components:unitFlag fromDate:date1];
//
//    NSDateComponents *comp2 = [calendar components:unitFlag fromDate:date2];
//
//    return (([comp1 day] == [comp2 day]) && ([comp1 month] == [comp2 month]) && ([comp1 year] == [comp2 year]));
//
//    }
    
    func sort(_ assetsArray:Array<WSAsset>){
        var array:Array<WSAsset>  = Array.init()
        array.append(contentsOf: assetsArray)
        array.sort { $0.createDate! > $1.createDate! }
        let timeArray:NSMutableArray = NSMutableArray.init()
        let photoGroupArray:NSMutableArray = NSMutableArray.init()
        if array.count>0 {
            let firstAsset = array.first
            firstAsset?.indexPath = IndexPath.init(row: 0, section: 0)
            let photoDateGroup1:NSMutableArray = NSMutableArray.init() //第一组照片
            photoDateGroup1.add(firstAsset!)
            photoGroupArray.add(photoDateGroup1)
            if firstAsset?.createDate != nil{
             timeArray.add(firstAsset!.createDate!)
            }
            if array.count == 1{
                self.assetDataSources = photoGroupArray as! Array<Array<WSAsset>>
               return
            }
            var photoDateGroup2:NSMutableArray? = photoDateGroup1 //最近的一组

            for i in 1..<array.count {
                let photo1 =  array[i]
                let photo2 = array[i-1]
                if Calendar.current.isDate(photo1.createDate! , inSameDayAs: photo2.createDate!){
                    photo1.indexPath = IndexPath.init(row: ((photoGroupArray[photoGroupArray.count - 1]) as! NSMutableArray).count, section: photoGroupArray.count - 1)
                   photoDateGroup2!.add(photo1)
                }else{
                    photo1.indexPath = IndexPath.init(row: 0, section: photoGroupArray.count)
                    if photo1.createDate != nil{
                        timeArray.add(photo1.createDate!)
                    }
                    photoDateGroup2 = nil
                    photoDateGroup2 = NSMutableArray.init()
                    photoDateGroup2!.add(photo1)
                    photoGroupArray.add(photoDateGroup2!)
                }
            }
        }
        self.assetDataSources = photoGroupArray as! Array<Array<WSAsset>>
    }
    
    func prepareCollectionView(){
        photoCollcectionViewController.isSelectMode = false
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
    
    lazy var localAssetDataSources: Array<WSAsset> = {
        let array:Array<WSAsset> = Array.init()
        return array
    }()
    
    lazy var assetDataSources: Array<Array<WSAsset>> = {
        let array:Array<Array<WSAsset>> = Array.init()
        return array
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