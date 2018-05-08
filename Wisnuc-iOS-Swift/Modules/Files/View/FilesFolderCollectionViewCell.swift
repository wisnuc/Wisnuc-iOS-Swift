
//
//  FilesFolderCollectionViewCell.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/4.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents

class FilesFolderCollectionViewCell: MDCCollectionViewTextCell{
    override init(frame: CGRect) {
        super.init(frame: frame)
        //        self.
        self.backgroundColor = UIColor.white
        self.contentView.addSubview(leftImageView)
        leftImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView.snp.left).offset(MarginsCloseWidth)
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
            make.left.equalTo(leftImageView.snp.right).offset(MarginsCloseWidth)
            make.centerY.equalTo(leftImageView.snp.centerY)
            make.size.equalTo(CGSize(width: self.contentView.width - MarginsCloseWidth - moreButton.width, height: 20))
        }
        

    }
    
    @objc func buttonClick(_ sender:UIButton){
        
    }
    
    lazy var leftImageView: UIImageView = {
        let image = UIImage.init(named: "files_files.png")
        let imageView = UIImageView.init(image: image)
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = DarkGrayColor
        label.font = MiddleTitleFont
        return label
    }()
    
    lazy var moreButton: UIButton = {
        let button = UIButton.init()
        button.setImage(UIImage.init(named: "more_gray_horizontal.png"), for: UIControlState.normal)
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

