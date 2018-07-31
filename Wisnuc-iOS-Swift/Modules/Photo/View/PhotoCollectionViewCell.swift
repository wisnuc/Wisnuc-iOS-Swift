//
//  PhotoCollectionViewCell.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/7/9.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
//import MaterialComponents.MaterialCollections
import SnapKit
//import SDWebImage


private let btnFrame:CGFloat = 23

class PhotoCollectionViewCell: UICollectionViewCell {
    var imageRequestID:PHImageRequestID?
    var identifier:String?
    var btnSelect:UIButton?
    var image:UIImage?
    var imageView:UIView?
    var isSelectMode:Bool?
    var isSelect:Bool?
    var selectedBlock:((Bool)->())?
    var longPressBlock:(()->())?
    var model:WSAsset?{
        didSet{
            
            switch model?.type {
            case .Image?:
                self.videoImageView.isHidden = true
                self.videoBottomView.isHidden = true
                self.liveImageView.isHidden = true
                self.videoBottomView.isHidden = false
                self.liveImageView.isHidden = true
                self.timeLabel.isHidden = true
            case .NetImage?:
                self.videoImageView.isHidden = false
                self.videoBottomView.isHidden = true
                self.liveImageView.isHidden = true
                self.videoImageView.image = UIImage.init(named: "ic_cloud_white")
                self.videoBottomView.isHidden = false
                self.liveImageView.isHidden = true
                self.timeLabel.isHidden = true
            case .Video?,.NetVideo?:
                self.videoBottomView.isHidden = false
                self.videoImageView.isHidden = false
                self.liveImageView.isHidden = true
                self.timeLabel.text = model?.duration
                self.timeLabel.isHidden = false
                self.videoImageView.image = UIImage.init(named: "ic_play")
            case .LivePhoto? :
                self.videoBottomView.isHidden = false
                self.videoImageView.isHidden = true
                self.liveImageView.isHidden = false
                self.liveImageView.image = UIImage.init(named: "livePhoto")
                self.timeLabel.text = "Live"
            case .GIF? :
                self.videoBottomView.isHidden = false
                self.videoImageView.isHidden = true
                self.liveImageView.isHidden = false
                self.liveImageView.image = UIImage .init(named: "gif_photo")
                self.timeLabel.text = ""
            default:
                self.videoImageView.isHidden = true
                self.videoBottomView.isHidden = true
                self.liveImageView.isHidden = true
            }

            if model?.type == .Image && model?.type != .NetImage {
                self.videoImageView.isHidden = true
                self.videoBottomView.isHidden = true
                self.liveImageView.isHidden = true
                self.videoBottomView.isHidden = false
                self.liveImageView.isHidden = true
                self.timeLabel.isHidden = true
            }
       
            
//            if self.imageRequestID != nil {
//                if self.imageRequestID! >= PHInvalidImageRequestID{
//                PHCachingImageManager.default().cancelImageRequest(self.imageRequestID!)
//                }
//            }
        
            if model?.asset != nil {
                self.identifier = model?.asset?.localIdentifier
            }else if model is NetAsset{
              self.identifier =  (model as! NetAsset).fmhash
            }

            let size = CGSize.init(width: self.width  , height: self.height )

            if model?.asset != nil{
                //                DispatchQueue.global(qos: .default).async {
                self.imageRequestID = self.imageManager.requestImage(for: (self.model?.asset!)!, targetSize: size, contentMode: PHImageContentMode.aspectFill, options: self.imageRequestOptions, resultHandler: { [weak self] (image, info) in
                    let downloadFinined =  !(info![PHImageResultIsDegradedKey] as! Bool)
                    if downloadFinined {
                        //                            DispatchQueue.main.async {
                        if  self?.imageView?.layer.contents != nil{
                            self?.imageView?.layer.contents = nil
                        }
                        self?.imageView?.layer.contents = image?.cgImage
                    }
                    //                        }
                })
            }else if model is NetAsset{
                let netAsset = model as! NetAsset
                _ = AppNetworkService.getThumbnail(hash: netAsset.fmhash!,size:size) { [weak self]  (error, image) in
                    if error == nil {
                        self?.model?.image = image
                        self?.imageView?.layer.contents = image?.cgImage
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView?.layer.contents =  nil
        self.imageView?.layer.backgroundColor = UIColor.colorFromRGB(rgbValue:0xf5f5f5).cgColor
//        self.contentView.backgroundColor = UIColor.colorFromRGB(rgbValue:0xf5f5f5)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
   
        let longGesture =
            UILongPressGestureRecognizer.init(target: self, action: #selector(handleLongGesture(_ :)))
        longGesture.minimumPressDuration = 0.5;
        self.contentView.addGestureRecognizer(longGesture)
        self.clipsToBounds = true
        self.isOpaque = false
    
        self.contentView.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.backgroundColor = UIColor.colorFromRGB(rgbValue: 0xf5f5f5)
        self.imageView?.snp.makeConstraints { [weak self] (make) in
            make.left.equalTo((self?.contentView.snp.left)!)
            make.right.equalTo((self?.contentView.snp.right)!)
            make.top.equalTo((self?.contentView.snp.top)!)
            make.bottom.equalTo((self?.contentView.snp.bottom)!)
        }


        self.videoBottomView.snp.makeConstraints { [weak self] (make) in
            make.left.equalTo((self?.contentView.left)!)
            make.right.equalTo((self?.contentView.right)!)
            make.top.equalTo((self?.contentView.bottom)!).offset(-20)
            make.bottom.equalTo((self?.contentView.bottom)!)
        }

        self.videoImageView.snp.makeConstraints { [weak self] (make) in
            make.left.equalTo((self?.videoBottomView.left)!).offset(5)
            make.top.equalTo((self?.videoBottomView.top)!).offset(2)
            make.size.equalTo(CGSize(width: 16, height: 16))
        }

        self.contentView.bringSubview(toFront: self.videoBottomView)
        if self.btnSelect != nil {
//             self.contentView.bringSubview(toFront: self.btnSelect!)
        }
    }
    
    func setImagView(indexPath:IndexPath){
        var imageView = self.contentView.subviews.first
        if imageView == nil && imageView?.tag != Int(INTMAX_MAX) {
            imageView = UIView.init(frame: self.bounds)
            imageView?.contentMode = UIViewContentMode.scaleAspectFill
            imageView?.clipsToBounds = true
            imageView?.tag = Int(INTMAX_MAX)
            self.contentView.addSubview(imageView!)
        }
        self.imageView = imageView
         self.imageView?.layer.contents =  nil
     
    }
    
    func setSelectButton(indexPath:IndexPath){
        if self.contentView.subviews.count>1 {//如果是重用cell，则不用再添加button
            if self.contentView.subviews[1] is UIButton{
            self.btnSelect = self.contentView.subviews[1] as? UIButton
            }
        } else {
            self.btnSelect = UIButton.init()
            self.btnSelect?.frame = CGRect.init(x: self.contentView.width - 26, y: 5, width: btnFrame, height: btnFrame)
            self.btnSelect?.setBackgroundImage(UIImage.init(named: "select.png"), for: UIControlState.normal)
            self.btnSelect?.addTarget(self, action: #selector(btnSelectClick(_ :)), for: UIControlEvents.touchUpInside)
        }
        self.contentView.addSubview(self.btnSelect!)
   
    }
    
    func setSelectAnimation(isSelect:Bool,animation:Bool){
        self.isSelect = isSelect
        self.btnSelect?.isHidden = !isSelect
        if (isSelect) {
            if(animation) {
                self.btnSelect?.layer.add(GetBtnStatusChangedAnimation(), forKey: nil)
            }
            self.imageView?.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
        }else{
            self.imageView?.transform = CGAffineTransform.identity
        }
    }

    @objc func btnSelectClick(_ sender:UIButton?){
        if self.isSelectMode == nil { return }
        if !self.isSelectMode! { return }
        self.setSelectAnimation(isSelect: !self.isSelect!, animation: true)
        if(self.selectedBlock != nil) {
            self.selectedBlock!(isSelect!)
        }
    }
    
    @objc func handleLongGesture(_ gesture:UILongPressGestureRecognizer){
        if (gesture.state == UIGestureRecognizerState.began && self.longPressBlock != nil) {
            self.longPressBlock!()
        }
    }
    
    lazy var imageManager = PHCachingImageManager.init()
    
    lazy var imageRequestOptions: PHImageRequestOptions = {
        let option = PHImageRequestOptions.init()
        
        option.resizeMode = PHImageRequestOptionsResizeMode.fast//控制照片尺寸
        //        option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;//控制照片质量
        option.isNetworkAccessAllowed = true
        
        return option
    }()
    
//    lazy var imageView: UIView = {
//        let imgView = UIView.init()
//        imgView.contentMode = UIViewContentMode.scaleAspectFill
//        imgView.clipsToBounds = true
//        self.contentView.clipsToBounds = true
//        return imgView
//        }()
//
//    lazy var btnSelect: UIButton = {
//        let button = UIButton.init()
//        button.frame = CGRect.init(x: self.contentView.width - 26, y: 5, width: btnFrame, height: btnFrame)
//        button.setBackgroundImage(UIImage.init(named: "select.png"), for: UIControlState.normal)
//        button.addTarget(self, action: #selector(btnSelectClick(_ :)), for: UIControlEvents.touchUpInside)
//        self.contentView.addSubview(button)
//        return button
//    }()
//
    lazy var videoBottomView: UIImageView = {
        let imgView = UIImageView.init()
        imgView.frame = CGRect(x: 0, y: self.height - 20, width: self.width, height: 20)
        self.contentView.addSubview(imgView)
        return imgView
    }()

    lazy var videoImageView: UIImageView = {
        let imgView = UIImageView.init()
        imgView.frame = CGRect(x: 5, y: 2, width: 16, height: 16)
        imgView.image = UIImage.init(named: "ic_play")
        videoBottomView.addSubview(imgView)
        return imgView
    }()

    lazy var liveImageView: UIImageView = {
        let imgView = UIImageView.init()
        imgView.frame = CGRect(x: 5, y: 2, width: 16, height: 16)
        imgView.image = UIImage.init(named: "livePhoto")
        videoBottomView.addSubview(imgView)
        return imgView
    }()


    lazy var timeLabel: UILabel = {
        let label = UILabel.init()
        label.frame = CGRect(x: 30, y: 4, width: self.width - 35, height: 12)
        label.textAlignment = NSTextAlignment.right
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.white
        videoBottomView.addSubview(label)
        return label
    }()

    lazy var topView: UIView = {
        let view = UIView.init()
        view.isUserInteractionEnabled = false
        view.isHidden = true
        self.contentView.addSubview(view)
        return view
    }()
}
