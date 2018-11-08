//
//  WSBigimgCollectionViewCell.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/7/11.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents.MDCActivityIndicator
import Photos
import Kingfisher
import PhotosUI
import RxSwift
import AVKit
import AVFoundation
//---------------base preview---------------
class WSBasePreviewView: UIView {
    
    var wsAsset:WSAsset?{
        didSet{
            
        }
    }
    
    var filesModel:EntriesModel?{
        didSet{
            
        }
    }
    
    var imageRequestID:PHImageRequestID?
    
    var singleTapCallback:(()->())?
    
    var imageDownloadTask:RetrieveImageDownloadTask?
    
    func image()->UIImage?
    {return imageView.image}
    
    func loadNormalImage(asset:WSAsset){
        
    }
    
    func resetScale(){
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addGestureRecognizer(singleTap)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func singleTapAction(_ sender:UITapGestureRecognizer?){
        if let singleCallback =  singleTapCallback{
            singleCallback()
        }
    }
    
    lazy var indicator: MDCActivityIndicator = {
        let activityIndicator = MDCActivityIndicator.init()
        activityIndicator.center = self.center
        return activityIndicator
    }()
    
    lazy var imageView: UIImageView = {
        let imgView = UIImageView.init()
        imgView.contentMode = UIViewContentMode.scaleAspectFit
        return imgView
    }()
    
    lazy var singleTap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(singleTapAction(_ :)))
        return tap
    }()

}

class WSPreviewImageAndGif: WSBasePreviewView {
    private var loadOK:Bool = false
    var loadCompleteCallback:(()->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.scrollView.frame = self.bounds
        self.scrollView.setZoomScale(1.0, animated: true)

        if (loadOK) {
            if wsAsset != nil {
                self.resetSubviewSize(self.wsAsset!.asset != nil ? self.wsAsset : self.imageView.image ?? nil)
            }else if filesModel != nil{
                self.resetSubviewSize(self.imageView.image ?? nil)
            }
        }
    }
    
    override func resetScale() {
        self.scrollView.zoomScale = 1
    }
    
    override func image() -> UIImage? {
        return self.imageView.image
    }
    
    func resumeGif(){
        let layer = self.imageView.layer
        if (layer.speed != 0.00000) {return}
        let pausedTime = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }
    
    func pauseGif(){
        let layer = self.imageView.layer
        if (layer.speed == 0.00000) {return}
        let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
    }
    
    func loadGifImage(asset:WSAsset){
        if asset.asset == nil {return}
        self.indicator.startAnimating()
        PHPhotoLibrary.requestOriginalImageData(for: asset.asset) { (data, info) in
            if !(info![PHImageResultIsDegradedKey] as! Bool){
                self.imageView.image = PHPhotoLibrary.animatedGIF(with: data!)
                self.resumeGif()
                self.resetSubviewSize(asset)
                self.indicator.stopAnimating()
            }
        }
    }
    
    override func loadNormalImage(asset:WSAsset){
        if (self.wsAsset?.asset != nil && self.imageRequestID != nil) {
            if self.imageRequestID! >= 0{
                PHCachingImageManager.default().cancelImageRequest(self.imageRequestID!)
            }
        }
        
        if(self.imageDownloadTask != nil){
            imageDownloadTask?.cancel()
            self.imageDownloadTask = nil
        }
        
        self.wsAsset = asset
        
        self.indicator.startAnimating()
        let scale = UIScreen.main.scale
        let width = MIN(x: __kWidth, y: CGFloat(kMaxImageWidth))
        var size = CGSize.zero
        if(self.wsAsset?.asset != nil){
            size = CGSize(width: width*scale, height: width*scale*CGFloat((asset.asset?.pixelHeight)!)/CGFloat((asset.asset?.pixelWidth)!))
        }
        
        self.imageRequestID = PHPhotoLibrary.requestImage(for: asset.asset, size: size, completion: { [weak self] (image, info) in
            self?.imageView.image = image;
            self?.resetSubviewSize(asset)
            if  !(info![PHImageResultIsDegradedKey] as! Bool){
                self?.indicator.stopAnimating()
                self?.loadOK = true
            }
        })
    }
    
