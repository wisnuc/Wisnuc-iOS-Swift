//
//  DeviceAddDeviceTableViewCell.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/18.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class DeviceAddDeviceTableViewCell: UITableViewCell {
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    var disabled:Bool = false{
        didSet{
            if disabled{
                disabledAction()
            }else{
                abledAction()
            }
        }
    }
    override var isSelected: Bool{
        didSet{
            if isSelected {
                self.selectButton.isSelected = true
            }else{
                self.selectButton.isSelected = false
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectButton.isEnabled = false
        nameLabel.textColor = DarkGrayColor
        detailLabel.textColor = LightGrayColor
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
    
    func disabledAction(){
        self.selectButton.isEnabled = false
        self.nameLabel.textColor = LightGrayColor
        self.isUserInteractionEnabled = false
    }
    
    func abledAction(){
        self.selectButton.isEnabled = true
        self.nameLabel.textColor = DarkGrayColor
        self.isUserInteractionEnabled = true
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
