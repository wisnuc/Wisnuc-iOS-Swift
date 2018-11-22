//
//  MyAccountSecurityVerificationTableViewCell.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/26.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class MyAccountSecurityVerificationTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    var disabled:Bool = false{
        didSet{
//            if disabled{
//                disabledAction()
//            }else{
//                abledAction()
//            }
        }
    }
    override var isSelected: Bool{
        didSet{
//            if isSelected {
//                self.selectButton.isSelected = true
//            }else{
//                self.selectButton.isSelected = false
//            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.selectButton.isUserInteractionEnabled = false
        // Initialization code
    }
    
//    func disabledAction(){
//        self.selectButton.isEnabled = false
//        self.isUserInteractionEnabled = false
//    }
//
//    func abledAction(){
//        self.selectButton.isEnabled = true
//        self.isUserInteractionEnabled = true
//    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
