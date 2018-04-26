//
//  InitLastViewCardViewTableViewCell.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/26.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class InitLastViewCardViewTableViewCell: UITableViewCell {
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
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
