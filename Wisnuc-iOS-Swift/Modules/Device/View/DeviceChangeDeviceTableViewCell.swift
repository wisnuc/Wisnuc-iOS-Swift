//
//  DeviceChangeDeviceTableViewCell.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/15.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class DeviceChangeDeviceTableViewCell: UITableViewCell {
    var disable:Bool = false{
        didSet{
            if disable{
                disableStyle()
            }else{
                ableStyle()
            }
        }
    }
    @IBOutlet weak var cardBackgroudView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var capacityLabel: UILabel!
    @IBOutlet weak var capacityProgressView: UIProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cardBackgroudView.layer.cornerRadius = 4
        cardBackgroudView.clipsToBounds = false
        // shadowColor阴影颜色
        cardBackgroudView.layer.shadowColor = UIColor.black.cgColor
        // shadowOffset阴影偏移,x向右偏移1，y向下偏移1，默认(0, -3),这个跟shadowRadius配合使用
        cardBackgroudView.layer.shadowOffset = CGSize(width: 0.3, height: 0.5)
        // 阴影半径，默认3
        cardBackgroudView.layer.shadowRadius = 2
        // 阴影透明度，默认0
        cardBackgroudView.layer.shadowOpacity = 0.5
        
    }
    
    
    func ableStyle(){
        cardBackgroudView.backgroundColor = COR1
        
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        
        capacityLabel.textColor = .white
        capacityLabel.font = UIFont.boldSystemFont(ofSize: 14)
        capacityProgressView.transform = CGAffineTransform(scaleX: 1.0, y: 8.0)
        //设置进度条颜色和圆角
        capacityProgressView.setRadiusTrackColor(UIColor.white.withAlphaComponent(0.12), progressColor: UIColor.colorFromRGB(rgbValue: 0x04db6ac))
    }
    
    func disableStyle(){
        cardBackgroudView.backgroundColor = Gray38Color
        
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.54)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        
        capacityLabel.textColor = UIColor.white.withAlphaComponent(0.54)
        capacityLabel.font = UIFont.boldSystemFont(ofSize: 14)
        capacityProgressView.transform = CGAffineTransform(scaleX: 1.0, y: 8.0)
        //设置进度条颜色和圆角
        capacityProgressView.setRadiusTrackColor(UIColor.white.withAlphaComponent(0.26), progressColor: LightGrayColor)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
