//
//  TransferTaskTableViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/11.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialShadowLayer
import Material
private let reuseIdentifier = "cellreuseIdentifier"

class TransferTaskTableViewController: BaseViewController {
    lazy var downloadTasks = [TRTask]()
    var downloadManager: TRManager?
    var taskDataSource: Array<Any>?

    override init(style: NavigationStyle) {
        super.init(style: style)
        taskDataSource = Array.init()
   
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appBar.headerViewController.headerView.trackingScrollView = tableView
        self.appBar.navigationBar.title = LocalizedString(forKey: "Transfer task")
        downloadManager = FilesRootViewController.downloadManager
        
        // 因为会读取缓存到沙盒的任务，所以第一次的时候，不要马上开始下载
        downloadManager?.isStartDownloadImmediately = false
        setupManager()
        taskDataSource?.append(contentsOf: downloadTasks)
        getTasks()
        self.view.addSubview(self.tableView)
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
    }
    
    func getTasks(){
        var array:Array<FilesTasksModel> = Array.init()
        TasksAPI.init().startRequestJSONCompletionHandler { [weak self] (response) in
            if response.error == nil {
                if let errorMessage = ErrorTools.responseErrorData(response.data){
                    Message.message(text: errorMessage)
                    return
                }
                let isLocal = AppNetworkService.networkState == .local ? true : false
                var rootArray:NSArray = NSArray.init()
                if isLocal{
                    if response.value is NSArray{
                        rootArray = response.value as! NSArray
                    }
                }else{
                    if let rootDic = response.value as? NSDictionary{
                        if let dataArray = rootDic["data"] as? NSArray{
                            rootArray = dataArray
                        }
                    }
                }
                
                for  value  in rootArray {
                    let dic = value as! NSDictionary
                    if let model = FilesTasksModel.deserialize(from: dic){
                        array.append(model)
                    }
                }
                self?.taskDataSource?.append(contentsOf: array)
            }else{
                Message.message(text: (response.error?.localizedDescription)!)
            }
            self?.tableView.reloadData()
        }
    }
    
    func setupManager() {
        guard let downloadManager = downloadManager else { return  }
        downloadTasks = downloadManager.tasks.map({ $0 })
        tableView.reloadData()
        // 设置manager的回调
         downloadManager.progress { [weak self] (manager) in
//            guard let strongSelf = self else { return }

            
            }.success{ [weak self] (manager) in
//                guard let strongSelf = self else { return }
                if manager.status == .suspend {
                    // manager 暂停了
                }
                if manager.status == .completed {
                    // manager 完成了
                    print("下载完成")
                }
            }.failure { [weak self] (manager) in
//                guard let strongSelf = self,
//                    let downloadManager = strongSelf.downloadManager
//                    else { return }
//                self?.downloadTasks = (self?.downloadManager?.tasks.map({ $0}))!
                
//                self?.tableView.reloadData()
                
                if manager.status == .failed {
                    // manager 失败了
                }
                if manager.status == .cancel {
                    // manager 取消了
                    print("下载取消")
                }
                if manager.status == .remove {
                    // manager 移除了
                }
        }
    }
    
    func removeTask(model:FilesTasksModel){
        if let uuid = model.uuid {
            DeleteTasksAPI.init(taskUUID: uuid).startRequestJSONCompletionHandler({ [weak self](response) in
                if response.error == nil {
                    //                        mainThreadSafe {
                    self?.taskDataSource?.removeAll(where: { (any) -> Bool in
                        if let anModel = any as? FilesTasksModel{
                            return anModel.uuid == uuid
                        }else{
                            return false
                        }
                    })
                    self?.tableView.reloadData()
                    //                        }
                }else{
                    Message.message(text: (response.error?.localizedDescription)!)
                }
            })
        }
    }


