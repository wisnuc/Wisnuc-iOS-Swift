//
//  PhotoMediaContainerViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/30.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit
import RxSwift

private let reuseIdentifier = "PhotoCell"
private let headerReuseIdentifier = "headView"
private var currentScale:CGFloat = 0
private let keyPath:String = "sliderState"
private let headerHeight:CGFloat = 42

class PhotoMediaContainerViewController: BaseViewController {
    var currentItemSize:CGSize = CGSize.zero
    var isAnimation = false
    var isDecelerating = false
    var showIndicator:Bool = true
    var dispose = DisposeBag()
    var sortedAssetsArray:Array<WSAsset>?
    var isSelectMode = false{
        didSet{
            
        }
    }
    
    var state:PhotoRootViewControllerState?{
        didSet{
            
        }
    }
    
    init(style: NavigationStyle ,state:PhotoRootViewControllerState) {
        super.init(style: style)
        self.setState(state: state)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionViewLayout()
        self.view.addSubview(mediaCollectionView)
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
        initGuestrue()
    }
    
    deinit {
        // Required for pre-iOS 11 devices because we've enabled observesTrackingScrollViewScrollEvents.
        appBar.appBarViewController.headerView.trackingScrollView = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appBar.appBarViewController.headerView.trackingScrollView = mediaCollectionView
        appBar.appBarViewController.headerView.observesTrackingScrollViewScrollEvents = true
        appBar.headerViewController.preferredStatusBarStyle = .default
        appBar.headerViewController.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateIndicatorFrame()
    }
    
    func setState(state:PhotoRootViewControllerState){
        self.state = state
    }
    
