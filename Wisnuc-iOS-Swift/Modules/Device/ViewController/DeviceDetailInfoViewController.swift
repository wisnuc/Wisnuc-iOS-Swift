//
//  DeviceDetailInfoViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/18.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class DeviceDetailInfoViewController: BaseViewController {
    let identifier = "cellIdentifier"
    let headerHeight:CGFloat = 130
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareNavigationBar()
        
        self.view.addSubview(infoTableView)
        
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
        
        setHeaderContentFrame()
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appBar.headerViewController.headerView.trackingScrollView = self.infoTableView
       
    }
    
    @objc func dismiss(_ sender:UIBarButtonItem){
        self.presentingViewController?.dismiss(animated: true, completion: {
            
        })
    }
    
    
    func prepareNavigationBar(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "close_gray.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(dismiss(_ :)))
    }
    
    func setHeaderContentFrame(){
        capacityFilesProgressView.snp.makeConstraints { (make) in
            make.centerY.equalTo(capacityProgressBackgroudView.snp.centerY)
            make.left.equalTo(capacityProgressBackgroudView.snp.left)
            make.top.equalTo(capacityProgressBackgroudView.snp.top)
            make.bottom.equalTo(capacityProgressBackgroudView.snp.bottom)
            make.width.equalTo((capacityProgressBackgroudView.width - 3*2) * 0.2)
        }
        
        capacityPhotoProgressView.snp.makeConstraints { (make) in
            make.centerY.equalTo(capacityProgressBackgroudView.snp.centerY)
            make.left.equalTo(capacityFilesProgressView.snp.right).offset(2)
            make.top.equalTo(capacityProgressBackgroudView.snp.top)
            make.bottom.equalTo(capacityProgressBackgroudView.snp.bottom)
            make.width.equalTo((capacityProgressBackgroudView.width - 3*2) * 0.4)
        }
        
        capacityVideoProgressView.snp.makeConstraints { (make) in
            make.centerY.equalTo(capacityProgressBackgroudView.snp.centerY)
            make.left.equalTo(capacityPhotoProgressView.snp.right).offset(2)
            make.top.equalTo(capacityProgressBackgroudView.snp.top)
            make.bottom.equalTo(capacityProgressBackgroudView.snp.bottom)
            make.width.equalTo((capacityProgressBackgroudView.width - 3*2) * 0.1)
        }
        
        capacityOtherProgressView.snp.makeConstraints { (make) in
            make.centerY.equalTo(capacityProgressBackgroudView.snp.centerY)
            make.left.equalTo(capacityVideoProgressView.snp.right).offset(2)
            make.top.equalTo(capacityProgressBackgroudView.snp.top)
            make.bottom.equalTo(capacityProgressBackgroudView.snp.bottom)
            make.width.equalTo((capacityProgressBackgroudView.width - 3*2) * 0.05)
        }
    }
    
    func setHeaderLegendFrame(){
        capacityFilesLegendView.snp.makeConstraints { (make) in
            make.left.equalTo(capacityProgressBackgroudView.snp.left)
            make.top.equalTo(capacityProgressBackgroudView.snp.bottom).offset(8)
            make.size.equalTo(CGSize(width: 12, height: 12))
        }
        
        capacityFilesLegendLabel.snp.makeConstraints { (make) in
            make.left.equalTo(capacityFilesLegendView.snp.right).offset(MarginsCloseWidth)
            make.top.equalTo(capacityProgressBackgroudView.snp.bottom).offset(8)
            make.size.equalTo(CGSize(width: labelWidthFrom(title: LocalizedString(forKey: capacityFilesLegendLabel.text!), font: capacityFilesLegendLabel.font), height: 12))
        }
        
        capacityPhotoLegendView.snp.makeConstraints { (make) in
            make.left.equalTo(capacityFilesLegendLabel.snp.right).offset(MarginsWidth)
            make.top.equalTo(capacityProgressBackgroudView.snp.bottom).offset(8)
            make.size.equalTo(CGSize(width: 12, height: 12))
        }
        
        capacityPhotoLegendLabel.snp.makeConstraints { (make) in
            make.left.equalTo(capacityPhotoLegendView.snp.right).offset(MarginsCloseWidth)
            make.top.equalTo(capacityProgressBackgroudView.snp.bottom).offset(8)
            make.size.equalTo(CGSize(width: labelWidthFrom(title: LocalizedString(forKey: capacityPhotoLegendLabel.text!), font: capacityPhotoLegendLabel.font), height: 12))
        }
        
        
        capacityVideoLegendView.snp.makeConstraints { (make) in
            make.left.equalTo(capacityPhotoLegendLabel.snp.right).offset(MarginsWidth)
            make.top.equalTo(capacityProgressBackgroudView.snp.bottom).offset(8)
            make.size.equalTo(CGSize(width: 12, height: 12))
        }
        
        capacityVideoLegendLabel.snp.makeConstraints { (make) in
            make.left.equalTo(capacityVideoLegendView.snp.right).offset(MarginsCloseWidth)
            make.top.equalTo(capacityProgressBackgroudView.snp.bottom).offset(8)
            make.size.equalTo(CGSize(width: labelWidthFrom(title: LocalizedString(forKey: capacityVideoLegendLabel.text!), font: capacityVideoLegendLabel.font), height: 12))
        }
        
        capacityOtherLegendView.snp.makeConstraints { (make) in
            make.left.equalTo(capacityVideoLegendLabel.snp.right).offset(MarginsWidth)
            make.top.equalTo(capacityProgressBackgroudView.snp.bottom).offset(8)
            make.size.equalTo(CGSize(width: 12, height: 12))
        }
        
        capacityOtherLegendLabel.snp.makeConstraints { (make) in
            make.left.equalTo(capacityOtherLegendView.snp.right).offset(MarginsCloseWidth)
            make.top.equalTo(capacityProgressBackgroudView.snp.bottom).offset(8)
            make.size.equalTo(CGSize(width: labelWidthFrom(title: LocalizedString(forKey: capacityPhotoLegendLabel.text!), font: capacityPhotoLegendLabel.font), height: 12))
        }
    }
    
    lazy var infoTableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: __kWidth, height: __kHeight), style: UITableViewStyle.plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib.init(nibName: StringExtension.classNameAsString(targetClass: DeviceDetailInfdTableViewCell.self), bundle: nil), forCellReuseIdentifier: identifier)
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    lazy var headerView: UIView = {
        let view = UIView.init(frame: CGRect.zero)
    
        return view
    }()
    
    lazy var deviecNameLabel: UILabel = {
        let text = "WISNUC"
        let font = UIFont.boldSystemFont(ofSize: 28)
        let width = labelWidthFrom(title: text, font: font)
        let label = UILabel.init(frame: CGRect(x:MarginsWidth , y:8 , width: width + 2, height: 28))
        label.textColor = DarkGrayColor
        label.font = font
        label.text = text
        return label
    }()
    
    lazy var capacityProgressBackgroudView: UIView = { [weak self] in
        let progressView = UIView.init(frame: CGRect(x: MarginsWidth, y: (self?.deviecNameLabel.bottom)! + MarginsWidth , width: __kWidth - MarginsWidth*2, height: 24))
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        progressView.backgroundColor = UIColor.colorFromRGB(rgbValue: 0x0eceff1)
        progressView.addSubview((self?.capacityFilesProgressView)!)
        progressView.addSubview((self?.capacityPhotoProgressView)!)
        progressView.addSubview((self?.capacityVideoProgressView)!)
        progressView.addSubview((self?.capacityOtherProgressView)!)
        return progressView
        }()
    
    lazy var capacityLabel: UILabel = { [weak self] in
        let text = "已使用45.4GB / 2TB"
        let font = UIFont.boldSystemFont(ofSize: 14)
        let width = labelWidthFrom(title: text, font: font)
        let label = UILabel.init(frame: CGRect(x:__kWidth - MarginsWidth - width - 2  , y:(self?.deviecNameLabel.top)! + 5, width: width + 2, height: 14))
        label.textColor = LightGrayColor
        label.font = font
        label.text = text
        return label
        }()
    
    lazy var capacityFilesProgressView: UIView = {
        let progressView = UIView.init()
        progressView.backgroundColor = UIColor.colorFromRGB(rgbValue: 0x0ffb300)
        return progressView
        }()
    
    lazy var capacityPhotoProgressView: UIView = {
        let progressView = UIView.init()
        progressView.backgroundColor = UIColor.colorFromRGB(rgbValue: 0x0aa00ff)
        return progressView
    }()
    
    lazy var capacityVideoProgressView: UIView = {
        let progressView = UIView.init()
        progressView.backgroundColor = UIColor.colorFromRGB(rgbValue: 0x02196f3)
        return progressView
    }()
    
    lazy var capacityOtherProgressView: UIView = {
        let progressView = UIView.init()
        progressView.backgroundColor = UIColor.colorFromRGB(rgbValue: 0x000c853)
        return progressView
    }()
    
    lazy var capacityFilesLegendView: UIView = {
        let view = UIView.init()
        view.layer.cornerRadius = 2
        view.clipsToBounds = true
        view.backgroundColor = UIColor.colorFromRGB(rgbValue: 0x0ffb300)
        return view
    }()
    
    lazy var capacityPhotoLegendView: UIView = {
        let view = UIView.init()
        view.layer.cornerRadius = 2
        view.clipsToBounds = true
        view.backgroundColor = UIColor.colorFromRGB(rgbValue: 0x0aa00ff)
        return view
    }()
    
    lazy var capacityVideoLegendView: UIView = {
        let view = UIView.init()
        view.layer.cornerRadius = 2
        view.clipsToBounds = true
        view.backgroundColor = UIColor.colorFromRGB(rgbValue: 0x02196f3)
        return view
    }()
    
    lazy var capacityOtherLegendView: UIView = {
        let view = UIView.init()
        view.layer.cornerRadius = 2
        view.clipsToBounds = true
        view.backgroundColor = UIColor.colorFromRGB(rgbValue: 0x000c853)
        return view
    }()
    
    lazy var capacityFilesLegendLabel: UILabel = {
        let label = UILabel.init()
        label.text = LocalizedString(forKey: "文件")
        label.textColor = DarkGrayColor
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    lazy var capacityPhotoLegendLabel: UILabel = {
        let label = UILabel.init()
        label.text = LocalizedString(forKey: "照片")
        label.textColor = DarkGrayColor
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    lazy var capacityVideoLegendLabel: UILabel = {
        let label = UILabel.init()
        label.text = LocalizedString(forKey: "视频")
        label.textColor = DarkGrayColor
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    lazy var capacityOtherLegendLabel: UILabel = {
        let label = UILabel.init()
        label.text = LocalizedString(forKey: "其他")
        label.textColor = DarkGrayColor
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
}

extension DeviceDetailInfoViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headerView.addSubview(deviecNameLabel)
        headerView.addSubview(capacityProgressBackgroudView)
        headerView.addSubview(capacityLabel)
      
        headerView.addSubview(capacityFilesLegendView)
        headerView.addSubview(capacityFilesLegendLabel)
        headerView.addSubview(capacityPhotoLegendView)
        headerView.addSubview(capacityPhotoLegendLabel)
        headerView.addSubview(capacityVideoLegendView)
        headerView.addSubview(capacityVideoLegendLabel)
        headerView.addSubview(capacityOtherLegendView)
        headerView.addSubview(capacityOtherLegendLabel)
        setHeaderLegendFrame()
     
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:DeviceDetailInfdTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! DeviceDetailInfdTableViewCell
        
        switch indexPath.row {
        case 0:
            cell.titleLabel.text = LocalizedString(forKey: "文件")
            cell.detailLabel.text = "12233个"
            cell.rightLabel.text = "201G"
        case 1:
            cell.titleLabel.text = LocalizedString(forKey: "照片")
            cell.detailLabel.text = "12233个"
            cell.rightLabel.text = "201G"
        case 2:
            cell.titleLabel.text = LocalizedString(forKey: "视频")
            cell.detailLabel.text = "12233个"
            cell.rightLabel.text = "2G"
        case 3:
            cell.titleLabel.text = LocalizedString(forKey: "其他")
            cell.detailLabel.text = "12233个"
            cell.rightLabel.text = "21G"
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