    func loadImage(asset:WSAsset){
        self.imageView.image = nil
        if (self.wsAsset?.asset != nil && self.imageRequestID != nil) {
            if self.imageRequestID! >= 0{
                PHCachingImageManager.default().cancelImageRequest(self.imageRequestID!)
            }
        }
        
        if(self.imageDownloadTask != nil){
            imageDownloadTask?.cancel()
            self.imageDownloadTask = nil
        }
        self.wsAsset = asset
        self.indicator.startAnimating()

        self.imageDownloadTask = AppNetworkService.getHighWebImage(hash: (asset as! NetAsset).fmhash!, callback: { [weak self] (error, img) in
            self?.indicator.stopAnimating()
            if let completeCallback = self?.loadCompleteCallback{
                completeCallback()
            }
            if error != nil {
                // TODO: Load Error Image
            } else {
                self?.loadOK = true
                self?.imageView.image = img
                if asset.type == WSAssetType.GIF{
                  self?.resumeGif()
                }
                self?.resetSubviewSize(img)
            }
            self?.imageDownloadTask = nil
         
        })
    }
    
    func loadImage(filesModel:EntriesModel){
        self.imageView.image = nil

        if(self.imageDownloadTask != nil){
            imageDownloadTask?.cancel()
            self.imageDownloadTask = nil
        }
        self.filesModel = filesModel
        self.indicator.startAnimating()
        self.imageDownloadTask = AppNetworkService.getHighWebImage(hash: filesModel.hash ?? "", callback: { [weak self] (error, img) in
          
            if let completeCallback = self?.loadCompleteCallback{
                completeCallback()
            }
            if error != nil {
                Message.message(text: "图片加载失败", duration: 1.4)
                // TODO: Load Error Image
            } else {
                self?.loadOK = true
                self?.imageView.image = img
                if filesModel.metadata?.type?.lowercased() == FilesFormatType.GIF.rawValue{
                    self?.resumeGif()
                }
                self?.resetSubviewSize(img)
            }
            self?.imageDownloadTask = nil
            self?.indicator.stopAnimating()
        })
    }

    @objc func doubleTapAction(_ sender:UITapGestureRecognizer?){
        var scale:CGFloat = 1
        if (scrollView.zoomScale != 3.0) {
            scale = 3
        } else {
            scale = 1
        }
        let zoomRect = self.zoomRect(scale: scale, center: (sender?.location(in: sender?.view))!)
        scrollView.zoom(to: zoomRect, animated: true)
    }
    
    func initUI(){
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.containerView)
        self.containerView.addSubview(self.imageView)
        self.addSubview(self.indicator)
        
