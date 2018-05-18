//
//  FilesAShareAuthorityTableViewCell.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/18.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import BEMCheckBox
class FilesAShareAuthorityTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var checkBox: BEMCheckBox!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkBox.boxType = BEMBoxType.square
        checkBox.onAnimationType = BEMAnimationType.bounce
        checkBox.offAnimationType = BEMAnimationType.bounce
        checkBox.onFillColor = COR1
        checkBox.onTintColor = UIColor.white
        checkBox.onCheckColor = UIColor.white
        checkBox.tintColor = LightGrayColor
        checkBox.delegate = self
        leftImageView.was_setRoundRectImage(withUrlString: "", placeholder: #imageLiteral(resourceName: "touxiang.jpg"), cornerRadius: 40/2)
        titleLable.textColor = DarkGrayColor
        titleLable.font = MiddleTitleFont.withBold()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}


extension FilesAShareAuthorityTableViewCell:BEMCheckBoxDelegate{
    
}
