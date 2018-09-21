//
//  PhotoAlbumCollectionViewCell.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/9/20.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class PhotoAlbumCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.nameLabel.textColor = DarkGrayColor
        self.countLabel.textColor = LightGrayColor
        self.imageView.backgroundColor = UIColor.colorFromRGB(rgbValue:0xf5f5f5)
        self.imageView.layer.cornerRadius = 4
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        self.imageView?.layer.backgroundColor = UIColor.colorFromRGB(rgbValue:0xf5f5f5).cgColor
    }

}
