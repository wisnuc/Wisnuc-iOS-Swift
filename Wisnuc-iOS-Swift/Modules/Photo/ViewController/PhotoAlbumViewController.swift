//
//  PhotoAlbumViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/9/20.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class PhotoAlbumViewController: BaseViewController {
    private let reuseIdentifier = "reuseIdentifierPhotoCell"
    private let reuseHeaderIdentifier = "reuseIdentifierPhotoFooter"
    private let cellContentSizeWidth = (__kWidth - MarginsWidth*3)/2
    private let cellContentSizeHeight = (__kWidth - MarginsWidth*3)/2 + 56
    var dataSource:Array<Array<PhotoAlbumModel>>?
    var index:Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareNavigationBar()
        setData()
        self.view.addSubview(albumCollectionView)
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
        appBar.headerViewController.headerView.changeContentInsets { [weak self] in
            self?.appBar.headerViewController.headerView.trackingScrollView?.contentInset = UIEdgeInsets(top: (self?.appBar.headerViewController.headerView.trackingScrollView?.contentInset.top)! + kScrollViewTopMargin, left: 0, bottom: 0, right: 0)
        }
    }
    
    deinit {
        // Required for pre-iOS 11 devices because we've enabled observesTrackingScrollViewScrollEvents.
        appBar.appBarViewController.headerView.trackingScrollView = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setStatusBar(.default)
        if let tabbar = retrieveTabbarController(){
            if tabbar.tabBarHidden {
               tabbar.tabBarHidden = false
//            tabbar.setTabBarHidden(false, animated: false)
            }
        }
        appBar.headerViewController.headerView.trackingScrollView = albumCollectionView
        appBar.appBarViewController.headerView.observesTrackingScrollViewScrollEvents = true
    }

    func prepareNavigationBar(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "add_album.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(rightButtonItemTap(_:)))
    }
    
    func setData(){
        dataSource = Array.init()
        var collectionAlbumArray = Array<PhotoAlbumModel>.init()
        let photoAlbumModel1 = PhotoAlbumModel.init()
        photoAlbumModel1.type = PhotoAlbumType.collecion
        photoAlbumModel1.name = "所有相片"
        photoAlbumModel1.describe = nil
        photoAlbumModel1.dataSource = nil
        let photoAlbumModel2 = PhotoAlbumModel.init()
        photoAlbumModel2.type = PhotoAlbumType.collecion
        photoAlbumModel2.name = "来自iPhone XR"
        photoAlbumModel2.describe = nil
        photoAlbumModel2.dataSource = nil
        let photoAlbumModel3 = PhotoAlbumModel.init()
        photoAlbumModel3.type  = PhotoAlbumType.collecion
        photoAlbumModel3.name = "视频"
        photoAlbumModel3.describe = nil
        photoAlbumModel3.dataSource = nil
        collectionAlbumArray.append(photoAlbumModel1)
        collectionAlbumArray.append(photoAlbumModel2)
        collectionAlbumArray.append(photoAlbumModel3)
        
        let collectionMyArray = Array<PhotoAlbumModel>.init()
        dataSource?.append(collectionAlbumArray)
        dataSource?.append(collectionMyArray)
        
    }

    @objc func rightButtonItemTap(_ sender:UIBarButtonItem){
        let photosVC = PhotoRootViewController.init(style: NavigationStyle.select, state: PhotoRootViewControllerState.creat)
        photosVC.delegate = self
        DispatchQueue.global(qos: .default).async {
            let assets = AppAssetService.allAssets!
            DispatchQueue.main.async {
                photosVC.localAssetDataSources.append(contentsOf:assets)
                photosVC.localDataSouceSort()
            }
            AppAssetService.getNetAssets { (error, netAssets) in
                if error == nil{
                    DispatchQueue.main.async {
                        photosVC.addNetAssets(assetsArr: netAssets!)
                    }
                }else{
                    DispatchQueue.main.async {
                        photosVC.localDataSouceSort()
                    }
                }
            }
        }
        let navigationVC = UINavigationController.init(rootViewController: photosVC)
        self.present(navigationVC, animated: true) {
            
        }
    }
    
    lazy var albumCollectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout.init()
