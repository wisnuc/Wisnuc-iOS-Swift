//
//  TransferTaskTableViewCell.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/14.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class TransferTaskTableViewCell: UITableViewCell {
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = DarkGrayColor
        detailLabel.textColor = LightGrayColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
