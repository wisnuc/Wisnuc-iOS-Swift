//
//  FilesOfflineTableViewCell.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/14.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Material

class FilesOfflineTableViewCell: UITableViewCell {

    @IBOutlet weak var moreButton: IconButton!
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var leftImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = DarkGrayColor
        detailLabel.textColor = LightGrayColor
        moreButton.image = Icon.moreHorizontal?.byTintColor(LightGrayColor)
        moreButton.tintColor = LightGrayColor
        moreButton.isHidden = true
        detailImageView.isHidden = true
    }
    
    func reloadLayout(){
        if detailImageView.isHidden{
            DispatchQueue.main.async {
                self.detailLabel.left = self.titleLabel.left
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
