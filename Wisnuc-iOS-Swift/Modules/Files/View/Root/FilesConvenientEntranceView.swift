//
//  FilesConvenientEntranceView.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/19.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

@objc protocol FilesConvenientEntranceViewDelegate{
    func shareBoxTap()
    func backupBoxTap()
    func usbDeviceTap()
    func transferTaskTap()
}

class FilesConvenientEntranceView: UIScrollView {
    weak var viewDelegate:FilesConvenientEntranceViewDelegate?
    let entranceViewFrame:CGFloat = 72
    let entranceViewImageViewFrame:CGFloat = 48
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(shareBoxView)
        self.addSubview(backupBoxView)
        self.addSubview(transferTaskView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func shareBoxTap(_ sender:UIGestureRecognizer){
        self.viewDelegate?.shareBoxTap()
    }
    
    @objc func backupBoxTap(_ sender:UIGestureRecognizer){
        self.viewDelegate?.backupBoxTap()
    }
    
    @objc func usbDeviceTap(_ sender:UIGestureRecognizer){
         self.viewDelegate?.usbDeviceTap()
    }
    
    @objc func transferTaskTap(_ sender:UIGestureRecognizer){
         self.viewDelegate?.transferTaskTap()
    }
    
    lazy var shareBoxView: UIView = { [weak self] in
        let view = UIView.init(frame: CGRect(x: MarginsCloseWidth, y: 4, width: (self?.entranceViewFrame)!, height: (self?.entranceViewFrame)!))
        view.isUserInteractionEnabled = true
        let tapGestrue = UITapGestureRecognizer.init(target: self, action: #selector(shareBoxTap(_ :)))
        view.addGestureRecognizer(tapGestrue)
        
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "share_box_icon.png")
        view.addSubview(imageView)
        
        let label = UILabel.init()
        label.textColor = DarkGrayColor
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.text = LocalizedString(forKey: "共享空间")
        label.textAlignment = .center
        view.addSubview(label)
        imageView.snp.makeConstraints({ (make) in
            make.top.equalTo(view.snp.top)
            make.centerX.equalTo(view.snp.centerX)
            make.size.equalTo(CGSize(width:entranceViewImageViewFrame , height: entranceViewImageViewFrame))
        })
        
        label.snp.makeConstraints({ (make) in
            make.bottom.equalTo(view.snp.bottom).offset(-4)
            make.centerX.equalTo(view.snp.centerX)
            make.size.equalTo(CGSize(width:view.width , height: 14))
        })
        return view
    }()
    
    lazy var backupBoxView: UIView = { [weak self] in
        let view = UIView.init(frame: CGRect(x: (self?.shareBoxView.right)! + MarginsCloseWidth, y: 4, width: (self?.entranceViewFrame)!, height: (self?.entranceViewFrame)!))
        view.isUserInteractionEnabled = true
        let tapGestrue = UITapGestureRecognizer.init(target: self, action: #selector(backupBoxTap(_ :)))
        view.addGestureRecognizer(tapGestrue)
        
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "backup_box_icon.png")
        view.addSubview(imageView)
        
        let label = UILabel.init()
        label.textColor = DarkGrayColor
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.text = LocalizedString(forKey: "备份空间")
        label.textAlignment = .center
        view.addSubview(label)
        imageView.snp.makeConstraints({ (make) in
            make.top.equalTo(view.snp.top)
            make.centerX.equalTo(view.snp.centerX)
            make.size.equalTo(CGSize(width:entranceViewImageViewFrame , height: entranceViewImageViewFrame))
        })
        
        label.snp.makeConstraints({ (make) in
            make.bottom.equalTo(view.snp.bottom).offset(-4)
            make.centerX.equalTo(view.snp.centerX)
            make.size.equalTo(CGSize(width:view.width , height: 14))
        })
        return view
        }()
    
//    lazy var usbDeviceView: UIView = { [weak self] in
//        let view = UIView.init(frame: CGRect(x: (self?.backupBoxView.right)! + MarginsCloseWidth, y: 4, width: (self?.entranceViewFrame)!, height: (self?.entranceViewFrame)!))
//        view.isUserInteractionEnabled = true
//        let tapGestrue = UITapGestureRecognizer.init(target: self, action: #selector(usbDeviceTap(_ :)))
//        view.addGestureRecognizer(tapGestrue)
//
//        let imageView = UIImageView.init()
//        imageView.image = UIImage.init(named: "usb_icon.png")
//        view.addSubview(imageView)
//
//        let label = UILabel.init()
//        label.textColor = DarkGrayColor
//        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
//        label.text = LocalizedString(forKey: "USB")
//        label.textAlignment = .center
//        view.addSubview(label)
//        imageView.snp.makeConstraints({ (make) in
//            make.top.equalTo(view.snp.top)
//            make.centerX.equalTo(view.snp.centerX)
//            make.size.equalTo(CGSize(width:entranceViewImageViewFrame , height: entranceViewImageViewFrame))
//        })
//
//        label.snp.makeConstraints({ (make) in
//            make.bottom.equalTo(view.snp.bottom).offset(-4)
//            make.centerX.equalTo(view.snp.centerX)
//            make.size.equalTo(CGSize(width:view.width , height: 14))
//        })
//        return view
//        }()
    
    lazy var transferTaskView: UIView = { [weak self] in
        let view = UIView.init(frame: CGRect(x: (self?.backupBoxView.right)! + MarginsCloseWidth, y: 4, width: (self?.entranceViewFrame)!, height: (self?.entranceViewFrame)!))
        view.isUserInteractionEnabled = true
        let tapGestrue = UITapGestureRecognizer.init(target: self, action: #selector(transferTaskTap(_ :)))
        view.addGestureRecognizer(tapGestrue)
        
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "transfer_taks_icon.png")
        view.addSubview(imageView)
        
        let label = UILabel.init()
        label.textColor = DarkGrayColor
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.text = LocalizedString(forKey: "传输任务")
        label.textAlignment = .center
        view.addSubview(label)
        imageView.snp.makeConstraints({ (make) in
            make.top.equalTo(view.snp.top)
            make.centerX.equalTo(view.snp.centerX)
            make.size.equalTo(CGSize(width:entranceViewImageViewFrame , height: entranceViewImageViewFrame))
        })
        
        label.snp.makeConstraints({ (make) in
            make.bottom.equalTo(view.snp.bottom).offset(-4)
            make.centerX.equalTo(view.snp.centerX)
            make.size.equalTo(CGSize(width:view.width , height: 14))
        })
        return view
        }()
}
