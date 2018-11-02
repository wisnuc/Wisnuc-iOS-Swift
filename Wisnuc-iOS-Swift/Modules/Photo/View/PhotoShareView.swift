//
//  PhotoShareView.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/9/28.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit
@objc protocol  PhotoShareViewDelegate{
    func didEndShare()
    @objc optional func shareImage()->UIImage?
    @objc optional func shareImages()->[UIImage]?
}

class PhotoShareView: UIView {
    weak var delegate:PhotoShareViewDelegate?
    deinit {
        
    }
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        setContentStyle()
    }
    
    func setContentStyle(){
        self.backgroundColor = .white
        self.alpha = 0.9
        line1.backgroundColor = Gray12Color
        self.addSubview(line1)
        self.addSubview(appShareScrollView)
        line2.backgroundColor = Gray12Color
        self.addSubview(line2)
        self.addSubview(customShareScrollView)
        appShareScrollView.addSubview(wechatFriendsView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func shared(){
        self.delegate?.didEndShare()
    }
    
    @objc func shareToFriends(_ sender:UIButton){
        self.shared()
        let message = WXMediaMessage.init()
        let req = SendMessageToWXReq()
//        req.text = "这是测试发送的内容。"
        req.bText = false
        req.scene = Int32(WXSceneTimeline.rawValue)
        let wximageObjc = WXImageObject.init()
        if let image = self.delegate?.shareImage!(){
            wximageObjc.imageData = UIImagePNGRepresentation(image)
        }
        message.mediaObject = wximageObjc
        req.message = message
        WXApi.send(req)
    }
    
    lazy var wechatFriendsView: UIView = {
        let iconWidth:CGFloat = 48
        let iconTopMargin:CGFloat = 20
        let labelHeight:CGFloat = 10
        let view = UIView.init(frame: CGRect(x: MarginsWidth, y: 20, width: iconWidth, height: iconWidth + MarginsCloseWidth + labelHeight))
        let button = UIButton.init(frame: CGRect(x: 0, y: 0, width: iconWidth, height: iconWidth))
        button.setImage(UIImage.init(named: "wechat_friend_icon.png"), for: UIControlState.normal)
        button.addTarget(self, action: #selector(shareToFriends(_ :)), for: UIControlEvents.touchUpInside)
        let label = UILabel.init(frame: CGRect(x: 0, y: button.bottom + MarginsCloseWidth, width: iconWidth, height: labelHeight))
        label.text = "朋友圈"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 10)
        view.addSubview(label)
        view.addSubview(button)
        return view
    }()
    
    lazy var line1 = UIView.init(frame: CGRect(x: MarginsWidth, y: 48, width: self.width - MarginsWidth*2, height: 1))
    lazy var appShareScrollView: UIScrollView = { [weak self] in
        let scrollView = UIScrollView.init(frame: CGRect(x: 0, y: (self?.line1.bottom)! + 0.5, width: (self?.width)!, height: 108))
//        scrollView.backgroundColor = .cyan
        return scrollView
    }()
    
    lazy var line2 = UIView.init(frame: CGRect(x: MarginsWidth, y: self.appShareScrollView.bottom + 0.5, width: self.width - MarginsWidth*2, height: 1))
    lazy var customShareScrollView: UIScrollView = { [weak self] in
        let scrollView = UIScrollView.init(frame: CGRect(x: 0, y: (self?.line2.bottom)! + 0.5, width: (self?.width)!, height: 108))
//        scrollView.backgroundColor = .red
        return scrollView
        }()
}
