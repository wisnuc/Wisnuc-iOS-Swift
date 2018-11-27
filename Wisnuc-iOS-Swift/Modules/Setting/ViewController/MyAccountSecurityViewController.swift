//
//  MyAccountSecurityViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/11.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit
import Material
import HandyJSON

class MyAccountSecurityViewController: BaseViewController {
    let identifier = "Cellidentifier"
    let identifierSection2 = "Cellidentifier2"
    let headerHeight:CGFloat = 48
    let cellHeight:CGFloat = 72
    var mailDataSource:Array<UserMailModel>?
    var phoneDataSource:Array<UserPhoneModel>?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(infoTabelView)
        
        appBar.headerViewController.headerView.trackingScrollView = infoTabelView
        
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setData()
    }
    
    func setData(){
        getPhone()
        getMail()
    }
    
    func getMail(){
        UserMailAPI.init().startRequestJSONCompletionHandler { [weak self](response) in
            if let error = response.error {
                Message.message(text: error.localizedDescription)
            }else{
                if let errorMessage = ErrorTools.responseErrorData(response.data){
                    Message.message(text: errorMessage)
                }else{
                    guard let jsonData = response.data else{
                        return
                    }
                    do {
                        if let stringDic = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]{
                            if let mailArray = stringDic["data"] as? Array<[String:Any]>{
                                var mailDataArray = Array<UserMailModel>.init()
                                for value in mailArray{
                                    if let mailModel = UserMailModel.deserialize(from: value) {
                                        mailDataArray.append(mailModel)
                                    }
                                }
                                self?.mailDataSource = mailDataArray
                                self?.infoTabelView.reloadData()
                            }
                            print(stringDic as Any)
                        }
                    } catch let error {
                        print(error)
                    }
                }
            }
        }
    }
    
    func getPhone(){
        UserPhoneAPI.init().startRequestJSONCompletionHandler { [weak self](response) in
            if let error = response.error {
                Message.message(text: error.localizedDescription)
            }else{
                if let errorMessage = ErrorTools.responseErrorData(response.data){
                    Message.message(text: errorMessage)
                }else{
                    guard let jsonData = response.data else{
                        return
                    }
                    do {
                        if let stringDic = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]{
                            if let phoneArray = stringDic["data"] as? Array<[String:Any]>{
                                var phoneDataArray = Array<UserPhoneModel>.init()
                                for value in phoneArray{
                                    if let phoneModel = UserPhoneModel.deserialize(from: value) {
                                        phoneDataArray.append(phoneModel)
                                    }
                                }
                                self?.phoneDataSource = phoneDataArray
                                self?.infoTabelView.reloadData()
                            }
                            print(stringDic as Any)
                        }
                    } catch let error {
                        print(error)
                    }
                }
            }
        }
    }
    
    func rightLabel(_ text:String) ->UILabel{
        let rightFont = UIFont.systemFont(ofSize: 14)
        let rightText = text
        let height:CGFloat = 14
        let width:CGFloat = labelWidthFrom(title: rightText, font: rightFont)
        
        let label = UILabel.init(frame: CGRect(x: __kWidth - MarginsCloseWidth - width - MarginsWidth - MarginsWidth, y: cellHeight/2  - height/2, width: width, height: height))
        label.font = rightFont
        label.textColor = LightGrayColor
        label.text = rightText
        label.textAlignment = .right
        
        return label
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == infoTabelView {
//            var tableview = scrollView as? UITableView
            let sectionHeaderHeight: CGFloat = headerHeight
            if scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0 {
                scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0)
            } else if scrollView.contentOffset.y >= sectionHeaderHeight {
                scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0)
            }
        }
    }
    
    func sendCodeAction(type:SendCodeType,callback:@escaping (()->())){
        guard let phone = phoneDataSource?.first?.phoneNumber else {
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
    
    
    @objc func switchBtnHandle(_ sender:UISwitch){
        
    }
    
    lazy var infoTabelView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: __kWidth, height: __kHeight), style: UITableViewStyle.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView.init()
        tableView.backgroundColor = .white
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    lazy var headerView: UIView = {
        let view = UIView.init(frame: CGRect.zero)
        //        view.backgroundColor = .red
        return view
    }()
}

extension MyAccountSecurityViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0{
            switch indexPath.row {
            case 0:
                break
            case 1:
                  break
//                var verificationCodeViewController:MyVerificationCodeViewController?
//                switch verificationState {
//                case .phone?:
//                   verificationCodeViewController = MyVerificationCodeViewController.init(style: .whiteWithoutShadow,state:.phone,nextState:.changePassword)
//                case .doubleVerification?:
//                    verificationCodeViewController = MyVerificationCodeViewController.init(style: .whiteWithoutShadow,state:.phone,nextState:.changePassword)
//                default:
//                    break
//                }
//
//                if let verificationCodeVC = verificationCodeViewController{
//                    self.navigationController?.pushViewController(verificationCodeVC, animated: true)
//                }
              
            case 2:
                let bindPhoneViewController = MyBindPhoneViewController.init(style: .whiteWithoutShadow)
                self.navigationController?.pushViewController(bindPhoneViewController, animated: true)
            case 3:
                guard let phone = phoneDataSource?.first?.phoneNumber else {
                    Message.message(text: "没有绑定手机号")
                    return
                }
                
                sendCodeAction(type: .mail) {
                    var verificationCodeVC = MyVerificationCodeViewController.init(style: .whiteWithoutShadow,state:.phone,nextState:.bindEmail,codeType:.mail,phone:phone)
                    if let mail = self.mailDataSource?.first?.mail{
                        verificationCodeVC = MyVerificationCodeViewController.init(style: .whiteWithoutShadow,state:.phone,nextState:.emailCodeVerification,codeType:.mail,phone:phone,mail:mail)
                    }
                    self.navigationController?.pushViewController(verificationCodeVC, animated: true)
                }
            default:
                break
            }
        }
    }
}

