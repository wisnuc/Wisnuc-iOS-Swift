//
//  MyChangePhoneNumberViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/12.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class MyChangePhoneNumberViewController: BaseViewController {
    let textFieldHeight:CGFloat = 64
    var oldTicket:String?
    init(style: NavigationStyle,oldTicket:String?) {
        super.init(style: style)
        self.oldTicket = oldTicket
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setContentFrame()
        prepareNotification()
        self.view.addSubview(titleLabel)
        self.view.addSubview(detailLabel)
        self.view.addSubview(phoneTextField)
        self.view.addSubview(nextButton)
        // Do any additional setup after loading the view.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func prepareNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow(note:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        //键盘即将隐藏
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHidden(note:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func setContentFrame(){
        titleLabel.frame = CGRect(x: MarginsWidth, y: MarginsWidth + MDCAppNavigationBarHeight , width: __kWidth - MarginsWidth*2, height: 48)
        detailLabel.frame = CGRect(x: MarginsWidth, y: titleLabel.bottom + MarginsWidth , width: __kWidth - MarginsWidth*2, height: 14)
        
    }
    
    func nextButtonDisableStyle(){
        self.nextButton.backgroundColor = COR1.withAlphaComponent(0.26)
        self.nextButton.isEnabled = false
    }
    
    func nextButtonEnableStyle(){
        self.nextButton.backgroundColor = COR1
        self.nextButton.isEnabled = true
    }
    
    func sendCodeAction(phone:String,type:SendCodeType,callback:@escaping (()->())){
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
    
    
    @objc func nextButtonTap(_ sender:UIButton){
        guard let phone = self.phoneTextField.text else { return }
        guard let phoneTicket = self.oldTicket else { return }
        let sendCodeType = SendCodeType.replace
        self.sendCodeAction(phone: phone, type: sendCodeType) { [weak self] in
           let verificationCodeVC =  MyVerificationCodeViewController.init(style: .whiteWithoutShadow,state:.phone,nextState:.replacePhoneComplete,codeType:sendCodeType,phone:phone,phoneTicket:phoneTicket)
            self?.navigationController?.pushViewController(verificationCodeVC, animated: true)
        }
    }
    
    //键盘弹出监听
    @objc func keyboardShow(note: Notification)  {
        guard let userInfo = note.userInfo else {return}
        guard let keyboardRect = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else{return}
        //获取键盘弹起的高度
        let keyboardTopYPosition =  keyboardRect.origin.y
        let duration = note.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        UIView.animate(withDuration: duration) {
            self.nextButton.center = CGPoint(x: self.nextButton.center.x, y: keyboardTopYPosition - 36)
        }
    }
    
    //键盘隐藏监听
    @objc func keyboardHidden(note: Notification){
        guard let userInfo = note.userInfo else {return}
        guard let keyboardRect = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else{return}
        //        //获取键盘弹起的高度
        let keyboardTopYPosition = keyboardRect.origin.y
        let duration = note.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: duration) {
            self.nextButton.center = CGPoint(x: self.nextButton.center.x, y:keyboardTopYPosition - MarginsWidth - self.nextButton.height/2 )
        }
    }
    
    lazy var titleLabel = UILabel.initTitleLabel(color: DarkGrayColor, text: LocalizedString(forKey: "修改绑定手机"))
    lazy var detailLabel = UILabel.initDetailTitleLabel(text:LocalizedString(forKey: "更换手机号后，下次登录使用新手机号登录"))
  
    lazy var phoneTextField: UITextField = { [weak self] in
        let textField = UITextField.init(frame: CGRect(x: 0, y: (self?.detailLabel.bottom)! + 32, width: __kWidth, height: textFieldHeight))
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: 114, height:textFieldHeight))
        let textLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: 96, height: view.height))
        textLabel.textColor = DarkGrayColor
        textLabel.font = UIFont.systemFont(ofSize: 16)
        textLabel.textAlignment = .center
        textLabel.text = "+86"
        view.addSubview(textLabel)
        
        let separate = UIView.init(frame: CGRect(x: textLabel.right, y: 0, width: 1, height: view.height))
        separate.backgroundColor = Gray6Color
        view.addSubview(separate)
        
        textField.leftView = view
        textField.leftViewMode = .always
        textField.tintColor = COR1
        textField.font = UIFont.systemFont(ofSize: 21)
        textField.placeholder = LocalizedString(forKey: "手机号")
        textField.delegate = self
        textField.layer.borderColor = Gray6Color.cgColor
        textField.layer.borderWidth = 1.0
 
        textField.keyboardType = .phonePad
        return textField
        }()
    
    
    lazy var nextButton: UIButton = {
        let button = UIButton.init(type: .custom)
        let width:CGFloat = 40
        button.frame = CGRect(x: __kWidth - MarginsWidth - width , y: __kHeight - MarginsWidth - width, width: width, height: width)
        button.setImage(UIImage.init(named: "next_button_arrow_white.png"), for: UIControlState.normal)
        button.backgroundColor =  COR1.withAlphaComponent(0.26)
        button.isEnabled = false
        button.layer.masksToBounds = true
        button.layer.cornerRadius = width/2
        button.addTarget(self, action: #selector(nextButtonTap(_ :)), for: UIControlEvents.touchUpInside)
        return button
    }()
}

extension MyChangePhoneNumberViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let rawText = textField.text else {
            return true
        }
        
        let fullString = NSString(string: rawText).replacingCharacters(in: range, with: string)
        if fullString.count > 0 && Validate.phoneNum(fullString).isRight{
            nextButtonEnableStyle()
        }else{
            nextButtonDisableStyle()
        }
        return true
    }

}