        let doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(doubleTapAction(_ :)))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
        self.singleTap.require(toFail: doubleTap)
    }
    
    func resetSubviewSize(_ value:Any?){
        if value == nil{
            return
        }
        self.containerView.frame = CGRect(x: 0, y: 0, width: __kWidth, height: 0)
        
        var frame:CGRect = CGRect.zero
        
        let orientation =  UIDevice.current.orientation
        
        var w:CGFloat = 0.0, h:CGFloat = 0.0
        
        if value is WSAsset{
            if let asset = (value as! WSAsset).asset{
                w = CGFloat(asset.pixelWidth)
                h = CGFloat(asset.pixelHeight)
            }
        }else{
            w = (value as! UIImage).size.width
            h = (value as! UIImage).size.height
        }
        
        let width = MIN(x: __kWidth, y: w)
        var orientationIsUpOrDown = true
        if (orientation == UIDeviceOrientation.landscapeLeft ||
            orientation == UIDeviceOrientation.landscapeRight) {
            orientationIsUpOrDown = false
            let height = MIN(x: __kHeight, y: h)
            frame.origin = CGPoint.zero
            frame.size.height = height
            let image = self.imageView.image
            
            let imageScale = (image?.size.width)!/(image?.size.height)!
            let screenScale = __kWidth/__kHeight
            if (imageScale > screenScale) {
                frame.size.width = CGFloat(floorf(Float(height * imageScale)))
                if (frame.size.width > __kWidth) {
                    frame.size.width = __kWidth;
                    frame.size.height = __kWidth / imageScale
                }
            } else {
                var imageWidth:CGFloat = CGFloat(floorf(Float(height * imageScale)))
                if (imageWidth < 1 || imageWidth.isNaN) {
                    //iCloud图片height为NaN
                    imageWidth = self.width
                }
                frame.size.width = imageWidth
            }
        }else{
            frame.origin = CGPoint.zero
            frame.size.width = width
            let image = self.imageView.image
            
            let imageScale = (image?.size.height)!/(image?.size.width)!
            let screenScale = __kHeight/__kWidth
            
            if (imageScale > screenScale) {
                //            frame.size.height = floorf(width * imageScale);
                frame.size.height = __kHeight;
                frame.size.width = CGFloat(floorf(Float(width * __kHeight / h)));
            } else {
                var height = floorf(Float(width * imageScale));
                if (height < 1 || height.isNaN) {
                    //iCloud图片height为NaN
                    height = Float(self.height)
                }
                
                frame.size.height = CGFloat(height)
            }
        }
        self.containerView.frame = frame
        
        var contentSize = CGSize.zero
        if (orientationIsUpOrDown) {
            contentSize = CGSize(width: width, height: MAX(x:__kHeight, y:frame.size.height))
            if (frame.size.height < self.height) {
                self.containerView.center = CGPoint(x: self.width/2, y: self.height/2)
            } else {
                self.containerView.frame = CGRect(origin: CGPoint(x: (self.width - frame.size.width)/2, y: 0), size: frame.size)
            }
        }else{
            contentSize = frame.size
            if (frame.size.width < self.width ||
                frame.size.height < self.height) {
                self.containerView.center = CGPoint(x: self.width/2, y: self.height/2)
            }
        }
        self.scrollView.contentSize = contentSize
        self.imageView.frame = self.containerView.bounds
        self.scrollView.scrollRectToVisible(self.bounds, animated: false)
    }
    
    func zoomRect(scale:CGFloat,center:CGPoint) ->CGRect{
        var zoomRect = CGRect.zero
        zoomRect.size.height = self.scrollView.frame.size.height / scale
        zoomRect.size.width  = self.scrollView.frame.size.width  / scale
        zoomRect.origin.x    = center.x - (zoomRect.size.width  / CGFloat.init(2.0))
        zoomRect.origin.y    = center.y - (zoomRect.size.height / CGFloat.init(2.0))
        return zoomRect
    }
    
    lazy var scrollView: UIScrollView = {
        let lazyScrollView = UIScrollView.init()
        lazyScrollView.frame = self.bounds
        lazyScrollView.maximumZoomScale = 3.0
        lazyScrollView.minimumZoomScale = 1.0
        lazyScrollView.isMultipleTouchEnabled = true
        lazyScrollView.delegate = self
        lazyScrollView.scrollsToTop = false
        lazyScrollView.showsHorizontalScrollIndicator = false
        lazyScrollView.showsVerticalScrollIndicator = false
        lazyScrollView.delaysContentTouches = false
        return lazyScrollView
    }()
    
    lazy var containerView: UIView = {
        let view = UIView.init()
        return view
    }()
}

extension WSPreviewImageAndGif:UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews[0]
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = (scrollView.width > scrollView.contentSize.width) ? (scrollView.width - scrollView.contentSize.width) * 0.5 : 0.0;
        let offsetY = (scrollView.height > scrollView.contentSize.height) ? (scrollView.height - scrollView.contentSize.height) * 0.5 : 0.0;
        self.containerView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.resumeGif()
    }
}

class WSPreviewLivePhoto: WSBasePreviewView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = self.bounds
        lpView.frame = self.bounds
    }
    
    override func loadNormalImage(asset: WSAsset) {
        if (self.wsAsset?.asset != nil && self.imageRequestID != nil) {
            if self.imageRequestID! >= 0{
                PHCachingImageManager.default().cancelImageRequest(self.imageRequestID!)
            }
        }
        
        self.wsAsset = asset
        self.indicator.startAnimating()
        let scale = UIScreen.main.scale
        let width = MIN(x:__kWidth, y:CGFloat(kMaxImageWidth))
        let size = CGSize(width: width*scale, height: width*scale*CGFloat((asset.asset?.pixelHeight)!)/CGFloat((asset.asset?.pixelWidth)!))
        self.imageRequestID = PHPhotoLibrary.requestImage(for: asset.asset, size: size, completion: { [weak self] (image, info) in
            self?.imageView.image = image;
            if !(info![PHImageResultIsDegradedKey] as! Bool){
                self?.indicator.stopAnimating()
            }
        })
    }
    
    func initUI(){
        self.addSubview(self.imageView)
        self.addSubview(self.lpView)
        self.addSubview(self.indicator)
    }
    
    func loadLivePhoto(asset:WSAsset){
      _ = PHPhotoLibrary.requestLivePhoto(for: asset.asset, completion: { (lv, info) in
                self.lpView.livePhoto = lv
                self.lpView.startPlayback(with: PHLivePhotoViewPlaybackStyle.full)
        })
    }
    
    func stopPlayLivePhoto(){
        self.lpView.stopPlayback()
    }
    
    lazy var lpView: PHLivePhotoView = {
        let liveView = PHLivePhotoView.init(frame: self.bounds)
        liveView.contentMode = UIViewContentMode.scaleAspectFit
        return liveView
    }()
}

