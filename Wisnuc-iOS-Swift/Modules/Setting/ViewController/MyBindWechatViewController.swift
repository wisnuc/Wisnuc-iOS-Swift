//
//  MyBindWechatViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/12.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit
enum  MyBindWechatViewControllerState{
    case none
    case binded
}

class MyBindWechatViewController: BaseViewController {
    var state:MyBindWechatViewControllerState?{
        didSet{
            switch self.state {
            case .none?:
                noneStateAction()
            case .binded?:
                bindedStateAction()
            default:
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setContentFrame()
        self.view.addSubview(titleLabel)
        self.view.addSubview(detailLabel)
        self.view.addSubview(bindStateLabel)
        self.view.addSubview(bindButton)
        setState(.none)
        // Do any additional setup after loading the view.
    }
    
    func setState(_ state:MyBindWechatViewControllerState){
        self.state = state
    }
    
    func setContentFrame(){
        titleLabel.frame = CGRect(x: MarginsWidth, y: MarginsWidth + MDCAppNavigationBarHeight , width: __kWidth - MarginsWidth*2, height: 48)
        detailLabel.frame = CGRect(x: MarginsWidth, y: titleLabel.bottom + MarginsWidth , width: __kWidth - MarginsWidth*2, height: 14)
        bindStateLabel.textColor = DarkGrayColor
        bindStateLabel.textAlignment = .center
    }
    
    func noneStateAction(){
        bindStateLabel.text = "未检测到微信号"
        bindButton.isEnabled = true
    }
    
    func bindedStateAction(){
        bindStateLabel.text = "检测到微信号：139****2222"
        bindButton.isEnabled = false
    }
    
    @objc func bindButtonTap(_ sender:UIButton){
        
    }
    
    lazy var titleLabel = UILabel.initTitleLabel(color: DarkGrayColor, text: LocalizedString(forKey: "绑定微信"))
    lazy var detailLabel = UILabel.initDetailTitleLabel(text:LocalizedString(forKey: "绑定微信，便捷登录"))
    lazy var bindStateLabel = UILabel.init(frame: CGRect(x: MarginsWidth, y: detailLabel.bottom + 66, width: __kWidth - MarginsWidth*2, height: 16))
    lazy var bindButton: UIButton = { [weak self] in
        let button = UIButton.init(frame: CGRect(x: MarginsWidth, y: (self?.bindStateLabel.bottom)! + 30, width:__kWidth - MarginsWidth*2 , height: 48))
        button.setTitle(LocalizedString(forKey: "立即绑定"), for: UIControlState.normal)
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