extension MyAccountSecurityViewController:UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 4
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            let titleLabel = UILabel.init(frame: CGRect(x: MarginsWidth, y: 0 , width: __kWidth - MarginsWidth*2, height: headerHeight))
            titleLabel.textColor = DarkGrayColor
            titleLabel.text = LocalizedString(forKey: "账户安全")
            titleLabel.font = UIFont.boldSystemFont(ofSize: 21)
            headerView.addSubview(titleLabel)
            return headerView
        }else{
            let separateView = UILabel.init(frame: CGRect(x: 0, y: 0 , width: __kWidth, height: MarginsCloseWidth))
            separateView.backgroundColor = UIColor.colorFromRGB(rgbValue: 0x0f5f5f5)
            let titleLabel = UILabel.init(frame: CGRect(x: MarginsWidth, y: separateView.height , width: __kWidth - MarginsWidth*2, height: headerHeight - separateView.height))
            titleLabel.textColor = LightGrayColor
            titleLabel.text = LocalizedString(forKey: "安全性高级设置")
            titleLabel.font = UIFont.systemFont(ofSize: 14)
            let headerView = UIView.init(frame: CGRect.zero)
            headerView.addSubview(separateView)
            headerView.addSubview(titleLabel)
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
            let  cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: identifier)
            cell.selectionStyle = .none
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = LocalizedString(forKey: "账号")
                if let userName = AppUserService.currentUser?.userName {
                    cell.detailTextLabel?.text = userName.replacePhone()
                }
                
            case 1:
                cell.textLabel?.text = LocalizedString(forKey: "密码")
                let secureLevelString = "低"
                let detailText = "安全性 \(secureLevelString)"
                let attributedText = NSMutableAttributedString.init(string:detailText )
                let font = UIFont.systemFont(ofSize: 12)
                attributedText.addAttribute(NSAttributedStringKey.font, value:font , range: NSRange.init(location: 0, length: attributedText.length))
                attributedText.addAttribute(NSAttributedStringKey.foregroundColor, value: LightGrayColor, range: NSRange.init(location: 0, length: 3))
                attributedText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: NSRange.init(location: 4, length: 1))
                cell.detailTextLabel?.attributedText = attributedText
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                
                let label = self.rightLabel(LocalizedString(forKey: "去修改"))
                cell.contentView.addSubview(label)
            case 2:
                cell.textLabel?.text = LocalizedString(forKey: "绑定手机号")
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                if let phoneArray = self.phoneDataSource{
                    if phoneArray.count > 0 && phoneArray.first?.phoneNumber != nil {
                        cell.detailTextLabel?.text = (phoneArray.first?.phoneNumber)!.replacePhone()
                        let label = self.rightLabel(LocalizedString(forKey: "去修改"))
                        cell.contentView.addSubview(label)
                    }
                }
               
            case 3:
                cell.textLabel?.text = LocalizedString(forKey: "邮箱")
                cell.detailTextLabel?.text =  LocalizedString(forKey: "未绑定")
                var label = self.rightLabel(LocalizedString(forKey: "去绑定"))
                if let mailArray = self.mailDataSource{
                    if mailArray.count > 0 && mailArray.first?.mail != nil {
                        if mailArray.first?.user == AppUserService.currentUser?.uuid{
                            cell.detailTextLabel?.text = LocalizedString(forKey: (mailArray.first?.mail)!)
                            label = self.rightLabel(LocalizedString(forKey: "去修改"))
                        }
                    }
                }
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                cell.contentView.addSubview(label)
            default: break
            }
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
            cell.textLabel?.textColor = DarkGrayColor
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
            cell.detailTextLabel?.textColor = LightGrayColor
            return cell
        }else{
            tableView.register(UINib.init(nibName: StringExtension.classNameAsString(targetClass: MyAccountSecurityVerificationTableViewCell.self), bundle: nil), forCellReuseIdentifier: identifierSection2)
            let  cell = tableView.dequeueReusableCell(withIdentifier: identifierSection2, for: indexPath) as! MyAccountSecurityVerificationTableViewCell
            cell.selectionStyle = .none
            switch indexPath.row {
            case 0:
                cell.titleLabel.text = LocalizedString(forKey: "双重身份验证")
                let switchBtn = UISwitch.init()
                switchBtn.center = CGPoint.init(x: __kWidth - 16 - switchBtn.width/2, y: cell.height/2)
                switchBtn.isOn = AppUserService.currentUser?.retrievePasswordState?.intValue  == 1 ? true : false
                switchBtn.addTarget(self, action: #selector(switchBtnHandle(_ :)), for: UIControlEvents.valueChanged)
                if let switchButton = cell.contentView.subviews.first(where: {$0 is UISwitch}){
                    switchButton.removeFromSuperview()
                }

                cell.contentView.addSubview(switchBtn)
            default: break
                
            }
            return cell
        }
    }
    
}