@objc protocol SWPreviewVideoPlayerDelegate {
    func playVideo(viewController:AVPlayerViewController)
}

class WSPreviewVideo: WSBasePreviewView {
    var disposeBag = DisposeBag()
//    var player:SGPlayer?
    var request:BaseRequest?
    weak var delegate:SWPreviewVideoPlayerDelegate?
    private var hasObserverStatus:Bool = false
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let request = request{
            request.cancel()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = self.bounds
        self.playLayer?.frame = self.bounds
        self.playBtn.center = self.center
    }
    
    override func loadNormalImage(asset: WSAsset) {
        if (self.wsAsset?.asset != nil && self.imageRequestID != nil) {
            if self.imageRequestID! >= 0{
                PHCachingImageManager.default().cancelImageRequest(self.imageRequestID!)
            }
        }
        self.wsAsset = asset
        
//        if playLayer != nil {
//            playLayer?.player = nil
//            playLayer?.removeFromSuperlayer()
////            [_playLayer removeObserver:self forKeyPath:@"status"];
//            hasObserverStatus = false
//            playLayer = nil
//        }
        
        self.imageView.image = nil;
        
        if !(asset.asset?.isLocal())! {
            self.initVideoLoadFailedFromiCloudUI()
            return
        }
        
        self.playBtn.isEnabled = true
        self.playBtn.isHidden = false
        self.icloudLoadFailedLabel.isHidden = true
        self.imageView.isHidden = false
        
        self.indicator.startAnimating()
        let scale = UIScreen.main.scale
        let width = MIN(x: __kWidth, y: CGFloat(kMaxImageWidth));
        let size = CGSize(width: width*scale, height: width*scale*CGFloat((asset.asset?.pixelHeight)!)/CGFloat((asset.asset?.pixelWidth)!))
        self.imageRequestID = PHPhotoLibrary.requestImage(for: asset.asset, size: size, completion: { [weak self] (image, info) in
            self?.imageView.image = image
            if !(info![PHImageResultIsDegradedKey] as! Bool){
                self?.indicator.stopAnimating()
            }
        })
    }
    
    @objc func playFinished(_ item: AVPlayerItem) {
        //    [super singleTapAction];
        self.playBtn.isHidden = false
        self.imageView.isHidden = false
        let time = CMTime.init(seconds: 0, preferredTimescale: 600)
        self.playLayer?.player?.seek(to: time)
    }
    
    @objc func playEnd(_ notification: Notification) {
    }
    