    func setCollectionViewLayout() {
        showIndicator = true
        currentScale = 3
       
        self.mediaCollectionView.register(FMHeadView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)
        // Register cell classes
        self.mediaCollectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        if self.forceTouchAvailable(){
            self.registerForPreviewing(with: self as UIViewControllerPreviewingDelegate, sourceView: self.mediaCollectionView)
        }
        self.mediaCollectionView.reloadData()
        if #available(iOS 10.0, *) {
            self.mediaCollectionView.prefetchDataSource = self
            self.mediaCollectionView.isPrefetchingEnabled = true
        }
        if showIndicator{
            initIndicator()
        }
    }
    
        func getMatchVC(model:WSAsset) -> UIViewController?{
            let arr = self.sortedAssetsArray
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
            let cell:PhotoCollectionViewCell = self.mediaCollectionView.cellForItem(at: (self.mediaCollectionView.indexPathsForSelectedItems?.first)!) as! PhotoCollectionViewCell
            vc.senderViewForAnimation = cell
            vc.scaleImage = cell.image
            return vc
        }
    
    func addNetAssets(assetsArr:Array<NetAsset>) {
        //        DispatchQueue.global(qos: .default).async {
        self.netAssetDataSource = assetsArr
        self.sort(self.merge())
        ActivityIndicator.stopActivityIndicatorAnimation()
    }
    
    func localDataSouceSort() {
        self.sort(self.merge())
        ActivityIndicator.stopActivityIndicatorAnimation()
    }
    
    func initGuestrue(){
        //增加捏合手势
        let  pin = UIPinchGestureRecognizer.init(target: self, action: #selector(handlePinch(_ :)))
        self.mediaCollectionView.addGestureRecognizer(pin)
    }
    
    func updateIndicatorFrame() {
        if self.mediaCollectionView.indicator != nil {
            self.mediaCollectionView.indicator.frame = CGRect(x: self.mediaCollectionView.indicator.left, y: self.mediaCollectionView.indicator.top, width: 1, height: self.mediaCollectionView.height)
        }
    }
    
    func initIndicator() {
        self.mediaCollectionView.registerILSIndicator()
        if self.mediaCollectionView.indicator == nil {
            return
        }
        
        self.mediaCollectionView.indicator.slider.rx.observe(String.self, keyPath)
            .subscribe(onNext: { [weak self] (newValue) in
                if (self?.showIndicator)! {
                    if (self?.mediaCollectionView.indicator.slider.sliderState == UIControlState.normal && (self?.mediaCollectionView.indicator.transform)!.isIdentity) {
                        self?.isDecelerating = false
                        DispatchQueue.global(qos: .default).asyncAfter(deadline: DispatchTime.now() + 1.5) {
                            if !(self?.isDecelerating)!{
                                self?.isAnimation = false
                                DispatchQueue.main.async {
                                    UIView.animate(withDuration: 0.5, animations: {
                                        self?.mediaCollectionView.indicator.transform = CGAffineTransform(translationX: 40, y: 0)
                                    }, completion: { (finished) in
                                        self?.isAnimation = false
                                        self?.isDecelerating = false
                                    })
                                }
                            }
                        }
                    }else{
                        self?.isDecelerating = true
                    }
                }
            })
            .disposed(by: dispose)
        self.mediaCollectionView.indicator.frame = CGRect(x: self.mediaCollectionView.indicator.frame.origin.x, y:  self.mediaCollectionView.indicator.frame.origin.y, width: 1, height: self.mediaCollectionView.height - CGFloat(2 * kILSDefaultSliderMargin))
    }
    
    func sort(_ assetsArray:Array<WSAsset>){
        autoreleasepool {
            var array:Array<WSAsset>  = Array.init()
            array.append(contentsOf: assetsArray)
            array.sort { (item1, item2) -> Bool in
                let t1 = item1.createDate ?? Date.distantPast
                let t2 = item2.createDate ?? Date.distantPast
                return t1 > t2
            }
            sortedAssetsArray = array
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
            self.dataSource =  self.assetDataSources
            self.mediaCollectionView.reloadData()
        }
    }
    
    func merge()->Array<WSAsset> {
        let localHashs = NSMutableArray.init(capacity: 0)
        for asset in self.localAssetDataSources {
            if !isNilString(asset.digest){
                localHashs.add(asset.digest!)
            }
        }
        
        let netTmpArr = NSMutableArray.init(capacity: 0)
        for asset in self.netAssetDataSource {
            if asset.fmhash != nil {
                if !localHashs.contains(asset.fmhash!){
                    netTmpArr.add(asset)
                }
            }
        }
        
        let mergedAssets =  NSMutableArray.init(array: self.localAssetDataSources)
        mergedAssets.addObjects(from: netTmpArr as! [Any])
        return mergedAssets as! Array<WSAsset>
    }
    
    //捏合响应
    @objc func handlePinch(_ pin:UIPinchGestureRecognizer){
        if  pin.state == UIGestureRecognizerState.began {
            let isSmall = pin.scale > 1.0
            self.changeFlowLayout(isSmall:!isSmall)
            self.mediaCollectionView.reloadData()
        }
    }
    
    func changeFlowLayout(isSmall:Bool){
        if ((!isSmall && currentScale == 1) || (isSmall && currentScale == 6)){
            return
        }
        
        let layout = self.mediaCollectionView.collectionViewLayout as! TYDecorationSectionLayout
        
        layout.sectionHeadersPinToVisibleBounds = false
        currentScale = isSmall ? currentScale + 1 : currentScale - 1;
        
        layout.itemSize = CGSize(width: (__kWidth - 2*(currentScale-1))/currentScale, height: (__kWidth - 2*(currentScale-1))/currentScale)
        currentItemSize = layout.itemSize
        self.mediaCollectionView.setCollectionViewLayout(layout, animated: true)
        
        self.mediaCollectionView.reloadData()
    }
    
    
    lazy var mediaCollectionView: UICollectionView = {
        let collectionViewLayout = TYDecorationSectionLayout.init()
        collectionViewLayout.alternateDecorationViews = true
        collectionViewLayout.decorationViewOfKinds = ["FMHeadView"]
        collectionViewLayout.scrollDirection = UICollectionViewScrollDirection.vertical
        let collectionView = UICollectionView.init(frame: CGRect(x: 0, y: 0, width: __kWidth, height: __kHeight) ,collectionViewLayout:collectionViewLayout)
        collectionView.backgroundColor = UIColor.white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    lazy var choosePhotos:Array<WSAsset> = {
        let array = Array<WSAsset>.init()
        return array
    }()
    
    lazy var chooseSection: Array<IndexPath> = {
        let array = Array<IndexPath>.init()
        return array
    }()
    
    lazy var localAssetDataSources: Array<WSAsset> = {
        let array:Array<WSAsset> = Array.init()
        return array
    }()
    
    lazy var netAssetDataSource: Array<NetAsset> = {
        let array:Array<NetAsset> = Array.init()
        return array
    }()
    
    lazy var assetDataSources: Array<Array<WSAsset>> = {
        let array:Array<Array<WSAsset>> = Array.init()
        return array
    }()
    
    lazy var dataSource:Array<Array<WSAsset>>? = Array.init()
}

extension PhotoMediaContainerViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (self.dataSource?.count)!
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.dataSource?[section].count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:PhotoCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
        let model = self.dataSource![indexPath.section][indexPath.row]
        weak var weakCell = cell
        cell.selectedBlock = { [weak self] (selected) in
            if !(self?.isSelectMode)! { return}
            var needReload = false
            if selected {
                self?.choosePhotos.append(model)
                let dataCollect = (self?.dataSource?[indexPath.section])!.filter { value in
                    (self?.choosePhotos.contains(value))!
                }
                if dataCollect.count == 0 {
                    self?.chooseSection.append(IndexPath.init(row: 0, section: indexPath.section))
                }
                
                needReload = dataCollect.count == 0 ? false : true
                
            }else{
                if let index = self?.choosePhotos.index(of: model) {
                    self?.choosePhotos.remove(at: index)
                }
                let indexP = IndexPath.init(row: 0, section: indexPath.section)
                if (self?.chooseSection.contains(indexP))!{
                    if let index = self?.chooseSection.index(of: indexP) {
                        self?.chooseSection.remove(at: index)
                    }
                }
                needReload = true
            }
            let header = self?.mediaCollectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at:IndexPath.init(item: 0, section: indexPath.section))
            if(needReload){
                self?.mediaCollectionView.reloadItems(at: [indexPath])
                if header != nil{
                    (header as! FMHeadView).isChoose =  (self?.choosePhotos.contains(array:(self?.dataSource![indexPath.section])!))!
                }
            }
            if self?.state == .normal{
                if self?.choosePhotos.count == 0{
                    self?.isSelectMode = false
                    let headers = self?.mediaCollectionView.visibleSupplementaryViews(ofKind: UICollectionElementKindSectionHeader)
                    if let headers = headers {
                        for header in headers {
                            (header as! FMHeadView).isChoose = false
                            (header as! FMHeadView).isSelectMode = (self?.isSelectMode)!
                            
                        }
                    }

                    weakCell?.isSelectMode = self?.isSelectMode
                    if let cellsIndexPath = self?.mediaCollectionView.indexPathsForVisibleItems{
                        self?.mediaCollectionView.reloadItems(at: cellsIndexPath)
                    }
                }
            }
        }
        
        cell.longPressBlock = { [weak self] in
            if (self?.isSelectMode ?? false) { return}
            self?.isSelectMode = true
            self?.choosePhotos.append(model)
            let dataCollect = (self?.dataSource![indexPath.section])!.filter { value in
                (self?.choosePhotos.contains(value))!
            }
            if dataCollect.count == 0 {
                self?.chooseSection.append(IndexPath.init(row: 0, section: indexPath.section))
            }
            var indexPaths =  self?.mediaCollectionView.indexPathsForVisibleItems
            if indexPaths != nil {
                indexPaths = indexPaths?.filter{$0 != indexPath}
                DispatchQueue.global(qos: .default).async {
                    for value in indexPaths!{
                        DispatchQueue.main.async {
                            let relaodCell:PhotoCollectionViewCell = collectionView.cellForItem(at: value) as! PhotoCollectionViewCell
                            relaodCell.isSelectMode = self?.isSelectMode
                        }
                    }
                }
            }
            self?.mediaCollectionView.reloadItems(at: [indexPath])
            let headers = self?.mediaCollectionView.visibleSupplementaryViews(ofKind: UICollectionElementKindSectionHeader)
            if let headers = headers {
                for header in headers {
                    (header as! FMHeadView).isSelectMode = (self?.isSelectMode)!
                }
            }
            
            let nowHeader = self?.mediaCollectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at:IndexPath.init(item: 0, section: indexPath.section))
            if nowHeader != nil {
                (nowHeader as! FMHeadView).isChoose =  (self?.choosePhotos.contains(array:(self?.dataSource![indexPath.section])!))!
            }
        }
        
        if (self.mediaCollectionView.indicator != nil) {
            self.mediaCollectionView.indicator.slider.timeLabel.text = PhotoTools.getMouthDateString(date: model.createDate!)
        }
        
        cell.setImagView(indexPath:indexPath)
        cell.setSelectButton(indexPath: indexPath)
        cell.isSelectMode = self.isSelectMode
        cell.setSelectAnimation(isSelect: self.isSelectMode ? self.choosePhotos.contains(model) : false, animation: false)
        cell.model = model
        let tagString = "\(indexPath.section)\(indexPath.item)"
        cell.tag = (NSNumber.init(string: tagString)?.intValue)!
        return cell
    }
    
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headView:FMHeadView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! FMHeadView
        
        headView.headTitle =  PhotoTools.getDateString(date: dataSource![indexPath.section][indexPath.row].createDate!)
        headView.fmIndexPath = indexPath
        headView.isSelectMode = isSelectMode
        headView.isChoose =  self.choosePhotos.contains(array:self.dataSource![indexPath.section])
        headView.fmDelegate = self
        return headView
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isSelectMode {
            let cell:PhotoCollectionViewCell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
            cell.btnSelectClick(nil)
        }else{
            let model = self.dataSource![indexPath.section][indexPath.row]
            model.indexPath = IndexPath(row: indexPath.row, section: indexPath.section)
            let vc = self.getMatchVC(model: model)
            if vc != nil {
                self.present(vc!, animated: true) {
                }
            }
        }
    }
}

