//
//  MyBindPhoneViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/12.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class MyBindPhoneViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setContentFrame()
        self.view.addSubview(titleLabel)
        self.view.addSubview(detailLabel)
        self.view.addSubview(bindStateLabel)
        self.view.addSubview(bindButton)
        // Do any additional setup after loading the view.
    }
  
    func setContentFrame(){
        titleLabel.frame = CGRect(x: MarginsWidth, y: MarginsWidth + MDCAppNavigationBarHeight , width: __kWidth - MarginsWidth*2, height: 48)
        detailLabel.frame = CGRect(x: MarginsWidth, y: titleLabel.bottom + MarginsWidth , width: __kWidth - MarginsWidth*2, height: 14)
        bindStateLabel.textColor = DarkGrayColor
        bindStateLabel.textAlignment = .center
        bindStateLabel.text = LocalizedString(forKey: "139****2222")
    }
    

    @objc func bindButtonTap(_ sender:UIButton){
        let verificationCodeViewController = MyVerificationCodeViewController.init(style: .whiteWithoutShadow, state: .phone, nextState: .bindPhone)
        self.navigationController?.pushViewController(verificationCodeViewController, animated: true)
    }
    
    lazy var titleLabel = UILabel.initTitleLabel(color: DarkGrayColor, text: LocalizedString(forKey: "修改绑定手机"))
    lazy var detailLabel = UILabel.initDetailTitleLabel(text:LocalizedString(forKey: "为了您的账号安全，请慎重选择绑定的手机号"))
    lazy var bindStateLabel = UILabel.init(frame: CGRect(x: MarginsWidth, y: detailLabel.bottom + 66, width: __kWidth - MarginsWidth*2, height: 16))
    lazy var bindButton: UIButton = { [weak self] in
        let button = UIButton.init(frame: CGRect(x: MarginsWidth, y: (self?.bindStateLabel.bottom)! + 30, width:__kWidth - MarginsWidth*2 , height: 48))
        button.setTitle(LocalizedString(forKey: "更换手机号码"), for: UIControlState.normal)
        button.setTitleColor(.white, for: UIControlState.normal)
        button.setTitleColor(.white, for: UIControlState.disabled)
        button.setBackgroundImage(UIImage.init(color: COR1), for: UIControlState.normal)
        button.setBackgroundImage(UIImage.init(color: Gray12Color), for: UIControlState.disabled)
        button.layer.cornerRadius = 48/2
        button.clipsToBounds = true
        
        button.addTarget(self, action: #selector(bindButtonTap(_ :)), for: UIControlEvents.touchUpInside)
        return button
        }()
}
