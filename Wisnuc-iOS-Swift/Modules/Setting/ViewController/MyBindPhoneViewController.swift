//
//  MyBindPhoneViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/12.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class MyBindPhoneViewController: BaseViewController {
    
    var phone:String?
    init(style: NavigationStyle,phone:String?) {
        super.init(style: style)
        self.phone = phone
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
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
        if let phone = self.phone{
           bindStateLabel.text = phone.replacePhone()
        }
    }
    
    func sendCodeAction(type:SendCodeType,callback:@escaping (()->())){
        guard let phone = self.phone else {
            Message.message(text: "没有绑定手机号")
            return
        }
        
        if !Validate.phoneNum(phone).isRight{
            Message.message(text: "手机号不符合规则")
            return
        }
        
        guard let token = AppUserService.currentUser?.cloudToken else {
            Message.message(text: "无法发送短信验证码")
            return
        }
        
        ActivityIndicator.startActivityIndicatorAnimation()
        GetSmsCodeAPI.init(phoneNumber: phone,type:type,wechatToken:token).startRequestJSONCompletionHandler { (response) in
            if  response.error == nil{
                let responseDic = response.value as! NSDictionary
                let code = responseDic["code"] as? Int
                if code == 1 {
                    ActivityIndicator.stopActivityIndicatorAnimation()
                    callback()
                }else{
                    
                    if let message = ErrorTools.responseErrorData(response.data){
                        Message.message(text:"error: code:\(code!) message:\(message)")
                    }
                    ActivityIndicator.stopActivityIndicatorAnimation()
                }
            }else{
                // error
                ActivityIndicator.stopActivityIndicatorAnimation()
                guard let responseDic =  dataToNSDictionary(data: response.data) else{
                    if response.error is BaseError{
                        let baseError = response.error as! BaseError
                        Message.message(text:"请求错误：\(String(describing: baseError.localizedDescription))")
                    }else{
                        let message = response.error?.localizedDescription ?? "未知原因"
                        Message.message(text:"请求错误：\(message)")
                    }
                    return
                }
                if let code = responseDic["code"] as? Int{
                    switch code {
                    case ErrorCode.Request.MobileError:
                        Message.message(text: LocalizedString(forKey: "手机号错误"))
                    case ErrorCode.Request.CodeLimitOut:
                        Message.message(text: LocalizedString(forKey: "验证码发送超过限制，请稍候重试"))
                    default:
                        if let message = responseDic["message"] as? String{
                            Message.message(text:"\(message)")
                        }
                    }
                }else{
                    Message.message(text: "error code :\(String(describing: response.response?.statusCode ?? -0)) error:\(String(describing: response.error?.localizedDescription ?? "未知错误"))")
                }
            }
        }
    }

    @objc func bindButtonTap(_ sender:UIButton){
        guard let phone = self.phone else {
            Message.message(text: "没有绑定手机号")
            return
        }
        let sendCodeType = SendCodeType.replace
        self.sendCodeAction(type: sendCodeType) {
            let verificationCodeViewController = MyVerificationCodeViewController.init(style: .whiteWithoutShadow, state: .phone, nextState: .bindPhone,codeType:sendCodeType,phone:phone)
            self.navigationController?.pushViewController(verificationCodeViewController, animated: true)
        }
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
