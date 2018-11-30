//
//  MySecureStepViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/15.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class MySecureStepViewController: BaseViewController {
    let headerHeight:CGFloat = 48
    let cellHeight:CGFloat = 72
    let identifier = "celled"
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(infoTabelView)
        
        appBar.headerViewController.headerView.trackingScrollView = infoTabelView
        
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
    }
    
    func sendCodeAction(phone:String,type:SendCodeType,callback:@escaping ((_ userExist:Bool?)->())){
        if !Validate.phoneNum(phone).isRight{
           Message.message(text:  LocalizedString(forKey: "手机号不正确"))
        }
        
        guard let requestToken = AppUserService.currentUser?.cloudToken else {
            Message.message(text:  LocalizedString(forKey:"无法发送验证码"))
            return
        }
        
        ActivityIndicator.startActivityIndicatorAnimation()
        GetSmsCodeAPI.init(phoneNumber: phone,type:type,wechatToken:requestToken).startRequestJSONCompletionHandler { [weak self] (response) in
            //            print(String(data: response.data!, encoding: String.Encoding.utf8) as String? ?? "2222")
            if  response.error == nil{
                let responseDic = response.value as! NSDictionary
                let code = responseDic["code"] as? Int
                if code == 1 {
                    var userExist:Bool?
                    if responseDic["data"] != nil{
                        let dataDic = responseDic["data"] as! NSDictionary
                        userExist = dataDic["userExist"] as? Bool
                    }
                    ActivityIndicator.stopActivityIndicatorAnimation()
                    callback(userExist)
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
    
    lazy var infoTabelView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: __kWidth, height: __kHeight), style: UITableViewStyle.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        tableView.tableFooterView = UIView.init()
        tableView.backgroundColor = .white
        tableView.isScrollEnabled = false
        return tableView
    }()

}

extension MySecureStepViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            guard let phone = AppUserService.currentUser?.userName else {
                Message.message(text: "没有绑定手机号")
                return
            }
            
            self.sendCodeAction(phone:phone,type: .mail) { [weak self] (userExist) in
                let verificationCodeVC = MyVerificationCodeViewController.init(style: .whiteWithoutShadow,state:.phone,nextState:.bindEmail,codeType:.mail,phone:phone)
                self?.navigationController?.pushViewController(verificationCodeVC, animated: true)
            }
//        case 2:
//            break
//        case 3:
//            let bindWechatVC = MyBindWechatViewController.init(style: .whiteWithoutShadow)
//            self.navigationController?.pushViewController(bindWechatVC, animated: true)
        default: break
            
        }
    }
}

extension MySecureStepViewController:UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let headerView = UIView.init(frame: CGRect.zero)
            let titleLabel = UILabel.init(frame: CGRect(x: MarginsWidth, y: 0 , width: __kWidth - MarginsWidth*2, height: headerHeight))
            titleLabel.textColor = DarkGrayColor
            titleLabel.text = LocalizedString(forKey: "剩余步骤")
            titleLabel.font = UIFont.boldSystemFont(ofSize: 21)
            headerView.addSubview(titleLabel)
            return headerView
        }else{
            let headerView = UIView.init(frame: CGRect.zero)
            let titleLabel = UILabel.init(frame: CGRect(x: MarginsWidth, y: 0 , width: __kWidth - MarginsWidth*2, height: headerHeight))
            titleLabel.textColor = DarkGrayColor
            titleLabel.text = LocalizedString(forKey: "已完成")
            titleLabel.font = UIFont.boldSystemFont(ofSize: 21)
            headerView.addSubview(titleLabel)
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        if indexPath.section == 0{
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = LocalizedString(forKey: "绑定邮箱")
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            default: break
                
            }
          
        }else{
            switch indexPath.row {
            case 0:
            cell.textLabel?.text = LocalizedString(forKey: "绑定手机")
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
            default: break
                
            }
        }
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.textLabel?.textColor = DarkGrayColor
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.detailTextLabel?.textColor = LightGrayColor
        cell.tintColor = COR1
        return cell
    }
    
}
