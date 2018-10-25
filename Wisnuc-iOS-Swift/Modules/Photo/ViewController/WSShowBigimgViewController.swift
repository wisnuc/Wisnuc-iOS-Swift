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
import MapKit

enum  WSShowBigimgViewControllerState{
    case imageBrowser
    case info
}

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
    var appearResizableImageView:UIImageView?
    var mapView:MKMapView?
    var state:WSShowBigimgViewControllerState?{
        didSet{
            switch state {
            case .imageBrowser?:
                imageBrowserStateAction()
            case .info?:
                infoStateAction()
            default:
                break
            }
        }
    }
    private let cellReuseIdentifier = "WSBigimgCollectionViewCell"
    private let infoCellReuseIdentifier = "infoCellReuseIdentifierCell"
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
        self.mapView?.removeFromSuperview()
        self.mapView = nil
        print("show big image deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setState(.imageBrowser)
        basicSetting()
        self.view.addSubview(self.collectionView)
        collectionView.setContentOffset(CGPoint(x: __kWidth + CGFloat(kItemMargin)*CGFloat(indexBeforeRotation), y: 0), animated: false)
        initNavBtns()
        self.view.addSubview(self.infoTableView)
        self.view.addSubview(self.shareView)
        shareView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (!isFirstAppear) {
            return
        }
        collectionView.setContentOffset(CGPoint(x: (__kWidth+CGFloat(kItemMargin))*CGFloat(indexBeforeRotation), y: 0), animated: false)
        self.performPresentAnimation()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
//        if (self.getCurrentPageModel()!.type == .Image && self.getCurrentPageModel()?.type != .NetImage) {
//            rightImageView.isHidden = true
//        }else if self.getCurrentPageModel()?.type == .NetImage {
//            rightImageView.isHidden = false
//        }
    }
    
    
    func setState(_ state:WSShowBigimgViewControllerState){
        self.state = state
    }
    
    func basicSetting(){
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
        
        naviView.addSubview(moreNaviButton)
        
        moreNaviButton.snp.makeConstraints { [weak self] (make) in
            make.centerY.equalTo((self?.titleLabel.snp.centerY)!)
            make.right.equalTo((self?.naviView.snp.right)!).offset(-16)
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
        
        moreNaviButton.setEnlargeEdgeWithTop(5, right: 5, bottom: 5, left: 5)
        
        naviView.addSubview(shareNaviButton)
        shareNaviButton.snp.makeConstraints { [weak self] (make) in
            make.centerY.equalTo((self?.titleLabel.snp.centerY)!)
            make.right.equalTo((self?.moreNaviButton.snp.left)!).offset(-MarginsWidth)
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
        
       
   
//        naviView.addSubview(rightImageView)
//
//        rightImageView.snp.makeConstraints { [weak self] (make) in
//            make.centerY.equalTo((self?.titleLabel.snp.centerY)!)
//            make.right.equalTo((self?.rightNaviButton.snp.left)!).offset(-16)
//            make.size.equalTo(CGSize(width: 24, height: 24))
//        }
        
        if (self.getCurrentPageModel()?.type != .NetImage ) {
//            rightImageView.isHidden = true
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
    
    func imageBrowserStateAction(){
        setImageBrowserStateNavigationBar()
        self.collectionView.isScrollEnabled = true
        self.infoTableView.alpha = 0
        self.view.backgroundColor = .black
    }

    func infoStateAction(){
        self.collectionView.isScrollEnabled = false
        self.view.backgroundColor = .white
    }
    
    func setImageBrowserStateNavigationBar(){
    
    }
    
    func setInfoStateStateNavigationBar(){
    
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
            view.contentMode = .scaleAspectFill
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
        self.infoTableView.reloadData()
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
//        let cell = senderViewForAnimation as! PhotoCollectionViewCell
      
//        let cgImage = cell.imageView.layer.contents
        
//        let image =
        let imageFromView = scaleImage != nil ? scaleImage : self.getImageFromView(view: senderViewForAnimation!)
    
        
        let senderViewOriginalFrame = senderViewForAnimation?.superview?.convert((senderViewForAnimation?.frame)!, to: self.view)
        
        let fadeView = UIView.init(frame: self.view.bounds)
        fadeView.backgroundColor = UIColor.clear
        let mainWindow = UIApplication.shared.keyWindow
        mainWindow?.addSubview(fadeView)
        let resizableImageView = UIImageView.init(image: imageFromView)
        resizableImageView.frame = senderViewOriginalFrame!
        resizableImageView.clipsToBounds = true
        resizableImageView.contentMode =  UIViewContentMode.scaleAspectFill
        resizableImageView.backgroundColor = UIColor.clear
//        if (cell.model is NetAsset){
//            appearResizableImageView = resizableImageView
//        }
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
//            if !(cell.model is NetAsset){
               resizableImageView.removeFromSuperview()
//            }
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
        appearResizableImageView?.removeFromSuperview()
   
        let fadeAlpha = 1 - fabs(collectionView.top)/collectionView.frame.size.height
        
        //    JYBigImgCell * cell = _collectionView.visibleCells[0];
        let indexP = IndexPath.init(row: currentPage - 1, section: 0)
        let cell:WSBigimgCollectionViewCell? = collectionView.cellForItem(at: indexP) as? WSBigimgCollectionViewCell
        
        if cell == nil{
            return
        }
        let mainWindow = UIApplication.shared.keyWindow
        var frame = cell?.previewView.imageViewFrame() ?? CGRect.zero
        if cell?.previewView.imageViewFrame() == CGRect.zero{
//            if appearResizableImageView != nil {
                frame = CGRect(x: 0, y: 0, width: __kWidth, height: __kHeight)
//            }
        }
        let rect = cell?.previewView.convert(frame, to: self.view)
      
        
        if let delegateOK = self.delegate{
            senderViewForAnimation =  delegateOK.photoBrowser(browser: self, willDismiss: (cell?.model?.indexPath!)!)
        }
        
        let senderViewOriginalFrame = senderViewForAnimation?.superview?.convert((senderViewForAnimation?.frame)! , to: self.view)
        if senderViewForAnimation == nil {
            return
        }

        let image = (senderViewForAnimation as! PhotoCollectionViewCell).image ?? self.getImageFromView(view: senderViewForAnimation!)
        
        
        let fadeView = UIView.init(frame: (mainWindow?.bounds)!)
        fadeView.backgroundColor = UIColor.black
        fadeView.alpha = fadeAlpha
        mainWindow?.addSubview(fadeView)
        
        appearResizableImageView = nil
        
        let resizableImageView = UIImageView.init(image: image)
        resizableImageView.frame = rect!
        resizableImageView.contentMode =  UIViewContentMode.scaleAspectFill
        resizableImageView.backgroundColor = UIColor.clear
        resizableImageView.clipsToBounds = true
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
        
//        let senderViewOriginalFrame = senderViewForAnimation?.superview?.convert((senderViewForAnimation?.frame)! , to: nil)
        UIView.animate(withDuration: 0.3, animations: {
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
    
    func shareViewAction(){
        backView.backgroundColor = .black
        backView.alpha = 0
        self.view.addSubview(backView)
        self.view.bringSubview(toFront:shareView)
        UIView.animate(withDuration: 0.3, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.backView.alpha = 0.54
            self.shareView.frame = CGRect(x: 0, y: __kHeight - self.shareView.height, width: self.shareView.width, height: self.shareView.height)
        }) { (finish) in
           self.panGesture.isEnabled = false
        }
    }
    
    
    func infoBrowser(translatedPoint:CGPoint,gesture:UIPanGestureRecognizer){
       
    }
    
    func fetchAssetEXIFInfo(model:WSAsset?) ->[AnyHashable : Any]? {
        let fileUrl:URL = model?.asset?.getAssetPath() ?? URL.init(fileURLWithPath: "")
        let imageSource = CGImageSourceCreateWithURL(fileUrl as CFURL, nil)
        if imageSource != nil{
            let imageInfo = CGImageSourceCopyPropertiesAtIndex(imageSource!, 0, nil)
            if let dict = imageInfo as? [AnyHashable : Any] {
//                print("EXIF:\(dict)")
                return dict
            }
        }
        
        return nil
    }
    
    @objc func panGestureRecognized(_ gesture:UIPanGestureRecognizer){
        
        let scrollView = self.collectionView
        
        var  firstX:CGFloat = self.view.width/2, firstY:CGFloat = 0
        
        let viewHeight = scrollView.height
        let viewHalfHeight = viewHeight/2
        firstY = viewHalfHeight
        
        let translatedPoint = gesture.translation(in: self.view)
//        self.infoBrowser(translatedPoint: translatedPoint,gesture)
        let absX = CGFloat(fabs(translatedPoint.x))
        let absY = CGFloat(fabs(translatedPoint.y)) // 设置滑动有效距离
        if max(absX, absY) < 10 {
            return
        }
        
        
        if absX > absY {
            if translatedPoint.x < 0 {
                if self.state ==  .info{
                    return
                }
                //向左滑动
            } else {
                //向右滑动
                if self.state ==  .info{
                    return
                }
            }
        } else if absY > absX {
            if translatedPoint.y < 0 {
                isdraggingPhoto = true
                self.setNeedsStatusBarAppearanceUpdate()
                //                let newTranslatedPoint = CGPoint(x: firstX+translatedPoint.x, y: firstY+translatedPoint.y)
                print(translatedPoint.y)
                if scrollView.center.y <= scrollView.height/4 - scrollView.height/2{
                    if gesture.state == UIGestureRecognizerState.changed {
                        var point :CGFloat = -35
                        if translatedPoint.y > -35{
                            point = translatedPoint.y
                        }
//                        print("😁\(point)")
                        UIView.animate(withDuration: 0.05, animations: {
                            scrollView.center = CGPoint(x: scrollView.center.x, y: scrollView.center.y+point)
                            self.infoTableView.frame =  CGRect(x: 0, y: scrollView.bottom  - 0.5, width: __kWidth, height: __kHeight - scrollView.height/4)
                        }) { (finish) in
                            UIView.animate(withDuration: 0.2, delay: 0.1, options: UIView.AnimationOptions.curveEaseIn, animations: {
                                scrollView.center = CGPoint(x: scrollView.center.x, y: scrollView.center.y-point)
                                self.infoTableView.frame =  CGRect(x: 0, y: scrollView.bottom - 0.5, width: __kWidth, height: __kHeight - scrollView.height/4)
                            }, completion: { (finish) in
                                
                            })
                        }
                    }
                    return
                }
                
                if gesture.state == UIGestureRecognizerState.changed {
                    gesture.isEnabled = false
                    let rect = self.getCurrentPageRect()
                    if rect.height < __kHeight - 2{
                        self.infoTableView.frame =  CGRect(x: 0, y: scrollView.bottom - (__kHeight - rect.height)/2 - 0.5, width: __kWidth, height: __kHeight - scrollView.height/4)
                    }else{
                        self.infoTableView.frame =  CGRect(x: 0, y: scrollView.bottom - 0.5, width: __kWidth, height: __kHeight - scrollView.height/4)
                    }
                    UIView.animate(withDuration: 0.3, delay: 0.1, options: UIView.AnimationOptions.curveEaseIn, animations: {
                        if rect.height < __kHeight - 2{
                            scrollView.center = CGPoint(x: scrollView.center.x, y: scrollView.height/4 - scrollView.height/2 + (__kHeight - rect.height)/2)
                            self.infoTableView.frame =  CGRect(x: 0, y: scrollView.bottom - (__kHeight - rect.height)/2 - 0.5, width: __kWidth, height: __kHeight - scrollView.height/4)
                        }else{
                            scrollView.center = CGPoint(x: scrollView.center.x, y: scrollView.height/4 - scrollView.height/2)
                            self.infoTableView.frame =  CGRect(x: 0, y: scrollView.bottom - 0.5, width: __kWidth, height: __kHeight - scrollView.height/4)
                        }
                        self.infoTableView.alpha = 1
                    }, completion: { (finish) in
                        gesture.isEnabled = true
                        self.state = .info
                    })
//                    UIView.animate(withDuration: 0.5, animations: {
//                        self.infoTableView.alpha = 1
//                        scrollView.center = CGPoint(x: scrollView.center.x, y: scrollView.height/4 - scrollView.height/2)
//                        if rect.height < __kHeight - 2{
//                             self.infoTableView.frame =  CGRect(x: 0, y: scrollView.bottom - rect.height - 0.5, width: __kWidth, height: __kHeight - scrollView.height/4)
//                        }else{
//                            self.infoTableView.frame =  CGRect(x: 0, y: scrollView.bottom - 0.5, width: __kWidth, height: __kHeight - scrollView.height/4)
//
//                        }
//
//                    }) { (finsih) in
//                        gesture.isEnabled = true
//                        self.state = .info
//                    }
                }
                return
            } else {
                if scrollView.top <  -(__kHeight/4){
                    if gesture.state == UIGestureRecognizerState.changed {
                        gesture.isEnabled = false
                        UIView.animate(withDuration: 0.3, animations: {
                            scrollView.center = CGPoint(x: scrollView.center.x, y: __kHeight/2)
                            self.infoTableView.frame =  CGRect(x: 0, y: scrollView.bottom, width: __kWidth, height: __kHeight - scrollView.height/4)
                            self.infoTableView.alpha = 0
                        }) { (finsih) in
                            gesture.isEnabled = true
                            self.state = .imageBrowser
                        }
                    }
                    return
                }
                //向下滑动
            }
        }
        isdraggingPhoto = true
        self.setNeedsStatusBarAppearanceUpdate()
        let newTranslatedPoint = CGPoint(x: firstX+translatedPoint.x, y: firstY+translatedPoint.y)
        if gesture.state == UIGestureRecognizerState.changed {
            scrollView.center = newTranslatedPoint
            if appearResizableImageView != nil{
                appearResizableImageView!.center = newTranslatedPoint
            }
        }
        
        let newY = scrollView.center.y - viewHalfHeight
        let newAlpha =  1.0 - (fabsf(Float(newY))/Float(viewHeight))//abs(newY)/viewHeight * 1.8;
      
        self.view.isOpaque = true

        self.view.backgroundColor = UIColor.init(white: 0, alpha: CGFloat(newAlpha))
        

      
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
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func readyToShare(){
        self.shareViewAction()
    }
    
    @objc func doneButtonPressed(){
       self.performDismissAnimation()
    }
    
    @objc func shareItemTap(_ sender:UIBarButtonItem){
        
    }
    
    @objc func moreItemTap(_ sender:UIButton){
        
    }
    
    @objc func backViewTap(_ sender:UITapGestureRecognizer?){
        UIView.animate(withDuration: 0.3, delay: 0.1, options: UIViewAnimationOptions.curveEaseOut, animations: {
             self.shareView.frame = CGRect(x: 0, y: __kHeight, width: __kWidth, height: 266)
             self.backView.alpha = 0
        }) { (finish) in
             self.backView.removeFromSuperview()
             self.panGesture.isEnabled = true
        }
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
        layout.itemSize = self.view.bounds.size
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
    
    lazy var infoTableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: __kHeight, width: __kWidth, height: __kHeight), style: UITableViewStyle.grouped)
        tableView.register(UINib.init(nibName: StringExtension.classNameAsString(targetClass: BigPhotoInfoTableViewCell.self), bundle: nil), forCellReuseIdentifier: infoCellReuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isPagingEnabled = true
//        tableView.backgroundColor = UIColor.clear
        tableView.bounces = false
        tableView.alpha = 0
        return tableView
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
        let font = UIFont.mdc_standardFont(forMaterialTextStyle: MDCFontTextStyle.body1)
        label.font = font.withSize(20)
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
        button.setImage(MDCIcons.imageFor_ic_arrow_back()?.byTintColor(UIColor.white), for: UIControlState.normal)
        button.addTarget(self, action: #selector(doneButtonPressed), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    lazy var moreNaviButton: UIButton = {
        let button  = UIButton.init()
        button.setImage(MDCIcons.imageFor_ic_more_horiz()?.byTintColor(.white), for: UIControlState.normal)
        button.addTarget(self, action: #selector(moreItemTap(_:)), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    lazy var shareNaviButton: UIButton = {
        let button  = UIButton.init()
        button.setImage(UIImage.init(named: "share_white.png"), for: UIControlState.normal)
        button.addTarget(self, action: #selector(readyToShare), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    lazy var backView: UIView = {
        let view  = UIView.init(frame: CGRect(x: 0, y: 0, width: __kWidth, height: __kHeight))
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(backViewTap(_ :)))
        view.addGestureRecognizer(tap)
        return view
    }()

    lazy var shareView = PhotoShareView.init(frame: CGRect(x: 0, y: __kHeight, width: __kWidth, height: 266))
    
    
//    lazy var rightImageView: UIImageView = {
//        let imageView = UIImageView.init(image: UIImage.init(named: "ic_cloud_white"))
//        return imageView
//    }()


    lazy var describeTextField = UITextField.init()
 
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
   
        cell.loadImageCompleteCallback = { [weak self] in
            self?.appearResizableImageView?.removeFromSuperview()
            self?.appearResizableImageView = nil
        }
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
            if scrollView.center.y <= scrollView.height/4 - scrollView.height/2{
                return
            }
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

extension WSShowBigimgViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:BigPhotoInfoTableViewCell = tableView.dequeueReusableCell(withIdentifier: infoCellReuseIdentifier, for: indexPath) as! BigPhotoInfoTableViewCell
        tableView.separatorStyle = .none
        let model = getCurrentPageModel()

        switch indexPath.row {
        case 0:
            cell.leftImageView.image = UIImage.init(named: "calendar_gray.png")
            cell.titleLabel.text =  model is NetAsset ? TimeTools.timeString(TimeInterval((model as! NetAsset).mtime ?? 0)/1000) : TimeTools.timeString(model?.asset?.creationDate ?? Date.init())
            cell.detailLabel.text = model is NetAsset ? "\(TimeTools.weekDay(TimeInterval((model as! NetAsset).mtime ?? 0)/1000)) \(TimeTools.timeHourMinuteString(TimeInterval((model as! NetAsset).mtime ?? 0)/1000))" : "\(TimeTools.weekDay(model?.asset?.creationDate ?? Date.init())) \(TimeTools.timeHourMinuteString(model?.asset?.creationDate ?? Date.init()))"
            
        case 1:
            cell.leftImageView.image = UIImage.init(named: "photo_gray_info.png")
            if model is NetAsset{
              cell.titleLabel.text = (model as! NetAsset).name  ?? ""
            }else{
                if let asset = model?.asset{
                   cell.titleLabel.text = asset.getName()
                }
            }
            
            var infoArray:Array<String> = Array.init()
            if let exifDic = self.fetchAssetEXIFInfo(model: model){
//                if  let compressedBitsPerPixel = exifDic[kCGImagePropertyExifCompressedBitsPerPixel] as? NSNumber{
////                    print(compressedBitsPerPixel)
//                }
                if  let pixelWidthNumber = exifDic[kCGImagePropertyPixelWidth] as? NSNumber,let pixelHeightNumber = exifDic[kCGImagePropertyPixelHeight] as? NSNumber{
                    let pixelWidth = pixelWidthNumber.stringValue
                    let pixelHeight = pixelHeightNumber.stringValue
                    let pixel = "\(pixelWidth)x\(pixelHeight)"
//                    print(pixel)
                    infoArray.append(pixel)
                }else if let pixelWidthNumber = exifDic["PixelWidth"] as? NSNumber,let pixelHeightNumber = exifDic["PixelHeight"] as? NSNumber{
                    let pixelWidth = pixelWidthNumber.stringValue
                    let pixelHeight = pixelHeightNumber.stringValue
                    let pixel = "\(pixelWidth)x\(pixelHeight)"
//                    print(pixel)
                    infoArray.append(pixel)
                }
           }
            
            if let size = model is NetAsset ? sizeString((model as! NetAsset).size ?? 0) : model?.asset?.getSizeString(){
                infoArray.append(size)
            }
            cell.detailLabel.text = infoArray.joined(separator: "  ")
        case 2:
            cell.leftImageView.image = UIImage.init(named: "lens_gary.png")
            var infoArray:Array<String> = Array.init()
            if let exifDic = self.fetchAssetEXIFInfo(model: model){
                if  let imageTIFFDictionary = exifDic[kCGImagePropertyTIFFDictionary] as? [AnyHashable : Any]{
                    if let imageTIFFModel = imageTIFFDictionary[kCGImagePropertyTIFFModel] as? String{
                    cell.titleLabel.text = imageTIFFModel
//                    print(imageTIFFModel)
                    }
                    
                    if  let imageExifDictionary = exifDic[kCGImagePropertyExifDictionary] as? [AnyHashable : Any]{
                        if  let imageFNumber = imageExifDictionary[kCGImagePropertyExifFNumber] as? NSNumber{
                            let imageFNumberString = "f/\(imageFNumber.stringValue)"
                            infoArray.append(imageFNumberString)
                        }
                        
                        if  let imageExposureTime = imageExifDictionary[kCGImagePropertyExifExposureTime] as? NSNumber{
                            var exposureTimeString = ""
                            if imageExposureTime.floatValue < 1.00000{
                               exposureTimeString = "1/\(String.init(format: "%.2f", imageExposureTime.floatValue*100))"
                            }else{
                               exposureTimeString = "\(String.init(format: "%.f", imageExposureTime.floatValue))s"
                            }
                            infoArray.append(exposureTimeString)
                        }
                        
                        if  let imageFocalLength = imageExifDictionary[kCGImagePropertyExifFocalLength] as? NSNumber{
                            infoArray.append("\(imageFocalLength.stringValue)mm")
                        }
                        
                        if  let imageISOSpeedRatings = imageExifDictionary[kCGImagePropertyExifISOSpeedRatings] as? [NSNumber]{
//                            print(imageISOSpeedRatings)
                            if imageISOSpeedRatings.count > 0{
                                infoArray.append("ISO \(imageISOSpeedRatings[0].stringValue)")
                            }
                        }
                    }
                }
            }

           cell.detailLabel.text = infoArray.joined(separator: "  ")
        case 3:
            cell.leftImageView.image = UIImage.init(named: "location_gary.png")
            var infoArray:Array<String> = Array.init()
            if let exifDic = self.fetchAssetEXIFInfo(model: model){
                if  let imageGPSDictionary = exifDic[kCGImagePropertyGPSDictionary] as? [AnyHashable : Any]{
//                    print(imageGPSDictionary)
                    if let imageLatitude = imageGPSDictionary[kCGImagePropertyGPSLatitude] as? NSNumber,let imageLongitude = imageGPSDictionary[kCGImagePropertyGPSLongitude] as? NSNumber{
                        // 创建经纬度
                        let location = CLLocation(latitude: imageLatitude.doubleValue, longitude: imageLongitude.doubleValue)
                        let cLGeocoder = CLGeocoder.init()
                        cLGeocoder.reverseGeocodeLocation(location) {(placemarks, error) in
                            if let  placemarks = placemarks{
                                if  placemarks.count > 0{
                                    var locationArray:Array<String> = Array.init()
                                    let place = placemarks[0]
                                    if  let country = place.country{
                                        locationArray.append(country)
                                    }
                                    
                                    if  let locality = place.locality{
                                        locationArray.append(locality)
                                    }
                                    
                                    if  let subLocality = place.subLocality{
                                        locationArray.append(subLocality)
                                    }
                                    
                                    cell.titleLabel.text = locationArray.joined(separator: "")
                                }
                            }
                        }
                        
                        let centerCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(imageLatitude.doubleValue, imageLongitude.doubleValue)
                        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.1, 0.1)
                        let region: MKCoordinateRegion = MKCoordinateRegionMake(centerCoordinate, span)
                        if self.mapView == nil{
                            self.mapView = MKMapView.init()
                        }
                        mapView?.region = region
                        mapView?.showsTraffic = true
                        let pin = MapPin.init(coordinate: centerCoordinate)
                        mapView?.addAnnotation(pin)
                        let latitude = String.init(format: "%.3f", imageLatitude.floatValue)
                        let longitude = String.init(format: "%.3f", imageLongitude.floatValue)
                        let coordinate = "\(latitude),\(longitude)"
//                        print(coordinate)
                        infoArray.append(coordinate)
                    }
                }
            }
    
            cell.detailLabel.text = infoArray.joined(separator: "  ")
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 154
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.zero)
        self.describeTextField.frame = CGRect(x: MarginsWidth, y: 0, width: __kWidth - MarginsWidth*2, height: 56 - 1)
        self.describeTextField.placeholder = LocalizedString(forKey: "添加说明")
        let view = UIView.init(frame: CGRect(x: 0, y: 56 - 1, width: __kWidth, height: 1))
        view.backgroundColor = Gray12Color
        headerView.backgroundColor = .white
        headerView.addSubview(self.describeTextField)
        headerView.addSubview(view)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let model = getCurrentPageModel()
        if let exifDic = self.fetchAssetEXIFInfo(model: model){
            if  exifDic[kCGImagePropertyGPSDictionary] != nil {
                if self.mapView == nil{
                    self.mapView = MKMapView.init()
                }
                self.mapView?.isZoomEnabled = false
                self.mapView?.isScrollEnabled = false
                self.mapView?.isRotateEnabled = false
                self.mapView?.delegate = self
            }else{
                self.mapView = nil
            }
        }
        return self.mapView
    }
    
}

extension WSShowBigimgViewController:MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        let identifier = "annotationView"
//        var annotationView: MKAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
//        if annotationView == nil {
//            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//        }
//        annotationView?.backgroundColor = COR3
//        annotationView?.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
//        annotationView?.layer.cornerRadius = 20/2
//        annotationView?.canShowCallout = true
        return nil
    }
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        print("AnnotationViews were added.")
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("AnnotationView's calloutView was tapped.")
    }
}

extension WSShowBigimgViewController:PhotoShareViewDelegate{
    func shareImages() -> [UIImage]? {
        return nil
    }
    
    func shareImage() -> UIImage? {
     
        let indexP = IndexPath.init(row: currentPage - 1, section: 0)
        let cell:WSBigimgCollectionViewCell? = collectionView.cellForItem(at: indexP) as? WSBigimgCollectionViewCell

        return  cell?.previewView.image()
    }
    
    func didEndShare(){
        self.backViewTap(nil)
    }
}

class MapPin : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}
