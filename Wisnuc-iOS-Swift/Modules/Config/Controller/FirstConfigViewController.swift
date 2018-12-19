//
//  FirstConfigViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/9/12.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class FirstConfigViewController: BaseViewController {
    var user:User?
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        self.view.addSubview(titleLabel)
        titleLabel.text = LocalizedString(forKey: "主人，您还没有闻上云盘")
        self.view.addSubview(newDeviceButton)
        self.view.addSubview(scanButton)
        // Do any additional setup after loading the view.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .default
    }
    
    init(style: NavigationStyle,user:User) {
        super.init(style: style)
        self.user = user
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.appBar.navigationBar.tintColor = COR1
//        self.appBar.headerViewController.headerView.tintColor = COR1
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.view.frame = CGRect(x: 0, y: 0, width: __kWidth, height: __kHeight)
    }
    

    func setNavigationBar(){
        self.navigationItem.leftBarButtonItem  = UIBarButtonItem.init(title: LocalizedString(forKey: "退出"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(leftBarButtonItemTap(_ :)))
    }

    @objc func leftBarButtonItemTap(_ sender:UIBarButtonItem){
        self.presentingViewController?.dismiss(animated: true, completion: {
            
        })
    }
    
    @objc func newDeviceButtonClick(_ sender:MDBaseButton){
        guard let user = self.user else {
            return
        }
        let seekNewDeviceVC = SeekNewDeviceViewController.init(style: NavigationStyle.whiteWithoutShadow,user:user)
        self.navigationController?.pushViewController(seekNewDeviceVC, animated: true)
    }
    
    @objc func scanButtonButtonTap(_ sender:MDBaseButton){
        
    }

    lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect(x: MarginsWidth, y: MarginsWidth + MDCAppNavigationBarHeight, width: __kWidth - MarginsWidth*2, height: 22))
        label.font = UIFont.systemFont(ofSize: 21)
        label.textColor = DarkGrayColor
        return label
    }()
    
    lazy var newDeviceButton: MDBaseButton = { [weak self] in
        let button = MDBaseButton.init(frame: CGRect(x: MarginsWidth, y: (self?.titleLabel.bottom)! + 65, width: __kWidth - MarginsWidth * 2, height: 48))
        button.backgroundColor = COR1
        button.layer.cornerRadius = 48/2
  
        
        let plusImage = #imageLiteral(resourceName: "plus_white.png")
        let plusImageView = UIImageView.init(image: plusImage)
        button.addSubview(plusImageView)
        plusImageView.snp.makeConstraints({ (make) in
            make.left.equalTo(button.snp.left).offset(16)
            make.centerY.equalTo(button.snp.centerY)
            make.size.equalTo(CGSize(width: 24, height: 24))
        })
        
        let label = UILabel.init();
        label.text = LocalizedString(forKey: "添加新设备")
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.alpha = 0.87
        label.textAlignment = .center
        
        button.addSubview(label)
        
        label.snp.makeConstraints { (make) in
            make.centerX.equalTo(button.snp.centerX)
            make.centerY.equalTo(button.snp.centerY)
            make.size.equalTo(CGSize(width: labelWidthFrom(title: label.text!, font: label.font!), height: labelHeightFrom(title: label.text!, font: label.font!)))
        }
        
        button .addTarget(self, action: #selector(newDeviceButtonClick(_ :)), for: UIControlEvents.touchUpInside)
        return button
        }()
    
    lazy var scanButton: MDBaseButton = { [weak self] in
        let innerView = MDBaseButton.init(frame: CGRect(x: MarginsWidth, y: (self?.newDeviceButton.bottom)! + 16, width: __kWidth - MarginsWidth * 2, height: 48))
        innerView.backgroundColor = .white
        innerView.layer.cornerRadius = 48/2
        innerView.setBorderColor(Gray12Color, for: UIControlState.normal)
        innerView.setBorderWidth(1, for: UIControlState.normal)
        innerView.inkColor = COR1.withAlphaComponent(0.3)
        
        let label = UILabel.init()
        label.text = LocalizedString(forKey: "扫一扫，添加他人设备")
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = COR1
        label.alpha = 0.87
        label.textAlignment = .center
        
        innerView.addSubview(label)
        
        let plusImage = #imageLiteral(resourceName: "plus_gray.png")
        let plusImageView = UIImageView.init(image: plusImage)
        innerView.addSubview(plusImageView)
        plusImageView.snp.makeConstraints({ (make) in
            make.left.equalTo(innerView.snp.left).offset(16)
            make.centerY.equalTo(innerView.snp.centerY)
            make.size.equalTo(CGSize(width: 24, height: 24))
        })
        
        label.snp.makeConstraints { (make) in
            make.centerX.equalTo(innerView.snp.centerX)
            make.centerY.equalTo(innerView.snp.centerY)
            make.size.equalTo(CGSize(width: labelWidthFrom(title: label.text!, font: label.font!), height: labelHeightFrom(title: label.text!, font: label.font!)))
        }
        
        innerView .addTarget(self, action: #selector(scanButtonButtonTap(_ :)), for: UIControlEvents.touchUpInside)
        return innerView
        }()
}
