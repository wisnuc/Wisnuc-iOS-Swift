//
//  FilesListCollectionViewCell.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/10.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialCollections
import Material

class FilesListCollectionViewCell: MDCCollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        //        self.
        self.backgroundColor = UIColor.white
        self.contentView.addSubview(leftImageView)
        leftImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView.snp.left).offset(MarginsWidth)
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
        
        self.contentView.addSubview(moreButton)
        let image = UIImage.init(named: "more_gray_horizontal.png")
        moreButton.snp.makeConstraints { (make) in
            make.right.equalTo(self.contentView.snp.right).offset(-MarginsWidth)
            make.centerY.equalTo(self.leftImageView.snp.centerY)
            make.size.equalTo(CGSize(width: (image?.size.width)! + 8, height: (image?.size.height)! + 20))
        }
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(leftImageView.snp.right).offset(MarginsWidth*2)
            make.centerY.equalTo(leftImageView.snp.centerY).offset(-20/2-2)
            make.size.equalTo(CGSize(width: self.contentView.width - leftImageView.right - MarginsWidth*2 - moreButton.left-4, height: 20))
        }
        
        self.contentView.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { (make) in
            make.left.equalTo(leftImageView.snp.right).offset(MarginsWidth*2)
            make.centerY.equalTo(leftImageView.snp.centerY).offset(20/2+2)
            make.size.equalTo(CGSize(width: self.contentView.width - leftImageView.right - MarginsWidth*2 - moreButton.left-4, height: 20))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func buttonClick(_ sender:UIButton){
        
    }
    
    lazy var leftImageView: UIImageView = {
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
    
    lazy var detailLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = LightGrayColor
        label.font = SmallTitleFont
        return label
    }() 
}
