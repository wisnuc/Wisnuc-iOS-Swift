//
//  LogOutViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/19.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents.MDCButton
@objc protocol  LogOutViewControllerDelegate{
    func logOutButtonTap(sender:UIButton)
}
class LogOutViewController: BaseViewController {
    weak var delegate:LogOutViewControllerDelegate?
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var modifyNameLabel: UIButton!
    @IBOutlet weak var logOutButton: MDCButton!
    @IBOutlet weak var mainBackgroudView: UIView!
    var avatarURL:String?
    var name:String?
    init(avatarUrl:String?,name:String?) {
        super.init()
        appBar.headerViewController.headerView.backgroundColor = UIColor.clear
        appBar.navigationBar.backgroundColor = UIColor.clear
        appBar.headerStackView.backgroundColor = UIColor.clear
        self.avatarURL = avatarUrl
        self.name = name
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = LocalizedString(forKey: "me")
        setUpUI()
    }
    
    func setUpUI(){
        mainBackgroudView.backgroundColor = COR1
        nameTextField.font = BoldBigTitleFont
        nameTextField.textColor = UIColor.white
        nameTextField.text = name ?? "unknow"
        nameTextField.isEnabled = false
        nameTextField.backgroundColor = UIColor.clear
        userImageView.layer.masksToBounds = true
        userImageView.layer.cornerRadius = userImageView.width/2
        userImageView.layer.borderColor = ImageViewBorderColor
        userImageView.layer.borderWidth = 8
        userImageView.was_setCircleImage(withUrlString: avatarURL ?? "", placeholder: UIImage.init())
        logOutButton.backgroundColor = UIColor.red
        logOutButton.setTitle(LocalizedString(forKey: "logout"), for: UIControlState.normal)
        logOutButton.setTitleColor(UIColor.white, for: UIControlState.normal)
    }

    @IBAction func modifyNameButtonClick(_ sender: UIButton) {
        nameTextField.isEnabled = true
        nameTextField.borderStyle = UITextBorderStyle.roundedRect
    }
    
    @IBAction func logOutButtonClick(_ sender: MDCButton) {
        if let delegateOK = self.delegate{
            self.navigationController?.popViewController(animated: true)
            delegateOK.logOutButtonTap(sender: sender)
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