    func loadNetNormalImage(asset:WSAsset){
        if (self.wsAsset?.asset != nil && self.imageRequestID != nil) {
            if self.imageRequestID! >= 0{
                PHCachingImageManager.default().cancelImageRequest(self.imageRequestID!)
            }
        }
        self.wsAsset = asset
        if (playLayer != nil) {
            playLayer?.player = nil
            playLayer?.removeFromSuperlayer()
            playLayer?.removeObserver(self, forKeyPath: "status")
            hasObserverStatus = false
            playLayer = nil
        }
        self.imageView.image = nil
        self.playBtn.isEnabled = true
        self.playBtn.isHidden = false
        self.icloudLoadFailedLabel.isHidden = true
        self.imageView.isHidden = false
        if AppNetworkService.networkState == .normal{
            Message.message(text: LocalizedString(forKey: "Operation not support"))
        }
//
        self.indicator.startAnimating()
        if (asset as! NetAsset).fmhash == nil{
            return
        }
        let request = MediaRandomAPI.init(hash: (asset as! NetAsset).fmhash!)
        self.request = request
        request.startRequestJSONCompletionHandler { [weak self](response) in
            self?.indicator.stopAnimating()
            if response.error == nil{
                DispatchQueue.main.async {
//                    if response.result == nil{
//                        self?.initVideoLoadFailedFromiCloudUI()
//                        return
//                    }
                    var url: URL? = nil
                    if let anURL = RequestConfig.sharedInstance.baseURL {
                        url = URL(string: "\(anURL)media/random/\(String(describing: (response.value as! NSDictionary)["key"]))")
                        let player = AVPlayer(url: url!)
                        self?.layer.addSublayer((self?.playLayer)!)
                        self?.playLayer?.player = player
                        self?.switchVideoStatus()
                        self?.playLayer?.addObserver(self!, forKeyPath: "status", options: .new, context: nil)
                            do {
                                try  AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                            }catch{
                                
                            }

                        self?.hasObserverStatus = true
                        NotificationCenter.default.addObserver(self!, selector: #selector(self?.playFinished(_:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
//                        NotificationCenter.default.addObserver(self, selector: #selector(playEnd(_:)), name: Notification.Name.mpmove, object: player)
                        self?.indicator.stopAnimating()
                        
//                        self?.player = SGPlayer()
//
//                        // register callback handle.
//
//                        self?.player?.registerNotificationTarget(self!, stateAction: #selector(self?.stateAction(_:)), progressAction: #selector(self?.progressAction(_:)), playableAction: #selector(self?.playableAction(_:)), errorAction: #selector(self?.errorAction(_:)))
//
////                        // display view tap action.
//
//                        self?.player?.viewTapAction = { player, view in
//                                print("player display view did click!")
//                            }
////                        // playback plane video.
//                        self?.player?.replaceVideo(with: url!)
////                        [self.player replaceVideoWithURL:contentURL videoType:SGVideoTypeNormal]; // 方式2
////
////                        // playback 360° panorama video.
////                        [self.player replaceVideoWithURL:contentURL videoType:SGVideoTypeVR];
////
////                        // start playing
//                        self?.player?.play()
                    }
                }
            }else{
                print(response.error as Any)
            }
        }
//        [[FMMediaRamdomKeyAPI apiWithHash:[(WBAsset *)self.jyAsset fmhash]] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
//        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@media/random/%@", [JYRequestConfig sharedConfig].baseURL, request.responseJsonObject[@"key"]]];
//        if(!weakSelf) return;
//        dispatch_async(dispatch_get_main_queue(), ^{
//        jy_strongify(weakSelf);
//        if (!request.responseJsonObject) {
//        [self? initVideoLoadFailedFromiCloudUI];
//        return;
//        }
//        AVPlayer *player = [AVPlayer playerWithURL:url];
//        [self?.layer addSublayer:self?.playLayer];
//        self?.playLayer.player = player;
//        [self? switchVideoStatus];
//        [self?.playLayer addObserver:self? forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
//        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
//        _hasObserverStatus = YES;
//        [[NSNotificationCenter defaultCenter] addObserver:self? selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:player.currentItem];
//        [[NSNotificationCenter defaultCenter] addObserver:self? selector:@selector(playEnd:) name:MPMoviePlayerPlaybackDidFinishNotification object:player];
//        [self?.indicator stopAnimating];
//        });
//        } failure:^(__kindof JYBaseRequest *request) {
//        [SXLoadingView showAlertHUD:WBLocalizedString(@"play_failed", nil) duration:1];
//        [weakSelf.indicator stopAnimating];
//        }];
    }
    
    func loadNetNormalImage(filesModel:EntriesModel){
        if (self.wsAsset?.asset != nil && self.imageRequestID != nil) {
            if self.imageRequestID! >= 0{
                PHCachingImageManager.default().cancelImageRequest(self.imageRequestID!)
            }
        }
        self.filesModel = filesModel

        self.imageView.image = nil
        self.playBtn.isEnabled = true
        self.playBtn.isHidden = false
        self.icloudLoadFailedLabel.isHidden = true
        self.imageView.isHidden = false
        if AppNetworkService.networkState == .normal{
            Message.message(text: LocalizedString(forKey: "Operation not support"))
        }
        //
        self.indicator.startAnimating()
        if filesModel.hash == nil{
            return
        }
        let request = MediaRandomAPI.init(hash: filesModel.hash!)
        self.request = request
        request.startRequestJSONCompletionHandler { [weak self](response) in
            self?.indicator.stopAnimating()
            if response.error == nil{
                DispatchQueue.main.async {
                    //                    if response.result == nil{
                    //                        self?.initVideoLoadFailedFromiCloudUI()
                    //                        return
                    //                    }
                    var url: URL? = nil
                    if let anURL = RequestConfig.sharedInstance.baseURL {
                        guard let dic = response.value as? NSDictionary else{
                            self?.initVideoLoadFailedFromiCloudUI()
                            return
                        }
                        
                        guard let randomKey = dic["random"] else {
                            self?.initVideoLoadFailedFromiCloudUI()
                            return
                        }
                        
                        url = URL(string: "\(anURL)/media/random/\(String(describing: randomKey))")
//                        self?.player = SGPlayer.init()
//                        self?.player?.decoder = SGPlayerDecoder.byDefault()
//
//                        self?.player?.registerNotificationTarget(self!, stateAction: #selector(self?.stateAction(_:)), progressAction: #selector(self?.progressAction(_:)), playableAction: #selector(self?.playableAction(_:)), errorAction: #selector(self?.errorAction(_:)))
//
//                        //                        // display view tap action.
//
//                        self?.player?.viewTapAction = { player, view in
//                            print("player display view did click!")
//                        }
//                        //                        // playback plane video.
//                        self?.player?.replaceVideo(with: url, videoType: SGVideoType.normal)
//                        //                        [self.player replaceVideoWithURL:contentURL videoType:SGVideoTypeNormal]; // 方式2
//                        //
//                        //                        // playback 360° panorama video.
//                        //                        [self.player replaceVideoWithURL:contentURL videoType:SGVideoTypeVR];
//                        //
//                        //                        // start playing
//                        self?.player?.play()
                    }
                }
            }else{
                print(response.error as Any)
            }
        }
    }
    @objc func playableAction(_ notification:Notification){
        
    }
    
    @objc func errorAction(_ notification:Notification){
//        let error = SGError.error(fromUserInfo: notification.userInfo!)
//        print("player did error : \(error.error)")
    }
    
    @objc func progressAction(_ notification:Notification){
        
    }
    
    @objc func stateAction(_ notification:Notification){
        
    }
    
    func initUI(){
        hasObserverStatus = false
        self.addSubview(self.imageView)
        self.addSubview(self.playBtn)
        self.addSubview(self.indicator)
        self.addSubview(self.icloudLoadFailedLabel)
    }
    
    func initVideoLoadFailedFromiCloudUI(){
        self.icloudLoadFailedLabel.isHidden = false
        self.playBtn.isEnabled = false
    }
    
    func haveLoadVideo()->Bool{
    return playLayer != nil ? true : false
    }
    
    func stopPlayVideo(){
        if (playLayer == nil) {
            return
        }
        self.playBtn.isHidden = false
        
    }
    
    func singleTapAction(){
      super.singleTapAction(nil)
    
    }
    
    func startPlayVideo(){
        if self.playLayer?.player == nil {
            if self.wsAsset?.type == .Video{
                PHPhotoLibrary.requestVideo(for: self.wsAsset?.asset, completion: { (item, info) in
                    DispatchQueue.main.async {
                        if item == nil {
                            self.initVideoLoadFailedFromiCloudUI()
                            return
                        }
                        let player = AVPlayer.init(playerItem: item)
                        self.layer.addSublayer(self.playLayer!)
                        self.playLayer?.player = player
                        self.switchVideoStatus()
                        do {
                           try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                        }catch{
                            
                        }
                        self.playLayer?
                            .rx
                            .observe(AVPlayerItem.self, "status")
                            .subscribe(onNext: { [weak self] (newValue) in
                                
                                if let playerItem:AVPlayerItem = newValue {
                                    switch playerItem.status{
                                    case .readyToPlay : self?.imageView.isHidden = true
                                    case .unknown : Message.message(text: LocalizedString(forKey: "Error:Unkown error"))
                                    case .failed: Message.message(text: LocalizedString(forKey: "Error"))
                                        
                                    }
                                }
                            })
                            .disposed(by: self.disposeBag)
                        self.hasObserverStatus = true
                        defaultNotificationCenter()
                            .rx
                            .notification(NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
                            .subscribe(onNext: { (notification) in
                                self.playBtn.isHidden = false
                                self.imageView.isHidden = false
                                self.playLayer?.player?.seek(to: kCMTimeZero)
                            })
                          .disposed(by: self.disposeBag)
                    }
                })
            }else {
                if AppNetworkService.networkState == .normal{
                 Message.message(text: LocalizedString(forKey: "Operation not support"))
                }
            }
        } else {
            self.switchVideoStatus()
        }
    }

    func switchVideoStatus(){
        let player = self.playLayer?.player
        let stop = player?.currentItem?.currentTime
        let duration = player?.currentItem?.duration
        if player?.rate == 0.0 {
            self.playBtn.isHidden = true
            if  stop?().value == duration?.value  {
                player?.currentItem?.seek(to: CMTime.init(value: 0, timescale: 1))
            }
    
            let playerViewController = AVPlayerViewController.init()
            playerViewController.delegate = self
            playerViewController.player = player
            if let delegateOK = self.delegate{
                delegateOK.playVideo(viewController: playerViewController)
            }
            playerViewController.player?.play()
        }else{
            self.playBtn.isHidden = false
            player?.pause()
        }
    }
    
    @objc func playBtnClick(_ sender:UIButton?){
        self.startPlayVideo()
    }
    
    
    lazy var icloudLoadFailedLabel: UILabel = {
        let str = NSMutableAttributedString.init()
        //创建图片附件
        let attach = NSTextAttachment.init()
        //        attach.image = GetImageWithName(@"videoLoadFailed");
        attach.bounds = CGRect(x: 0, y: -10, width: 30, height: 30)
        //创建属性字符串 通过图片附件
        let attrStr = NSAttributedString.init(attachment: attach)
        //把NSAttributedString添加到NSMutableAttributedString里面
        str.append(attrStr)
        
        let label = UILabel.init(frame: CGRect(x: 5, y: 70, width: 200, height: 35))
        label.font = UIFont.systemFont(ofSize: 12)
        label.attributedText = str
        label.textColor = UIColor.white
        return label
    }()
    
    lazy var playBtn: UIButton = {
        let button = UIButton.init(frame: CGRect(origin: self.center, size: CGSize(width:80, height: 80)))
        button.setImage(UIImage.init(named: "play_video.png"), for: UIControlState.normal)
        button.addTarget(self, action: #selector(playBtnClick(_ :)), for: UIControlEvents.touchUpInside)
        self.bringSubview(toFront: button)
        return button
    }()
    
    lazy var playLayer: AVPlayerLayer? = {
        let player = AVPlayerLayer.init()
        player.frame = self.bounds
        return player
    }()
}

extension WSPreviewVideo:AVPlayerViewControllerDelegate{
    
}

class WSPreviewView: UIView {
    
    var showGif:Bool?
    var singleTapCallBack:(()->())?
    var showLivePhoto = false
    var model:Any?{
        didSet{
            for view in self.subviews{
               view.removeFromSuperview()
            }
            if model is WSAsset{
                let assetModel = model as! WSAsset
                switch assetModel.type {
                case .Image?,.GIF?:
                    self.addSubview(self.imageGifView)
                    
                    if assetModel is NetAsset {
                        return self.imageGifView.loadImage(asset:assetModel)
                    }
                    self.imageGifView.loadNormalImage(asset: assetModel)
                case .LivePhoto?:
                    if (self.showLivePhoto) {
                        self.addSubview(self.livePhotoView)
                        self.livePhotoView.loadNormalImage(asset:assetModel)
                    } else {
                        self.addSubview(self.imageGifView)
                        self.imageGifView.loadNormalImage(asset: assetModel)
                    }
                case .Video?:
                    self.addSubview(self.videoView)
                    self.videoView.loadNormalImage(asset: assetModel)
                    
                case .NetImage?:
                    self.addSubview(self.imageGifView)
                    self.imageGifView.loadImage(asset: assetModel)
                    
                case .NetVideo? :
                    self.addSubview(self.videoView)
                    self.videoView.loadNetNormalImage(asset: assetModel)
                default:
                    break
                }
            }else{
                self.addSubview(self.imageGifView)
                let filesModel = model as! EntriesModel
                if let type = filesModel.metadata?.type{
                    if  kVideoTypes.contains(type.lowercased()) {
                        self.videoView.loadNetNormalImage(filesModel: filesModel)
                    }else if kImageTypes.contains(type.lowercased()){
                        self.imageGifView.loadImage(filesModel: filesModel)
                    }
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if model is WSAsset{
            let assetModel = model as! WSAsset
            switch assetModel.type {
            case .Image?,.GIF?:
                self.imageGifView.frame = self.bounds
            case .LivePhoto?:
                if !self.showLivePhoto {
                    self.imageGifView.frame = self.bounds
                }else{
                    self.livePhotoView.frame = self.bounds
                }
            case .Video?,.NetVideo?:
                self.videoView.frame = self.bounds
            default:
                break
            }
        }else{
             self.imageGifView.frame = self.bounds
        }
    }
    
    func imageViewFrame() -> CGRect{
        if model is WSAsset{
            let assetModel = model as! WSAsset
            switch assetModel.type {
            case .Image?,.GIF?,.NetImage?:
                return self.imageGifView.containerView.frame
            case .LivePhoto?:
                if !self.showLivePhoto {
                    return self.imageGifView.containerView.frame
                }else{
                    return self.livePhotoView.lpView.frame
                }
            case .Video?,.NetVideo?:
                return self.videoView.playLayer?.frame ?? CGRect.zero
            default:
                break
            }
        }else{
             return self.imageGifView.containerView.frame
        }
        return CGRect.zero
    }
    
    func reload(){
        if model is WSAsset{
            let assetModel = model as! WSAsset
            if self.showGif! &&
                assetModel.type == .GIF {
                if assetModel is NetAsset {
                    self.imageGifView.loadImage(asset: assetModel)
                    return
                }
                self.imageGifView.loadGifImage(asset: assetModel)
            } else if self.showLivePhoto &&
                assetModel.type == .LivePhoto {
                self.livePhotoView.loadLivePhoto(asset: assetModel)
            }
        }else{
            let filesModel = model as! EntriesModel
            self.imageGifView.loadImage(filesModel: filesModel)
        }
    }

    func resumePlay(){
        if model is WSAsset{
            let assetModel = model as! WSAsset
            if assetModel.type == .GIF {
                self.imageGifView.resumeGif()
            }
        }
    }
    
    func pausePlay(){
        if model is WSAsset{
             let assetModel = model as! WSAsset
            switch assetModel.type{
            case .GIF? :
                self.imageGifView.pauseGif()
            case .LivePhoto? :
                self.livePhotoView.stopPlayLivePhoto()
            case .Video?,.NetVideo?:
                self.videoView.stopPlayVideo()
            default: break
                
            }
        }else{
            
        }
    }
    
    func handlerEndDisplaying(){
        if model is WSAsset{
            let assetModel = model as! WSAsset
            switch assetModel.type {
            case .GIF?:
                if  (self.imageGifView.imageView.image?.isKind(of: NSClassFromString("_UIAnimatedImage")!))!{
                    self.imageGifView.loadNormalImage(asset: assetModel)
                }
            case .Video?:
                if self.videoView.haveLoadVideo() {
                    self.videoView.loadNormalImage(asset: assetModel)
                }
            default:
                break
            }
        }else{
            
        }
    }
    
    func resetScale(){
      self.imageGifView.resetScale()
    }
    
    func image() ->UIImage?{
        if model is WSAsset{
            let assetModel = model as! WSAsset
            if  assetModel.type == .Image {
                return self.imageGifView.imageView.image
            }
        }else{
             return self.imageGifView.imageView.image
        }
        return nil
    }

    lazy var imageGifView: WSPreviewImageAndGif = {
        let imageView = WSPreviewImageAndGif.init(frame: self.bounds)
        imageView.singleTapCallback = self.singleTapCallBack
        return imageView
    }()

    lazy var livePhotoView: WSPreviewLivePhoto = {
        let imageView = WSPreviewLivePhoto.init(frame: self.bounds)
        imageView.singleTapCallback = self.singleTapCallBack
        return imageView
    }()
    
    lazy var videoView: WSPreviewVideo = {
        let imageView = WSPreviewVideo.init(frame: self.bounds)
        imageView.singleTapCallback = self.singleTapCallBack
        return imageView
    }()
}

class WSBigimgCollectionViewCell: UICollectionViewCell {
    var singleTapCallBack:(()->())?
    var loadImageCompleteCallback:(()->())?
    var showGif:Bool = false
    var showLivePhoto:Bool = false
    var willDisplaying:Bool = false
    var model:Any?{
        didSet{
            self.previewView.showGif = self.showGif
            self.previewView.showLivePhoto = self.showLivePhoto
            self.previewView.model = model
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(previewView)
        previewView.singleTapCallBack = { [weak self] in
            if let singleTapCallBack = self?.singleTapCallBack {
                singleTapCallBack()
            }
        }
        
        previewView.imageGifView.loadCompleteCallback = { [weak self] in
            if let loadImageCompleteCallback = self?.loadImageCompleteCallback{
                loadImageCompleteCallback()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetCellStatus(){
        self.previewView.resetScale()
    }
    
    func reloadGifLivePhoto(){
        if  self.willDisplaying {
            self.willDisplaying = false
            self.previewView.reload()
        } else {
            self.previewView.resumePlay()
        }
    }
    
    func pausePlay(){
        self.previewView.pausePlay()
    }
    
    lazy var previewView: WSPreviewView = {
        let view = WSPreviewView.init(frame: self.bounds)
        view.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.RawValue(UInt8(UIViewAutoresizing.flexibleWidth.rawValue) | UInt8(UIViewAutoresizing.flexibleHeight.rawValue)))
        return view
    }()
}



