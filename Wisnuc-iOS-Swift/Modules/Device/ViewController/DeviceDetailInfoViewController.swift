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
    let headerHeight:CGFloat = 64
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
        let text = LocalizedString(forKey: "存储详情")
        let font = UIFont.boldSystemFont(ofSize: 21)
        let height = headerHeight
        let label = UILabel.init(frame: CGRect(x:MarginsWidth , y:0 , width: __kWidth - MarginsWidth*2, height: height))
        label.textColor = DarkGrayColor
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
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:DeviceDetailInfdTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! DeviceDetailInfdTableViewCell
        
        switch indexPath.row {
        case 0:
            cell.titleLabel.text = LocalizedString(forKey: "文件")
            cell.leftImageView.image = UIImage.init(named: "files_icon_device_detail.png")
            cell.detailLabel.text = "12233个"
            cell.rightLabel.text = "201G"
        case 1:
            cell.titleLabel.text = LocalizedString(forKey: "照片")
            cell.leftImageView.image = UIImage.init(named: "photo_icon_device_detail.png")
            cell.detailLabel.text = "12233个"
            cell.rightLabel.text = "201G"
        case 2:
            cell.titleLabel.text = LocalizedString(forKey: "视频")
            cell.leftImageView.image = UIImage.init(named: "video_icon_device_detail.png")
            cell.detailLabel.text = "12233个"
            cell.rightLabel.text = "2G"
        case 3:
            cell.titleLabel.text = LocalizedString(forKey: "其他")
            cell.leftImageView.image = UIImage.init(named: "other_icon_device_detail.png")
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


