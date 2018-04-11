//
//  LoginViewController.swift
//  FruitMix-Swift
//
//  Created by wisnuc-imac on 2018/3/16.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import SnapKit
import MaterialComponents

enum LoginState:Int{
    case wechat = 0
    case token
}

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = COR1
        self.view.addSubview(self.agreementButton)
        self.view.addSubview(self.weChatView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    deinit {
        
    }
    
    @objc func agreementButtonClick (){
        let messageString = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur " +
            "ultricies diam libero, eget porta arcu feugiat sit amet. Maecenas placerat felis sed risus " +
            "maximus tempus. Integer feugiat, augue in pellentesque dictum, justo erat ultricies leo, " +
            "quis eleifend nisi eros dictum mi. In finibus vulputate eros, in luctus diam auctor in. " +
            "Aliquam fringilla neque at augue dictum iaculis. Etiam ac pellentesque lectus. Aenean " +
            "vestibulum, tortor nec cursus euismod, lectus tortor rhoncus massa, eu interdum lectus urna " +
            "ut nulla. Phasellus elementum lorem sit amet sapien dictum, vel cursus est semper. Aenean " +
            "vel turpis maximus, accumsan dui quis, cursus turpis. Nunc a tincidunt nunc, ut tempus " +
            "libero. Morbi ut orci laoreet, luctus neque nec, rhoncus enim. Cras dui erat, blandit ac " +
            "malesuada vitae, fringilla ac ante. Nullam dui diam, condimentum vitae mi et, dictum " +
        "euismod libero. Aliquam commodo urna vitae massa convallis aliquet."
        
        let materialAlertController = MDCAlertController(title: "用户协议", message: messageString)
    
        let action = MDCAlertAction(title:"OK") { (_) in print("OK") }

        materialAlertController.addAction(action)
        
        self.present(materialAlertController, animated: true, completion: nil)
    }
    
    
    lazy var agreementButton: UIView = {
        let bgView = UIView.init(frame: CGRect(x: 0, y: __kHeight - 48, width: __kWidth, height: 48))
        let button = UIButton.init(frame: CGRect(x: 0, y: 0, width: bgView.bounds.width, height: 13))
        
        let str = "用户协议"
//        let str = NSMutableAttributedString.init(string:"用户协议")
//        str.addAttribute(NSAttributedStringKey.underlineStyle, value: NSNumber(integerLiteral: NSUnderlineStyle.styleSingle.rawValue), range: NSRange(location: 0, length: str.length))
//        str.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: str.length))
//        str.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 13), range: NSRange(location: 0, length: str.length))
//        button.setAttributedTitle(str, for: UIControlState.normal)
  
        button.setTitle(str, for: UIControlState.normal)
        button.setTitleColor(UIColor.white, for: UIControlState.normal)
        button.addTarget(self, action: #selector(agreementButtonClick), for: UIControlEvents.touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        bgView.addSubview(button)
 
        let widthSize = getWidth(title: str, font:(button.titleLabel?.font)!)

        
        let underline = UIView.init(frame: CGRect(origin: CGPoint(x:CGFloat(Float(button.center.x) - widthSize/2)  , y: button.center.y + button.frame.size.height/2 + 3), size: CGSize(width: Int(widthSize), height: 1)))
        underline.backgroundColor = UIColor.white
        
        bgView.addSubview(underline)
        return bgView
    }()
    
    lazy var weChatView: UIView = {
        let innerWechatView = UIButton.init(frame: CGRect(x: 16, y: self.view.frame.size.height/2, width: __kWidth - 32, height: 44))
        innerWechatView.backgroundColor = UIColor.cyan
        innerWechatView.layer.shadowColor = UIColor.black.cgColor
        innerWechatView.layer.shadowOffset = CGSize(width: 0, height: 2)
        innerWechatView.layer.shadowRadius = 2.0
        innerWechatView.layer.shadowOpacity = 0.4
        innerWechatView.isUserInteractionEnabled = true
        
        let wechatImage = UIImage.init(named: "wechat_icon")
        let wechatImageView = UIImageView.init(image: wechatImage)
        innerWechatView.addSubview(wechatImageView)
        wechatImageView.snp.makeConstraints({ (make) in
            make.centerX.equalTo(innerWechatView.snp.centerX).offset(-30)
            make.centerY.equalTo(innerWechatView.snp.centerY)
            make.size.equalTo((wechatImage?.size)!)
        })
        
        let label = UILabel.init();
        label.text = WBLocalizedString(forKey: "wechat_login")
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.white
        label.alpha = 0.87
        
        innerWechatView.addSubview(label)
        
        label.snp.makeConstraints { (make) in
            make.left.equalTo(wechatImageView.snp.right).offset(8)
            make.centerY.equalTo(innerWechatView.snp.centerY)
            make.size.equalTo(CGSize(width: 100, height: 20))
        }
        return innerWechatView
    }()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

