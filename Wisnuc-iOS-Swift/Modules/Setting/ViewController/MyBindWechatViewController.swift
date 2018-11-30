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
    var wmodels:[WechatInfoModel]?
    var state:MyBindWechatViewControllerState?{
        didSet{
            switch self.state {
            case .none?:
                noneStateAction()
            case .binded?:
                bindedStateAction(nickName: wmodels?.first?.nickname)
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
        wechatInfoCheck()
        // Do any additional setup after loading the view.
    }
    
    func wechatInfoCheck(){
        self.loadData { [weak self](models) in
            if let wechatModels = models{
                self?.wmodels = wechatModels
                self?.setState(.binded)
            }else{
                self?.setState(.none)
            }
        }
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
        bindStateLabel.text =  LocalizedString(forKey: "您尚未绑定微信")
        bindButton.setTitle(LocalizedString(forKey: "立即绑定"), for: UIControlState.normal)
    }
    
    func bindedStateAction(nickName:String?){
        if let nickName = nickName{
            bindStateLabel.text = "已绑定微信昵称为\(nickName)的用户"
        }else{
            bindStateLabel.text = "已绑定微信"
        }
        bindButton.setTitle(LocalizedString(forKey: "立即更换"), for: UIControlState.normal)
    }
    
    func loadData(closure:@escaping (_ wechatInfoModels:[WechatInfoModel]?)->()){
        ActivityIndicator.startActivityIndicatorAnimation()
        let requset = WechatInfoAPI.init()
        requset.startRequestJSONCompletionHandler({(response) in
            ActivityIndicator.stopActivityIndicatorAnimation()
            if let error =  response.error{
                Message.message(text: error.localizedDescription)
                return closure(nil)
            }else{
                if let errorMessage = ErrorTools.responseErrorData(response.data){
                    Message.message(text: errorMessage)
                    return closure(nil)
                }
                guard let rootDic = response.value as? NSDictionary else {
                    return closure(nil)
                }
                
                guard let dataArray = rootDic["data"] as? NSArray else {
                    return closure(nil)
                }
                var resultArray = Array<WechatInfoModel>.init()
                for value in dataArray{
                    if let dataDic = value as? NSDictionary{
                        do {
                            if let data = jsonToData(jsonDic: dataDic ){
                                let model = try JSONDecoder().decode(WechatInfoModel.self, from: data)
                                resultArray.append(model)
                            }
                        }catch{
                            print(error as Any)
                        }
                    }
                }
                return closure(resultArray)
            }
        })
    }
    
    func weChatCallBackRespCode(code:String){
        if let models = wmodels{
            if models.count>0{
                guard let unionid  =  models.first?.unionid else {
                    return
                }
                self.unbindWechat(unionid: unionid, closure: { [weak self] in
                    self?.bindWechat(code:code, closure: { [weak self] in
                        self?.wechatInfoCheck()
                    })
                })
            }else{
               bindWechat(code:code, closure: { [weak self] in
                    self?.wechatInfoCheck()
               })
            }
        }else{
            bindWechat(code:code, closure: { [weak self] in
                self?.wechatInfoCheck()
            })
        }
    }
    
    func bindWechat(code:String,closure:@escaping ()->()){
        ActivityIndicator.startActivityIndicatorAnimation()
        let requset =  WechatActionAPI.init(type: .bind, code: code)
        requset.startRequestJSONCompletionHandler { (response) in
            ActivityIndicator.stopActivityIndicatorAnimation()
            if let error =  response.error{
                Message.message(text: error.localizedDescription)
            }else{
                if let errorMessage = ErrorTools.responseErrorData(response.data){
                    Message.message(text: errorMessage)
                    return
                }
                return closure()
            }
        }
    }
    
    func unbindWechat(unionid:String,closure:@escaping ()->()){
        ActivityIndicator.startActivityIndicatorAnimation()
        let requset =  WechatActionAPI.init(type: .unbind, unionid: unionid)
        requset.startRequestJSONCompletionHandler { (response) in
            ActivityIndicator.stopActivityIndicatorAnimation()
            if let error =  response.error{
                Message.message(text: error.localizedDescription)
            }else{
                if let errorMessage = ErrorTools.responseErrorData(response.data){
                    Message.message(text: errorMessage)
                    return
                }
                return closure()
            }
        }
    }
    
    func checkWechat() {
        if (WXApi.isWXAppInstalled()) {
            let req = SendAuthReq.init()
            req.scope = "snsapi_userinfo"
            req.state = "App"
            WXApi.send(req)
        }else{
            Message.message(text: LocalizedString(forKey: "请先安装微信"))
        }
    }
    
    @objc func bindButtonTap(_ sender:UIButton){
       self.checkWechat()
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