extension PhotoMediaContainerViewController:UICollectionViewDataSourcePrefetching{
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let cell = collectionView.cellForItem(at: indexPath)
            if cell != nil{
                let photoCell:PhotoCollectionViewCell =  cell as! PhotoCollectionViewCell
                let model = self.dataSource![indexPath.section][indexPath.row]
                if (self.mediaCollectionView.indicator != nil) {
                    self.mediaCollectionView.indicator.slider.timeLabel.text = PhotoTools.getMouthDateString(date: model.createDate!)
                }
                photoCell.isSelectMode = self.isSelectMode
                photoCell.setSelectAnimation(isSelect: self.isSelectMode ? self.choosePhotos.contains(model) : false, animation: false)
                photoCell.model = model
                let size = CGSize.init(width: photoCell.width * 1.7 , height: photoCell.height * 1.7)
                if model.asset != nil{
                    DispatchQueue.global(qos: .default).async {
                        photoCell.imageRequestID = PHPhotoLibrary.requestImage(for: model.asset!, size: size, completion: { [weak photoCell] (image, info) in
                            if (photoCell?.identifier == model.asset?.localIdentifier) {
                                DispatchQueue.main.async {
                                    //                                   photoCell?.imageView.layer.contents = nil
                                }
                            }
                            if !(info![PHImageResultIsDegradedKey] as! Bool) {
                                photoCell?.imageRequestID = -1
                            }
                        })
                        
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let cell = collectionView.cellForItem(at: indexPath)
            if cell != nil{
                let photoCell:PhotoCollectionViewCell =  cell as! PhotoCollectionViewCell
                photoCell.imageView?.layer.contents  = nil
            }
        }
    }
}

extension PhotoMediaContainerViewController:FMHeadViewDelegate{
    func fmHeadView(_ headView: FMHeadView!, isChooseBtn isChoose: Bool) {
        if isChoose {
            self.chooseSection.append(headView.fmIndexPath)
            self.choosePhotos.append(contentsOf: self.dataSource![headView.fmIndexPath.section])
        }else{
            if let idx = self.chooseSection.index(of: headView.fmIndexPath){
                self.chooseSection.remove(at: idx)
            }
            self.choosePhotos  = self.choosePhotos.filter { value in
                !self.dataSource![headView.fmIndexPath.section].contains(value)
            }
        }
        
        if self.choosePhotos.count == 0{
            self.isSelectMode = false
            let headers = self.mediaCollectionView.visibleSupplementaryViews(ofKind: UICollectionElementKindSectionHeader)
            for header in headers {
                (header as! FMHeadView).isSelectMode = self.isSelectMode
            }
            //            self leftBtnClick:_leftBtn];
        }
        //        _countLb.text = [NSString stringWithFormat:WBLocalizedString(@"select_count", nil),(unsigned long)self.choosePhotos.count];
        let indexSet = IndexSet.init(integer: headView.fmIndexPath.section)
        mediaCollectionView.performBatchUpdates({
            self.mediaCollectionView.reloadSections(indexSet)
        }, completion: nil)
    }
}


extension PhotoMediaContainerViewController :UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = (__kWidth - 2 * (currentScale - 1))/currentScale
        let itemSize = CGSize(width: frame, height: frame)
        currentItemSize = itemSize
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let size = CGSize(width: __kWidth, height: headerHeight)
        return size
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
}

