//
//  FilesShareFolderTableViewCell.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/15.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Material
class FilesShareFolderTableViewCell: UITableViewCell {
    @IBOutlet weak var leftImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var moreButton: IconButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = DarkGrayColor
        titleLabel.font = MiddleTitleFont
        moreButton.image = Icon.moreHorizontal?.byTintColor(.cyan)
        moreButton.tintColor = LightGrayColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
