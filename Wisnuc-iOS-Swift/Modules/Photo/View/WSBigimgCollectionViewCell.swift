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
    
    var drive:String?
    
    var dir:String?
    
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
        // 2.根据Data获取CGImageSource对象
        guard let img = self.imageView.image else { return }
        guard let data = UIImagePNGRepresentation(img) as Data? else { return }
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else { return }
        
        // 3.获取gif图片中图片的个数
        let frameCount = CGImageSourceGetCount(imageSource)
        // 记录播放时间
        var duration : TimeInterval = 0
        var images = [UIImage]()
        for i in 0..<frameCount {
            // 3.1.获取图片
            guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, i, nil) else { continue }
            // 3.2.获取时长
            guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil) , let gifInfo = (properties as NSDictionary)[kCGImagePropertyGIFDictionary as String] as? NSDictionary,
                let frameDuration = (gifInfo[kCGImagePropertyGIFDelayTime as String] as? NSNumber) else { continue }
            duration += frameDuration.doubleValue
            let image = UIImage(cgImage: cgImage)
            images.append(image)
            // 设置停止播放时现实的图片
            if i == frameCount - 1 {
                imageView.image = image
            }
        }
        // 4.播放图片
        imageView.animationImages = images
        // 播放总时间
        imageView.animationDuration = duration
        // 播放次数, 0为无限循环
        imageView.animationRepeatCount = 1
        // 开始播放
        imageView.startAnimating()
        // 停止播放
        // imageView.stopAnimating()
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
//        self.imageView.image = asset.image
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
        if let requestImageUrl = self.requestImageUrl(model: asset as! NetAsset){
            ImageCache.default.retrieveImage(forKey: requestImageUrl, options: nil) { [weak self]
                image, cacheType in
                if let image = image {
                    self?.indicator.stopAnimating()
                    self?.loadOK = true
                    self?.imageView.image = image
                    if asset.type == WSAssetType.GIF{
                        self?.resumeGif()
                    }
                    self?.resetSubviewSize(image)
                    print("Get image \(image), cacheType: \(cacheType).")
                    //In this code snippet, the `cacheType` is .disk
                } else {
                    guard let imageUrl =  URL.init(string: requestImageUrl) else{
                        return
                    }
                    self?.imageDownloadTask = AppNetworkService.getHighWebImage(url: imageUrl, callback: { [weak self] (error, img) in
                        self?.indicator.stopAnimating()
                        if let completeCallback = self?.loadCompleteCallback{
                            completeCallback()
                        }
                        if error != nil {
//                            Message.message(text: "图片加载失败", duration: 1.4)
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
            }
        }else{
            self.indicator.stopAnimating()
//            Message.message(text: "图片加载失败", duration: 1.4)
        }
    }
    
    func loadImage(filesModel:EntriesModel){
//        self.imageView.image = nil

        if(self.imageDownloadTask != nil){
            imageDownloadTask?.cancel()
            self.imageDownloadTask = nil
        }
        self.filesModel = filesModel
        self.indicator.startAnimating()
      
        if let requestImageUrl = self.requestImageUrl(filesModel: filesModel){
            ImageCache.default.retrieveImage(forKey: requestImageUrl, options: nil) { [weak self]
                image, cacheType in
                if let image = image {
                    self?.indicator.stopAnimating()
                    self?.loadOK = true
                    self?.imageView.image = image
                    if(filesModel.metadata?.type?.caseInsensitiveCompare(FilesFormatType.GIF.rawValue) == .orderedSame){
                        self?.resumeGif()
                    }
                    self?.resetSubviewSize(image)
                    print("Get image \(image), cacheType: \(cacheType).")
                    //In this code snippet, the `cacheType` is .disk
                } else {
                    guard let imageUrl =  URL.init(string: requestImageUrl) else{
                        return
                    }
                    self?.imageDownloadTask = AppNetworkService.getHighWebImage(url: imageUrl, callback: { [weak self] (error, img) in
                        
                        if error != nil {
//                            Message.message(text: "图片加载失败", duration: 1.4)
                            // TODO: Load Error Image
                        } else {
                            self?.loadOK = true
                            self?.imageView.image = img
                            if (filesModel.metadata?.type?.caseInsensitiveCompare(FilesFormatType.GIF.rawValue) == .orderedSame){
                                self?.resumeGif()
                            }
                            self?.resetSubviewSize(img)
                        }
                        self?.imageDownloadTask = nil
                        self?.indicator.stopAnimating()
                        
                        if let completeCallback = self?.loadCompleteCallback{
                            completeCallback()
                        }
                    })
                }
            }
        }else{
            self.indicator.stopAnimating()
//            Message.message(text: "图片加载失败", duration: 1.4)
        }
    }

//    func requestImageUrl(hash:String?)->URL?{
//        guard let digest = hash else {
//            return nil
//        }
//        let detailURL = "media"
//        let resource = "/media/\(digest)"
//        let param = "\(kRequestImageAltKey)=\(kRequestImageDataValue)"
//        ImageDownloader.default.downloadTimeout = 20000
//
//        let params:[String:String] = [kRequestImageAltKey:kRequestImageDataValue]
//        let dataDic = [kRequestUrlPathKey:resource,kRequestVerbKey:RequestMethodValue.GET,"params":params] as [String : Any]
//        guard let data = jsonToData(jsonDic: dataDic as NSDictionary) else {
//            return nil
//        }
//
//        guard let dataString = String.init(data: data, encoding: .utf8) else {
//            return nil
//        }
//
//        guard let urlString = String.init(describing:"\(kCloudBaseURL)\(kCloudCommonPipeUrl)?data=\(dataString)").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
//            return nil
//        }
//
//        guard  let normalUrl = URL.init(string:urlString) else {
//            return nil
//        }
//        //                req.addValue(dataString, forHTTPHeaderField: kRequestImageDataValue)
//        guard let url = AppNetworkService.networkState == .local ? URL.init(string: "\(RequestConfig.sharedInstance.baseURL!)/\(detailURL)/\(digest)?\(param)") : normalUrl else {
//            return nil
//        }
//
//        return url
//    }
    
    func requestImageUrl(model:NetAsset) -> String?{
        guard let userHome = AppUserService.currentUser?.userHome else{
            return nil
        }
        
        var placesArray = Array<String>.init()
        placesArray.append(userHome)
        
        if let shareSpace = AppUserService.currentUser?.shareSpace{
             placesArray.append(shareSpace)
        }
        
         let backArray = AppUserService.backupArray.map({$0.uuid})
        for uuid in backArray{
            if let uuid = uuid{
                 placesArray.append(uuid)
            }
        }
        
        guard let place = model.place else {
            return nil
        }
        
        var driveUUID = placesArray[place]
        
        if let drive = self.drive{
            driveUUID = drive
        }
        
        guard let directoryUUID = model.pdir else {
            return nil
        }
        
        guard let uuid = model.uuid else {
            return nil
        }
        
        let name = model.name ?? ""
        
        switch AppNetworkService.networkState {
        case .normal?:
            let urlPath = "/drives/\(String(describing: driveUUID))/dirs/\(String(describing: directoryUUID))/entries/\(String(describing: uuid))"
            var params = ["name":name]
            if backArray.contains(driveUUID){
                if let hash = model.fmhash{
                    params = ["hash":hash]
                }
            }else if self.drive != nil{
                if let hash = model.fmhash{
                    params = ["hash":hash]
                }
            }
            let dataDic = [kRequestUrlPathKey:urlPath,kRequestVerbKey:RequestMethodValue.GET,"params":params] as [String : Any]
            guard let data = jsonToData(jsonDic: dataDic as NSDictionary) else {
                return nil
            }
            
            guard let dataString = String.init(data: data, encoding: .utf8) else {
                return nil
            }
            
            guard let urlString = String.init(describing:"\(kCloudBaseURL)\(kCloudCommonPipeUrl)?data=\(dataString)").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
                return nil
            }
            
            return urlString
        case .local?:
            guard let baseURL = RequestConfig.sharedInstance.baseURL else {
                return nil
            }
            
            var localUrl = "\(String(describing: baseURL))/drives/\(String(describing: driveUUID))/dirs/\(String(describing: directoryUUID))/entries/\(String(describing: uuid))?name=\(String(describing: name))"
            if backArray.contains(driveUUID){
                if let hash = model.fmhash{
                   localUrl = "\(String(describing: baseURL))/drives/\(driveUUID)/dirs/\( directoryUUID)/entries/\(uuid)?hash=\(hash)"
                }
            }else if self.drive != nil{
                if let hash = model.fmhash{
                   localUrl = "\(String(describing: baseURL))/drives/\(driveUUID)/dirs/\( directoryUUID)/entries/\(uuid)?hash=\(hash)"
                }
            }
            return localUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        default:
            break
        }
        return nil
    }
    
    
    func requestImageUrl(filesModel:EntriesModel) -> String?{
        guard let userHome = AppUserService.currentUser?.userHome else{
            return nil
        }
        
        var placesArray = Array<String>.init()
        placesArray.append(userHome)
        
        if let shareSpace = AppUserService.currentUser?.shareSpace{
            placesArray.append(shareSpace)
        }
        
        let backArray = AppUserService.backupArray.map({$0.uuid})
        for uuid in backArray{
            if let uuid = uuid{
                placesArray.append(uuid)
            }
        }
        
        
        var  driveUUID:String?
        if let place = filesModel.place  {
             driveUUID = placesArray[place]
        }
        
        if let drive = self.drive{
            driveUUID = drive
        }
        
        
        if driveUUID == nil{
            return nil
        }
        
        var directoryUUID:String?
        
        if let pdir = filesModel.pdir {
            directoryUUID = pdir
        }
        
        if let dir = self.dir {
            directoryUUID = dir
        }
        
        if directoryUUID == nil{
            return nil
        }
        
        guard let uuid = filesModel.uuid else {
            return nil
        }
        
        let name = filesModel.name ?? ""
        
        switch AppNetworkService.networkState {
        case .normal?:
            let urlPath = "/drives/\(String(describing: driveUUID!))/dirs/\(String(describing: directoryUUID!))/entries/\(String(describing: uuid))"
            var params = ["name":name]
            if let hash = filesModel.hash, filesModel.bname != nil{
                params = ["hash":hash]
            }
            let dataDic = [kRequestUrlPathKey:urlPath,kRequestVerbKey:RequestMethodValue.GET,"params":params] as [String : Any]
            guard let data = jsonToData(jsonDic: dataDic as NSDictionary) else {
                return nil
            }
            
            guard let dataString = String.init(data: data, encoding: .utf8) else {
                return nil
            }
            
            guard let urlString = String.init(describing:"\(kCloudBaseURL)\(kCloudCommonPipeUrl)?data=\(dataString)").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
                return nil
            }
            
            return urlString
        case .local?:
            guard let baseURL = RequestConfig.sharedInstance.baseURL else {
                return nil
            }
            
            var localUrl = "\(String(describing: baseURL))/drives/\(String(describing: driveUUID!))/dirs/\(String(describing: directoryUUID!))/entries/\(String(describing: uuid))?name=\(String(describing: name))"
            if let hash = filesModel.hash, filesModel.bname != nil{
                localUrl = "\(String(describing: baseURL))/drives/\(driveUUID!)/dirs/\( directoryUUID!)/entries/\(uuid)?hash=\(hash)"
            }
            return localUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        default:
            break
        }
        return nil
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
    private var kVideoCover = "https://upload-images.jianshu.io/upload_images/635942-14593722fe3f0695.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240"
    var disposeBag = DisposeBag()
    var player: ZFPlayerController?
    var request:BaseRequest?
    weak var delegate:SWPreviewVideoPlayerDelegate?
    private var hasObserverStatus:Bool = false
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
        if let containerView = self.containerView{
            self.addSubview(containerView)
        }
//containerView.addSubview(playBtn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        defaultNotificationCenter().removeObserver(self)
        if let request = request{
            request.cancel()
        }
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = self.bounds
        self.playLayer.frame = self.bounds
//        self.playBtn.center = self.center
    
//        w = 44
//        h = w
//        x = (containerView.frame.width - w) / 2
//        y = (containerView.frame.height - h) / 2
//        playBtn.frame = CGRect(x: x, y: y, width: w, height: h)
//        w = 100
//        h = 30
//        x = (view.frame.width - w) / 2
//        y = containerView.frame.maxY + 50
//        changeBtn.frame = CGRect(x: x, y: y, width: w, height: h)
//        w = 100
//        h = 30
//        x = (view.frame.width - w) / 2
//        y = changeBtn.frame.maxY + 50
//        nextBtn.frame = CGRect(x: x, y: y, width: w, height: h)
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
        
//        self.playBtn.isEnabled = true
//        self.playBtn.isHidden = false
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
        let playerManager = ZFAVPlayerManager()
        //    KSMediaPlayerManager *playerManager = [[KSMediaPlayerManager alloc] init];
        //    ZFIJKPlayerManager *playerManager = [[ZFIJKPlayerManager alloc] init];
        /// 播放器相关
  
        let videoSize = self.screenDisplaySize(size: size)
//        let w: CGFloat = self.frame.width
//
//        let h: CGFloat = w * 9 / 16
//        let x: CGFloat = 0
//        let y: CGFloat = self.height/2 - h/2
        
        containerView?.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)
        self.player = ZFPlayerController.player(withPlayerManager: playerManager, containerView: (self.containerView)!)
        self.player?.disableGestureTypes = ZFPlayerDisableGestureTypes.pan
        //                        self?.player?.
        self.player?.controlView = (self.controlView)!
        /// 设置退到后台继续播放
        self.player?.pauseWhenAppResignActive = false
        self.player?.orientationWillChange = { [weak self](player, isFullScreen) in
            if isFullScreen{
                player.disableGestureTypes = ZFPlayerDisableGestureTypes.init(rawValue: 0)
            }else{
                player.disableGestureTypes = ZFPlayerDisableGestureTypes.pan
            }
        }
        
        /// 播放完成
        self.player?.playerDidToEnd = { [weak self] (asset) in
            if let replay = self?.player?.currentPlayerManager.replay{
                replay()
            }
   
        }
        self.player?.playerPrepareToPlay = { asset, assetURL in
            self.imageView.image = nil
            print("======开始播放了")
        }
        PHPhotoLibrary.requestVideo(for: asset.asset) { (aVPlayerItem, dict) in
            if let urlAsset = aVPlayerItem?.asset as? AVURLAsset{
                DispatchQueue.main.async {
                    self.player?.assetURLs = [urlAsset.url]
                    self.player?.playTheIndex(0)
                }
            }
        }
    }
    
    func screenDisplaySize(size:CGSize?)->CGRect{
        let imageSize: CGSize = size ?? UIScreen.main.bounds.size
        let targetSize: CGSize = UIScreen.main.bounds.size
        let width: CGFloat = imageSize.width
        let height: CGFloat = imageSize.height
        let targetWidth: CGFloat = targetSize.width
        let targetHeight: CGFloat = targetSize.height
        var scaleFactor: CGFloat = 0.0
        var scaledWidth: CGFloat = targetWidth
        var scaledHeight: CGFloat = targetHeight
        var thumbnailPoint = CGPoint(x: 0.0, y: 0.0)
        if imageSize.equalTo(targetSize) == false {
            let widthFactor: CGFloat = targetWidth / width
            let heightFactor: CGFloat = targetHeight / height
            if widthFactor < heightFactor {
                scaleFactor = widthFactor
            } else {
                scaleFactor = heightFactor
            }
            scaledWidth = width * scaleFactor
            scaledHeight = height * scaleFactor
            // center the image
            if widthFactor < heightFactor {

                thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5
            } else if widthFactor > heightFactor {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5
            }
        }
        
        var thumbnailRect = CGRect.zero
        thumbnailRect.origin = thumbnailPoint
        thumbnailRect.size.width = scaledWidth
        thumbnailRect.size.height = scaledHeight
        return thumbnailRect
    }
    
    @objc func playFinished(_ item: AVPlayerItem) {
        //    [super singleTapAction];
//        self.playBtn.isHidden = false
        self.imageView.isHidden = false
        let time = CMTime.init(seconds: 0, preferredTimescale: 600)
        self.playLayer.player?.seek(to: time)
    }
    
    @objc func playEnd(_ notification: Notification) {
    }
    
    func loadNetNormalImage(asset:WSAsset){
        if AppNetworkService.networkState == .normal{
            SVProgressHUD.showError(withStatus: "暂不支持远程视频播放")
            return
        }
        
        guard let hash = (asset as? NetAsset)?.fmhash else{
            return
        }
        
        
        let scale = UIScreen.main.scale
        let width = MIN(x: __kWidth, y: CGFloat(kMaxImageWidth))
        
        let w = (asset as? NetAsset)?.metadata?.w
        let h = (asset as? NetAsset)?.metadata?.h
        let size = CGSize(width: width*scale, height: width*scale*CGFloat(w ?? Float(__kWidth))/CGFloat(h ?? Float(__kHeight)))
        
        let _ = AppNetworkService.getThumbnail(hash: hash, size: CGSize(width: CGFloat(w ?? Float(__kWidth)), height: CGFloat( h ?? Float(self.frame.width * 9 / 16)))) { (error, image, url) in
            if let image = image{
                self.containerView?.image = image
            }
        }
        
        if (self.wsAsset?.asset != nil && self.imageRequestID != nil) {
            if self.imageRequestID! >= 0{
                PHCachingImageManager.default().cancelImageRequest(self.imageRequestID!)
            }
        }
        self.wsAsset = asset
        playLayer.player = nil
        playLayer.removeFromSuperlayer()
        hasObserverStatus = false
    
        self.imageView.image = nil
//        self.playBtn.isEnabled = true
//        self.playBtn.isHidden = false
        self.icloudLoadFailedLabel.isHidden = true
        self.imageView.isHidden = false
        self.indicator.startAnimating()
       
        
        let request = MediaRandomAPI.init(hash: hash)
        self.request = request
        request.startRequestJSONCompletionHandler { [weak self](response) in
            self?.indicator.stopAnimating()
            if response.error == nil{
                DispatchQueue.main.async {
                    if let anURL = AppUserService.currentUser?.localAddr {
                        guard let dataDic = response.value as? NSDictionary else {
                            return
                        }
                        
                        guard let random = dataDic["random"] as? String else {
                            return
                        }
                        
                        guard let url = URL(string: "\(anURL)/media/\(random)") else{
                            return
                        }
                        
                        self?.indicator.stopAnimating()
                        let playerManager = ZFAVPlayerManager()
                        //    KSMediaPlayerManager *playerManager = [[KSMediaPlayerManager alloc] init];
                        //    ZFIJKPlayerManager *playerManager = [[ZFIJKPlayerManager alloc] init];
                        /// 播放器相关
//                        playerManager.play()
                
                        let videoSize = self?.screenDisplaySize(size: size)
                        //        let w: CGFloat = self.frame.width
                        //
                        //        let h: CGFloat = w * 9 / 16
                        //        let x: CGFloat = 0
                        //        let y: CGFloat = self.height/2 - h/2
                        
                        self?.containerView?.frame = CGRect(x: 0, y: 0, width: (videoSize?.width)!, height: (videoSize?.height)!)
                        self?.player = ZFPlayerController.player(withPlayerManager: playerManager, containerView: (self?.containerView)!)
                        self?.player?.disableGestureTypes = ZFPlayerDisableGestureTypes.pan
//                        self?.player?.
                        self?.player?.controlView = (self?.controlView)!
                        /// 设置退到后台继续播放
                        self?.player?.pauseWhenAppResignActive = false
                        self?.player?.orientationWillChange = { [weak self](player, isFullScreen) in
                            if isFullScreen{
                                player.disableGestureTypes = ZFPlayerDisableGestureTypes.init(rawValue: 0)
                            }else{
                                player.disableGestureTypes = ZFPlayerDisableGestureTypes.pan
                            }
                        }
                        
                        /// 播放完成
                        self?.player?.playerDidToEnd = { [weak self] (asset) in
                            if let replay = self?.player?.currentPlayerManager.replay{
                                replay()
                            }
                            //        [self.player playTheNext];
                            //        if (!self.player.isLastAssetURL) {
                            //            NSString *title = [NSString stringWithFormat:@"视频标题%zd",self.player.currentPlayIndex];
                            //            [self.controlView showTitle:title coverURLString:kVideoCover fullScreenMode:ZFFullScreenModeLandscape];
                            //        } else {
                            //            [self.player stop];
                            //        }
                            //        [self.player stop];
                        }
                        self?.player?.playerPrepareToPlay = { asset, assetURL in
                            print("======开始播放了")
                        }
                
                        self?.player?.assetURLs = [url]
                        
                        self?.player?.playTheIndex(0)

//                        let player = AVPlayer(url: url)
//                        self?.playLayer.player = player
//                        self?.switchVideoStatus()
//                        self?.playLayer.addObserver(self!, forKeyPath: "status", options: .new, context: nil)
//                            do {
//                                try  AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
//                            }catch{
//
//                            }
//
//                        self?.hasObserverStatus = true
//                        NotificationCenter.default.addObserver(self!, selector: #selector(self?.playFinished(_:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
//                        NotificationCenter.default.addObserver(self, selector: #selector(playEnd(_:)), name: Notification.Name.mpmove, object: player)

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
//        self.playBtn.isEnabled = true
//        self.playBtn.isHidden = false
        self.icloudLoadFailedLabel.isHidden = true
        self.imageView.isHidden = false
//        if AppNetworkService.networkState == .normal{
//            Message.message(text: LocalizedString(forKey: "Operation not support"))
//        }
        //
        self.indicator.startAnimating()
        guard let hash = filesModel.hash  else {
           return
        }
        
        let scale = UIScreen.main.scale
        let width = MIN(x: __kWidth, y: CGFloat(kMaxImageWidth))
        
        let w = filesModel.metadata?.w
        let h = filesModel.metadata?.h
        let size = CGSize(width: width*scale, height: width*scale*CGFloat(w ?? Float(__kWidth))/CGFloat(h ?? Float(__kHeight)))
        
        let _ = AppNetworkService.getThumbnail(hash: hash, size: CGSize(width: CGFloat(w ?? Float(__kWidth)), height: CGFloat( h ?? Float(self.frame.width * 9 / 16)))) { (error, image, url) in
            if let image = image{
                self.containerView?.image = image
            }
        }
        
        playLayer.player = nil
        playLayer.removeFromSuperlayer()
        hasObserverStatus = false
        
        self.imageView.image = nil
        //        self.playBtn.isEnabled = true
        //        self.playBtn.isHidden = false
        self.icloudLoadFailedLabel.isHidden = true
        self.imageView.isHidden = false
        self.indicator.startAnimating()
        
        
        let request = MediaRandomAPI.init(hash: hash)
        self.request = request
        request.startRequestJSONCompletionHandler { [weak self](response) in
            self?.indicator.stopAnimating()
            if response.error == nil{
                DispatchQueue.main.async {
                    if let anURL = AppUserService.currentUser?.localAddr {
                        guard let dataDic = response.value as? NSDictionary else {
                            return
                        }
                        
                        guard let random = dataDic["random"] as? String else {
                            return
                        }
                        
                        guard let url = URL(string: "\(anURL)/media/\(random)") else{
                            return
                        }
                        
                        self?.indicator.stopAnimating()
                        let playerManager = ZFAVPlayerManager()
                        //    KSMediaPlayerManager *playerManager = [[KSMediaPlayerManager alloc] init];
                        //    ZFIJKPlayerManager *playerManager = [[ZFIJKPlayerManager alloc] init];
                        /// 播放器相关
                        //                        playerManager.play()
                        
                        let videoSize = self?.screenDisplaySize(size: size)
                        //        let w: CGFloat = self.frame.width
                        //
                        //        let h: CGFloat = w * 9 / 16
                        //        let x: CGFloat = 0
                        //        let y: CGFloat = self.height/2 - h/2
                        
                        self?.containerView?.frame = CGRect(x: 0, y: 0, width: (videoSize?.width)!, height: (videoSize?.height)!)
                        self?.player = ZFPlayerController.player(withPlayerManager: playerManager, containerView: (self?.containerView)!)
                        self?.player?.disableGestureTypes = ZFPlayerDisableGestureTypes.pan
                        //                        self?.player?.
                        self?.player?.controlView = (self?.controlView)!
                        /// 设置退到后台继续播放
                        self?.player?.pauseWhenAppResignActive = false
                        self?.player?.orientationWillChange = { [weak self](player, isFullScreen) in
                            if isFullScreen{
                                player.disableGestureTypes = ZFPlayerDisableGestureTypes.init(rawValue: 0)
                            }else{
                                player.disableGestureTypes = ZFPlayerDisableGestureTypes.pan
                            }
                        }
                        
                        /// 播放完成
                        self?.player?.playerDidToEnd = { [weak self] (asset) in
                            if let replay = self?.player?.currentPlayerManager.replay{
                                replay()
                            }
                            //        [self.player playTheNext];
                            //        if (!self.player.isLastAssetURL) {
                            //            NSString *title = [NSString stringWithFormat:@"视频标题%zd",self.player.currentPlayIndex];
                            //            [self.controlView showTitle:title coverURLString:kVideoCover fullScreenMode:ZFFullScreenModeLandscape];
                            //        } else {
                            //            [self.player stop];
                            //        }
                            //        [self.player stop];
                        }
                        self?.player?.playerPrepareToPlay = { asset, assetURL in
                            print("======开始播放了")
                        }
                        
                        self?.player?.assetURLs = [url]
                        
                        self?.player?.playTheIndex(0)
                        
                        //                        let player = AVPlayer(url: url)
                        //                        self?.playLayer.player = player
                        //                        self?.switchVideoStatus()
                        //                        self?.playLayer.addObserver(self!, forKeyPath: "status", options: .new, context: nil)
                        //                            do {
                        //                                try  AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                        //                            }catch{
                        //
                        //                            }
                        //
                        //                        self?.hasObserverStatus = true
                        //                        NotificationCenter.default.addObserver(self!, selector: #selector(self?.playFinished(_:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
                        //                        NotificationCenter.default.addObserver(self, selector: #selector(playEnd(_:)), name: Notification.Name.mpmove, object: player)
                        
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
//        self.addSubview(self.playBtn)
        self.addSubview(self.indicator)
        self.addSubview(self.icloudLoadFailedLabel)
    }
    
    func initVideoLoadFailedFromiCloudUI(){
        self.icloudLoadFailedLabel.isHidden = false
//        self.playBtn.isEnabled = false
    }
    
    func haveLoadVideo()->Bool{
        return playLayer.player == nil ? true : false
    }
    
    func stopPlayVideo(){
//        if (playLayer == nil) {
//            return
//        }
//        self.playBtn.isHidden = false
        
    }
    
    func singleTapAction(){
      super.singleTapAction(nil)
    
    }
    
    func startPlayVideo(){
        if self.playLayer.player == nil {
            if self.wsAsset?.type == .Video{
                PHPhotoLibrary.requestVideo(for: self.wsAsset?.asset, completion: { (item, info) in
                    DispatchQueue.main.async {
                        if item == nil {
                            self.initVideoLoadFailedFromiCloudUI()
                            return
                        }
                        let player = AVPlayer.init(playerItem: item)
                        self.playLayer.player = player
                        self.switchVideoStatus()
                        do {
                           try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                        }catch{
                            
                        }
//                        self.playLayer
//                            .rx
//                            .observe(AVPlayerItem.self, "status")
//                            .subscribe(onNext: { [weak self] (newValue) in
//
//                                if let playerItem:AVPlayerItem = newValue {
//                                    switch playerItem.status{
//                                    case .readyToPlay : self?.imageView.isHidden = true
//                                    case .unknown : Message.message(text: LocalizedString(forKey: "Error:Unkown error"))
//                                    case .failed: Message.message(text: LocalizedString(forKey: "Error"))
//
//                                    }
//                                }
//                            })
//                            .disposed(by: self.disposeBag)
//                        self.hasObserverStatus = true
                        defaultNotificationCenter()
                            .rx
                            .notification(NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
                            .subscribe(onNext: { (notification) in
//                                self.playBtn.isHidden = false
                                self.imageView.isHidden = false
                                self.playLayer.player?.seek(to: kCMTimeZero)
                            })
                          .disposed(by: self.disposeBag)
                    }
                })
            }else {
                if AppNetworkService.networkState == .normal{
//                 Message.message(text: LocalizedString(forKey: "Operation not support"))
                }
            }
        } else {
            self.switchVideoStatus()
        }
    }

    func switchVideoStatus(){
        let player = self.playLayer.player
        let stop = player?.currentItem?.currentTime
        let duration = player?.currentItem?.duration
        if player?.rate == 0.0 {
//            self.playBtn.isHidden = true
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
//            self.playBtn.isHidden = false
            player?.pause()
        }
    }
    
    @objc func playBtnClick(_ sender:UIButton?){
        self.player?.playTheIndex(0)
//        self.controlView?.showTitle("视频标题", coverURLString: kVideoCover, fullScreenMode: ZFFullScreenMode.landscape)
////        self.startPlayVideo()
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
    
    private var _containerView: UIImageView? = nil
    var containerView: UIImageView?{
        get{
            if self._containerView == nil {
                _containerView = UIImageView()
                return _containerView
            }
            return  _containerView
        }
        
        set(newValue){
            self._containerView = newValue
        }
    }
    private var _controlView: ZFPlayerControlView? = nil
    var controlView : ZFPlayerControlView? {
        get{
            if self._controlView == nil {
                _controlView = ZFPlayerControlView()
                _controlView?.fastViewAnimated = true
//                controllerView.autoHiddenTimeInterval = 5
//                controllerView.autoFadeTimeInterval = 0.5
                return _controlView
            }
            return  _controlView
        }
        set(newValue){
            self._controlView = newValue
        }
    }
    
    
    lazy var playLayer: AVPlayerLayer = {
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
    var drive:String?
    var dir:String?
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
                    self.imageGifView.drive = self.drive
                    self.imageGifView.dir = self.dir
                    if assetModel is NetAsset {
                        return self.imageGifView.loadImage(asset:assetModel)
                    }
                    
                    self.imageGifView.loadNormalImage(asset: assetModel)
                case .LivePhoto?:
                    self.livePhotoView.drive = self.drive
                    self.livePhotoView.dir = self.dir
                    if (self.showLivePhoto) {
                        self.addSubview(self.livePhotoView)
                        self.livePhotoView.loadNormalImage(asset:assetModel)
                    } else {
                        self.addSubview(self.imageGifView)
                        self.imageGifView.loadNormalImage(asset: assetModel)
                    }
                case .Video?:
                    self.videoView.drive = self.drive
                    self.videoView.dir = self.dir
                    self.addSubview(self.videoView)
                    self.videoView.loadNormalImage(asset: assetModel)
                    
                case .NetImage?:
                    self.imageGifView.drive = self.drive
                    self.imageGifView.dir = self.dir
                    self.addSubview(self.imageGifView)
                    self.imageGifView.loadImage(asset: assetModel)
                    
                case .NetVideo? :
                    self.videoView.drive = self.drive
                    self.videoView.dir = self.dir
                    self.addSubview(self.videoView)
                    self.videoView.loadNetNormalImage(asset: assetModel)
                default:
                    break
                }
            }else{
                self.addSubview(self.imageGifView)
                let filesModel = model as! EntriesModel
                if let type = filesModel.metadata?.type{
                    if kVideoTypes.contains(where: {$0.caseInsensitiveCompare(type) == .orderedSame}) {
                        self.videoView.drive = self.drive
                        self.videoView.dir = self.dir
                        self.videoView.loadNetNormalImage(filesModel: filesModel)
                    }else if kImageTypes.contains(where: {$0.caseInsensitiveCompare(type) == .orderedSame}){
                        self.imageGifView.drive = self.drive
                        self.imageGifView.dir = self.dir
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
                return self.videoView.playLayer.frame
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
                if let image = self.imageGifView.imageView.image{
                    if let obj =  NSClassFromString("_UIAnimatedImage"){
                        if  image.isKind(of:obj){
                            self.imageGifView.loadNormalImage(asset: assetModel)
                        }
                    }
                }
//                "_UIAnimatedImage".
//                if  (self.imageGifView.imageView.image?.isKind(of: NSClassFromString("_UIAnimatedImage")!))!{
//                    self.imageGifView.loadNormalImage(asset: assetModel)
//                }
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
            } else if  assetModel.type == .NetImage {
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
    var drive:String?
    var dir:String?
    var showLivePhoto:Bool = false
    var willDisplaying:Bool = false
    var model:Any?{
        didSet{
            self.previewView.drive = self.drive
            self.previewView.dir = self.dir
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



