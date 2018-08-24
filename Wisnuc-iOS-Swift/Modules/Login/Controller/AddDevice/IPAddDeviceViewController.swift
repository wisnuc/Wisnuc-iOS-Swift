//
//  IPAddDeviceViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/24.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents.MDCTextField

class IPAddDeviceViewController: BaseViewController {
    var ipTextField:MDCTextField?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = LocalizedString(forKey: "通过IP地址添加")
        appBar.headerViewController.headerView.backgroundColor = COR2
        addNavigationItemBar()
        view.addSubview(titleLabel)
        setTextField()
        view.addSubview(errorLabel)
    }
    
    func setTextField(){
        for idx in  0...4{
            View_Width_Space = MarginsCloseWidth
            View_Height_Space = 0
            View_Height = 32
            View_Width = (__kWidth - 8*4 - 16*2)/5.5
            View_Start_X = 16
            View_Start_Y = titleLabel.bottom + 86/2
            let width = View_Width
            if idx == 4{
                View_Width = View_Width*1.5
            }
            
            let textField = MDCTextField.init(frame: CGRect(x: View_Start_X + CGFloat(idx) * (View_Width_Space + width), y: View_Start_Y , width: View_Width, height: View_Height))
            textField.tag = idx
            textField.textColor = DarkGrayColor
            textField.textAlignment = NSTextAlignment.center
            textField.clearButtonMode = .never
            textField.tintColor = UIColor.colorFromRGB(rgbValue: 0x0dfdfdf)
            if idx == 4{
                let placeholderText = LocalizedString(forKey: "默认端口")
                let placeholderTextColor = LightGrayColor
                let style = NSMutableParagraphStyle.init()
//                //水平对齐
//                style.firstLineHeadIndent = (textField.width - labelWidthFrom(title: placeholderText, font: UIFont.systemFont(ofSize: UIFont.systemFontSize))*0.5 + 10)
                style.alignment = NSTextAlignment.center
                let attri = NSAttributedString.init(string: placeholderText, attributes: [NSAttributedStringKey.foregroundColor: placeholderTextColor,NSAttributedStringKey.paragraphStyle:style,NSAttributedStringKey.font:UIFont.systemFont(ofSize: UIFont.systemFontSize)])
                textField.attributedPlaceholder = attri

            }
            textField.delegate = self
            ipTextField = textField
            self.view.addSubview(textField)
            
            let labelStartX = textField.right
            
            if idx < 4 {
                let label = UILabel.init(frame: CGRect(x: labelStartX, y: textField.top + 10, width:View_Width_Space, height: View_Height))
                label.textColor = DarkGrayColor
                label.textAlignment = NSTextAlignment.center
                var text = "."
                if idx == 3 {
                    text = ":"
                }
                label.text = text
                label.font = BoldBigTitleFont
                self.view.addSubview(label)
            }
        }
    }

    func addNavigationItemBar() {
        let leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "close.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(leftBarButtonItemClick(_ :)))
        appBar.navigationBar.leftBarButtonItem = leftBarButtonItem
        
        let rightBarButtonItem = UIBarButtonItem.init(title: LocalizedString(forKey: "confirm"), style: UIBarButtonItemStyle.plain, target: self, action:#selector(rightBarButtonItemClick(_ :)))
        appBar.navigationBar.rightBarButtonItem = rightBarButtonItem
    }
    
  
    @objc func leftBarButtonItemClick(_ sender:UIBarButtonItem){
        self.presentingViewController?.dismiss(animated: true) {
            
        }
    }
    
    @objc func rightBarButtonItemClick(_ sender:UIBarButtonItem){
        
    }
    
    lazy var titleLabel:UILabel  = {
        let text = self.title!
        let font = SmallTitleFont
        let label = UILabel.init(frame: CGRect(x: MarginsWidth, y:MDCAppNavigationBarHeight + 52/2, width: __kWidth - 32    , height: labelHeightFrom(title: text, font: font)))
        label.text = text
        label.textColor = LightGrayColor
        label.font = font
        return label
    }()
    
    lazy var errorLabel: UILabel = {
        let startY = (ipTextField?.bottom)! - 28
        let text = LocalizedString(forKey: "请输入正确的IP地址")
        let font = SmallTitleFont
        let label = UILabel.init(frame: CGRect(x: MarginsWidth, y: startY, width:__kWidth - MarginsWidth*2 , height: labelWidthFrom(title: text, font: font)))
        label.text = text
        label.font = font
        label.textColor = RedErrorColor
//        label.hide = true
        return label
    }()
}

extension IPAddDeviceViewController:UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }

}
