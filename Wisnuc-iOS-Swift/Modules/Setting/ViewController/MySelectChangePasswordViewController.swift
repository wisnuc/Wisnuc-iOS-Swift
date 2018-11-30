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
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
        if let phoneNumber = self.phone?.replacePhone(){
            phoneButton.setTitle(LocalizedString(forKey: "通过手机号：\(phoneNumber)"), for: UIControlState.normal)
        }
        
        if let email = self.mail?.replaceMail(){
            mailButton.setTitle(LocalizedString(forKey: "通过邮箱：\(email)"), for: UIControlState.normal)
        }
    }
    
    
    func setContentFrame(){
        titleLabel.frame = CGRect(x: MarginsWidth, y: MarginsWidth + MDCAppNavigationBarHeight , width: __kWidth - MarginsWidth*2, height: 21)
        detailLabel.frame = CGRect(x: MarginsWidth, y: titleLabel.bottom + MarginsWidth , width: __kWidth - MarginsWidth*2, height: 12)
    }
    
    @objc func phoneButtonTap(_ sender:UIButton){
        guard let phoneNumber = self.phone else {
            Message.message(text: "没有绑定手机号")
            return
        }
        let sendCodeType = SendCodeType.password
        self.sendCodeAction(type: sendCodeType) { [weak self] in
            let  verificationCodeVC = MyVerificationCodeViewController.init(style: .whiteWithoutShadow,state:.phone,nextState:.resetPassword,codeType:sendCodeType,phone:phoneNumber)
            self?.navigationController?.pushViewController(verificationCodeVC, animated: true)
        }
    }
    
    @objc func mailButtonTap(_ sender:UIButton){
        guard let email = self.mail else {
            Message.message(text: "没有绑定邮箱")
            return
        }
        let sendCodeType = SendCodeType.password
        self.sendMailCodeAction(mail: email, type: sendCodeType) { [weak self] in
            let  verificationCodeVC = MyVerificationCodeViewController.init(style: .whiteWithoutShadow,state:.email,nextState:.resetPassword,codeType:sendCodeType,mail:email)
            self?.navigationController?.pushViewController(verificationCodeVC, animated: true)
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
    
    func sendMailCodeAction(mail:String?,type:SendCodeType,callback:@escaping (()->())){
        ActivityIndicator.startActivityIndicatorAnimation()
        guard let email = mail else {
            Message.message(text: "邮箱不能为空")
            return
        }
        if !Validate.email(email).isRight{
            Message.message(text: "邮箱格式不正确")
        }
        GetMailCodeAPI.init(mail: email,type:type).startRequestJSONCompletionHandler { (response) in
            ActivityIndicator.stopActivityIndicatorAnimation()
            if  response.error == nil{
                let responseDic = response.value as! NSDictionary
                let code = responseDic["code"] as? Int
                if code == 1 {
                    return callback()
                }else{
                    if let message = ErrorTools.responseErrorData(response.data){
                        Message.message(text:"error: code:\(code!) message:\(message)")
                    }
                }
            }else{
                // error
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
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        button.layer.borderWidth = 1
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
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(mailButtonTap(_ :)), for: UIControlEvents.touchUpInside)
        return button
        }()
}
