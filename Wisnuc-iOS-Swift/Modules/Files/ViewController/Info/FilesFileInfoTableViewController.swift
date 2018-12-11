//
//  FilesFileInfoTableViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/16.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents.MDCAppBar
private let cellReuseIdentifier = "reuseIdentifier"
class FilesFileInfoTableViewController: BaseViewController {
    var model:EntriesModel?
    var location:String?
    var driveUUID:String?
    var dirUUID:String?
    var filseDirModel:FilesStatsModel?
    deinit {
        print("\(className()) deinit")
    }
    
    init(style: NavigationStyle,model:EntriesModel,driveUUID:String,dirUUID:String,location:String?) {
        super.init(style: style)
        self.model = model
        self.driveUUID = driveUUID
        self.dirUUID = dirUUID
        self.location = location
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareNavigationBar()
        if self.model?.type == FilesType.directory.rawValue{
           self.loadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appBar.headerViewController.headerView.isHidden = false
        let tab = retrieveTabbarController()
        tab?.setTabBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func prepareNavigationBar(){
        appBar.headerViewController.headerView.trackingScrollView = self.tableView
        self.tableView.delegate = appBar.headerViewController
        self.view.addSubview(tableView)
        ViewTools.automaticallyAdjustsScrollView(scrollView: tableView, viewController: self)
        view.bringSubview(toFront: appBar.headerViewController.headerView)
        appBar.navigationBar.title = model?.name ?? "未命名文件"
        appBar.navigationBar.titleTextColor = .clear
        appBar.headerViewController.headerView.addSubview(navigationBarBottomImageView)
        appBar.headerViewController.headerView.addSubview(navigationBarBottomLabel)
        appBar.headerViewController.headerView.delegate = self
        navigationBarBottomImageView.image = UIImage.init(named: FileTools.switchFilesFormatType(type: FilesType(rawValue: (model?.type)!), format: FilesFormatType(rawValue: model?.metadata?.type ?? FilesFormatType.DEFAULT.rawValue)))
        navigationBarBottomLabel.text = appBar.navigationBar.title
    }
    
    func loadData(){
        guard let driveUUID = self.driveUUID else {
            return
        }
        
//        guard let model = self.model else {
//            return
//        }
        
        guard let dirUUID = self.dirUUID else {
            return
        }
        let request = FilesStats.init(driveUUID: driveUUID, directoryUUID: dirUUID)
        request.startRequestJSONCompletionHandler { [weak self](response) in
            if let error = response.error{
                Message.message(text: error.localizedDescription)
            }else{
                if let errorMessage = ErrorTools.responseErrorData(response.data){
                    Message.message(text: errorMessage)
                }else{
                    guard let dic = response.value as? NSDictionary else{
                        Message.message(text: LocalizedString(forKey: "error"))
                        return
                    }
                    
                    let isLocal = AppNetworkService.networkState == .local ? true : false
                    var modelDic:NSDictionary = dic
                    if !isLocal{
                        if let dataDic = dic["data"] as? NSDictionary{
                            modelDic = dataDic
                        }
                    }
                    if let data = jsonToData(jsonDic: modelDic){
                        do{
                            let model = try JSONDecoder().decode(FilesStatsModel.self, from: data)
                            self?.filseDirModel = model
                            self?.tableView.reloadData()
                        }catch{
                           Message.message(text: error.localizedDescription)
                        }
                    }
                }
            }
        }
        
    }

    lazy var tableView: UITableView = {
        let contentTableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: __kWidth, height: __kHeight), style:.plain)
        contentTableView.delegate = self
        contentTableView.dataSource = self
        contentTableView.register(UINib.init(nibName:StringExtension.classNameAsString(obj: FilesFileInfoTableViewCell()), bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
        contentTableView.separatorStyle = .none
        contentTableView.contentInset = UIEdgeInsets.init(top:MarginsCloseWidth, left: 0, bottom: 0, right: 0)
        return contentTableView
    }()
    
    lazy var navigationBarBottomImageView: UIImageView = {
        let imageView = UIImageView.init(frame: CGRect.init(x: MarginsWidth, y: appBar.headerViewController.headerView.maximumHeight - MarginsWidth - 24, width: 24, height: 24))
        return imageView
    }()
    
    lazy var navigationBarBottomLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.init(x:navigationBarBottomImageView.right + MarginsWidth, y: appBar.headerViewController.headerView.maximumHeight - MarginsWidth -  24, width: __kWidth - navigationBarBottomImageView.right - MarginsWidth*2, height: 24))
        label.textColor = DarkGrayColor
        label.font = MiddlePlusTitleFont.withBold()
        label.text = appBar.navigationBar.title!
        return label
    }()
}

