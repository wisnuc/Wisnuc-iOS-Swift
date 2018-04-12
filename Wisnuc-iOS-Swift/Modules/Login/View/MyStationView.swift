//
//  MyStationView.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/12.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class MyStationView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func stationViewButtonClick(_ sender:UIButton){
        
        
    }
    
    lazy var stationViewButton: UIButton = {
        let button = UIButton.init(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.backgroundColor = UIColor.cyan
        button.addTarget(self, action:#selector(stationViewButtonClick(_ :)), for: UIControlEvents.touchUpInside)
        return button
    }()
}
