//
//  WSShowBigimgViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/7/11.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import PhotosUI
import Photos
import AVKit
import SnapKit
import RxSwift

@objc protocol WSShowBigImgViewControllerDelegate {
    func photoBrowser(browser:WSShowBigimgViewController, indexPath:IndexPath)
    func photoBrowser(browser:WSShowBigimgViewController, willDismiss indexPath:IndexPath) ->UIView?
}

class WSShowBigimgViewController: UIViewController {
    weak var delegate:WSShowBigImgViewControllerDelegate?
    var indexBeforeRotation:Int = 0
    var selectIndex:Int = 0
    var models:Array<WSAsset>?
    var scaleImage:UIImage?
    var senderViewForAnimation:UIView?
    var isdraggingPhoto:Bool = false
    var currentPage:Int = 0
    var isFirstAppear:Bool = true
    var currentModelForRecord:WSAsset?
    var disposeBag = DisposeBag()
    private let cellReuseIdentifier = "WSBigimgCollectionViewCell"
    init() {
        super.init(nibName: nil, bundle: nil)
        if self.responds(to: #selector(getter: self.automaticallyAdjustsScrollViewInsets) ){
            self.automaticallyAdjustsScrollViewInsets = false
            self.modalPresentationStyle = UIModalPresentationStyle.custom
            self.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            self.modalPresentationCapturesStatusBarAppearance = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("show big image deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        basicSetting()
        self.view.addSubview(self.collectionView)
        collectionView.setContentOffset(CGPoint(x: __kWidth + CGFloat(kItemMargin)*CGFloat(indexBeforeRotation), y: 0), animated: false)
        initNavBtns()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (!isFirstAppear) {
            return
        }
        collectionView.setContentOffset(CGPoint(x: (__kWidth+CGFloat(kItemMargin))*CGFloat(indexBeforeRotation), y: 0), animated: false)
        self.performPresentAnimation()
//        WBApplication.statusBarStyle = UIStatusBarStyleLightContent;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (!isFirstAppear) {
            return
        }
        isFirstAppear = false
        self.reloadCurrentCell()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if (self.getCurrentPageModel()!.type == .Image && self.getCurrentPageModel()?.type != .NetImage) {
            rightImageView.isHidden = true
        }else if self.getCurrentPageModel()?.type == .NetImage {
            rightImageView.isHidden = false
        }
    }
    
    func basicSetting(){
        self.view.backgroundColor = UIColor.black
        ViewTools.automaticallyAdjustsScrollView(scrollView: collectionView, viewController: self)
        self.view.clipsToBounds = true
        self.view.alpha = 0
        currentPage = self.selectIndex+1
        indexBeforeRotation = self.selectIndex
        gestureSetting()
    }
    
    func initNavBtns(){
       naviView.addSubview(leftNaviButton)
        leftNaviButton.snp.makeConstraints { [weak self] (make) in
            make.centerY.equalTo((self?.naviView.snp.centerY)!).offset(10)
            make.left.equalTo((self?.naviView.snp.left)!).offset(16)
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
       
        leftNaviButton.setEnlargeEdgeWithTop(5, right: 5, bottom: 5, left: 5)

//        titleLabel.text =  [NSString stringWithFormat:@"%ld/%ld", _currentPage, self.models.count];
        naviView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { [weak self] (make) in
            make.centerX.equalTo((self?.naviView.snp.centerX)!)
            make.centerY.equalTo((self?.naviView.snp.centerY)!).offset(10)
        }
        
        naviView.addSubview(rightNaviButton)
        
        rightNaviButton.snp.makeConstraints { [weak self] (make) in
            make.centerY.equalTo((self?.titleLabel.snp.centerY)!)
            make.right.equalTo((self?.naviView.snp.right)!).offset(-10)
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
        
        rightNaviButton.setEnlargeEdgeWithTop(5, right: 5, bottom: 5, left: 5)
   
        naviView.addSubview(rightImageView)
        
        rightImageView.snp.makeConstraints { [weak self] (make) in
            make.centerY.equalTo((self?.titleLabel.snp.centerY)!)
            make.right.equalTo((self?.rightNaviButton.snp.left)!).offset(-16)
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
        
        if (self.getCurrentPageModel()?.type != .NetImage ) {
            rightImageView.isHidden = true
        }
        
        self.view.addSubview(naviView)
    }
    
    func notificationSetting(){
        defaultNotificationCenter()
            .rx
            .notification(NSNotification.Name.UIApplicationDidChangeStatusBarOrientation)
            .subscribe(onNext: { (noti) in
               self.indexBeforeRotation = self.currentPage - 1
            })
            .disposed(by:disposeBag )
    }
    
    func gestureSetting(){
        self.view.addGestureRecognizer(panGesture)
        let longGesture = UILongPressGestureRecognizer.init(target: self, action:#selector(longGestureRecognized(_ :)))
        self.view.addGestureRecognizer(longGesture)
    }
    
    func getImageFromView(view:UIView)->UIImage?{
            if view is UIImageView {
                return (view as! UIImageView).image
            }
            UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, 2);
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
    }
    
    func getCurrentPageModel() -> WSAsset?{
        let offset = self.collectionView.contentOffset
        
        let page = offset.x/(__kWidth+CGFloat(kItemMargin))
        if (ceilf(Float(page)) >= Float(self.models!.count) || page < 0) {
            return nil
        }
        let str = NSString.init(format: "%.0f", page)
        currentPage = str.integerValue + 1
        let model = self.models![currentPage-1]
        return model
    }
    
    func getCurrentPageRect()->CGRect{
        var frame = CGRect.zero
        let model = self.getCurrentPageModel()
        
        var w:CGFloat? = 0, h:CGFloat? = 0
        if (model?.asset != nil) {
            w = CGFloat((model?.asset?.pixelWidth)!)
            h = CGFloat((model?.asset?.pixelHeight)!)
        } else if model is NetAsset {
            w = CGFloat(((model as! NetAsset).metadata?.w!)!)
            h = CGFloat(((model as! NetAsset).metadata?.h!)!)
        } else {
            w = __kWidth
            h = __kHeight
        }
        
        let width = MIN(x: __kWidth, y: w!)
        frame.origin = CGPoint.zero
        frame.size.width = width
        
        let imageScale = h!/w!
        let screenScale = __kHeight/__kWidth
        
        if (imageScale > screenScale) {
            frame.size.height = __kHeight
            frame.size.width = CGFloat(floorf(Float(width * __kHeight / h!)))
        } else {
            var height = floorf(Float(width * imageScale))
            if (height < 1 || height.isNaN) {
                //iCloud图片height为NaN
                height = Float(self.view.height)
            }
            frame.size.height = CGFloat(height)
        }
        frame.origin.x = (__kWidth - frame.size.width)/2
        frame.origin.y = (__kHeight - frame.size.height)/2
        
        return frame
    }
    
    func reloadCurrentCell(){
        let m = self.getCurrentPageModel()
        if (m?.type == .GIF ||
            m?.type == .LivePhoto) {
            let indexP = IndexPath.init(row: currentPage - 1, section: 0)
            let cell:WSBigimgCollectionViewCell? = collectionView.cellForItem(at: indexP) as? WSBigimgCollectionViewCell
            cell?.reloadGifLivePhoto()
        }
    }

    
    func handlerSingleTap(){
//    if sharing {
//    [self dismissShareView];
//    return;
//    }
//    _hideNavBar = !_hideNavBar;
//
//    [self setNeedsStatusBarAppearanceUpdate];
//
//    CGRect frame = _hideNavBar?CGRectMake(0, -64, __kWidth, 64):CGRectMake(0, 0, __kWidth, 64);
//    [UIView animateWithDuration:0.3 animations:^{
//    _navView.frame = frame;
//    }];
    }
    
    func performPresentAnimation(){
        self.view.alpha = 0
        collectionView.alpha = 0
        
        let imageFromView = scaleImage != nil ? scaleImage : self.getImageFromView(view: senderViewForAnimation!)
        
        let senderViewOriginalFrame = senderViewForAnimation?.superview?.convert((senderViewForAnimation?.frame)!, to: nil)
        
        let fadeView = UIView.init(frame: self.view.bounds)
        fadeView.backgroundColor = UIColor.clear
        let mainWindow = UIApplication.shared.keyWindow
        mainWindow?.addSubview(fadeView)
        let resizableImageView = UIImageView.init(image: imageFromView)
        resizableImageView.frame = senderViewOriginalFrame!
        resizableImageView.clipsToBounds = true
        resizableImageView.contentMode = senderViewForAnimation != nil ? (senderViewForAnimation?.contentMode)! : UIViewContentMode.scaleAspectFill
        resizableImageView.backgroundColor = UIColor.clear
        mainWindow?.addSubview(resizableImageView)
        //
        //    //jy
        //    //    _senderViewForAnimation.hidden = YES;
        //
        let completion:()->Void =  {
            self.view.alpha = 1.0
            self.collectionView.alpha = 1.0
            resizableImageView.backgroundColor = UIColor.init(white: 1, alpha: 1)
            fadeView.removeFromSuperview()
            resizableImageView.removeFromSuperview()

        }
        // FIXME: net video animation error!
        if self.getCurrentPageModel()?.type == .Video{
        return completion()
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            fadeView.backgroundColor =  UIColor.black
        }) { (finished) in
            
        }
        
        let finalImageViewFrame = self.getCurrentPageRect()
        self.view.isOpaque = true
        
        UIView.animate(withDuration: 0.3, animations: {
            resizableImageView.frame = finalImageViewFrame
        }) { (finished) in
            completion()
        }
    }
  
    func performDismissAnimation(){
        
        let fadeAlpha = 1 - fabs(collectionView.top)/collectionView.frame.size.height
        
        //    JYBigImgCell * cell = _collectionView.visibleCells[0];
        let indexP = IndexPath.init(row: currentPage - 1, section: 0)
        let cell:WSBigimgCollectionViewCell? = collectionView.cellForItem(at: indexP) as? WSBigimgCollectionViewCell
        
        if cell == nil{
            return
        }
        let mainWindow = UIApplication.shared.keyWindow
        
        let rect = cell?.previewView.convert((cell?.previewView.imageViewFrame())!, to: self.view)
        
        if let delegateOK = self.delegate{
            senderViewForAnimation =  delegateOK.photoBrowser(browser: self, willDismiss: (cell?.model?.indexPath!)!)
        }
        
        if senderViewForAnimation == nil {
            return
        }

        let image = self.getImageFromView(view: senderViewForAnimation!)
        
        
        let fadeView = UIView.init(frame: (mainWindow?.bounds)!)
        fadeView.backgroundColor = UIColor.black
        fadeView.alpha = fadeAlpha
        mainWindow?.addSubview(fadeView)
        
        let resizableImageView = UIImageView.init(image: image)
        resizableImageView.frame = rect!
        resizableImageView.contentMode = senderViewForAnimation != nil ? (senderViewForAnimation?.contentMode)! : UIViewContentMode.scaleAspectFill
        resizableImageView.backgroundColor = UIColor.clear
        resizableImageView.layer.masksToBounds = true
        mainWindow?.addSubview(resizableImageView)
        self.view.isHidden = true
        
        let completion:()->() = { [weak self] in
            self?.senderViewForAnimation?.isHidden = false
            self?.senderViewForAnimation = nil
            self?.scaleImage = nil
            fadeView.removeFromSuperview()
            resizableImageView.removeFromSuperview()
            // Gesture
            mainWindow?.removeGestureRecognizer((self?.panGesture)!)
            // Controls
            NSObject.cancelPreviousPerformRequests(withTarget: self!)
            
            self?.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            self?.dismiss(animated: false, completion: nil)
        }
        
        let senderViewOriginalFrame = senderViewForAnimation?.superview?.convert((senderViewForAnimation?.frame)! , to: self.view)
        UIView.animate(withDuration: 0.4, animations: {
            resizableImageView.frame = senderViewOriginalFrame!
            fadeView.alpha = 0
            self.view.backgroundColor = UIColor.clear
        }) { (finished) in
             completion()
        }
    }
    
    func shareAlert(){
        share()
    }
    
    func share(){
//        NSString *titleText = title;
//        NSString *shareText = text;
//        NSURL *URL = [NSURL URLWithString:siteurl];
//        UIImage *image =[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
//        UIActivityViewController *a = [[UIActivityViewController alloc] initWithActivityItems:[NSArray arrayWithObjects:titleText,shareText,URL,image, nil] applicationActivities:nil];
//        self.presentViewController:a animated:true completion:nil];
        var array = Array<Any>.init()
        
        let indexP = IndexPath.init(row: currentPage - 1, section: 0)
        let cell:WSBigimgCollectionViewCell? = collectionView.cellForItem(at: indexP) as? WSBigimgCollectionViewCell
        
        if cell?.previewView.image() != nil{
           array.append((cell?.previewView.image())!)
        }
       
        let activityViewController =  UIActivityViewController.init(activityItems: array, applicationActivities: nil)
        self.present(activityViewController, animated: true) {
            
        }
        activityViewController.completionWithItemsHandler = { (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) -> Void in
            if completed {
                if activityType == UIActivityType.saveToCameraRoll {
                   Message.message(text: LocalizedString(forKey: "已存入相册"))
                }else{
                    Message.message(text: LocalizedString(forKey: "分享完成"))
                }
            }
            else{
                
            }
        }
    }
    
    @objc func panGestureRecognized(_ gesture:UIPanGestureRecognizer){
        
        let scrollView = self.collectionView
        
        var  firstX:CGFloat = self.view.width/2, firstY:CGFloat = 0
        
        let viewHeight = scrollView.height
        let viewHalfHeight = viewHeight/2
        firstY = viewHalfHeight
        
        let translatedPoint = gesture.translation(in: self.view)
        isdraggingPhoto = true
        self.setNeedsStatusBarAppearanceUpdate()
        let newTranslatedPoint = CGPoint(x: firstX+translatedPoint.x, y: firstY+translatedPoint.y)
        if gesture.state == UIGestureRecognizerState.changed {
        scrollView.center = newTranslatedPoint
        }
        
        let newY = scrollView.center.y - viewHalfHeight
        let newAlpha =  1.0 - (fabsf(Float(newY))/Float(viewHeight))//abs(newY)/viewHeight * 1.8;
      
        self.view.isOpaque = true

        self.view.backgroundColor = UIColor.init(white: 0, alpha: CGFloat(newAlpha))
        
        scrollView.isScrollEnabled = false

        // Gesture Ended
        if (gesture.state == UIGestureRecognizerState.ended) {
            scrollView.isScrollEnabled = true
            let moveDismissDistance:CGFloat = 80
            if (scrollView.center.y > viewHalfHeight+moveDismissDistance || scrollView.center.y < viewHalfHeight-moveDismissDistance) {
                if ((senderViewForAnimation) != nil) {
                    self.performDismissAnimation()
                    return
                }
                
                let finalX:CGFloat  = firstX
                var finalY:CGFloat  = firstX
                
                let windowsHeigt:CGFloat  = self.view.height
                
                if(scrollView.center.y > viewHalfHeight+30){ // swipe down
                finalY = windowsHeigt*2
                }else{ // swipe up
                finalY = -viewHalfHeight
                }
                
                let animationDuration:CGFloat = 0.35
                
                UIView.beginAnimations(nil, context: nil)
                UIView.setAnimationDuration(TimeInterval(animationDuration))
                UIView.setAnimationCurve(UIViewAnimationCurve.easeIn)
                UIView.setAnimationDelegate(self)
                scrollView.center = CGPoint(x: finalX, y: finalY)
                self.view.backgroundColor = UIColor.init(white: 0, alpha: CGFloat(newAlpha))
                UIView.commitAnimations()

                self.perform(#selector(back), with: self, afterDelay: TimeInterval(animationDuration))
            }
            else // Continue Showing View
            {
                isdraggingPhoto = false
                self.setNeedsStatusBarAppearanceUpdate()
                
                self.view.backgroundColor = UIColor.init(white: 0, alpha: 1)
                
                let velocityY:CGFloat = (0.35*gesture.velocity(in: self.view).y);
                
                let finalX:CGFloat = firstX
                let finalY:CGFloat = viewHalfHeight
                
                let animationDuration  = abs((velocityY)*0.0002)+0.2
                
                
                UIView.beginAnimations(nil, context: nil)
                UIView.setAnimationDuration(TimeInterval(animationDuration))
                UIView.setAnimationCurve(UIViewAnimationCurve.easeOut)
                UIView.setAnimationDelegate(self)
                scrollView.center = CGPoint(x: finalX, y: finalY)
                UIView.commitAnimations()
            }
        }
    }
    
    @objc func longGestureRecognized(_ sender:UILongPressGestureRecognizer){
        if (sender.state == UIGestureRecognizerState.began) {
           shareAlert()
        }
    }
    
    @objc func back(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func readyToShare(){
        
    }
    
    @objc func doneButtonPressed(){
       self.performDismissAnimation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    lazy var collectionViewlayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        layout.minimumLineSpacing = CGFloat(kItemMargin);
        layout.sectionInset = UIEdgeInsetsMake(0, CGFloat(kItemMargin/2), 0, CGFloat(kItemMargin/2));
        layout.itemSize = self.view.bounds.size;
        return layout
    }()

    lazy var collectionView: UICollectionView = {
        let collection = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: collectionViewlayout)
        collection.register(WSBigimgCollectionViewCell.self, forCellWithReuseIdentifier:cellReuseIdentifier)
        
        collection.dataSource = self
        collection.delegate = self
        collection.isPagingEnabled = true
        collection.backgroundColor = UIColor.clear
        
        collection.setCollectionViewLayout(collectionViewlayout, animated: true)
        collection.frame = CGRect(x: -CGFloat(kItemMargin)/2, y: 0, width: __kWidth+CGFloat(kItemMargin), height: __kHeight)
//        // TODO: rotation
       
        return collection
    }()
    
    lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGestureRecognized(_ :)))
        gesture.minimumNumberOfTouches = 1
        gesture.maximumNumberOfTouches = 1
        return gesture
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.white
        label.textAlignment = NSTextAlignment.center
        return label
    }()

    lazy var naviView: UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: __kWidth, height: 64))
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    lazy var leftNaviButton: UIButton = {
        let button = UIButton.init()
        button.setImage(UIImage.init(named: "back"), for: UIControlState.normal)
        button.addTarget(self, action: #selector(doneButtonPressed), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    lazy var rightNaviButton: UIButton = {
        let button  = UIButton.init()
        button.setImage(UIImage.init(named: "more_white"), for: UIControlState.normal)
        button.addTarget(self, action: #selector(readyToShare), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    lazy var rightImageView: UIImageView = {
        let imageView = UIImageView.init(image: UIImage.init(named: "ic_cloud_white"))
        return imageView
    }()
}

extension WSShowBigimgViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.models!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:WSBigimgCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! WSBigimgCollectionViewCell
        let model = self.models![indexPath.row]
        cell.previewView.videoView.delegate = self
        
        cell.showGif = true
        cell.showLivePhoto = true
        cell.model = model
   
        cell.singleTapCallBack = { [weak self] in
            self?.handlerSingleTap()
        };
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! WSBigimgCollectionViewCell).previewView.resetScale()
        (cell as! WSBigimgCollectionViewCell).willDisplaying = true
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! WSBigimgCollectionViewCell).previewView.handlerEndDisplaying()
    }
}

