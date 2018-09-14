//
//  IdentifyingFromDeviceViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/9/13.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
enum  IdentifyingFromDeviceViewControllerState{
    case searching
    case waiting
    case finish
    case error
}

class IdentifyingFromDeviceViewController: BaseViewController {
    var state:IdentifyingFromDeviceViewControllerState?{
        didSet{
            switch state {
            case .searching?:
              searchingStateAction()
            case .waiting?:
                waitingStateAction()
            case .finish?:
                finishStateAction()
            case .error?:
                waitingStateAction()
            default:
                break
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(titleLabel)
        self.view.addSubview(confirmImageView)
        setContentStyle()
        self.view.addSubview(tipsLabel)
        self.view.addSubview(activityIndicator)
        self.state = .waiting
        DispatchQueue.global(qos: .default).asyncAfter(deadline: DispatchTime.now() + 3) {
            DispatchQueue.main.async {
                self.state = .searching
                DispatchQueue.global(qos: .default).asyncAfter(deadline: DispatchTime.now() + 3) {
                    DispatchQueue.main.async {
                      self.state = .finish
                    }
                }
            }
        }
    }
    
    deinit {
        print("\(className()) deinit")
    }
    
    func searchingStateAction(){
        self.setTipsLabelStyle(text: "身份已确认\n设备正在连接闻上云")
        activityIndicator.frame = CGRect(x: (__kWidth - 20)/2, y: self.tipsLabel.bottom + 26, width: 20, height: 20)
        let color = UIColor.init(rgb: 0x00875b3)
        activityIndicator.cycleColors = [color]
//        activityIndicator.radius = 18.0
        activityIndicator.strokeWidth = 2.0
        activityIndicator.indicatorMode = .indeterminate
//        shareSingleOneActivityIndicator.sizeToFit()
        activityIndicator.startAnimating()
    }
    
    func waitingStateAction(){
        self.setTipsLabelStyle(text: "短按设备开关按键")
    }
    
    func finishStateAction(){
         defaultNotificationCenter().post(name: NSNotification.Name.Config.ConfigFinishPreDismissKey, object: nil)
        activityIndicator.stopAnimating()
        self.presentingViewController?.dismiss(animated: false, completion: {
            defaultNotificationCenter().post(name: NSNotification.Name.Config.ConfigFinishDismissKey, object: nil)
        })
    }
    
    func setTipsLabelStyle(text:String){
        let tipsString = LocalizedString(forKey: text)
        let font = UIFont.systemFont(ofSize: 14)
        let size = labelSizeToFit(title: tipsString, font: font)
        tipsLabel.numberOfLines = 0
        tipsLabel.frame = CGRect(x: (__kWidth - size.width*2)/2, y: confirmImageView.bottom + MarginsWidth, width: size.width*2, height: (tipsString as NSString).height(for: font, width: size.width))
        tipsLabel.font = font
        tipsLabel.textAlignment = NSTextAlignment.center
        tipsLabel.textColor = DarkGrayColor
        tipsLabel.text = tipsString
    }
    
    func setContentStyle(){
        titleLabel.text = LocalizedString(forKey: "身份确认")
        confirmImageView.layer.cornerRadius = 4
        confirmImageView.layer.borderColor = Gray26Color.cgColor
        confirmImageView.layer.borderWidth = 3
        confirmImageView.clipsToBounds = true
        
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect(x: MarginsWidth, y: MarginsWidth + MDCAppNavigationBarHeight, width: __kWidth - MarginsWidth*2, height: 22))
        label.font = UIFont.boldSystemFont(ofSize: 21)
        label.textColor = DarkGrayColor
        return label
    }()
    
    lazy var confirmImageView = UIImageView.init(frame: CGRect(x: (__kWidth - 100)/2, y: self.titleLabel.bottom + 40, width: 100, height: 196))
    
    lazy var tipsLabel = UILabel.init()
    
    lazy var activityIndicator = MDCActivityIndicator(frame: CGRect.zero)
}
