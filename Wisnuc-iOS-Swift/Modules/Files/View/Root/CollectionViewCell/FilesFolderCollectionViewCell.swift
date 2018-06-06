
//
//  FilesFolderCollectionViewCell.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/4.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents
import Material

let filesSelectImage = UIImage.init(named: "files_select.png")
let filesUnSelectImage = UIImage.init(named: "files_unselect.png")

class FilesFolderCollectionViewCell: MDCCollectionViewTextCell{
    var longPressCallBack:CellLongPressCallBack?
    var cellCallBack:CellCallBack?
    var isSelectModel: Bool?{
        didSet{
            if isSelectModel!{
               unselectAction()
            }else{
               normalAction()
            }
        }
    }
    var isSelect: Bool?{
        didSet{
            if isSelect!{
               selectAction()
            }else{
               unselectAction()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setGestrue()
        self.backgroundColor = UIColor.white
        
        self.contentView.addSubview(selectImageView)
        selectImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView.snp.left).offset(MarginsCloseWidth/2)
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        
        self.contentView.addSubview(leftImageView)
        leftImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(selectImageView)
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
      
        
        self.contentView.addSubview(moreButton)
        let image = UIImage.init(named: "more_gray_horizontal.png")
        moreButton.snp.makeConstraints { (make) in
            make.right.equalTo(self.contentView.snp.right).offset(-MarginsCloseWidth)
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.size.equalTo(CGSize(width: (image?.size.width)! + 8, height: (image?.size.height)! + 20))
        }
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(selectImageView.snp.right).offset(MarginsCloseWidth/2)
            make.centerY.equalTo(leftImageView.snp.centerY)
            make.size.equalTo(CGSize(width: self.contentView.width - MarginsCloseWidth - moreButton.width, height: 20))
        }
        
//        setSelectState()
    }
    
    func setGestrue(){
        let longPressGestrue = UILongPressGestureRecognizer.init(target: self, action: #selector(longPress(_ :)))
        //        longPressGestrue.delegate = self
        self.addGestureRecognizer(longPressGestrue)
        
    }
    
//    func setSelectState(){
//        self.isSelectModel = false
//    }
    
    func selectAction(){
        selectImageView.image = filesSelectImage
        leftImageView.isHidden = true
        selectImageView.isHidden = false
    }
    
    func unselectAction(){
        selectImageView.image = filesUnSelectImage
        leftImageView.isHidden = false
        selectImageView.isHidden = false
    }
    
    func normalAction(){
        leftImageView.isHidden = false
        selectImageView.isHidden = true
    }
    
    @objc func longPress(_ sender:UIGestureRecognizer){
        if sender.state == UIGestureRecognizerState.began{
            if self.longPressCallBack != nil {
                self.longPressCallBack!(self)
            }
        }
    }
    
    @objc func buttonClick(_ sender:UIButton){
        if self.cellCallBack != nil {
            self.cellCallBack!(self, sender)
        }
    }
    
    lazy var leftImageView: UIImageView = {
        let image = UIImage.init(named: "files_files.png")
        let imageView = UIImageView.init(image: image)
        return imageView
    }()
    
    lazy var selectImageView: UIImageView = {
        let imageView = UIImageView.init()
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = DarkGrayColor
        label.font = MiddleTitleFont
        return label
    }()
    
    lazy var moreButton: IconButton = {
        let button = IconButton.init(image: Icon.moreHorizontal, tintColor: LightGrayColor)
        button.addTarget(self, action: #selector(buttonClick(_ :)), for: UIControlEvents.touchUpInside)
        return button
    }()
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //    override func awakeFromNib() {
    //        super.awakeFromNib()
    //        // Initialization code
    
}

