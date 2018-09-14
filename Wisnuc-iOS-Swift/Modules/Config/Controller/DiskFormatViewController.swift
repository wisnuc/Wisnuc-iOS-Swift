//
//  DiskFormatViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/9/14.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class DiskFormatViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        self.view.addSubview(titleLabel)
        self.view.addSubview(powerOffButton)
        self.view.addSubview(confirmButton)
//
        titleLabel.text = LocalizedString(forKey: "磁盘格式化确认")
        // Do any additional setup after loading the view.
        setTipsLabelContentFrame()
    }
    
    deinit{
        defaultNotificationCenter().removeObserver(self)
    }
    
    func setTipsLabelContentFrame(){
        let tipsString = LocalizedString(forKey: "发现使用的磁盘含有数据,\n使用闻上设备需要格式化磁盘")
        let font = UIFont.systemFont(ofSize: 14)
        let size = labelSizeToFit(title: tipsString, font: font)
        tipsLabel.numberOfLines = 0
        tipsLabel.frame = CGRect(x: (__kWidth - size.width*2)/2, y: titleLabel.bottom + 110, width: size.width*2, height: (tipsString as NSString).height(for: font, width: size.width))
        tipsLabel.font = font
        tipsLabel.textAlignment = NSTextAlignment.center
        tipsLabel.textColor = DarkGrayColor
        tipsLabel.text = tipsString
        self.view.addSubview(tipsLabel)
    }
    
    func setNavigationBar(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "close_gray.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(leftBarButtonItemTap(_:)))
    }
    
    @objc func leftBarButtonItemTap(_ sender:UIBarButtonItem){
        self.presentingViewController?.dismiss(animated: true, completion: {
            
        })
    }
    
    @objc func confirmButtonClick(_ sender:MDBaseButton){
        self.presentingViewController?.dismiss(animated: true, completion: {
            defaultNotificationCenter().post(name: NSNotification.Name.Config.DiskFormaConfirmDismissKey, object: nil)
        })
    }
    
    @objc func powerOffButtonTap(_ sender:MDBaseButton){
        
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect(x: MarginsWidth, y: MarginsWidth + MDCAppNavigationBarHeight, width: __kWidth - MarginsWidth*2, height: 22))
        label.font = UIFont.boldSystemFont(ofSize: 21)
        label.textColor = DarkGrayColor
        return label
    }()
    
    lazy var confirmButton: MDBaseButton = { [weak self] in
        let button = MDBaseButton.init(frame: CGRect(x: MarginsWidth, y: (self?.powerOffButton.top)! - MarginsWidth - 40, width: __kWidth - MarginsWidth * 2, height: 40))
        button.setTitle(LocalizedString(forKey: "同意"), for: UIControlState.normal)
        button.setTitleFont(UIFont.systemFont(ofSize: 14), for: UIControlState.normal)
        button.backgroundColor = COR1
        button.layer.cornerRadius = 2
        button .addTarget(self, action: #selector(confirmButtonClick(_ :)), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    lazy var powerOffButton: MDBaseButton = {
        let button = MDBaseButton.init(frame: CGRect(x: MarginsWidth, y: __kHeight - 16 - 40, width: __kWidth - MarginsWidth * 2, height: 40))
        button.backgroundColor = .white
        button.setBorderColor(Gray12Color, for: UIControlState.normal)
        button.setBorderWidth(1, for: UIControlState.normal)
        button.inkColor = COR1.withAlphaComponent(0.3)
        button.layer.cornerRadius = 2
        button.setTitleColor(DarkGrayColor, for: UIControlState.normal)
        button.setTitle(LocalizedString(forKey: "关机,更换磁盘"), for: UIControlState.normal)
        button.setTitleFont(UIFont.systemFont(ofSize: 14), for: UIControlState.normal)
        button .addTarget(self, action: #selector(powerOffButtonTap(_ :)), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    lazy var tipsLabel = UILabel.init()
}
