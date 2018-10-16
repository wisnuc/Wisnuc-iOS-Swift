//
//  DeviceBackupRootTableViewCell.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/16.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class DeviceBackupRootTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabelCenterLayoutConstraint: NSLayoutConstraint!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = DarkGrayColor
        rightLabel.textColor = LightGrayColor
        detailLabel.textColor = LightGrayColor
        rightLabel.font = UIFont.boldSystemFont(ofSize: 14)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isNilString(detailLabel.text){
            
            titleLabelCenterLayoutConstraint.constant = 0
        }
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
