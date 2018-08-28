//
//  LoginNextStepViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/8/28.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

enum LoginNextStepViewControllerState{
    case phoneNumber
}

class LoginNextStepViewController: BaseViewController {
    var state:LoginNextStepViewControllerState?{
        didSet{
            
        }
    }
  
    init(titleString:String,detailTitleString:String,state:LoginNextStepViewControllerState) {
        super.init()
        IQKeyboardManager.shared.enable = false
        titleLabel.text = titleString
        detailTitleLabel.text = detailTitleString
//        self.titleString = titleString
//        self.detailTitleString = detailTitleString
//        self.state = state
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = COR1
        view.addSubview(titleLabel)
        view.addSubview(detailTitleLabel)
        detailTitleLabel.sizeToFit()
        view.addSubview(inputTextField)
        let textFieldController = MDCTextInputControllerFilled.init(textInput: inputTextField)
        textFieldController.placeholderText = "手机号"
//        textFieldController.isFloatingEnabled = true
        textFieldController.normalColor = .white
        view.addSubview(nextButton)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.init(x: MarginsWidth, y: MDCAppNavigationBarHeight + 25, width: __kWidth - MarginsWidth*2 , height: 28))
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textColor = .white
        return label
    }()
    
    lazy var detailTitleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.init(x: MarginsWidth, y: titleLabel.bottom + MarginsWidth, width: __kWidth - MarginsWidth*2 , height: 28))
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    lazy var inputTextField: MDCTextField = {
        let textField = MDCTextField.init(frame: CGRect(x: MarginsWidth, y: detailTitleLabel.bottom + 54, width: __kWidth - MarginsWidth*2, height: 120))
//       textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    lazy var nextButton: MDCFloatingButton = {
        let button = MDCFloatingButton.init(shape: MDCFloatingButtonShape.default)
        let width:CGFloat = 40
        button.frame = CGRect(x: __kWidth - MarginsWidth - width , y: __kHeight - MarginsWidth - width, width: width, height: width)
        button.setImage(UIImage.init(named: "next_button_arrow"), for: UIControlState.normal)
        return button
    }()
}