//        collectionViewLayout.itemSize
        let collectionView = UICollectionView.init(frame: CGRect(x: 0, y: 0, width: __kWidth, height: __kHeight - TabBarHeight), collectionViewLayout: collectionViewLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoAlbumCollectionViewHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: reuseHeaderIdentifier)
        collectionView.register(UINib.init(nibName: StringExtension.classNameAsString(targetClass: PhotoAlbumCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = .white
        return collectionView
    }()
}

extension PhotoAlbumViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.dataSource!.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return self.dataSource![section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:PhotoAlbumCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoAlbumCollectionViewCell
        let model = dataSource![indexPath.section][indexPath.row]
        cell.imageView.image =  UIImage.init(color: .red)
        cell.nameLabel.text = model.name
        if  let photoData = model.dataSource{
            cell.countLabel.text = String(describing: photoData.count)
        }else{
            cell.countLabel.text = "0"
        }
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let tabbar = retrieveTabbarController(){
            tabbar.setTabBarHidden(true, animated: true)
        }
        if indexPath.section == 0{
            switch indexPath.item {
            case 0:
                let photosVC = PhotoRootViewController.init(style: NavigationStyle.whiteWithoutShadow,state:.normal)
                if let cell = collectionView.cellForItem(at: indexPath) as? PhotoAlbumCollectionViewCell{
                    photosVC.title = cell.nameLabel.text
                }
                DispatchQueue.global(qos: .default).async {
                    let assets = AppAssetService.allAssets!
                    DispatchQueue.main.async {
                        photosVC.localAssetDataSources.append(contentsOf:assets)
                        photosVC.localDataSouceSort()
                    }
                    AppAssetService.getNetAssets { (error, netAssets) in
                        if error == nil{
                            DispatchQueue.main.async {
                                photosVC.addNetAssets(assetsArr: netAssets!)
                            }
                        }else{
                            DispatchQueue.main.async {
                                photosVC.localDataSouceSort()
                            }
                        }
                    }
                }
                self.navigationController?.pushViewController(photosVC, animated: true)
            default:
                break
            }
        }else{
            let model = dataSource?[indexPath.section][indexPath.row]
            let newAlbumVC = NewAlbumViewController.init(style: NavigationStyle.whiteWithoutShadow, photos: model?.dataSource)
            newAlbumVC.delegate = self
            newAlbumVC.setState(NewAlbumViewControllerState.normal)
            newAlbumVC.setContent(title: model?.name, describe: model?.describe)
            self.navigationController?.pushViewController(newAlbumVC, animated: true)
            self.index = indexPath.row
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headView:PhotoAlbumCollectionViewHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: reuseHeaderIdentifier, for: indexPath) as! PhotoAlbumCollectionViewHeaderView
        headView.setTitleLabelText(string: LocalizedString(forKey: "我的相册"))
        return headView
    }
    

}

extension PhotoAlbumViewController :UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      
        return CGSize(width:cellContentSizeWidth , height: cellContentSizeHeight)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return  section == 0 ? UIEdgeInsets.init(top: 0, left: 16, bottom: 0, right: 16) : UIEdgeInsets.init(top: 16, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return section == 1 ? CGSize(width: __kWidth, height: 30 + MarginsWidth) : CGSize.zero
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
//        return CGSize(width: cellContentSize, height: 8 + 14 + 8)
//    }
    
}

extension PhotoAlbumViewController:PhotoRootViewControllerDelegate{
    func selectPhotoComplete(assets: Array<WSAsset>) {
        let newAlbumVC = NewAlbumViewController.init(style: .whiteWithoutShadow,photos:assets)
        newAlbumVC.delegate = self
        newAlbumVC.setState(.editing)
        self.index = (self.dataSource?[1].count ?? 1) == 0 ? 0 : (self.dataSource?[1].count ?? 1) - 1
        self.navigationController?.pushViewController(newAlbumVC, animated: true)
    }
}

extension PhotoAlbumViewController:NewAlbumViewControllerDelegate{
//    func updateNewAlbumFinish(data: Dictionary<String, Any>) {
//        var array = self.dataSource?[1]
//        let albumModel = PhotoAlbumModel.init()
//        albumModel.type = PhotoAlbumType.my
//        albumModel.name = data["name"] as? String
//        albumModel.describe = data["describe"] as? String
//        albumModel.dataSource = data["photoData"] as? [WSAsset]
//        if (array?.count)! == 0{
//            array?.append(albumModel)
//        }else{
//            array?[self.index] = albumModel
//        }
//      
//        self.dataSource?[1] = array!
//        self.albumCollectionView.reloadData()
//    }
    
    func creatNewAlbumFinish(data: Dictionary<String, Any>) {
        var array = self.dataSource?[1]
        let albumModel = PhotoAlbumModel.init()
        albumModel.type = PhotoAlbumType.my
        albumModel.name = data["name"] as? String
        albumModel.describe = data["describe"] as? String
        albumModel.dataSource = data["photoData"] as? [WSAsset]
        array?.append(albumModel)
        self.dataSource?[1] = array!
        self.albumCollectionView.reloadData()
    }
}

