//
//  MyNicknameChangeViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/11.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class MyNicknameChangeViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.frame = CGRect(x: MarginsWidth, y: MarginsWidth + MDCAppNavigationBarHeight , width: __kWidth - MarginsWidth*2, height: 48)
        self.view.addSubview(titleLabel)
        // Do any additional setup after loading the view.
    }
    
    lazy var titleLabel = UILabel.initTitleLabel(color: DarkGrayColor, text: LocalizedString(forKey: "设置昵称"))
    
}
