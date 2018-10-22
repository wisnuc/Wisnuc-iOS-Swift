//
//  NewAlbumViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by liupeng on 2018/9/23.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
enum NewAlbumViewControllerState {
    case normal
    case editing
}

enum HeaderExtensionType {
    case textView
}

@objc protocol NewAlbumViewControllerDelegate {
    func creatNewAlbumFinish(data:Dictionary<String,Any>)
//    func updateNewAlbumFinish(data:Dictionary<String,Any>)
}

class NewAlbumViewController: BaseViewController {
    private let reuseIdentifier = "reuseIdentifierCell"
    private let reuseHeaderIdentifier = "reuseIdentifierHeader"
    private let cellContentSizeWidth = (__kWidth - 4)/2
    private let cellContentSizeHeight = (__kWidth - 4)/2
    private let estimateDefaultHeight:CGFloat = 100
    
    var dataDic:Dictionary<String,Any>?
    lazy var dataSource = Array<WSAsset>.init()
    lazy var headerExtensionArray:Array<HeaderExtensionType> =  Array.init()
    weak var delegate:NewAlbumViewControllerDelegate?
    var albumTitleText:String?
    var albumDescribeText:String?
    var headView:NewPhotoAlbumCollectionReusableView?
    var state:NewAlbumViewControllerState?{
        didSet{
            switch state {
            case .normal?:
                nomarlStateAction()
            case .editing?:
                editingStateAction()
            default:
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Do any additional setup after loading the view.
    }
    
    init(style: NavigationStyle,photos:Array<WSAsset>?) {
        super.init(style: style)
        if photos != nil{
            self.dataSource.append(contentsOf: photos!)
        }
        self.view.addSubview(photoCollectionView)
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
    }
    deinit {
        // Required for pre-iOS 11 devices because we've enabled observesTrackingScrollViewScrollEvents.
        appBar.appBarViewController.headerView.trackingScrollView = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let tabbar = retrieveTabbarController(){
            tabbar.setTabBarHidden(true, animated: false)
        }
        appBar.appBarViewController.headerView.trackingScrollView = photoCollectionView
       
    }
    
    @objc func finishEditing(_ sender:UIBarButtonItem){
        self.state = .normal
        var dic:Dictionary<String,Any> = Dictionary.init()
        dic["name"] = albumTitleText ?? LocalizedString(forKey: "未命名相册")
        dic["describe"] = albumDescribeText!
        dic["photoData"] = dataSource
       
      
        
//        if  self.dataDic == nil {
            self.delegate?.creatNewAlbumFinish(data: dic)
//        }else{
//            self.delegate?.updateNewAlbumFinish(data: dic)
//        }
        
        self.dataDic = dic
    }
    
    @objc func addTextBarButtonItemTap(_ sender:UIBarButtonItem){
        headerExtensionArray.append(.textView)
//        self.photoCollectionView.performBatchUpdates({ [weak self] in
            self.headView?.headerExtensionArray = headerExtensionArray
            
//        }) { (finished) in
//
//        }
        self.photoCollectionView.reloadData()
    }
    
    @objc func addNewPhotoBarButtonItemTap(_ sender:UIBarButtonItem){
        let photosVC = PhotoRootViewController.init(style: NavigationStyle.select, state: PhotoRootViewControllerState.select)
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
    
    @objc func addLocationBarButtonItemTap(_ sender:UIBarButtonItem){
     
    }
    
    @objc func sortPhotoBarButtonItemTap(_ sender:UIBarButtonItem){
        
    }
    
    @objc func moreBarButtonItemTap(_ sender:UIBarButtonItem){
        
    }
    
    func setState(_ state:NewAlbumViewControllerState){
        self.state = state
    }
    
    func setContent(title:String?,describe:String?){
        albumTitleText = title
        albumDescribeText = describe
        if !isNilString(describe) {
            headerExtensionArray.append(.textView)
        }
    }
    
    func editingStateAction(){
        self.style = .select
        appBar.appBarViewController.headerView.observesTrackingScrollViewScrollEvents = false
        self.navigationItem.rightBarButtonItems = nil
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "text_right.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(finishEditing(_:)))
        let addNewPhotoBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "add_new_photo_new_album.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(addNewPhotoBarButtonItemTap(_:)))
        let addTextBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "add_text_photo_new_album.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(addTextBarButtonItemTap(_:)))
//        let addLocationBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "location_new_album.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(addLocationBarButtonItemTap(_:)))
        let sortPhotoBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "sort_photo_new_album.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(sortPhotoBarButtonItemTap(_:)))
        self.navigationItem.rightBarButtonItems = [sortPhotoBarButtonItem,addTextBarButtonItem,addNewPhotoBarButtonItem]
        if let header = self.photoCollectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: IndexPath.init(row: 0, section: 0)){
            let headerView = header as! NewPhotoAlbumCollectionReusableView
            headerView.state = .editing
        }
       
        for collectionCell in self.photoCollectionView.visibleCells{
           let cell = collectionCell as! NewPhotoAlbumCollectionViewCell
            cell.setEditingAnimation(isEditing: self.state == .editing ? true : false, animation: true)
        }
    }
    
    func nomarlStateAction(){
        self.style = .whiteWithoutShadow
        appBar.appBarViewController.headerView.observesTrackingScrollViewScrollEvents = true
        let addNewPhotoBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "add_new_photo_new_album_gray.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(addNewPhotoBarButtonItemTap(_:)))
        let moreBarButtonItem = UIBarButtonItem.init(image: MDCIcons.imageFor_ic_more_horiz()?.byTintColor(LightGrayColor), style: UIBarButtonItemStyle.plain, target: self, action: #selector(moreBarButtonItemTap(_:)))
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItems = [moreBarButtonItem,addNewPhotoBarButtonItem]
        self.photoCollectionView.reloadData()
//
    }
    
    func imageHeight(asset:WSAsset, layoutWidth: CGFloat, estimateHeight: CGFloat) -> CGFloat {
        var showHeight = estimateDefaultHeight
        if estimateHeight != 0.0 {
            showHeight = estimateHeight
        }
        if  layoutWidth == 0.0 {
            return showHeight
        }
        
        var size: CGSize = CGSize.zero
        
        if asset is NetAsset{
            let  netAsset = asset as! NetAsset
            let width = netAsset.metadata?.w ?? 0
            let height = netAsset.metadata?.h ?? 0
            size = CGSize(width: CGFloat(width), height: CGFloat(height))
        }else{
            if asset.asset != nil{
                size = CGSize.init(width: asset.asset?.pixelWidth ?? 0, height: asset.asset?.pixelHeight ?? 0)
            }
        }
        
        let imgWidth: CGFloat = size.width
        let imgHeight: CGFloat = size.height
        if imgWidth > 0 && imgHeight > 0 {
            showHeight = layoutWidth / imgWidth * imgHeight
        }
        return showHeight
    }
    
    
    func itemHeight(at indexPath: IndexPath) -> CGFloat {
        let asset = dataSource[indexPath.row]
        /**
         *  参数1:图片URL
         *  参数2:imageView 宽度
         *  参数3:预估高度,(此高度仅在图片尚未加载出来前起作用,不影响真实高度)
         */
        return self.imageHeight(asset:asset, layoutWidth: self.layout.itemWidth, estimateHeight: 200)
    }
    
   
    
    lazy var layout: NewAlbumViewCollectionLayout = { [weak self] in
        var layoutNew:NewAlbumViewCollectionLayout?
        layoutNew = NewAlbumViewCollectionLayout.init(itemsHeightBlock: { [weak self] (index) -> CGFloat in
            return (self?.itemHeight(at: index!))!
        })
        return layoutNew!
    }()
    
    lazy var photoCollectionView: UICollectionView = { [weak self] in
        let collectionViewLayout = UICollectionViewFlowLayout.init()
        //        collectionViewLayout.itemSize
        let collectionView = UICollectionView.init(frame: CGRect(x: 0, y: 0, width: __kWidth, height: __kHeight), collectionViewLayout: collectionViewLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(NewPhotoAlbumCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: reuseHeaderIdentifier)
        collectionView.register(UINib.init(nibName: StringExtension.classNameAsString(targetClass: NewPhotoAlbumCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = .white
        return collectionView
    }()
}


extension NewAlbumViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:NewPhotoAlbumCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! NewPhotoAlbumCollectionViewCell
        let asset = dataSource[indexPath.row]
        
        cell.setImagView(indexPath:indexPath)
        cell.setDeleteButton(indexPath: indexPath)
        cell.setEditingAnimation(isEditing: self.state == .editing ? true : false, animation: true)
//        setSelectAnimation(isSelect: self.isSelectMode ?? false ? self.choosePhotos.contains(model) : false, animation: false)
        cell.model = asset
//        cell.nameLabel.text = model.name
//        cell.countLabel.text = "100"
        cell.deleteCallbck = { [weak self] (cellIndexPath) in
            self?.photoCollectionView.performBatchUpdates({
                if cellIndexPath.row < (self?.dataSource.count)!{
                    self?.dataSource.remove(at: cellIndexPath.row)
                    self?.photoCollectionView.deleteItems(at: [cellIndexPath])
                }

            }, completion: { [weak self](finish) in
                if self?.photoCollectionView.indexPathsForVisibleItems != nil{
                    self?.photoCollectionView.reloadItems(at: (self?.photoCollectionView.indexPathsForVisibleItems)!)
                }
            })
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headView:NewPhotoAlbumCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: reuseHeaderIdentifier, for: indexPath) as! NewPhotoAlbumCollectionReusableView
        headView.stateChangeClosure = { [weak self]  (headerState) in
            switch headerState {
            case .editing:
                self?.state = .editing
            case .normal:
                self?.state = .normal
            default:
                break
            }
        }
        headView.state = self.state == .normal ? .normal : .editing
        headView.textField.text = albumTitleText
        headView.textView.text = albumDescribeText
        if !isNilString(albumDescribeText) {
            headView.headerExtensionArray = headerExtensionArray
        }
        self.headView = headView
        return headView
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if let header = self.photoCollectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at:indexPath) as? NewPhotoAlbumCollectionReusableView{
            albumTitleText =  header.textField.text ?? LocalizedString(forKey: "未命名相册")
            albumDescribeText =  header.textView.text ?? ""
        }
    }
}

extension NewAlbumViewController :UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let asset = dataSource[indexPath.row]
        if asset is NetAsset{
          let  netAsset = asset as! NetAsset
            netAsset.metadata?.w
            netAsset.metadata?.h
        }
//        var size = CGSize(width: <#T##CGFloat#>, height: <#T##CGFloat#>)
        return CGSize(width:cellContentSizeWidth , height: cellContentSizeHeight)
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return   UIEdgeInsets.init(top: 8, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return  CGSize(width: __kWidth, height: headerExtensionArray.contains(HeaderExtensionType.textView) ? 155 + MarginsWidth + 88 + MarginsWidth : 155 )
    }
    
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    //        return CGSize(width: cellContentSize, height: 8 + 14 + 8)
    //    }
    
}

extension NewAlbumViewController :PhotoRootViewControllerDelegate{
    func selectPhotoComplete(assets: Array<WSAsset>) {
        self.photoCollectionView.performBatchUpdates({ [weak self] in
           let resultsSize = self?.dataSource.count
            self?.dataSource.append(contentsOf: assets)
           
            self?.dataDic!["photoData"] = self?.dataSource
//            self?.delegate?.updateNewAlbumFinish(data: (self?.dataDic)!)
           var arrayWithIndexPaths = [IndexPath]()
          
            for i in resultsSize!..<resultsSize! + assets.count {
                print(i)
                arrayWithIndexPaths.append(IndexPath(row: i, section: 0))
            }
            self?.photoCollectionView.insertItems(at:arrayWithIndexPaths)
          
        }) { [weak self](finish) in
            if self?.photoCollectionView.indexPathsForVisibleItems != nil{
                self?.photoCollectionView.reloadItems(at: (self?.photoCollectionView.indexPathsForVisibleItems)!)
            }
        }
    }
}
