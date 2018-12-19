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
    var statsModel:StatsModel?
    var bootSpaceModel:BootSpaceModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareNavigationBar()
        
        self.view.addSubview(infoTableView)
        
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)

      
    }
    
    init(style: NavigationStyle,statsModel:StatsModel,bootSpaceModel:BootSpaceModel) {
        super.init(style: style)
        self.statsModel = statsModel
        self.bootSpaceModel = bootSpaceModel
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appBar.headerViewController.headerView.trackingScrollView = self.infoTableView
       
    }
    
    func fetchTotalProportion(statsModel:StatsModel,bootSpaceModel:BootSpaceModel) ->  Float? {
        guard  let documentSize = statsModel.document?.totalSize ,let imageSize = statsModel.image?.totalSize,let videoSize = statsModel.video?.totalSize,let otherSize = statsModel.others?.totalSize else {
            return nil
        }
        guard  var totalSize = bootSpaceModel.total else {
            return nil
        }
        
        guard  var usedSize = bootSpaceModel.used else {
            return nil
        }
        
        if totalSize == 0{
            return nil
        }
        totalSize = totalSize * 1024
        usedSize = usedSize * 1024
        let statsTotalSize = documentSize + imageSize + videoSize + otherSize
        
        var totalProportion:Float = 1.0
        
        if statsTotalSize != 0 && statsTotalSize > usedSize {
            totalProportion = Float(usedSize)/Float(statsTotalSize)
        }
        return totalProportion
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
            if let count = self.statsModel?.document?.count{
                cell.detailLabel.text = "\(count)个"
            }
            
            if let documentTotalSize = self.statsModel?.document?.totalSize{
                if let proportion  = self.fetchTotalProportion(statsModel: statsModel!, bootSpaceModel: bootSpaceModel!) {
                    let size = Float(documentTotalSize) * proportion
                    cell.rightLabel.text = sizeString(Int64(size))
                }
            }
           
        case 1:
            cell.titleLabel.text = LocalizedString(forKey: "照片")
            cell.leftImageView.image = UIImage.init(named: "photo_icon_device_detail.png")
            if let count = self.statsModel?.image?.count{
                cell.detailLabel.text = "\(count)个"
            }
            if let imageTotalSize = self.statsModel?.image?.totalSize{
                if let proportion  = self.fetchTotalProportion(statsModel: statsModel!, bootSpaceModel: bootSpaceModel!) {
                    let size = Float(imageTotalSize) * proportion
                    cell.rightLabel.text = sizeString(Int64(size))
                }
            }
        case 2:
            cell.titleLabel.text = LocalizedString(forKey: "视频")
            cell.leftImageView.image = UIImage.init(named: "video_icon_device_detail.png")
            if let count = self.statsModel?.video?.count{
                cell.detailLabel.text = "\(count)个"
            }
            if let videoTotalSize = self.statsModel?.video?.totalSize{
                if let proportion  = self.fetchTotalProportion(statsModel: statsModel!, bootSpaceModel: bootSpaceModel!) {
                    let size = Float(videoTotalSize) * proportion
                    cell.rightLabel.text = sizeString(Int64(size))
                }
            }
        case 3:
            cell.titleLabel.text = LocalizedString(forKey: "其他")
            cell.leftImageView.image = UIImage.init(named: "other_icon_device_detail.png")
            if let count = self.statsModel?.others?.count{
                cell.detailLabel.text = "\(count)个"
            }
            if let othersTotalSize = self.statsModel?.others?.totalSize{
                if let proportion  = self.fetchTotalProportion(statsModel: statsModel!, bootSpaceModel: bootSpaceModel!) {
                    let size = Float(othersTotalSize) * proportion
                    cell.rightLabel.text = sizeString(Int64(size))
                }
            }
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


