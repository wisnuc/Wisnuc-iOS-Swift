//
//  ChlipsView.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/18.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
protocol  ChipsViewDelegate{
    func closeButtonTap(_ sender:UIButton)
}

class ChipsView: UIView {
    var delegate:ChipsViewDelegate?
    override init(frame: CGRect) {
     super.init(frame: frame)
        self.backgroundColor = .white
        self.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        self.layer.shadowRadius = 1
        self.layer.shadowOpacity = 0.5
        self.layer.shadowColor = DarkGrayColor.cgColor
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 4
        self.clipsToBounds = false
        self.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(MarginsCloseWidth)
            make.centerY.equalTo(self.snp.centerY)
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
        
        self.addSubview(closeButton)
        closeButton.snp.makeConstraints { (make) in
            make.right.equalTo(self.snp.right).offset(-MarginsCloseWidth)
            make.centerY.equalTo(self.snp.centerY)
            make.size.equalTo(CGSize(width: 18, height: 18))
        }
        
        self.addSubview(titleTextLabel)
        titleTextLabel.snp.makeConstraints { (make) in
            make.left.equalTo(imageView.snp.right).offset(MarginsWidth)
            make.right.equalTo(closeButton.snp.left).offset(MarginsCloseWidth)
            make.centerY.equalTo(self.snp.centerY)
        }
    }
    
    @objc func closeButtonTap(_ sender:UIButton){
        if let delegateOK = delegate{
            delegateOK.closeButtonTap(sender)
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var imageView: UIImageView = {
        let contentImageView = UIImageView.init()
        return contentImageView
    }()
    
    lazy var titleTextLabel: UILabel = {
        let label = UILabel.init()
        label.font = MiddlePlusTitleFont
        label.textColor = DarkGrayColor
        return label
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton.init()
        button.setImage(UIImage.init(named: "chips_close.png"), for: UIControlState.normal)
        button.addTarget(self, action: #selector(closeButtonTap(_ :)), for: UIControlEvents.touchUpInside)
        return button
    }()
}
