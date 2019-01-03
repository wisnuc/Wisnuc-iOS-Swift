//
//  PhotoCollectionViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/7/5.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialCollections
import RxSwift
import Kingfisher

private let reuseIdentifier = "PhotoCell"
private let headerReuseIdentifier = "headView"
private var currentScale:CGFloat = 0
private let keyPath:String = "sliderState"
private let headerHeight:CGFloat = 42
private let kthumbnilNormalSize:CGFloat = 186
private let kthumbnilSmallSize:CGFloat = 64

@objc protocol PhotoCollectionViewControllerDelegate{
    func collectionView(_ collectionView: UICollectionView, isSelectMode:Bool)
    func collectionView(_ collectionView: UICollectionView, selectArray:Array<WSAsset>)
}

class PhotoCollectionViewController: UICollectionViewController {
    weak var delegate:PhotoCollectionViewControllerDelegate?
    var isSelectMode:Bool?{
        didSet{
            if  isSelectMode! {
                selectModeAction()
            }else{
                unselectModeAction()
            }
        }
    }
    lazy var imageRequestIDDataSources:Array<PHImageRequestID> = Array.init()
    lazy var imageDownloadTasks:Array<RetrieveImageDownloadTask> = Array.init()
    lazy var imageSDDownloadTasks:Array<SDWebImageDownloadToken> = Array.init()
    lazy var imageDiskTasks:Array<RetrieveImageDiskTask> = Array.init()
    var drive:String?
    var currentItemSize:CGSize = CGSize.zero
    var showIndicator:Bool = true
    var sortedAssetsBackupArray:Array<WSAsset>?
    var dispose = DisposeBag()
    var pollingCallback:((_ stop:Bool)->())?
    var state:PhotoRootViewControllerState?{
        didSet{
            
        }
    }
    var timeViewArray:[UIView]?
    var dataSource:Array<Array<WSAsset>>?{
        didSet{
            mainThreadSafe {
                if let isSelectMode = self.isSelectMode{
                    if !isSelectMode{
                        self.dataSourceHasValue()
                    }
                }
            }
        }
    }
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        clearChache()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
       super.viewDidLoad()
       imageDownloadTasks.removeAll()
        imageDiskTasks.removeAll()
      dataSource = Array.init()
      initCollectionViewLayout()
      initGuestrue()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        clearChache()
    }
    
    //清除缓存
    func clearChache(){
        let cache = KingfisherManager.shared.cache
        cache.clearMemoryCache()
        for imageRequestID in imageRequestIDDataSources{
            PHCachingImageManager.default().cancelImageRequest(imageRequestID)
        }
        imageRequestIDDataSources.removeAll()
        for task in imageDownloadTasks{
            task.cancel()
        }
        for task in imageDiskTasks{
            task.cancel()
        }
        
        for task in imageDownloadTasks{
            task.cancel()
        }
      
        imageDownloadTasks.removeAll()
        imageDiskTasks.removeAll()
        ImageCache.default.clearMemoryCache()
        YYImageCache.shared().memoryCache.removeAllObjects()
        imageDownloadTasks.removeAll()
    }
    
    //时间轴
    func dataSourceHasValue(){
        if  let array = self.timeViewArray{
            if array.count != 0{
                for view in array{
                    view.removeFromSuperview()
                }
                timeViewArray?.removeAll()
            }
        }
        timeViewArray = Array.init()
        if sortedAssetsBackupArray == nil {
            return
        }
        let copyArray = NSArray.init(array: sortedAssetsBackupArray!, copyItems: true)
        
        if let allAssetArray = copyArray as? Array<WSAsset>{
            let yearArray = sort(allAssetArray)
            var originMargin:CGFloat = 0
            for (i,value) in yearArray.enumerated(){
                
                let photos = value
                let yearsAsset = dataSource?.filter({Calendar.current.isDate($0.first?.createDate ?? Date.distantPast, equalTo:  photos.first?.createDate ?? Date.distantPast, toGranularity: Calendar.Component.year)})
                if let yearsAsset = yearsAsset{
                    var sum = 0
                    for (_,assets) in yearsAsset.enumerated(){
                        sum += assets.count
                    }
                    var photoScale:CGFloat = 1
                    if sum > 3{
                        photoScale = CGFloat(ceilf(Float(sum)/Float(currentScale)))
                    }
                    
                    if self.currentItemSize.height == 0 {
                        self.currentItemSize = CGSize(width: (__kWidth - 2 * (currentScale - 1))/currentScale, height: (__kWidth - 2 * (currentScale - 1))/currentScale)
                    }
                    if let height = self.collectionView?.contentSize.height {
                        if height>0 {
                            let margin = ((photoScale * self.currentItemSize.height) + CGFloat(yearsAsset.count*Int(headerHeight)) - (photoScale*2) * 2 )/(height - MDCAppNavigationBarHeight) * (__kHeight - MDCAppNavigationBarHeight)
                            let timelineView = UIView.init(frame: CGRect(x: __kWidth - 35 - 58 - 40 , y: MDCAppNavigationBarHeight + originMargin, width: 58, height: 24))
                            let label = UILabel.init(frame: timelineView.bounds)
                            label.font = UIFont.boldSystemFont(ofSize: 12)
                            label.textColor = LightGrayColor
                            label.textAlignment = .center
                            label.layer.cornerRadius = 24/2
                            if let date = value.first?.createDate{
                                label.text = "\(TimeTools.getYear(date:date))年"
                            }
                            timelineView.addSubview(label)
                            timelineView.backgroundColor = .white
                            timelineView.alpha = 0.87
                            timelineView.layer.cornerRadius = 24/2
                            timelineView.isHidden = true
                            if i == 0 || value == yearArray.last{
                                self.view.addSubview(timelineView)
                                self.timeViewArray?.append(timelineView)
                            }else{
                                if yearsAsset.count > 0{
                                    if photoScale >= CGFloat(floorf(Float(allAssetArray.count/yearsAsset.count))){
                                        self.view.addSubview(timelineView)
                                        self.timeViewArray?.append(timelineView)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //排序
    func sort(_ assetsArray:Array<WSAsset>) -> Array<Array<WSAsset>>{
        var finishArray:Array<Array<WSAsset>> = Array.init()
        autoreleasepool {
            var array:Array<WSAsset>  = Array.init()
            array.append(contentsOf: assetsArray)
            array.sort { (item1, item2) -> Bool in
                let t1 = item1.createDate ?? Date.distantPast
                let t2 = item2.createDate ?? Date.distantPast
                return t1 > t2
            }
            
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
                    finishArray = photoGroupArray as! Array<Array<WSAsset>>
                }
                var photoDateGroup2:NSMutableArray? = photoDateGroup1 //最近的一组
                
                for i in 1..<array.count {
                    let photo1 =  array[i]
                    let photo2 = array[i-1]
                  
                    if   Calendar.current.isDate(photo1.createDate ?? Date.distantPast, equalTo:  photo2.createDate ?? Date.distantPast, toGranularity: Calendar.Component.year){
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
            finishArray =  photoGroupArray as! Array<Array<WSAsset>>
        }
        return finishArray
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateIndicatorFrame()
    }
    
    func initGuestrue(){
        //增加捏合手势
        let  pin = UIPinchGestureRecognizer.init(target: self, action: #selector(handlePinch(_ :)))
        self.collectionView?.addGestureRecognizer(pin)
    }

    func selectModeAction(){
        if let delegateOK = self.delegate{
            delegateOK.collectionView(self.collectionView!, isSelectMode: self.isSelectMode!)
        }
    }
    
    func unselectModeAction(){
        if let delegateOK = self.delegate{
            delegateOK.collectionView(self.collectionView!, isSelectMode: self.isSelectMode!)
        }
    }
  
 //捏合响应
    @objc func handlePinch(_ pin:UIPinchGestureRecognizer){
    if  pin.state == UIGestureRecognizerState.began {
        let isSmall = pin.scale > 1.0
        self.changeFlowLayout(isSmall:!isSmall)
        self.collectionView?.reloadData()
    }
}

    func changeFlowLayout(isSmall:Bool){
        if ((!isSmall && currentScale == 1) || (isSmall && currentScale == 6)){
            return
        }
        
        let layout = self.collectionView?.collectionViewLayout as! TYDecorationSectionLayout
        
        layout.sectionHeadersPinToVisibleBounds = false
        currentScale = isSmall ? currentScale + 1 : currentScale - 1;
        
        layout.itemSize = CGSize(width: (__kWidth - 2*(currentScale-1))/currentScale, height: (__kWidth - 2*(currentScale-1))/currentScale)
        currentItemSize = layout.itemSize
        self.collectionView?.setCollectionViewLayout(layout, animated: true)
        
        self.collectionView?.reloadData()
    }
    
    func initCollectionViewLayout() {
        showIndicator = true
        currentScale = 3
        let fmCollectionViewLayout = TYDecorationSectionLayout.init()
        fmCollectionViewLayout.alternateDecorationViews = true
        fmCollectionViewLayout.decorationViewOfKinds = ["FMHeadView"]
        fmCollectionViewLayout.scrollDirection = UICollectionViewScrollDirection.vertical
        self.collectionView?.collectionViewLayout = fmCollectionViewLayout
        self.collectionView?.backgroundColor = UIColor.white
        self.collectionView?.showsVerticalScrollIndicator = false
        self.collectionView?.showsHorizontalScrollIndicator = false
        self.collectionView?.register(FMHeadView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)
        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = true
        // Register cell classes
        self.collectionView!.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        if self.forceTouchAvailable(){
            self.registerForPreviewing(with: self as UIViewControllerPreviewingDelegate, sourceView: self.collectionView!)
        }
        self.collectionView?.reloadData()
        
        if #available(iOS 10.0, *) {
            self.collectionView?.prefetchDataSource = self
             self.collectionView?.isPrefetchingEnabled = true
        } else {

        }
        
        if showIndicator{
            initIndicator()
        }
    }
    
    func updateIndicatorFrame() {
        if self.collectionView?.indicator != nil {
            self.collectionView?.indicator.frame = CGRect(x: (self.collectionView?.indicator.left)!, y: (self.collectionView?.indicator.top)!, width: 1, height: (self.collectionView?.height)!)
        }
    }
    
//    侧面滑动指示器
    func initIndicator() {
        self.collectionView?.registerILSIndicator()
        if self.collectionView?.indicator == nil {
            return
        }

        self.collectionView?.indicator.slider.rx.observe(String.self, keyPath)
            .subscribe(onNext: { [weak self] (newValue) in
                if (self?.showIndicator)! {
                    if (self?.collectionView?.indicator.slider.sliderState == UIControlState.normal && (self?.collectionView?.indicator.transform)!.isIdentity) {
                        self?.isDecelerating = false
                        DispatchQueue.global(qos: .default).asyncAfter(deadline: DispatchTime.now() + 1.5) {
                            if !(self?.isDecelerating)!{
                                self?.isAnimation = false
                                DispatchQueue.main.async {
                                    UIView.animate(withDuration: 0.5, animations: {
                                        self?.collectionView?.indicator.transform = CGAffineTransform(translationX: 40, y: 0)
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
        self.collectionView?.indicator.frame = CGRect(x: self.collectionView!.indicator.frame.origin.x, y:  self.collectionView!.indicator.frame.origin.y, width: 1, height: self.collectionView!.height - CGFloat(2 * kILSDefaultSliderMargin))
    }
    
    func getMatchVC(model:WSAsset) -> UIViewController?{
        let arr = self.sortedAssetsBackupArray
        let index = arr?.index(of: model)
        if index != nil {
            return self.getBigImageVC(data: arr!, index:index!)
        }else{
            return nil
        }
    }
    
    //查看大图
    func getBigImageVC(data:Array<WSAsset>,index:Int) -> UIViewController{
        let vc = WSShowBigimgViewController.init()
        vc.drive = self.drive
        vc.delegate = self
        vc.models = data
        vc.selectIndex = index
        let cell:PhotoCollectionViewCell = self.collectionView?.cellForItem(at: (self.collectionView?.indexPathsForSelectedItems?.first)!) as! PhotoCollectionViewCell
        vc.senderViewForAnimation = cell
       
        vc.scaleImage = cell.image
        return vc
    }

    func hiddenIndicator(){
        if self.showIndicator {
            if self.collectionView?.indicator == nil {
                //导航按钮
                self.collectionView?.registerILSIndicator()
                if self.collectionView?.indicator == nil{
                    return
                }
            }
            if (self.collectionView?.indicator.slider.sliderState == UIControlState.normal)  {
                if let isIdentity = self.collectionView?.indicator.transform.isIdentity{
                    if isIdentity{
                        isDecelerating = false
                        DispatchQueue.global(qos: .default).asyncAfter(deadline: DispatchTime.now() + 1.5) {
                            if !self.isDecelerating{
                                self.isAnimation = false
                                DispatchQueue.main.async {
                                    UIView.animate(withDuration: 0.5, animations: {
                                        self.collectionView?.indicator.transform = CGAffineTransform(translationX: 40, y: 0)
                                    }, completion: { (finished) in
                                        self.isAnimation = false
                                        self.isDecelerating = false
                                    })
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func displayTimeViews(){
        if let timeViewArray = self.timeViewArray{
            for timeView in timeViewArray {
                timeView.isHidden = false
            }
        }
       
    }
    
    func hiddenTimeViews(){
        if let timeViewArray = self.timeViewArray{
            for timeView in timeViewArray {
                timeView.isHidden = true
            }
        }
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
    }

    // MARK: UICollectionViewDataSource 

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.dataSource!.count
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.dataSource![section].count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:PhotoCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
        guard let dataSource = self.dataSource else {
            return cell
        }
        if indexPath.section >= dataSource.count{
            return cell
        }
        
        if indexPath.row >= dataSource[indexPath.section].count{
            return cell
        }
         let model = dataSource[indexPath.section][indexPath.row]
        weak var weakCell = cell
        //more（...）
        cell.selectedBlock = { [weak self] (selected) in
            if !(self?.isSelectMode)! { return}
            var needReload = false
            if selected {
                self?.choosePhotos.append(model)
                let dataCollect = (self?.dataSource![indexPath.section])!.filter { value in
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
            let header = self?.collectionView?.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at:IndexPath.init(item: 0, section: indexPath.section))
            if(needReload){
                self?.delegate?.collectionView(collectionView, selectArray: self?.choosePhotos ?? Array.init())
                self?.collectionView?.reloadItems(at: [indexPath])
                if header != nil{
                    (header as! FMHeadView).isChoose =  (self?.choosePhotos.contains(array:(self?.dataSource![indexPath.section])!))!
                }
            }
            if self?.state == .normal{
                if self?.choosePhotos.count == 0{
                    self?.isSelectMode = false
                    let headers = self?.collectionView?.visibleSupplementaryViews(ofKind: UICollectionElementKindSectionHeader)
                    if let headers = headers {
                        for header in headers {
                            (header as! FMHeadView).isChoose = false
                            (header as! FMHeadView).isSelectMode = (self?.isSelectMode)!
                            
                        }
                    }
                    weakCell?.isSelectMode = self?.isSelectMode
                  
                    if let cellsIndexPath = self?.collectionView?.indexPathsForVisibleItems{
                         self?.collectionView?.reloadItems(at: cellsIndexPath)
                    }
                }
            }
        }
        
//      长按
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
            
            
            var indexPaths =  self?.collectionView?.indexPathsForVisibleItems
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
            self?.collectionView?.reloadItems(at: [indexPath])
            let headers = self?.collectionView?.visibleSupplementaryViews(ofKind: UICollectionElementKindSectionHeader)
            if let headers = headers {
                for header in headers {
                    (header as! FMHeadView).isSelectMode = (self?.isSelectMode)!
                }
            }
            
            let nowHeader = self?.collectionView?.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at:IndexPath.init(item: 0, section: indexPath.section))
            if nowHeader != nil {
                (nowHeader as! FMHeadView).isChoose =  (self?.choosePhotos.contains(array:(self?.dataSource![indexPath.section])!))!
            }
            self?.delegate?.collectionView(collectionView, selectArray: self?.choosePhotos ?? Array.init())
        }

        if (self.collectionView!.indicator != nil) {
            self.collectionView?.indicator.slider.timeLabel.text = PhotoTools.getMouthDateString(date: model.createDate!)
        }
        model.cellIndexPath = indexPath
        cell.setImagView(indexPath:indexPath)
        cell.setSelectButton(indexPath: indexPath)
        cell.isSelectMode = self.isSelectMode
        cell.setSelectAnimation(isSelect: self.isSelectMode ?? false ? self.choosePhotos.contains(model) : false, animation: false)
        cell.model = model
        cell.imageView?.layer.contents = nil
        if indexPath == cell.model?.cellIndexPath {
            cell.imageView?.layer.contents = model.image
        }
        let tagString = "\(indexPath.section)\(indexPath.item)"
        cell.tag = (NSNumber.init(string: tagString)?.intValue)!
        self.setCellImage(model: model,cell:cell)
        return cell
    }
    
//  加载缩略图
    func setCellImage(model:WSAsset,cell:PhotoCollectionViewCell){
        let size = self.fetchRequestSize(origin: kthumbnilNormalSize, model: model)
        if cell.indexPath != model.indexPath{
            return
        }
        if model.asset != nil {
            loadLocalImage(cell: cell, model: model,size:size)
        }else if model is NetAsset{
            guard let hash = (model as? NetAsset)?.fmhash else{
                return
            }
            if cell.indexPath != model.indexPath{
                return
            }
            DispatchQueue.global(qos: .userInitiated).async {
                
            }
            if let image = YYImageCache.shared().getImageForKey(hash){
                cell.imageView?.layer.contents = image.cgImage
                self.checkSmallImage(model: model, size: size) { (image) in
                    if cell.indexPath == model.indexPath{
                        cell.imageView?.layer.contents = nil
                        cell.model?.image = image
                        cell.imageView?.layer.contents = image.cgImage
                        cell.image = image
                    }
                }
            }else{
                self.fetchNormalCachePicDispay(cell: cell, model: model, size: size, closure: { (image) in
                    if cell.indexPath == model.indexPath{
                        DispatchQueue.main.async {
                            cell.imageView?.layer.contents = nil
                            cell.model?.image = image
                            cell.imageView?.layer.contents = image.cgImage
                            cell.image = image
                        }
                    }
                })
            }
        }
    }
    

    //本地照片缩略图
    func loadLocalImage(cell:PhotoCollectionViewCell,model:WSAsset,size:CGSize){
        let asset = model.asset
        let contentMode = PHImageContentMode.default
        self.imageManager.startCachingImages(for: [asset!], targetSize: size, contentMode: contentMode, options:self.imageRequestOptions)
        let imageRequestID = self.imageManager.requestImage(for: (asset)!, targetSize: size, contentMode: contentMode, options: self.imageRequestOptions, resultHandler: { (image, info) in
            if cell.indexPath == model.indexPath{
                cell.imageView?.layer.contents = nil
                cell.imageView?.layer.contents = image?.cgImage
                cell.image = image
                cell.model?.image = image
            }
        })
        imageRequestIDDataSources.append(imageRequestID)
    }
    
    //64*64小图
    func checkSmallImage(model:WSAsset,size:CGSize,closure:@escaping (_ image:UIImage)->()){
        guard let hash = (model as? NetAsset)?.fmhash else{
            return
        }
        let queue = DispatchQueue.init(label: "downloadReady", qos: DispatchQoS.default)
        queue.async {
            if let requset = PhotoHelper.requestImageUrl(size: size, hash: hash){
                ImageCache.default.retrieveImage(forKey: requset.absoluteString, options: nil, completionHandler: { (image, type) in
                    if let image = image{
                        return closure(image)
                    }else{
                        let _ = self.fetchSmallPic(model: model, callback: { [weak self] (error, image, url) in
                            if let image = image{
                                let _ = self?.fetchNormalPic(model: model, callback: { (error, image, url) in
                                    if let image = image{
                                        return closure(image)
                                    }
                                })
                                return closure(image)
                            }
                        })
                    }
                })
            }
            
        }
    }
    
    //从缓存中获取64*64小图
    func fetchSmallCachePicDispay(model:WSAsset,callback:@escaping (_ image:UIImage?)->()){
        guard let hash = (model as? NetAsset)?.fmhash else {
           return
        }
        
        let size = self.fetchRequestSize(origin: kthumbnilSmallSize, model: model)
        if let requset = PhotoHelper.requestImageUrl(size: size, hash: hash){
            ImageCache.default.retrieveImage(forKey: requset.absoluteString, options: nil, completionHandler: { (image, type) in
                if let image = image{
                return callback(image)
            }
         })
       }
    }
    
    //从缓存中获取正常（186*186)缩略图
    func fetchNormalCachePicDispay(cell:PhotoCollectionViewCell,model:WSAsset,size:CGSize,closure:@escaping (_ image:UIImage)->()){
        guard let hash = (model as? NetAsset)?.fmhash else {
            return
        }
        if let image = YYImageCache.shared().getImageForKey(hash){
            return closure(image)
        }else{
            let _ = self.fetchSmallPic(model: model, callback: { [weak self](error, image, url) in
                if let image = image{
                    if let requsetBig = PhotoHelper.requestImageUrl(size: size, hash: hash){
                        ImageCache.default.retrieveImage(forKey: requsetBig.absoluteString, options: nil, completionHandler: { (image, type) in
                            if let image = image{
                                print("💗💗💗💗💗💗💗💗💗来自缓存，type:\(type)")
                                return closure(image)
                            }else{
                                _ = self?.fetchNormalPic(model: model, callback: {(error, image, url) in
                                    if let image = image{
                                        return closure(image)
                                    }
                                })
                            }
                        })
                    }
                    return closure(image)
                }
            })
        }
    }
    
    //从网络获取64*64小图
    func fetchSmallPic(model:WSAsset,callback:@escaping (_ error:Error?, _ image:UIImage?,_ reqUrl:URL?)->())->SDWebImageDownloadToken?{
        guard let hash = (model as? NetAsset)?.fmhash else {
            return nil
        }
        let size = self.fetchRequestSize(origin: kthumbnilSmallSize, model: model)
        let task = AppNetworkService.getSDThumbnail(hash: hash,size:size) { (error, downloadImage,reqUrl)  in
            callback(error,downloadImage,reqUrl)
        }
        if task != nil{
            self.imageSDDownloadTasks.append(task!)
        }
        return task
    }
    
    //从网络获取正常（186*186)缩略图
    func fetchNormalPic(model:WSAsset,callback:@escaping (_ error:Error?, _ image:UIImage?,_ reqUrl:URL?)->())->RetrieveImageDownloadTask?{
        guard let hash = (model as? NetAsset)?.fmhash else {
            return nil
        }
        let size = self.fetchRequestSize(origin: kthumbnilNormalSize, model: model)
        let task = AppNetworkService.getThumbnail(hash: hash,size:size,downloadPriority:1) { (error, downloadImage,reqUrl)  in
            callback(error,downloadImage,reqUrl)
        }
        if task != nil{
            self.imageDownloadTasks.append(task!)
        }
        return task
    }
    
    //动态计算缩略图大小
    func fetchRequestSize(origin:CGFloat,model:WSAsset)->CGSize{
        var size = CGSize.init(width: origin , height: origin)
        if let w = (model as? NetAsset)?.metadata?.w,let h = (model as? NetAsset)?.metadata?.h{
            if w > h{
                size = CGSize.init(width: CGFloat(w) * origin/CGFloat(h), height: origin)
            }else{
                size = CGSize.init(width: origin, height: (CGFloat(h) * origin/CGFloat(w)))
            }
        }
        return size
    }
    
    lazy var imageManager = PHCachingImageManager.init()
    
    lazy var imageRequestOptions: PHImageRequestOptions = {
        let option = PHImageRequestOptions.init()
        
        option.resizeMode = PHImageRequestOptionsResizeMode.fast//控制照片尺寸
        option.deliveryMode = PHImageRequestOptionsDeliveryMode.opportunistic //控制照片质量
        option.isNetworkAccessAllowed = true
        option.version = PHImageRequestOptionsVersion.current
        return option
    }()
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let dataSource = self.dataSource else {
            return
        }
        if indexPath.section >= dataSource.count{
            return
        }
        
        if indexPath.row >= dataSource[indexPath.section].count{
            return
        }
        
         let model = dataSource[indexPath.section][indexPath.row]
        
        if let cell = cell as? PhotoCollectionViewCell{
            self.setCellImage(model: model,cell:cell)
        }
    }
    

    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headView:FMHeadView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! FMHeadView
        guard let dataSource = self.dataSource else {
            return headView
        }
        if indexPath.section >= dataSource.count{
            return headView
        }
        
        if indexPath.row >= dataSource[indexPath.section].count{
            return headView
        }
        let model =  dataSource[indexPath.section][indexPath.row]
        if let creatDate = model.createDate{
            headView.headTitle = PhotoTools.getDateString(date: creatDate)
        }
        headView.fmIndexPath = indexPath
        headView.isSelectMode = isSelectMode ?? false
        headView.isChoose =  self.choosePhotos.contains(array:self.dataSource![indexPath.section])
        headView.fmDelegate = self
        return headView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = (__kWidth - 2 * (currentScale - 1))/currentScale
        let itemSize = CGSize(width: frame, height: frame)
        currentItemSize = itemSize
        return itemSize
    }
    

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let dataSource = self.dataSource else {
            return
        }
        if indexPath.section >= dataSource.count{
            return
        }
        
        if indexPath.row >= dataSource[indexPath.section].count{
            return
        }
        if isSelectMode! {
            let cell:PhotoCollectionViewCell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
            cell.btnSelectClick(nil)
        }else{
            let model = dataSource[indexPath.section][indexPath.row]
            model.indexPath = IndexPath(row: indexPath.row, section: indexPath.section)
            let vc = self.getMatchVC(model: model)
            if let presentVC = vc{
                self.present(presentVC, animated: true) { [weak self] in
                    if let pollingCallback = self?.pollingCallback{
                        pollingCallback(true)
                    }
                }
            }
        }
    }
    
    var isAnimation = false
    var isDecelerating = false
    var isScrolling = false
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        isScrolling = true
        isDecelerating = true
        if self.showIndicator {
            if self.collectionView?.indicator == nil {
                //导航按钮
                self.collectionView?.registerILSIndicator()
                if self.collectionView?.indicator == nil{
                    return
                }
                self.collectionView?.indicator.slider.rx.observe(String.self, keyPath)
                    .subscribe(onNext: { [weak self] (newValue) in
                        if (self?.showIndicator)! {
                            if (self?.collectionView?.indicator.slider.sliderState == UIControlState.normal && (self?.collectionView?.indicator.transform)!.isIdentity) {
                                self?.isDecelerating = false
                                DispatchQueue.global(qos: .default).asyncAfter(deadline: DispatchTime.now() + 1.5) {
                                    if let isDecelerating = self?.isDecelerating{
                                        if isDecelerating {
                                        self?.isAnimation = false
                                        DispatchQueue.main.async {
                                            UIView.animate(withDuration: 0.5, animations: {
                                                self?.collectionView?.indicator.transform = CGAffineTransform(translationX: 40, y: 0)
                                            }, completion: { (finished) in
                                                self?.isAnimation = false
                                                self?.isDecelerating = false
                                            })
                                        }
                                    }
                                    }
                                }
                            }else{
                                self?.isDecelerating = true
                            }
                        }
                    })
                    .disposed(by: dispose)
            }else {
                if (!isAnimation) {
                    self.collectionView?.indicator.transform = CGAffineTransform.identity
                }else{
                    DispatchQueue.global(qos: .default).asyncAfter(deadline: DispatchTime.now() + 0.3) {
                        DispatchQueue.main.async {
                            self.collectionView?.indicator.transform = CGAffineTransform.identity
                        }
                    }
                }
            }
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.hiddenIndicator()
        isScrolling = false
    }
    
    lazy var choosePhotos:Array<WSAsset> = {
        let array = Array<WSAsset>.init()
        return array
    }()
    
    lazy var chooseSection: Array<IndexPath> = {
        let array = Array<IndexPath>.init()
        return array
    }()

}

extension PhotoCollectionViewController:UICollectionViewDataSourcePrefetching{
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            guard var dataSource = self.dataSource else {
                return
            }
            if indexPath.section >= dataSource.count{
                return
            }
            
            if indexPath.row >= dataSource[indexPath.section].count{
                return
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            guard let dataSource = self.dataSource else {
                return
            }
            if indexPath.section >= dataSource.count{
                return
            }
            
            if indexPath.row >= dataSource[indexPath.section].count{
                return
            }
            let model = dataSource[indexPath.section][indexPath.row]
            let size = self.fetchRequestSize(origin: kthumbnilNormalSize, model: model)
            if let fmhash = (model as? NetAsset)?.fmhash{
                if let url = PhotoHelper.requestImageUrl(size: size, hash: fmhash){
                    let task = self.imageDownloadTasks.first(where: {$0.url == url})
                    task?.cancel()
                    self.imageDownloadTasks.removeAll(where: {$0.url == url})
                }
            }
        }
    }
}

extension PhotoCollectionViewController:FMHeadViewDelegate{
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
            let headers = self.collectionView?.visibleSupplementaryViews(ofKind: UICollectionElementKindSectionHeader)
            if let headers = headers {
                for header in headers {
                    (header as! FMHeadView).isSelectMode = (self.isSelectMode)!
                }
            }
        }

        let indexSet = IndexSet.init(integer: headView.fmIndexPath.section)
        collectionView?.performBatchUpdates({
              self.collectionView?.reloadSections(indexSet)
        }, completion: nil)
    }
}


extension PhotoCollectionViewController :UICollectionViewDelegateFlowLayout{
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
extension PhotoCollectionViewController : UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let indexPath = self.collectionView?.indexPathForItem(at: location)
        if (indexPath == nil) {
            return nil
        }
        let cell:PhotoCollectionViewCell = self.collectionView?.cellForItem(at: indexPath!) as! PhotoCollectionViewCell
        
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
        if isSelectMode!{
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

extension PhotoCollectionViewController : WSShowBigImgViewControllerDelegate {
    func photoBrowser(browser: WSShowBigimgViewController, indexPath: IndexPath) {
        guard let dataSource = self.dataSource else { return  }
        if indexPath.section >= dataSource.count{
            return
        }
        
        if indexPath.item >= dataSource[indexPath.section].count{
            return
        }
        self.collectionView?.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredVertically, animated: false)
        self.collectionView?.layoutIfNeeded()
    }
    
    func photoBrowser(browser: WSShowBigimgViewController, willDismiss indexPath: IndexPath) -> UIView? {
        let cell = self.collectionView?.cellForItem(at: indexPath)
        return cell
    }
}