//3D Touch delegate method
extension PhotoMediaContainerViewController : UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let indexPath = self.mediaCollectionView.indexPathForItem(at: location)
        if (indexPath == nil) {
            return nil
        }
        let cell:PhotoCollectionViewCell = self.mediaCollectionView.cellForItem(at: indexPath!) as! PhotoCollectionViewCell
        
        //设置突出区域
        previewingContext.sourceRect = cell.frame
        let vc = WSForceTouchPreviewViewController.init()
        let model = self.dataSource![(indexPath?.section)!][(indexPath?.row)!]
        vc.model = model
        vc.placeHolder = cell.imageView?.layer.contents as? UIImage
        vc.allowSelectGif = true
        vc.allowSelectLivePhoto = true
        vc.preferredContentSize = PhotoTools.getSize(model:model)
        
        return vc;
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        if isSelectMode{
            return
        }
        let model = (viewControllerToCommit as! WSForceTouchPreviewViewController).model
        let vc = self.getMatchVC(model: model!)
        if vc != nil {
            self.present(vc!, animated: true) {

            }
        }
    }
}

extension PhotoMediaContainerViewController : WSShowBigImgViewControllerDelegate {
    func photoBrowser(browser: WSShowBigimgViewController, indexPath: IndexPath) {
        self.mediaCollectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredVertically, animated: false)
        self.mediaCollectionView.layoutIfNeeded()
    }
    
    func photoBrowser(browser: WSShowBigimgViewController, willDismiss indexPath: IndexPath) -> UIView? {
        let cell = self.mediaCollectionView.cellForItem(at: indexPath)
        return cell
    }
}
