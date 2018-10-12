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
    override func viewDidLoad() {
        super.viewDidLoad()
        setContentFrame()
        prepareNotification()
        self.view.addSubview(titleLabel)
        self.view.addSubview(detailLabel)
        self.view.addSubview(phoneNumberLabel)
        self.view.addSubview(nicknameTextField)
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
        
        phoneNumberLabel.frame = CGRect(x: MarginsWidth, y: detailLabel.bottom + 66 , width: __kWidth - MarginsWidth*2, height: 14)
        phoneNumberLabel.textAlignment = .center
        
    }
    
    func nextButtonDisableStyle(){
        self.nextButton.backgroundColor = COR1.withAlphaComponent(0.26)
        self.nextButton.isEnabled = false
    }
    
    func nextButtonEnableStyle(){
        self.nextButton.backgroundColor = COR1
        self.nextButton.isEnabled = true
    }
    
    @objc func nextButtonTap(_ sender:UIButton){
        self.alertController(title: "修改绑定手机号成功", message: "可用 139****2222加密码直接登录", okActionTitle: "重新登录") { (alertAction) in
            
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
    lazy var phoneNumberLabel = UILabel.initDetailTitleLabel(text:LocalizedString(forKey: "133****2333"))
    
    lazy var nicknameTextField: UITextField = { [weak self] in
        let textField = UITextField.init(frame: CGRect(x: 0, y: (self?.phoneNumberLabel.bottom)! + 32, width: __kWidth, height: textFieldHeight))
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: 114, height:textFieldHeight))
        let textLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: 96, height: view.height))
        textLabel.textColor = DarkGrayColor
        textLabel.font = UIFont.systemFont(ofSize: 14)
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
        if fullString.count > 0 && checkIsPhoneNumber(number: fullString){
            nextButtonEnableStyle()
        }else{
            nextButtonDisableStyle()
        }
        return true
    }

}
