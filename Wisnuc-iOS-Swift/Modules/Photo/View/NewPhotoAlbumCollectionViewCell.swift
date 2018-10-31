//
//  NewPhotoAlbumCollectionViewCell.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/9/25.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class NewPhotoAlbumCollectionViewCell: UICollectionViewCell {
  
    @IBOutlet weak var imageView: UIView!
    var btnSelect:UIButton?
    var btnDelete:DeleteButton?
    var imageRequestID:PHImageRequestID?
    var identifier:String?
    var isEditing:Bool = false
    let btnFrame:CGFloat = 24
    var deleteCallbck:((_ indexPath:IndexPath)->())?
    var image:UIImage?
    var model:WSAsset?{
        didSet{
            if model?.asset != nil {
                self.identifier = model?.asset?.localIdentifier
            }else if model is NetAsset{
                self.identifier =  (model as! NetAsset).fmhash
            }
            
            let size = CGSize.init(width: self.width  , height: self.height )
            
            if model?.asset != nil{
                //                DispatchQueue.global(qos: .default).async {
                self.imageRequestID = self.imageManager.requestImage(for: (self.model?.asset!)!, targetSize: size, contentMode: PHImageContentMode.aspectFill, options: self.imageRequestOptions, resultHandler: { [weak self] (image, info) in
                    
                    if let downloadFinined = (info![PHImageResultIsDegradedKey] as? Bool){
                        if !downloadFinined {
                            //                            DispatchQueue.main.async {
                            if  self?.imageView?.layer.contents != nil{
                                self?.imageView?.layer.contents = nil
                            }
                            self?.imageView?.layer.contents = image?.cgImage
                            self?.image = image
                        }
                    }
                    //                        }
                })
            }else if model is NetAsset{
                let netAsset = model as! NetAsset
                _ = AppNetworkService.getThumbnail(hash: netAsset.fmhash!,size:size) { [weak self]  (error, image) in
                    if error == nil {
                        self?.model?.image = image
                        self?.imageView?.layer.contents = image?.cgImage
                        self?.image = image
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
    
    @objc func btnSelectClick(_ sender:UIButton){
        
    }
    
    @objc func btnDeleteClick(_ sender:DeleteButton){
        if deleteCallbck != nil{
            self.deleteCallbck!(sender.indexPath!)
        }
    }
    
    func setImagView(indexPath:IndexPath){
        var imageView = self.contentView.subviews.first
        if imageView == nil && imageView?.tag != Int(NSIntegerMax) {
            imageView = UIView.init(frame: self.bounds)
            imageView?.contentMode = UIViewContentMode.scaleAspectFill
            imageView?.clipsToBounds = true
            imageView?.tag = Int(NSIntegerMax)
            self.contentView.addSubview(imageView!)
        }
        self.imageView = imageView
        self.imageView?.layer.contents =  nil
        if model?.indexPath == nil{
            model?.indexPath = indexPath
        }
    }
    
    func setDeleteButton(indexPath:IndexPath){
        if self.contentView.subviews.count>1 {//如果是重用cell，则不用再添加button
            if self.contentView.subviews[1] is UIButton{
                self.btnDelete = self.contentView.subviews[1] as? DeleteButton
                btnDelete?.indexPath = indexPath
            }
        } else {
            self.btnDelete = DeleteButton.init(frame: CGRect(origin: imageView.newTopLeft, size: CGSize(width: btnFrame, height: btnFrame)))
            self.btnDelete?.setImage(UIImage.init(named: "delete_photo_new_album.png"), for: UIControlState.normal)
            self.btnDelete?.addTarget(self, action: #selector(btnDeleteClick(_ :)), for: UIControlEvents.touchUpInside)
            btnDelete?.indexPath = indexPath
        }
        self.contentView.addSubview(self.btnDelete!)
    }
    
    func setEditingAnimation(isEditing:Bool,animation:Bool){
        self.isEditing = isEditing
        self.btnDelete?.isHidden = !isEditing
        if (isEditing) {
            self.imageView?.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
            if(animation) {
                self.btnDelete?.layer.add(GetBtnStatusChangedAnimation(), forKey: nil)
                let center =  CGPoint(x: (self.frame.width - self.frame.width * 0.8)/2, y: (self.frame.height - self.frame.height * 0.8)/2)
                self.btnDelete?.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: btnFrame, height: btnFrame))
                self.btnDelete?.center = center
            }
        }else{
            self.imageView?.transform = CGAffineTransform.identity
        }
    }
    
    func setSelectAnimation(isSelect:Bool,animation:Bool){
//        self.isSelect = isSelect
//        self.btnSelect?.isHidden = !isSelect
//        if (isSelect) {
//            if(animation) {
//                self.btnSelect?.layer.add(GetBtnStatusChangedAnimation(), forKey: nil)
//            }
//            self.imageView?.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
//        }else{
//            self.imageView?.transform = CGAffineTransform.identity
//        }
    }
    
    lazy var imageManager = PHCachingImageManager.init()
    lazy var imageRequestOptions: PHImageRequestOptions = {
        let option = PHImageRequestOptions.init()
        
        option.resizeMode = PHImageRequestOptionsResizeMode.fast//控制照片尺寸
        //        option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;//控制照片质量
        option.isNetworkAccessAllowed = true
        
        return option
    }()
}

class DeleteButton: UIButton {
    var indexPath:IndexPath?
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