extension WSShowBigimgViewController:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView  {
            let m =  self.getCurrentPageModel()
            if (m == nil || currentModelForRecord == m){
                return
            }
            currentModelForRecord = m
            //改变导航标题
            if self.delegate != nil && !isFirstAppear{
                self.delegate?.photoBrowser(browser: self, indexPath: (m?.indexPath!)!)
            }
            //!!!!!: change Title
            titleLabel.text = "\(currentPage)/\(String(describing: (self.models?.count)!))"
            if (m!.type == .GIF ||
                m!.type == .LivePhoto ||
                m!.type == .Video || m?.type == .NetVideo) {
                let cell = collectionView.cellForItem(at: IndexPath.init(row: currentPage-1 , section: 0))
                if  cell != nil{
                      (cell as! WSBigimgCollectionViewCell).pausePlay()
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
         self.reloadCurrentCell()
    }
}

extension WSShowBigimgViewController:SWPreviewVideoPlayerDelegate{
    func playVideo(viewController: AVPlayerViewController) {
        let indexP = IndexPath.init(row: currentPage - 1, section: 0)
        let  cell =  collectionView.cellForItem(at: indexP)
        if cell != nil {
            (cell as! WSBigimgCollectionViewCell).previewView.videoView.stopPlayVideo()
        }
    }
}
