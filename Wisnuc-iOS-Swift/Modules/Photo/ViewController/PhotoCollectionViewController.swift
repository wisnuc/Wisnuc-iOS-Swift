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

private let reuseIdentifier = "PhotoCell"
private let headerReuseIdentifier = "headView"
private var currentScale:CGFloat = 0
private let keyPath:String = "sliderState"
private let headerHeight:CGFloat = 42


@objc protocol PhotoCollectionViewControllerDelegate{
    func collectionView(_ collectionView: UICollectionView, isSelectMode:Bool)
}

class PhotoCollectionViewController: UICollectionViewController {
//    override func willDealloc() -> Bool {
//        return false
//    }
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
    var currentItemSize:CGSize = CGSize.zero
    var showIndicator:Bool = true
    var sortedAssetsBackupArray:Array<WSAsset>?
    var dispose = DisposeBag()
    var state:PhotoRootViewControllerState?{
        didSet{
            
        }
    }
    var timeViewArray:[UIView]?
    var dataSource:Array<Array<WSAsset>>?{
        didSet{
            mainThreadSafe {
                self.collectionView?.reloadData()
                self.dataSourceHasValue()
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
//         appBar.appBarViewController.headerView.trackingScrollView = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      dataSource = Array.init()
      initCollectionViewLayout()
      initGuestrue()
    }
    
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
        
        if let allAssetArray = sortedAssetsBackupArray{
           let yearArray = sort(allAssetArray)
//            dataSource?.filter({$0.first?.createDate }})

//            var limitCount = 1
//            if yearArray.count > 7{
//               limitCount  = Int(allAssetArray.count/7)
//            }else{
//                limitCount  = Int(allAssetArray.count/yearArray.count)
//            }
            
            var originMargin:CGFloat = 0
            for (i,value) in yearArray.enumerated(){
                let photos = value
                let yearsAsset = dataSource?.filter({Calendar.current.isDate(($0.first?.createDate)!, equalTo:  (photos.first?.createDate)!, toGranularity: Calendar.Component.year)})
                if let yearsAsset = yearsAsset{
                    var sum = 0
                    for (_,assets) in yearsAsset.enumerated(){
                       sum += assets.count
                    }
//                    print("😆\(sum)")
                var photoScale:CGFloat = 1
                if sum > 3{
                    photoScale = CGFloat(ceilf(Float(sum)/Float(currentScale)))
                }
                  print("😆\(photoScale)")
                if self.currentItemSize.height == 0 {
                    self.currentItemSize = CGSize(width: (__kWidth - 2 * (currentScale - 1))/currentScale, height: (__kWidth - 2 * (currentScale - 1))/currentScale)
                }
                
                if let height = self.collectionView?.contentSize.height {
                    if height>0{
                        let margin = ((photoScale * self.currentItemSize.height) + CGFloat(yearsAsset.count*Int(headerHeight)) + (photoScale - 1) * 2 )/(height - MDCAppNavigationBarHeight) * (__kHeight - MDCAppNavigationBarHeight)
                        //             imageView.frame = CGRectMake(index * (imageWithHeight + Width_Space) + Start_X,page * (imageWithHeight + Height_Space)+Start_Y, imageWithHeight, imageWithHeight);
                        print("😈\(margin)")
                        originMargin += margin
//                        print(self.collectionView?.contentSize.height ?? 0)
                        let xview = UIView.init(frame: CGRect(x: __kWidth - 100 - 74, y: MDCAppNavigationBarHeight + originMargin, width: 100, height: 30))
                       let label = UILabel.init(frame: xview.bounds)
                        if let date = value.first?.createDate{
                        label.text = TimeTools.getYear(date:date)
                        }
                        print("🐔\(originMargin)")
                        xview.addSubview(label)
                        xview.backgroundColor = .cyan
                        self.view.addSubview(xview)
                        self.timeViewArray?.append(xview)
                    }
                  }
                }
            }
        }
       
    }
    
    func sort(_ assetsArray:Array<WSAsset>) -> Array<Array<WSAsset>>{
        var finishArray:Array<Array<WSAsset>> = Array.init()
        autoreleasepool {
            var array:Array<WSAsset>  = Array.init()
            array.append(contentsOf: assetsArray)
            array.sort { $0.createDate! > $1.createDate! }
            sortedAssetsBackupArray = array
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
                  
                    if   Calendar.current.isDate(photo1.createDate!, equalTo:  photo2.createDate!, toGranularity: Calendar.Component.year){
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initGuestrue(){
        //增加捏合手势
        let  pin = UIPinchGestureRecognizer.init(target: self, action: #selector(handlePinch(_ :)))
        self.collectionView?.addGestureRecognizer(pin)
    }
//    func setSelectMode(mode:Bool){
//        self.isSelectMode = mode
//        self.collectionView?.reloadData()
//    }
    
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
//        self.styler.cellLayoutType = MDCCollectionViewCellLayoutType.grid
//        self.styler.cellStyle = MDCCollectionViewCellStyle.default
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
//        self.collectionView?.indicator.slider.addObserver(self, forKeyPath: "sliderState", options: NSKeyValueObservingOptions.init(rawValue: 0x01), context: nil)
        self.collectionView?.indicator.frame = CGRect(x: self.collectionView!.indicator.frame.origin.x, y:  self.collectionView!.indicator.frame.origin.y, width: 1, height: self.collectionView!.height - CGFloat(2 * kILSDefaultSliderMargin))
    }
        
    func forceTouchAvailable() -> Bool{
         if #available(iOS 9.1, *) {
            return self.traitCollection.forceTouchCapability == UIForceTouchCapability.available
        } else {
            return false
        }
    }
    
    
    func getMouthDateString(date:Date) -> String{
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyy年MM月"
        var dateString = formatter.string(from: date)
        if dateString == "1970年01月" {
            dateString = "未知时间"
        }
        return dateString
    }
    
    func getDateString(date:Date) -> String{
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        return dateString
    }
  
    func getSize(model:WSAsset) -> CGSize{
        
        var w:CGFloat = 0
        var h:CGFloat = 0
    
        if((model.asset) != nil){
            w = MIN(x: CGFloat(model.asset!.pixelWidth), y: __kWidth)
            h = w * CGFloat((model.asset?.pixelHeight)!) / CGFloat((model.asset?.pixelWidth)!)
        }else{
            w = MIN(x: CGFloat(((model as! NetAsset).metadata?.w!)!), y: __kWidth)
            h = w * CGFloat(((model as! NetAsset).metadata?.h)!) / CGFloat(((model as! NetAsset).metadata?.w!)!)
        }
    
        if h.isNaN{
            return CGSize.zero
        }
    
        if h > __kHeight || h.isNaN {
            h = __kHeight
            w = (model.asset != nil) ? h * CGFloat(model.asset!.pixelWidth) / CGFloat(model.asset!.pixelHeight)
                : h * CGFloat(((model as! NetAsset).metadata?.w!)!)  / CGFloat(((model as! NetAsset).metadata?.w!)!)
        }
        
        return CGSize(width: w, height: h)
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
    
    func getBigImageVC(data:Array<WSAsset>,index:Int) -> UIViewController{
        let vc = WSShowBigimgViewController.init()
        vc.delegate = self
        vc.models = data
        vc.selectIndex = index
        let cell:PhotoCollectionViewCell = self.collectionView?.cellForItem(at: (self.collectionView?.indexPathsForSelectedItems?.first)!) as! PhotoCollectionViewCell
        vc.senderViewForAnimation = cell
        vc.scaleImage = cell.imageView?.layer.contents as? UIImage
        //    weakify(self);
        //    [vc setBtnBackBlock:^(NSArray<JYAsset *> *selectedModels, BOOL isOriginal) {
        //        strongify(weakSelf);
        //        [strongSelf.collectionView reloadData];
        //    }];
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
         let model = self.dataSource![indexPath.section][indexPath.row]
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
                self?.collectionView?.reloadItems(at: [indexPath])
//                let listSet = Set((self?.dataSource![indexPath.section])!)
//                let findSet = Set((self?.choosePhotos)!)
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
                    //                [weakSelf leftBtnClick:_leftBtn];
                }
            }
            //            _countLb.text = [NSString stringWithFormat:WBLocalizedString(@"select_count", nil),(unsigned long)weakSelf.choosePhotos.count];
        }
        
        cell.longPressBlock = { [weak self] in
            if (self?.isSelectMode ?? false) { return}
             self?.isSelectMode = true
            
            self?.choosePhotos.append(model)
            //
            //            [weakSelf addLeftBtn];
            //            weakSelf.addButton.hidden = NO;
            //
            let dataCollect = (self?.dataSource![indexPath.section])!.filter { value in
                (self?.choosePhotos.contains(value))!
            }
            if dataCollect.count == 0 {
                self?.chooseSection.append(IndexPath.init(row: 0, section: indexPath.section))
            }
            
            //            _countLb.text = [NSString stringWithFormat:WBLocalizedString(@"select_count", nil),(unsigned long)weakSelf.choosePhotos.count];
            //
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
//                let listSet = Set((self?.dataSource![indexPath.section])!)
//                let findSet = Set((self?.choosePhotos)!)
            if nowHeader != nil {
                (nowHeader as! FMHeadView).isChoose =  (self?.choosePhotos.contains(array:(self?.dataSource![indexPath.section])!))!
            }
        }

        if (self.collectionView!.indicator != nil) {
            self.collectionView?.indicator.slider.timeLabel.text = self.getMouthDateString(date: model.createDate!)
        }
        
        cell.setImagView(indexPath:indexPath)
        cell.setSelectButton(indexPath: indexPath)
        cell.isSelectMode = self.isSelectMode
        cell.setSelectAnimation(isSelect: self.isSelectMode ?? false ? self.choosePhotos.contains(model) : false, animation: false)
        cell.model = model
        let tagString = "\(indexPath.section)\(indexPath.item)"
        cell.tag = (NSNumber.init(string: tagString)?.intValue)!
        return cell
    }
    

    // MARK: UICollectionViewDelegate
    
  
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headView:FMHeadView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! FMHeadView
      
        headView.headTitle =  self.getDateString(date: dataSource![indexPath.section][indexPath.row].createDate!)
        headView.fmIndexPath = indexPath
        headView.isSelectMode = isSelectMode ?? false
        headView.isChoose =  self.choosePhotos.contains(array:self.dataSource![indexPath.section])
//        let listSet = Set(self.dataSource![indexPath.section])
//        let findSet = Set(self.choosePhotos)
//        headView.isChoose = listSet.isSubset(of: findSet)
//        headView.isChoose = self.chooseSection.contains(indexPath)
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
        if isSelectMode! {
            let cell:PhotoCollectionViewCell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
            cell.btnSelectClick(nil)
        }else{
            let model = self.dataSource![indexPath.section][indexPath.row]
            let vc = self.getMatchVC(model: model)
            if vc != nil {
                self.present(vc!, animated: true) {
                }
            }
        }
    }
    
