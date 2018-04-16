//
//  MyStationView.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/12.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class MyStationView: UIView {
    var dataModel = 
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.addSubview(myStationLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setStationsView() {
        
    }
    
    @objc func stationViewButtonClick(_ sender:UIButton) {
        
    }
    
    
    
    lazy var myStationLabel: UILabel = {
        let string = LocalizedString(forKey: "my_station")
        let font = SmallTitleFont
        let lable = UILabel.init(frame: CGRect(x:MarginsWidth , y:20 , width: labelWidthFrom(title: string, font: font), height: labelHeightFrom(title: string, font: font)))
        lable.font = font
        lable.text = string
        lable.textColor = SmallTitleColor
        return lable
    }()
    
    
    lazy var stationViewButton: UIButton = {
        let button = UIButton.init(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.backgroundColor = UIColor.cyan
        button.addTarget(self, action:#selector(stationViewButtonClick(_ :)), for: UIControlEvents.touchUpInside)
        return button
    }()
}