    override func viewWillAppear(_ animated: Bool) {
        self.appBar.headerViewController.headerView.isHidden = false
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        if let tab = retrieveTabbarController(){
            if !tab.tabBarHidden{
                tab.setTabBarHidden(true, animated: true)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let tab = retrieveTabbarController(){
            if tab.tabBarHidden{
                tab.setTabBarHidden(false, animated: true)
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func rightBarButtonItem(_ sender:UIBarButtonItem){
       let bottomSheet = AppBottomSheetController.init(contentViewController: transferTaskBottomSheetContentVC)
        self.present(bottomSheet, animated: true, completion: nil)
    }
    
    func readFile(filePath:String){
        let documentController = UIDocumentInteractionController.init()
        documentController.delegate = self
        documentController.url = URL.init(fileURLWithPath: filePath)
        let  canOpen = documentController.presentPreview(animated: true)
        if (!canOpen) {
            Message.message(text: LocalizedString(forKey: "File preview failed"))
            documentController.presentOptionsMenu(from: self.view.bounds, in: self.view, animated: true)
        }
    }

    lazy var tableView: UITableView = {
        let tbView = UITableView.init(frame: CGRect(x: 0, y: 0, width: __kWidth, height: __kHeight))
        tbView.delegate = self
        tbView.dataSource = self
        tbView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        tbView.tableFooterView = UIView.init(frame: CGRect.zero)
        tbView.register(UINib.init(nibName: "TransferTaskTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        return tbView
    }()
    
    lazy var rightBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem.init(image:Icon.moreHorizontal?.byTintColor(LightGrayColor) , style: UIBarButtonItemStyle.done, target: self, action: #selector(rightBarButtonItem(_ :)))
        return barButtonItem
    }()
    
    lazy var transferTaskBottomSheetContentVC: TransferTaskBottomSheetContentTableViewController = {
        let vc = TransferTaskBottomSheetContentTableViewController.init(style: UITableViewStyle.plain)
        vc.delegate = self
        return vc
    }()
    
//    lazy var documentController: UIDocumentInteractionController = {
//       let doucumentController = UIDocumentInteractionController.init()
//        doucumentController.delegate = self
//        return doucumentController
//    }()
}

 // MARK: - Table view data source
extension TransferTaskTableViewController:UITableViewDataSource{
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell:TransferTaskTableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! TransferTaskTableViewCell

    let any = taskDataSource![indexPath.row]
    var downloadTask :TRTask?
    var model:FilesTasksModel?
    if any is TRTask {
        guard downloadManager != nil
            else { return cell }
        let task = any as! TRTask
        downloadTask = task
        cell.setTask(task:task)
        var image: UIImage?
        switch downloadTask?.status {
        case .running?:
            break
        case .suspend?:
            cell.suspendButton.setImage(#imageLiteral(resourceName: "task_suspend.png"), for: .normal)
        case .completed?:
            image = #imageLiteral(resourceName: "file_finish.png")
        case .waiting?:
            break
        default: break
        }
        cell.model = nil
        cell.controlButton.setImage(image, for: .normal)
        cell.detailLabel.text = "\(task.progress.totalUnitCount.tr.convertBytesToString())"
        cell.updateProgress(task: downloadTask!)
        task.progressHandler = { (progressTask) in
            if cell.model != nil{
                cell.progress.isHidden = true
                return
            }
            cell.progress.isHidden = false
            cell.progress.progressTotal = UInt(progressTask.progress.totalUnitCount)
            cell.progress.progressCounter = UInt(progressTask.progress.completedUnitCount)
            //        print("😁\(task.progress.totalUnitCount)")
            //        print("😈\(task.progress.completedUnitCount)")
            cell.progress.label.text = progressTask.speed.tr.convertSpeedToString()
            cell.updateProgress(task: downloadTask!)
        }
        cell.detailImageView.image = #imageLiteral(resourceName: "files_download_transfer.png")
    }else if any is FilesTasksModel{
        model = any as? FilesTasksModel
        cell.setModel(model: model!)
        var image = #imageLiteral(resourceName: "files_download_transfer.png")
        switch model?.type {
        case .move?:
            image = #imageLiteral(resourceName: "files_move_to.png")
        case .copy?:
            image = #imageLiteral(resourceName: "task_copy.png")
        default:
            break
        }
         cell.progress.isHidden = true
         cell.detailLabel.text = ""
         cell.detailImageView.image = image
         cell.controlButton.setImage(nil, for: UIControlState.normal)
    }
    
    let fileName = model != nil ? (model?.entries as! Array<String>).joined(separator: ",") : downloadTask?.fileName ?? ""
    cell.titleLabel.text = fileName
    let exestr = (fileName as NSString).pathExtension
    cell.leftImageView.image = UIImage.init(named: FileTools.switchFilesFormatType(type: FilesType.file, format: FilesFormatType(rawValue: exestr)))
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return taskDataSource!.count
    }
}

extension TransferTaskTableViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteRowAction = UITableViewRowAction.init(style: UITableViewRowActionStyle.default, title: LocalizedString(forKey: "Delete")) { [weak self](tableViewForAction, indexForAction) in
            let index = indexForAction.row
            guard let any = self?.taskDataSource?[index] else {
                return
            }
            if any is TRTask{
                let task = any as! TRTask
                guard let downloadManager = self?.downloadManager else { return  }
                let count = self?.taskDataSource?.count
                guard count! > 0 else { return }
                
                self?.taskDataSource?.remove(at: index)

                tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                downloadManager.remove(task.URLString, completely: true)
            }else if any is FilesTasksModel{
                let model = any as? FilesTasksModel
                DeleteTasksAPI.init(taskUUID: (model?.uuid!)!).startRequestJSONCompletionHandler({ (response) in
                    if response.error == nil {
//                        mainThreadSafe {
                            self?.taskDataSource?.remove(at: index)
                            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
//                        }
                    }else{
                        Message.message(text: (response.error?.localizedDescription)!)
                    }
                })
            }
        }
//        deleteRowAction.backgroundColor = UIColor.red
//        let priorityRowAction = UITableViewRowAction.init(style: UITableViewRowActionStyle.default, title: LocalizedString(forKey: "priority_transfer")) { (tableViewForAction, indexForAction) in
//
//        }
//        priorityRowAction.backgroundColor = UIColor.purple
        return [deleteRowAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let any = taskDataSource![indexPath.row]
        if any is TRTask {

            let task:TRTask = taskDataSource?.safeObjectAtIndex(indexPath.row) as! TRTask
            switch task.status {
            case .running:
                downloadManager?.suspend(task.URLString)
            case .completed:
                let filName = task.fileName
                if task.cache.fileExists(fileName: filName){
                    self.readFile(filePath: task.cache.filePtah(fileName: filName)!)
                }else{
                    Message.message(text: LocalizedString(forKey: "File not exist"))
                }
            case .suspend:
                downloadManager?.start(task.URLString)
            case .preSuspend:
                downloadManager?.start(task.URLString)
            default:
                break
            }
            if let cell = tableView.cellForRow(at: indexPath) as? TransferTaskTableViewCell{
                cell.updateProgress(task: task)
            }
        }else if any is FilesTasksModel{

        }
    }
    
    // 每个cell中的状态更新，应该在willDisplay中执行
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let any = taskDataSource![indexPath.row]
        if any is TRTask {
            let task:TRTask = taskDataSource?.safeObjectAtIndex(indexPath.row) as! TRTask
            task.progress { [weak cell] (task) in
                guard let cell = cell as? TransferTaskTableViewCell else { return }
                cell.setTask(task:task)
                cell.detailImageView.image = #imageLiteral(resourceName: "files_download_transfer.png")
                var image: UIImage?
                switch task.status {
                case .running:
                   cell.updateProgress(task: task)
                    task.progressHandler = { (progressTask) in
                        if cell.model != nil{
                            cell.progress.isHidden = true
                            return
                        }
                       
                        cell.progress.isHidden = false
                        cell.progress.progressTotal = UInt(progressTask.progress.totalUnitCount)
                        cell.progress.progressCounter = UInt(progressTask.progress.completedUnitCount)
                        //        print("😁\(task.progress.totalUnitCount)")
                        //        print("😈\(task.progress.completedUnitCount)")
                        cell.progress.label.text = progressTask.speed.tr.convertSpeedToString()
//                        cell.updateProgress(task: downloadTask!)
                    }
                case .failed:
                    image = #imageLiteral(resourceName: "files_error.png")
                case .suspend:
                    cell.suspendButton.setImage(#imageLiteral(resourceName: "task_suspend.png"), for: .normal)
                case .completed:
                    image = #imageLiteral(resourceName: "file_finish.png")
                case .waiting:
                    break
                default: break
                }
                cell.controlButton.setImage(image, for: .normal)
                cell.updateProgress(task: task)
                }
                .success({ [weak cell] (task) in
                    guard let cell = cell as? TransferTaskTableViewCell else { return }
                    //                cell.controlButton.setImage(#imageLiteral(resourceName: "suspend"), for: .normal)
                    if task.status == .suspend {
//                         cell.suspendButton.setImage(#imageLiteral(resourceName: "task_suspend.png"), for: .normal)
                        
                    }
                    if task.status == .completed {
                        // 下载任务完成了
                        cell.controlButton.setImage(#imageLiteral(resourceName: "file_finish.png"), for: .normal)
                    }
                    cell.updateProgress(task: task)

                })
                .failure({ [weak cell] (task) in
                    guard let cell = cell as? TransferTaskTableViewCell else { return }
                    //                cell.controlButton.setImage(#imageLiteral(resourceName: "suspend"), for: .normal)

                    if task.status == .failed {
                        // 下载任务失败了
                    }
                    if task.status == .cancel {
                        // 下载任务取消了
                    }
                    if task.status == .remove {
                        // 下载任务移除了
                    }
                    cell.updateProgress(task: task)
                })
        }else if any is FilesTasksModel{
            let model = any as! FilesTasksModel
           
            var image = #imageLiteral(resourceName: "files_download_transfer.png")
            switch model.type {
            case .move?:
                image = #imageLiteral(resourceName: "files_move_to.png")
            case .copy?:
                image = #imageLiteral(resourceName: "task_copy.png")
            default:
                break
            }
            guard let cell = cell as? TransferTaskTableViewCell else { return }
            cell.setModel(model: model)
            cell.detailImageView.image = image
            cell.detailLabel.text = ""
            cell.controlButton.setImage(nil, for: UIControlState.normal)
            cell.progress.isHidden = true
        }
    }
    
    // 由于cell是循环利用的，不在可视范围内的cell，不应该去更新cell的状态
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (taskDataSource?.count)! >= indexPath.row {
            return
        }
        if let any = taskDataSource?[indexPath.row]{
            if any is TRTask {
                let task = taskDataSource?.safeObjectAtIndex(indexPath.row) as! TRTask
                task.progress { _ in }.success({ _ in }).failure({ _ in})
            }
        }
    }
}


extension TransferTaskTableViewController:TransferTaskBottomSheetContentVCDelegate{
    func transferTaskBottomSheettableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.transferTaskBottomSheetContentVC.presentingViewController?.dismiss(animated: true, completion: {
            for  any  in self.taskDataSource!{
                if any is TRTask{
                    guard let downloadManager = self.downloadManager
                        else { return  }
                    let task = any as! TRTask
                    switch indexPath.row {
                    case 0:
                        if task.status == .suspend || task.status == .preSuspend  ||  task.status == .failed {
                            downloadManager.start(task.URLString)
                        }
                    case 1:
                        if task.status == .running {
                            downloadManager.suspend(task.URLString)
                        }
                    default:
                        break
                    }
                }
            }
            self.tableView.reloadData()
            if indexPath.row == 2{
            guard let downloadManager = self.downloadManager
                else { return  }
                downloadManager.totalRemove(completely: true)
                let array:NSArray = self.taskDataSource! as NSArray
                for value in array{
                    if value is TRTask{
                        if let task = value as? TRTask{
                            self.taskDataSource?.removeAll(where: { (any) -> Bool in
                                if let anTask = any as? TRTask{
                                    return anTask.url == task.url
                                }else{
                                    return false
                                }
                            })
                        }
                    }else if value is FilesTasksModel {
                        if let model = value as? FilesTasksModel{
                            self.removeTask(model: model)
                        }
                    }
                }
                self.tableView.reloadData()
            }
        })
    }
}

extension TransferTaskTableViewController:UIDocumentInteractionControllerDelegate{
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    func documentInteractionControllerViewForPreview(_ controller: UIDocumentInteractionController) -> UIView? {
        return self.view
    }
    
    func documentInteractionControllerRectForPreview(_ controller: UIDocumentInteractionController) -> CGRect {
        return self.view.frame
    }
}
