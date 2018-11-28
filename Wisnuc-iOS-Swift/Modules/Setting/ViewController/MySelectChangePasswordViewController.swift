//
//  MySelectChangePasswordViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/28.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class MySelectChangePasswordViewController: BaseViewController {
    let buttonHeight:CGFloat = 48
    var phone:String?
    var mail:String?
    
    init(style: NavigationStyle,phone:String,mail:String) {
        super.init(style: style)
        self.phone = phone
        self.mail = mail
        if let phoneNumber = phone.replacePhone(){
            phoneButton.setTitle(LocalizedString(forKey: "通过手机号：\(phoneNumber)"), for: UIControlState.normal)
        }
        
        if let email = mail.replaceMail(){
            mailButton.setTitle(LocalizedString(forKey: "通过邮箱：\(email)"), for: UIControlState.normal)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = COR1
        setContentFrame()
        self.view.addSubview(titleLabel)
        self.view.addSubview(detailLabel)
        self.view.addSubview(phoneButton)
        self.view.addSubview(mailButton)
    }
    
    
    func setContentFrame(){
        titleLabel.frame = CGRect(x: MarginsWidth, y: MarginsWidth + MDCAppNavigationBarHeight , width: __kWidth - MarginsWidth*2, height: 21)
        detailLabel.frame = CGRect(x: MarginsWidth, y: titleLabel.bottom + MarginsWidth , width: __kWidth - MarginsWidth*2, height: 12)
    }
    
    @objc func phoneButtonTap(_ sender:UIButton){
        
    }
    
    @objc func mailButtonTap(_ sender:UIButton){
        
    }
    
    lazy var titleLabel = UILabel.initTitleLabel(color: .white, text: LocalizedString(forKey: "修改密码"))
    lazy var detailLabel = UILabel.initDetailTitleLabel(text:LocalizedString(forKey: "您可通过手机号或邮箱来修改密码"),color:.white)
    
    lazy var phoneButton: UIButton = { [weak self] in
        let button = UIButton.init(frame: CGRect(x: MarginsWidth, y: (self?.detailLabel.bottom)! + 36, width:__kWidth - MarginsWidth*2 , height: buttonHeight))
        button.setTitleColor(.white, for: UIControlState.normal)
        button.setTitleColor(COR1, for: UIControlState.disabled)
        button.setBackgroundImage(UIImage.init(color: COR1), for: UIControlState.normal)
        button.setBackgroundImage(UIImage.init(color: Gray12Color), for: UIControlState.disabled)
        button.layer.cornerRadius = buttonHeight/2
        button.clipsToBounds = true
        
        button.addTarget(self, action: #selector(phoneButtonTap(_ :)), for: UIControlEvents.touchUpInside)
        return button
        }()
    
    lazy var mailButton: UIButton = { [weak self] in
        let button = UIButton.init(frame: CGRect(x: MarginsWidth, y: (self?.phoneButton.bottom)! + MarginsWidth, width:__kWidth - MarginsWidth*2 , height: buttonHeight))
        button.setTitleColor(.white, for: UIControlState.normal)
        button.setTitleColor(COR1, for: UIControlState.disabled)
        button.setBackgroundImage(UIImage.init(color: COR1), for: UIControlState.normal)
        button.setBackgroundImage(UIImage.init(color: Gray12Color), for: UIControlState.disabled)
        button.layer.cornerRadius = buttonHeight/2
        button.clipsToBounds = true
        
        button.addTarget(self, action: #selector(mailButtonTap(_ :)), for: UIControlEvents.touchUpInside)
        return button
        }()
}
