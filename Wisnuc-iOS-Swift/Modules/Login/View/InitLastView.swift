//
//  InitLastView.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/25.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
private let BackgroudViewHeight:CGFloat = 488/2
private let ImageTopMargins:CGFloat = 56/2
private let ImageSizeWidth:CGFloat = 210/2
private let BottomButtonBottomMargins:CGFloat = 50/2
private let BottomButtonRightMargins:CGFloat = 50/2
private let CardViewTopMargins:CGFloat = 132/2
private let CardViewHeight:CGFloat = 590/2

enum InitFinishState:Int{
    case succeed = 0
    case failed
}

class InitLastView: UIView {
    var state:InitFinishState?{
        didSet{
            switch state {
            case .succeed?:
                succeedAction()
            case .failed?:
                failedAction()
            default:
                break
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    init(state:InitFinishState,frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        setState(state:state)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setState(state:InitFinishState) {
        self.state = state
    }
    
    func succeedAction() {
        self.removeAllSubviews()
        self.addSubview(bgView)
        let image = UIImage.init(named: "ok.png")
        stateImageView.image = image
        self.addSubview(stateImageView)
        stateLabelTitle.text = LocalizedString(forKey: "设备添加成功")
        stateLabelTitle.textColor  = UIColor.white
        self.addSubview(stateLabelTitle)
        self.addSubview(doneButton)
        self.addSubview(infoCardView)
    }
    
    func failedAction() {
        self.removeAllSubviews()
        let image = UIImage.init(named: "no.png")
        stateImageView.image = image
        self.addSubview(stateImageView)
        stateLabelTitle.text = LocalizedString(forKey: "添加失败")
        stateLabelTitle.textColor  = DarkGrayColor
        self.addSubview(stateLabelTitle)
        self.addSubview(failedDetailTitleLabel)
    }
    
    @objc func doneButtonClick(_ sender:UIButton){
    
    }
    
    lazy var bgView: UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width:self.width, height: self.height/2 - 44))
        view.backgroundColor = COR1
        return view
    }()
    
    lazy var stateImageView: UIImageView = {
        let imageView = UIImageView.init(frame: CGRect(x: (self.width - ImageSizeWidth)/2, y:ImageTopMargins , width: ImageSizeWidth, height: ImageSizeWidth))
        return imageView
    }()
    
    lazy var stateLabelTitle: UILabel = {
        let label = UILabel.init(frame: CGRect(x: 16, y: stateImageView.bottom + MarginsWidth, width: __kWidth - MarginsWidth * 2, height: 20))
        label.font = MiddlePlusTitleFont
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    lazy var failedDetailTitleLabel: UILabel = {
        let text = LocalizedString(forKey: "请重新尝试或跟换磁盘后再尝试")
        let label = UILabel.init(frame: CGRect(x: 16, y: stateLabelTitle.bottom + MarginsWidth, width: __kWidth - MarginsWidth * 2, height: 20))
        label.font = MiddleTitleFont
        label.textAlignment = NSTextAlignment.center
        label.textColor = LightGrayColor
        label.text = text
        return label
    }()
    lazy var  doneButton: UIButton = {
        let title = LocalizedString(forKey: "知道了")
        let font = MiddleTitleFont
        let width = labelWidthFrom(title: title, font: font)
        let height = labelHeightFrom(title: title, font: font)
        let button = UIButton.init(frame: CGRect(x: __kWidth - BottomButtonRightMargins - width, y: self.height - BottomButtonBottomMargins - height, width: width, height: height))
        button.setTitle(title, for: UIControlState.normal)
        button.titleLabel?.font = font
        button.setTitleColor(COR1, for: UIControlState.normal)
        button.addTarget(self, action: #selector(doneButtonClick(_ :)), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    lazy var infoCardView: UIView = {
        let cardView = UIView.init(frame: CGRect(x: MarginsWidth, y: bgView.bottom - CardViewTopMargins, width:self.width - MarginsWidth * 2, height: CardViewHeight))
        cardView.backgroundColor = UIColor.white
        cardView.layer.masksToBounds = true
        cardView.layer.cornerRadius = 2
        cardView.layer.shadowColor = LightGrayColor.cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowOffset = CGSize.zero
        cardView.layer.shadowRadius = 2
        cardView.clipsToBounds = false
        return cardView
    }()
}
