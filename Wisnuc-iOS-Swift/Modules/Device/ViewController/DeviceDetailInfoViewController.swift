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
    let headerHeight:CGFloat = 165
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareNavigationBar()
        
        self.view.addSubview(infoTableView)
        
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
        
       
        
      
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
    
    lazy var capacityProgressView: UIProgressView = { [weak self] in
        let progressView = UIProgressView.init(frame: CGRect(x: MarginsWidth, y: (self?.deviecNameLabel.bottom)! + MarginsWidth , width: __kWidth - MarginsWidth*2, height: 12))
        progressView.progress = 0.4
        progressView.transform = CGAffineTransform(scaleX: 1.0, y: 8.0)
        //设置进度条颜色和圆角
        progressView.setRadiusTrackColor(UIColor.white.withAlphaComponent(0.12), progressColor: UIColor.colorFromRGB(rgbValue: 0x04db6ac))
        return progressView
        }()
    
    lazy var capacityLabel: UILabel = { [weak self] in
        let text = "已使用45.4GB / 2TB"
        let font = UIFont.boldSystemFont(ofSize: 28)
        let width = labelWidthFrom(title: text, font: font)
        let label = UILabel.init(frame: CGRect(x:__kWidth - MarginsWidth - width - 2  , y:(self?.deviecNameLabel.top)!, width: width + 2, height: 14))
        label.textColor = LightGrayColor
        label.font = font
        label.text = text
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
        headerView.addSubview(capacityProgressView)
        headerView.addSubview(capacityLabel)
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


