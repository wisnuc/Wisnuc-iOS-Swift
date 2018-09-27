//
//  BigPhotoInfoTableViewCell.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/9/27.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class BigPhotoInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var leftImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = DarkGrayColor
        detailLabel.textColor = LightGrayColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
