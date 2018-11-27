//
//  FilesFileInfoTableViewCell.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/16.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class FilesFileInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var filesImageView: UIImageView!
    @IBOutlet weak var folderButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lineView.backgroundColor = lightGrayBackgroudColor
        leftLabel.textColor = DarkGrayColor
        leftLabel.font = MiddleTitleFont
        rightLabel.textColor = DarkGrayColor
        rightLabel.font = BoldMiddleTitleFont
        rightLabel.isHidden = false
        filesImageView.isHidden = true
        folderButton.isHidden = true
        folderButton.setTitleColor(COR1, for: UIControlState.normal)
        folderButton.titleLabel?.font = BoldMiddleTitleFont
        folderButton.isEnabled = false
    }
    
    @IBAction func folderButtonTap(_ sender: UIButton) {
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