    var isAnimation = false
    var isDecelerating = false
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        isDecelerating = true
        
        if self.showIndicator {
            if self.collectionView?.indicator == nil {
                //导航按钮
                self.collectionView?.registerILSIndicator()
                if self.collectionView?.indicator == nil{
                    return
                }
//
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
            let cell = collectionView.cellForItem(at: indexPath)
            if cell != nil{
            let photoCell:PhotoCollectionViewCell =  cell as! PhotoCollectionViewCell
                let model = self.dataSource![indexPath.section][indexPath.row]
                if (self.collectionView!.indicator != nil) {
                    self.collectionView?.indicator.slider.timeLabel.text = self.getMouthDateString(date: model.createDate!)
                }
                photoCell.isSelectMode = self.isSelectMode
                photoCell.setSelectAnimation(isSelect: self.isSelectMode! ? self.choosePhotos.contains(model) : false, animation: false)
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
//            self leftBtnClick:_leftBtn];
        }
//        _countLb.text = [NSString stringWithFormat:WBLocalizedString(@"select_count", nil),(unsigned long)self.choosePhotos.count];
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
        vc.preferredContentSize = self.getSize(model:model)
        
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
        self.collectionView?.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredVertically, animated: false)
        self.collectionView?.layoutIfNeeded()
    }
    
    func photoBrowser(browser: WSShowBigimgViewController, willDismiss indexPath: IndexPath) -> UIView? {
        let cell = self.collectionView?.cellForItem(at: indexPath)
        return cell
    }
}


