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


let ChangePageDalay = 8
let Distance = 2
let NN:CGFloat = 3

class NewAlbumViewController: BaseViewController {
    private let reuseIdentifier = "reuseIdentifierCell"
    private let reuseHeaderIdentifier = "reuseIdentifierHeader"
    private let cellContentSizeWidth = (__kWidth - 4)/2
    private let cellContentSizeHeight = (__kWidth - 4)/2
    private let estimateDefaultHeight:CGFloat = 100
    private var idealHeight:CGFloat = 0.0
    
    var dataDic:Dictionary<String,Any>?
    private var dataSource:Array<WSAsset>?{
        willSet{
            print("😁🌶")
        }
        didSet{
           print("😁 set")
        }
    }
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
        var array = Array<WSAsset>.init()
        
        if photos != nil{
            for (i,value) in photos!.enumerated(){
                value.indexPath = IndexPath(item: i, section: 0)
                array.append(value)
            }
            let copyArray = NSArray.init(array: array, copyItems: true)
            if let allAssetArray = copyArray as? Array<WSAsset>{
                self.dataSource = allAssetArray
            }
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
    
    //图片算法
    private func CGSizeResizeToHeight(size: CGSize, height: CGFloat) -> CGSize {
        var size = size
        size.width *= height / size.height
        size.height = height
        return size
    }

    func getMatchVC(model:WSAsset) -> UIViewController?{
        let arr = self.dataSource
        let index = arr?.index(of: model)
        if index != nil {
            return self.getBigImageVC(data: arr!, index:index!)
        }else{
            return nil
        }
        
    }
    
    func getBigImageVC(data:Array<WSAsset>,index:Int) -> UIViewController{
        let vc = WSShowBigimgViewController.init()
        vc.delegate = self
        vc.models = data
        vc.selectIndex = index
        let cell:NewPhotoAlbumCollectionViewCell = self.photoCollectionView.cellForItem(at: (self.photoCollectionView.indexPathsForSelectedItems?.first)!) as! NewPhotoAlbumCollectionViewCell
        vc.senderViewForAnimation = cell
        vc.scaleImage = cell.image
        return vc
    }
    
    @objc func finishEditing(_ sender:UIBarButtonItem){
        self.state = .normal
        var dic:Dictionary<String,Any> = Dictionary.init()
        dic["name"] = albumTitleText ?? LocalizedString(forKey: "未命名相册")
        dic["describe"] = albumDescribeText ?? ""
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
        let newAlbumMoreBottomSheetVC = NewAlbumMoreBottomSheetTableViewController.init(style: UITableViewStyle.plain)
        newAlbumMoreBottomSheetVC.delegate = self
        let bottomSheet = AppBottomSheetController.init(contentViewController: newAlbumMoreBottomSheetVC)
        bottomSheet.trackingScrollView = newAlbumMoreBottomSheetVC.tableView
        self.present(bottomSheet, animated: true, completion: {
        })
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
        if let header = self.photoCollectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: IndexPath.init(item: 0, section: 0)){
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
    }
    
    lazy var photoCollectionView: UICollectionView = { [weak self] in
        let collectionViewLayout = UICollectionViewFlowLayout.init()
        collectionViewLayout.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2)
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
        return self.dataSource?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:NewPhotoAlbumCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! NewPhotoAlbumCollectionViewCell
        let asset = dataSource?[indexPath.item]
        cell.model = asset
        cell.setImagView(indexPath:indexPath)
        cell.setDeleteButton(indexPath: indexPath)
        cell.setEditingAnimation(isEditing: self.state == .editing ? true : false, animation: true)
        cell.deleteCallbck = { [weak self] (cellIndexPath) in
            self?.photoCollectionView.performBatchUpdates({
                if cellIndexPath.item < (self?.dataSource?.count)!{
                    self?.dataSource?.remove(at: cellIndexPath.item)
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
        if self.state != .editing{
            let model = self.dataSource?[indexPath.item]
            let vc = self.getMatchVC(model: model!)
            if vc != nil {
                self.present(vc!, animated: true) {
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        let asset = dataSource[indexPath.row]
//        asset.indexPath = indexPath
//         dataSource[indexPath.row] = asset
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
        
        let N = Int(dataSource?.count ?? 0)
        var newFrames = [CGRect](repeating: CGRect.zero, count: N)
        
        
        idealHeight = max(collectionView.frame.size.height, collectionView.frame.size.width) / NN
        var seq = [Float](repeating: 0.0, count: N)
        
        var totalWidth: Float = 0

        for i in 0..<(dataSource?.count ?? 0) {
            let asset = dataSource![i]
            let indexPath = IndexPath(item: i, section: 0)
            asset.indexPath = indexPath
            var imageSize = CGSize(width: CGFloat(asset.asset?.pixelWidth ?? Int(cellContentSizeWidth)), height: CGFloat(asset.asset?.pixelHeight ?? Int(cellContentSizeWidth)))
            
            if asset is NetAsset{
                let  netAsset = asset as! NetAsset
                imageSize =  CGSize(width: CGFloat(netAsset.metadata?.w ?? Float(cellContentSizeWidth)), height:   CGFloat(netAsset.metadata?.h ?? Float(cellContentSizeWidth)))
            }
            let newSize: CGSize = CGSizeResizeToHeight(size: imageSize, height: idealHeight)
            newFrames[i] = CGRect.init(origin: CGPoint(x: 0, y: 0), size: newSize)
            seq[i] = Float(newSize.width)
            totalWidth += seq[i]
        }
        
        let K = Int(roundf(totalWidth / Float(collectionView.frame.size.width)))
        
        var M = Array.init(repeating: Array<Float>.init(repeating: 0, count: K), count: N)
        var D = Array.init(repeating: Array<Float>.init(repeating: 0, count: K), count: N) 
        
        for i in 0..<N {
            for j in 0..<K {
                D[i][j] = 0
            }
        }
        for i in 0..<K {
            M[0][i] = seq[0]
        }
        for i in 0..<N {
            M[i][0] = seq[i] + (i == 0 ? 0 : M[i - 1][0] )
        }
        var cost: Float = 0.0
        for i in 1..<N {
            for j in 1..<K {
                M[i][j] = Float(INT_MAX)
                for k in 0..<i {
                    cost = max(M[k][j - 1], M[i][0] - M[k][0])
                    if M[i][j] > cost {
                        M[i][j] = cost
                        D[i][j] = Float(k)
                    }
                }
            }
        }
        
        /**
         Ranges & Resizes
         */
        var k1: Int = K - 1
        var n1: Int = N - 1
        var ranges = Array.init(repeating: Array<Int>.init(repeating: 0, count: 2), count: N)
        while k1 >= 0 {
            ranges[k1][0] = Int(D[n1][k1] + 1)
            ranges[k1][1] = n1
            n1 = Int(D[n1][k1])
            k1 -= 1
        }
        ranges[0][0] = 0
        
        let cellDistance = CGFloat(Distance)
        var heightOffset: CGFloat = cellDistance
        var widthOffset: CGFloat = 0.0
        var frameWidth: CGFloat = 0.0
        
        for i in 0..<K {
            var rowWidth: CGFloat = 0
            frameWidth = collectionView.frame.size.width - CGFloat(((ranges[i][1] - ranges[i][0]) + 2)) * CGFloat(cellDistance)
            for j in ranges[i][0]...ranges[i][1] {
                rowWidth += newFrames[j].size.width
            }
            let ratio: CGFloat = frameWidth / rowWidth
            widthOffset = 0
            for j in ranges[i][0]...ranges[i][1] {
                newFrames[j].size.width *= ratio
                newFrames[j].size.height *= ratio
                newFrames[j].origin.x = widthOffset + CGFloat(j - ranges[i][0] + 1) * cellDistance
                newFrames[j].origin.y = heightOffset
                widthOffset += newFrames[j].size.width
            }
            heightOffset += newFrames[ranges[i][0]].size.height + cellDistance
        }
        
        let frame: CGRect = newFrames[indexPath.item]
        return CGSize(width: frame.size.width - 1, height:  frame.size.height - 1)
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return   UIEdgeInsets.init(top: 8, left: 0, bottom: 0, right: 0)
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return  CGSize(width: __kWidth, height: headerExtensionArray.contains(HeaderExtensionType.textView) ? 165 + MarginsWidth + 88 + MarginsWidth : 165 )
    }
    
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    //        return CGSize(width: cellContentSize, height: 8 + 14 + 8)
    //    }
    
}

extension NewAlbumViewController :PhotoRootViewControllerDelegate{
    func selectPhotoComplete(assets: Array<WSAsset>) {
        self.photoCollectionView.performBatchUpdates({ [weak self] in
            let resultsSize = self?.dataSource?.count
            let copyArray = NSArray.init(array: assets, copyItems: true)
            if let allAssetArray = copyArray as? Array<WSAsset>{
                 self?.dataSource?.append(contentsOf: allAssetArray)
            }
           
           
//            self?.dataDic!["photoData"] = self?.dataSource
//            self?.delegate?.updateNewAlbumFinish(data: (self?.dataDic)!)
           var arrayWithIndexPaths = [IndexPath]()
          
            for i in resultsSize!..<resultsSize! + assets.count {
                print(i)
                let indexPath = IndexPath(item: i, section: 0)
                arrayWithIndexPaths.append(indexPath)
//                let asset = self?.dataSource?[i]
//                asset?.indexPath = indexPath
//                if let asset = asset{
//                    self?.dataSource![i] = asset
//                }
            }
            self?.photoCollectionView.insertItems(at:arrayWithIndexPaths)
          
        }) { [weak self](finish) in
            if self?.photoCollectionView.indexPathsForVisibleItems != nil{
                self?.photoCollectionView.reloadItems(at: (self?.photoCollectionView.indexPathsForVisibleItems)!)
            }
        }
    }
}

extension NewAlbumViewController:WSShowBigImgViewControllerDelegate{
    func photoBrowser(browser: WSShowBigimgViewController, indexPath: IndexPath) {
        self.photoCollectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredVertically, animated: false)
        self.photoCollectionView.layoutIfNeeded()
    }
    
    func photoBrowser(browser: WSShowBigimgViewController, willDismiss indexPath: IndexPath) -> UIView? {
        let cell = self.photoCollectionView.cellForItem(at: indexPath)
        return cell
    }
}

extension NewAlbumViewController:NewAlbumMoreBottomSheetTableViewControllerDelegate{
    func newAlbumMoreBottomSheetTableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            break
        case 1:
           self.state = .editing
        case 2:
            break
        case 3:
            break
        default:
            break
        }
    }
}
