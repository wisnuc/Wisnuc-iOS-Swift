//
//  DeviceDetailInfdTableViewCell.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/18.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class DeviceDetailInfdTableViewCell: UITableViewCell {
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        rightLabel.textColor = LightGrayColor
        titleLabel.textColor = DarkGrayColor
        detailLabel.textColor = LightGrayColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
