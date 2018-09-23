//
//  PhotoAlbumCollectionViewHeaderView.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/9/20.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class PhotoAlbumCollectionViewHeaderView: UICollectionReusableView {
    lazy var contentView:UIView = UIView.init(frame: CGRect.zero)
    lazy var titleLabel:UILabel = UILabel.init(frame: CGRect(x: MarginsWidth, y: 24, width: __kWidth - MarginsWidth*2, height: 18))
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        titleLabel.textColor = DarkGrayColor
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        contentView.addSubview(titleLabel)
        contentView.backgroundColor = UIColor.white
        self.addSubview(contentView)
//        self.backgroundColor = .red
    }
   
    func setTitleLabelText(string:String){
        titleLabel.text = string
    }
}
