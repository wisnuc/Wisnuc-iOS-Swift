//
//  FilsBottomSheetTableViewCell.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/16.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Material

@objc protocol  FilsBottomSheetTableViewCellDelegate{
    
}

class FilsBottomSheetTableViewCell: UITableViewCell {
    var switchChangeCallback:((_ sender:UISwitch)->())?
    @IBOutlet weak var mainSwitch: UISwitch!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var leftImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = DarkGrayColor
        titleLabel.font = MiddleTitleFont
        mainSwitch.addTarget(self, action: #selector(switchChangeTap(_ :)), for: UIControlEvents.valueChanged)
//        self.contentView.addSubview(materialSwitch)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func switchChangeTap(_ sender:UISwitch){
        if let switchChangeCallback = self.switchChangeCallback{
            switchChangeCallback(sender)
        }
    }

//    lazy var materialSwitch: Switch = {
//        let contentSwitch = Switch.init(state: SwitchState.off, style: SwitchStyle.dark  , size: SwitchSize.medium)
//        contentSwitch.frame = CGRect(x: self.contentView.width - 16 - contentSwitch.width, y: contentView.height/2 - contentSwitch.height/2, width: 20, height: 20)
//        return contentSwitch
//    }()
    
}