extension FilesFileInfoTableViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView.init()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - Table view data source
extension FilesFileInfoTableViewController:UITableViewDataSource{
     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if model?.type == FilesType.directory.rawValue {
             return 6
        }else{
            return 4
        }
      
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:FilesFileInfoTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! FilesFileInfoTableViewCell
        cell.selectionStyle = .none
        switch indexPath.row {
        case 0:
            cell.leftLabel.text = LocalizedString(forKey: "类型")
            cell.rightLabel.text = model?.type == FilesType.directory.rawValue ? "文件夹" : model?.name?.pathExtension
        case 1:
            cell.leftLabel.text = LocalizedString(forKey: "大小")
            if model?.type == FilesType.directory.rawValue{
                if let size = filseDirModel?.fileTotalSize{
                    cell.rightLabel.text = sizeString(size)
                }
            }else{
               cell.rightLabel.text = model?.size != nil ? sizeString((model?.size!)!) : ""
            }
        case 2:
            cell.leftLabel.text = LocalizedString(forKey: "位置")
            cell.rightLabel.isHidden = true
            cell.filesImageView.isHidden = false
            cell.folderButton.isHidden = false
            cell.folderButton.setTitle(self.location ?? "", for: UIControlState.normal)
        case 3:
            if model?.type == FilesType.directory.rawValue{
                cell.leftLabel.text = LocalizedString(forKey: "文件数量")
                cell.rightLabel.text = filseDirModel?.fileCount != nil ? String.init(describing: (filseDirModel?.fileCount)!) : "0"
            }else{
                cell.leftLabel.text = LocalizedString(forKey: "创建时间")
                cell.rightLabel.text =  model?.mtime != nil ? TimeTools.timeString(TimeInterval((model?.mtime!)!/1000)) : LocalizedString(forKey: "No time")
            }
        case 4:
            cell.leftLabel.text = LocalizedString(forKey: "文件夹数量")
            cell.rightLabel.text = filseDirModel?.dirCount != nil ? String.init(describing: (filseDirModel?.dirCount)!) : "0"
        case 5:
            cell.leftLabel.text = LocalizedString(forKey: "创建时间")
            cell.rightLabel.text =  model?.mtime != nil ? TimeTools.timeString(TimeInterval((model?.mtime!)!/1000)) : LocalizedString(forKey: "No time")
//        case 6:
//            cell.leftLabel.text = LocalizedString(forKey: "Modify")
//            cell.rightLabel.text = "30/12/2016 by Leo An"
        default:
            break
        }
        return cell
    }

}

extension FilesFileInfoTableViewController{
    override func flexibleHeaderViewNeedsStatusBarAppearanceUpdate(_ headerView: MDCFlexibleHeaderView) {
        
    }
    
    override func flexibleHeaderViewFrameDidChange(_ headerView: MDCFlexibleHeaderView) {
//       print(headerView.bottom)
        let viewOriginY:CGFloat = 120.0
        if headerView.maximumHeight != headerView.bottom{
             navigationBarBottomImageView.origin.y = viewOriginY + headerView.bottom - headerView.maximumHeight
            navigationBarBottomImageView.alpha = (navigationBarBottomImageView.origin.y-64)/(120-64)
            navigationBarBottomLabel.origin.y = viewOriginY + headerView.bottom - headerView.maximumHeight
        }
    }
}
