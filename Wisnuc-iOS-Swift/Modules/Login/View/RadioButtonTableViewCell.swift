//
//  RadioButtonTableViewCell.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/27.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents

class RadioButtonTableViewCell: UITableViewCell {
    var tableView:UITableView?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var radioButton: WSRadioButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = DarkGrayColor
        detailLabel.textColor = LightGrayColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func radioButtonClick(_ sender: WSRadioButton) {
//        sender.isSelected = !sender.isSelected
//        // 当被选中的时候
//        if ((sender.selected) != nil) {
//            // 获取 indexPath
//            let indexPath = self.tableView?.indexPath(for: self)
//            //            NSIndexPath *indexPath = [self.tableView indexPathForCell:self];
//
//        }
    }
    
}
