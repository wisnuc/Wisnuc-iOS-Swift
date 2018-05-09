//
//  BaseSearchBar.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/9.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents
import Material

class BaseSearchBar: SearchBar {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        self.layer.shadowRadius = 1
        self.layer.shadowOpacity = 0.5
        self.layer.shadowColor = DarkGrayColor.cgColor
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 2
        self.clipsToBounds = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
