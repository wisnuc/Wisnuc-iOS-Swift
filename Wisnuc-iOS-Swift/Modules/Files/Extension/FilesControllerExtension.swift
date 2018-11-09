//
//  FilesControllerExtension.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/7/4.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation
import MaterialComponents
import Material
//private let SearchBarBottom:CGFloat = 77.0
var downloadTask:TRTask?
extension FilesRootViewController:FilesRootCollectionViewControllerDelegate{
    func shareBoxTap() {
        let shareVC = FileShareFolderViewController.init(style:.white)
        let tab = retrieveTabbarController()
        tab?.setTabBarHidden(true, animated: true)
        self.navigationController?.pushViewController(shareVC, animated: true)
    }
    
    func backupBoxTap() {
        let deviceBackupRootViewController = DeviceBackupRootViewController.init(style:.highHeight)
        let tab = retrieveTabbarController()
        tab?.setTabBarHidden(true, animated: true)
        self.navigationController?.pushViewController(deviceBackupRootViewController, animated: true)
    }
    
    func usbDeviceTap() {
        let peripheralDeviceViewController = DevicePeripheralDeviceViewController.init(style:.highHeight)
        let tab = retrieveTabbarController()
        tab?.setTabBarHidden(true, animated: true)
        self.navigationController?.pushViewController(peripheralDeviceViewController, animated: true)
    }
    
    func transferTaskTap() {
        let transferTaskTableViewController = TransferTaskTableViewController.init(style:NavigationStyle.white)
        let tab = retrieveTabbarController()
        tab?.setTabBarHidden(true, animated: true)
        self.navigationController?.pushViewController(transferTaskTableViewController, animated: true)
    }
    
    func rootCollectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath, isSelectModel: Bool) {
        if isSelectModel == NSNumber.init(value: FilesStatus.select.rawValue).boolValue{
            self.title = "\(String(describing: (FilesHelper.sharedInstance().selectFilesArray?.count)!))"
        }else{
            let sectionArray:Array<EntriesModel> = dataSource![indexPath.section] as! Array
            let model  = sectionArray[indexPath.item]
            if model.type == FilesType.directory.rawValue{
                let nextViewController = FilesRootViewController.init(driveUUID: (AppUserService.currentUser?.userHome!)!, directoryUUID: model.uuid!,style:.white)
                if self.selfState == .movecopy{
                    nextViewController.moveModelArray = moveModelArray
                    nextViewController.srcDictionary = srcDictionary
                    nextViewController.model = model
                    nextViewController.isCopy = isCopy
                    nextViewController.selfState = self.selfState
                }
                let tab = retrieveTabbarController()
                tab?.setTabBarHidden(true, animated: true)
                nextViewController.title = model.name ?? ""
         
                self.navigationController?.pushViewController(nextViewController, animated: true)
                defaultNotificationCenter().removeObserver(self, name: NSNotification.Name.Refresh.MoveRefreshNotiKey, object: nil)
            }else{
                if FilesRootViewController.downloadManager.cache.fileExists(fileName: model.name ?? ""){
                    self.readFile(filePath: FilesRootViewController.downloadManager.cache.filePtah(fileName: model.name!)!)
                }else{
                    self.downloadFile(model: model, complete: { [weak self] (error, task) in
                        if error == nil{
                            Message.message(text: LocalizedString(forKey: "\(model.name ?? "文件")下载完成"))
                            DispatchQueue.global(qos: .default).asyncAfter(deadline: DispatchTime.now() + 0.5) {
                                DispatchQueue.main.async {
                                    self?.readFile(filePath:FilesRootViewController.downloadManager.cache.filePtah(fileName: model.name!)!)
                                }
                            }
                        }else{
                            Message.message(text: LocalizedString(forKey: "\(model.name ?? "文件")下载失败"))
                        }
                    })
                }
            }
        }
    }
    
    func downloadFile(model:EntriesModel,complete:@escaping ((_ error:Error?, _ task: TRTask)->())){
        let bundle = Bundle.init(for: FilesDownloadAlertViewController.self)
        let storyboard = UIStoryboard.init(name: "FilesDownloadAlertViewController", bundle: bundle)
        let identifier = "FilesDownloadDialogID"
        
        let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
        viewController.modalPresentationStyle = UIModalPresentationStyle.custom
        viewController.transitioningDelegate = self.transitionController
        
        weak var vc =  viewController as? FilesDownloadAlertViewController
        vc?.delegate = self
        
        self.present(viewController, animated: true, completion: {
            
        })
        let presentationController =
            viewController.mdc_dialogPresentationController
        if presentationController != nil{
            presentationController?.dismissOnBackgroundTap = false
        }
        if downloadTask != nil{
            downloadTask?.cancel()
            downloadTask = nil
        }
        FilesRootViewController.downloadManager.isStartDownloadImmediately = true
        let requestURL = downloadRequestURL(model:model)
        let task =  FilesRootViewController.downloadManager.download(requestURL, fileName: model.name!, filesModel: model)
        
        task?.progressHandler = { (taskP)in
            let float:Float = Float(taskP.progress.completedUnitCount)/Float(taskP.progress.totalUnitCount)
            vc?.downloadProgressView.progress = Float(float)
        }
        
        task?.successHandler  = { (taskS) in
            vc?.dismiss(animated: true, completion: {
                return complete(nil,taskS)
            })
        }
        
        task?.failureHandler  = { (taskF) in
            vc?.dismiss(animated: true, completion: {
                return complete(taskF.error,taskF)
            })
        }
        
        downloadTask = task
    }
    
    func cellButtonCallBack(_ cell: MDCCollectionViewCell, _ button: UIButton, _ indexPath: IndexPath) {
        let filesBottomVC = FilesFilesBottomSheetContentTableViewController.init(style: UITableViewStyle.plain)
        filesBottomVC.delegate = self
        let bottomSheet = AppBottomSheetController.init(contentViewController: filesBottomVC)
        bottomSheet.trackingScrollView = filesBottomVC.tableView
        let sectionArray:Array<EntriesModel> = dataSource![indexPath.section] as! Array
        let model  = sectionArray[indexPath.item]
        let exestr = (model.name! as NSString).pathExtension
        filesBottomVC.headerTitleLabel.text = model.name ?? ""
        filesBottomVC.headerImageView.image = UIImage.init(named: FileTools.switchFilesFormatType(type: FilesType(rawValue: model.type!), format: FilesFormatType(rawValue: exestr)))
        filesBottomVC.filesModel = model
        self.present(bottomSheet, animated: true, completion: {
        })
    }
    
    func sequenceButtonTap(_ sender: UIButton?) {
        let sequenceBottomVC = FilesSequenceBottomSheetContentTableViewController.init(style: UITableViewStyle.plain)
        sequenceBottomVC.delegate = self
        let bottomSheet = MDCBottomSheetController.init(contentViewController: sequenceBottomVC)
        self.present(bottomSheet, animated: true, completion: {
        })
    }
    
    func collectionView(_ collectionViewController: MDCCollectionViewController, isSelectModel: Bool) {
        self.isSelectModel = isSelectModel
    }
    
    func collectionViewData(_ collectionViewController: MDCCollectionViewController) -> Array<Any> {
        return dataSource!
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //        print(scrollView.contentOffset.y)
    
        if isSelectModel == nil || !isSelectModel!{
            //            if scrollView.contentOffset.y > -(SearchBarBottom + MarginsCloseWidth/2) {
            //            }else{
            //            }
            let translatedPoint = scrollView.panGestureRecognizer.translation(in: scrollView)
            if translatedPoint.y < 0 {
                //                if searchBar.bottom > 0{
                
                self.searchBar.origin.y = -(scrollView.contentOffset.y)-(SearchBarBottom + MarginsCloseWidth/2)+kStatusBarHeight
                //            }else{
                //                self.searchBar.origin.y = -(scrollView.contentOffset.y)
                //            }
            }
            
            if(translatedPoint.y > 0){
                //                print("mimimi")
                UIView.animate(withDuration: 0.3) {
                    self.searchBar.origin.y = kStatusBarHeight + MarginsCloseWidth
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let headerView = self.appBar.headerViewController.headerView
        if scrollView == headerView.trackingScrollView {
            headerView.trackingScrollDidEndDraggingWillDecelerate(decelerate)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let headerView = self.appBar.headerViewController.headerView
        if scrollView == headerView.trackingScrollView {
            headerView.trackingScrollWillEndDragging(withVelocity: velocity, targetContentOffset: targetContentOffset)
        }
    }
}

extension FilesRootViewController:FilesDownloadAlertViewControllerDelegate{
    func cancelButtonTap() {
        if downloadTask != nil{
            downloadTask?.cancel()
            downloadTask?.remove()
        }
    }
}

extension FilesRootViewController:SearchBarDelegate{
    func searchBar(searchBar: SearchBar, didClear textField: UITextField, with text: String?) {
        
    }
    
    func searchBar(searchBar: SearchBar, willClear textField: UITextField, with text: String?) {
        
    }
    
    func searchBar(searchBar: SearchBar, didChange textField: UITextField, with text: String?) {
        
    }
}

extension FilesRootViewController:FilesDrawerViewControllerDelegate{
    func settingButtonTap(_ sender: UIButton) {
        navigationDrawerController?.closeLeftView()
        let settingVC = SettingViewController.init(style: NavigationStyle.white)
        let tab = retrieveTabbarController()
        tab?.setTabBarHidden(true, animated: true)
        self.navigationController?.pushViewController(settingVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationDrawerController?.closeLeftView()
        switch indexPath.row {
        case 0:
            let transferTaskTableViewController = TransferTaskTableViewController.init(style:NavigationStyle.white)
            let tab = retrieveTabbarController()
            tab?.setTabBarHidden(true, animated: true)
            self.navigationController?.pushViewController(transferTaskTableViewController, animated: true)
        case 1:
            let shareVC = FileShareFolderViewController.init(style:.white)
            let tab = retrieveTabbarController()
            tab?.setTabBarHidden(true, animated: true)
            self.navigationController?.pushViewController(shareVC, animated: true)
        case 2:
            let offlineVC = FilesOfflineViewController.init(style:.white)
            let tab = retrieveTabbarController()
            tab?.setTabBarHidden(true, animated: true)
            self.navigationController?.pushViewController(offlineVC, animated: true)
        case 3:
            break
        default:
            break
        }
    }
}

extension FilesRootViewController:MDCBottomSheetControllerDelegate{
    func bottomSheetControllerDidDismissBottomSheet(_ controller: MDCBottomSheetController) {
//        self.fabButton.expand(true, completion: {
//        })
    }
}

extension FilesRootViewController:FABBottomSheetDisplayVCDelegte{
    func folderButtonTap(_ sender: UIButton) {
//        self.fabButton.expand(true, completion: { [weak self] in
            let bundle = Bundle.init(for: NewFolderViewController.self)
            let storyboard = UIStoryboard.init(name: "NewFolderViewController", bundle: bundle)
            let identifier = "inputNewFolderDialogID"
            
            let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
            viewController.modalPresentationStyle = UIModalPresentationStyle.custom
        viewController.transitioningDelegate = self.transitionController
            
            let vc =  viewController as! NewFolderViewController
            vc.type = InputAlertType.creatNewFolder
            vc.titleString = LocalizedString(forKey:"New folder")
            vc.inputString =  LocalizedString(forKey: "Untitled folder")
            vc.inputPlaceholder =  LocalizedString(forKey: "Folder name")
            vc.confirmButtonName =  LocalizedString(forKey: "Create")
            vc.delegate = self
            self.present(viewController, animated: true, completion: {
                vc.inputTextField.becomeFirstResponder()
            })
            let presentationController =
                viewController.mdc_dialogPresentationController
            if presentationController != nil{
                presentationController?.dismissOnBackgroundTap = false
            }
//        })
    }
    
    func uploadButtonTap(_ sender: UIButton) {
//        self.fabButton.expand(true, completion: { [weak self] in
//
//            //            } else {
//            //                Message.message(text: LocalizedString(forKey: "系统在iOS 11以下版本不支持该功能"))
//            //                // Fallback on earlier versions
//            //            }
//        })
        
        //       let i = UIDocumentBrowserViewController.init()
        //        i.browserUserInterfaceStyle =
        let documentPickerViewController =  UIDocumentPickerViewController.init(documentTypes:   ["com.apple.iwork.pages.pages", "com.apple.iwork.numbers.numbers", "com.apple.iwork.keynote.key","public.image", "com.apple.application", "public.item","public.data", "public.content", "public.audiovisual-content", "public.movie", "public.audiovisual-content", "public.video", "public.audio", "public.text", "public.data", "public.zip-archive", "com.pkware.zip-archive", "public.composite-content", "public.text"], in: .import)
        //        //            if #available(iOS 11.0, *) {
        //        //                let documentBrowserViewController = UIDocumentBrowserViewController.init()
        documentPickerViewController.delegate = self
        if #available(iOS 11.0, *) {
            documentPickerViewController.allowsMultipleSelection = true
        } else {
            // Fallback on earlier versions
        }
        
        self.present(documentPickerViewController, animated: true, completion: {
            
        })
    }
    
    func cllButtonTap(_ sender: UIButton) {
//        self.fabButton.expand(true, completion: {
//        })
    }
}

extension FilesRootViewController:SequenceBottomSheetContentVCDelegate{
    func sequenceBottomtableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, isDown: Bool) {
        self.setSortParameters(sortType:SortType(rawValue: Int64(indexPath.row))!, sortIsDown: isDown)
    }
}


extension FilesRootViewController:SearchMoreBottomSheetVCDelegate{
    func searchMoreBottomSheettableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.sequenceButtonTap(nil)
        case 1:
            self.isSelectModel = true
            self.collcectionViewController.isSelectModel = self.isSelectModel
        case 2:
            self.isSelectModel = true
            self.collcectionViewController.isSelectModel = self.isSelectModel
            FilesHelper.sharedInstance().addAllSelectFiles(array: self.originDataSource ?? Array<EntriesModel>.init())
            self.title = "\(String(describing: (FilesHelper.sharedInstance().selectFilesArray?.count)!))"
        default:break
        }
    }
}

extension FilesRootViewController:FilesBottomSheetContentVCDelegate{
    func filesBottomSheetContentInfoButtonTap(_ sender: UIButton, model: Any) {
        let tab = retrieveTabbarController()
        tab?.setTabBarHidden(true, animated: true)
        let filesInfoVC = FilesFileInfoTableViewController.init(style: NavigationStyle.imagery)
        filesInfoVC.model = model as? EntriesModel
        self.navigationController?.pushViewController(filesInfoVC, animated: true)
    }
    
    func filesBottomSheetContentSwitch(_ sender: UISwitch, model: Any) {
        let filesModel = model as! EntriesModel
        if sender.isOn{
            FilesRootViewController.downloadManager.isStartDownloadImmediately = true
            let requestURL = self.downloadRequestURL(model: model as! EntriesModel)
            let _ =  FilesRootViewController.downloadManager.download(requestURL, fileName: filesModel.name!, filesModel: filesModel, successHandler: { (task) in
                //                Message.message(text: LocalizedString(forKey: "\(filesModel.name!)离线可用完成"))
            }) { (task) in
                Message.message(text: LocalizedString(forKey: "\(filesModel.name!)离线可用失败"))
            }
            Message.message(text: LocalizedString(forKey: "正在使\(filesModel.name!)离线可用"))
        }else{
            if FilesRootViewController.downloadManager.cache.fileExists(fileName: filesModel.name!){
                for task in FilesRootViewController.downloadManager.completedTasks{
                    if task.fileName == filesModel.name{
                        FilesRootViewController.downloadManager.remove(task.URLString, completely: true)
                        FilesRootViewController.downloadManager.cache.remove(task as! TRDownloadTask, completely: true)
                        Message.message(text: LocalizedString(forKey: "\(filesModel.name!) 离线已不可用"))
                    }
                }
            }
        }
    }
    
    func patchNodes(taskUUID:String,nodeUUID:String,policySameValue:String? = nil , policyDiffValue:String? = nil ,callback:@escaping ((_ error:Error?)->())){
        TasksAPI.init(taskUUID: taskUUID, nodeUUID: nodeUUID, policySameValue: policySameValue, policyDiffValue: policyDiffValue).startRequestJSONCompletionHandler { [weak self] (response) in
            if response.error == nil{
                self?.prepareData()
                callback(nil)
            }else{
                if response.data != nil {
                    let errorDict =  dataToNSDictionary(data: response.data!)
                    if errorDict != nil{
                        Message.message(text: errorDict!["message"] != nil ? errorDict!["message"] as! String :  (response.error?.localizedDescription)!)
                    }else{
                        let backToString = String(data: response.data!, encoding: String.Encoding.utf8) as String?
                        Message.message(text: backToString ?? "error")
                    }
                }else{
                    //                    Message.message(text: (response.error?.localizedDescription)!)
                    callback(response.error)
                }
            }
        }
    }
    
    func getTask(taskUUID:String,callback:@escaping (_ task:FilesTasksModel? ,_ error:Error?)->()) {
        TasksAPI.init(taskUUID: taskUUID).startRequestJSONCompletionHandler {(response) in
            if response.error == nil{
                let dic = response.value as! NSDictionary
                if let taskModel = FilesTasksModel.deserialize(from: dic){
                    return callback(taskModel,nil)
                }else{
                    return callback(nil,BaseError(localizedDescription: ErrorLocalizedDescription.JsonModel.SwitchTOModelFail, code: ErrorCode.JsonModel.SwitchTOModelFail))
                }
            }else{
                return callback(nil,response.error)
            }
        }
    }
    
    func makeCopyTaskCreate(model:Any?){
        ActivityIndicator.startActivityIndicatorAnimation()
        if !(model is EntriesModel) || model == nil {
            return
        }
        let existModel = model as! EntriesModel
        let names = existModel.name != nil ? [existModel.name!] : []
        TasksAPI.init(type: FilesTasksType.copy.rawValue, names: names, srcDrive:self.existDrive(), srcDir: self.existDir(), dstDrive: self.existDrive(), dstDir: self.existDir()).startRequestJSONCompletionHandler { [weak self] (response) in
            if response.error == nil{
                let dic = response.value as! NSDictionary
                if let taskModel = FilesTasksModel.deserialize(from: dic){
                    self?.taskHandle(taskModel: taskModel)
                }
                
            }else{
                Message.message(text: (response.error?.localizedDescription)!)
            }
        }
    }
    
    func taskHandle(taskModel:FilesTasksModel){
        self.getTask(taskUUID: taskModel.uuid!, callback: { [weak self](model, error) in
            if model?.nodes?.count != 0 {
                if model?.nodes?.first?.state == .Conflict && model?.nodes?.first?.error?.code == .EEXIST{
                    self?.patchNodes(taskUUID: (model?.uuid!)!, nodeUUID: (model?.nodes?.first?.src?.uuid!)!, policySameValue: FilesTaskPolicy.rename.rawValue, callback: { [weak self] (error)in
                        ActivityIndicator.stopActivityIndicatorAnimation()
                        if error == nil{
                            Message.message(text: LocalizedString(forKey: "创建副本成功"))
                            self?.prepareData()
                        }
                        
                    })
                }else if model?.nodes?.first?.state == .Working{
                    self?.taskHandle(taskModel: taskModel)
                }
            }
        })
    }
    
    func filesBottomSheetContentTableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, models: [Any]?){
//        let filesModels =
        switch indexPath.row {
        case 0:
            self.removeFileOrDirectory(models: models as! [EntriesModel])
        default:
            break
        }
        self.isSelectModel = false
    }
    
    func filesBottomSheetContentTableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, model: Any?) {
        //        filesBottomVC.dismiss(animated: true, completion: { [weak self] in、
        let filesModel = model as! EntriesModel
        switch indexPath.row {
        case 0:
            let filesType =  model != nil ? (model as! EntriesModel).type : ""
            let name =  model != nil ? (model as! EntriesModel).name : ""
            let bundle = Bundle.init(for: NewFolderViewController.self)
            let storyboard = UIStoryboard.init(name: "NewFolderViewController", bundle: bundle)
            let identifier = "inputNewFolderDialogID"
            
            let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
            viewController.modalPresentationStyle = UIModalPresentationStyle.custom
            viewController.transitioningDelegate = self.transitionController
            
            let vc =  viewController as! NewFolderViewController
            vc.type = InputAlertType.rename
            vc.theFilesName = name
            vc.titleString = "\(LocalizedString(forKey:"Rename")) \(LocalizedString(forKey: filesType == FilesType.directory.rawValue ? "Folder" : "File"))"
            vc.inputString =  name
            vc.inputPlaceholder =  "\(LocalizedString(forKey:filesType == FilesType.directory.rawValue ? "Folder" : "File")) \(LocalizedString(forKey:"name"))"
            vc.confirmButtonName =  LocalizedString(forKey: "Rename")
            vc.delegate = self
            self.present(viewController, animated: true, completion: {
                vc.inputTextField.becomeFirstResponder()
            })
            let presentationController =
                viewController.mdc_dialogPresentationController
            if presentationController != nil{
                presentationController?.dismissOnBackgroundTap = false
            }
        case 1:
            let filesMoveToRootViewController = FilesMoveToRootViewController.init(style: NavigationStyle.white)
            
            filesMoveToRootViewController.srcDictionary = [kRequestTaskDriveKey : self.existDrive(),kRequestTaskDirKey:self.existDir()]
            filesMoveToRootViewController.moveModelArray =  model != nil ? [model as! EntriesModel] : Array.init()
            self.registerNotification()
            let navi = UINavigationController.init(rootViewController: filesMoveToRootViewController)
            self.present(navi, animated: true, completion: nil)
        case 2:
            if filesModel.type != FilesType.file.rawValue{
                self.makeCopyTaskCreate(model: model)
            }
            
        case 3 :
            if filesModel.type == FilesType.file.rawValue{
                if FilesRootViewController.downloadManager.cache.fileExists(fileName: filesModel.name!){
                    self.openForOtherApp(filesModel: filesModel)
                }else{
                    self.downloadFile(model: filesModel) { [weak self](error, task) in
                        if error == nil{
                            self?.openForOtherApp(filesModel: filesModel)
                        }else{
                            Message.message(text: LocalizedString(forKey: "\(filesModel.name ?? "文件")下载失败"))
                        }
                    }
                }
            }else{
                
            }
        case 4:
            if filesModel.type == FilesType.file.rawValue{
                self.makeCopyTaskCreate(model: model)
            }else{
                
            }
        case 5:
            if filesModel.type == FilesType.file.rawValue{
                
            }else{
                self.removeFileOrDirectory(model: filesModel)
            }
        case 6:
            if filesModel.type == FilesType.file.rawValue{
                let filesMoveToRootViewController = FilesMoveToRootViewController.init(style: NavigationStyle.white)
                
                filesMoveToRootViewController.srcDictionary = [kRequestTaskDriveKey : self.existDrive(),kRequestTaskDirKey:self.existDir()]
                filesMoveToRootViewController.moveModelArray =  model != nil ? [model as! EntriesModel] : Array.init()
                filesMoveToRootViewController.isCopy = true
                self.registerNotification()
                let navi = UINavigationController.init(rootViewController: filesMoveToRootViewController)
                self.present(navi, animated: true, completion: nil)
            }else{
                
            }
        case 7:
            self.removeFileOrDirectory(model: filesModel)
            
        default:
            break
        }
       
        //        })
    }
    
    func openForOtherApp(filesModel:EntriesModel){
        let documentController = UIDocumentInteractionController.init(url: URL.init(fileURLWithPath: FilesRootViewController.downloadManager.cache.filePtah(fileName: filesModel.name!)!))
        documentController.delegate = self
        documentController.presentOpenInMenu(from: CGRect.zero, in: self.view, animated: true)
    }
    
    func removeFileOrDirectory(model:EntriesModel){
        let type = model.type
        let typeString = type == FilesType.directory.rawValue ? LocalizedString(forKey: "folder") : LocalizedString(forKey: "file")
        let title = "\(LocalizedString(forKey: "Remove")) \(typeString)"
        let name = model.name ?? ""
        let messageString =  "\(name) \(LocalizedString(forKey: "will be moved"))"
        
        let alertController = MDCAlertController(title: title, message: messageString)
        
        let acceptAction = MDCAlertAction(title:LocalizedString(forKey: "Remove")) { [weak self] (_) in
            switch AppNetworkService.networkState {
            case .local?:
                self?.localNetStateFilesRemoveOptionRequest(name:name)
            case .normal?:
                self?.normalNetStateFilesRemoveOptionRequest(name:name)
            default:
                break
            }
        }
        alertController.addAction(acceptAction)
        
        let considerAction = MDCAlertAction(title:LocalizedString(forKey: "Cancel")) { (_) in print("Cancel") }
        alertController.addAction(considerAction)
        
        let presentationController =
            alertController.mdc_dialogPresentationController
        presentationController?.dismissOnBackgroundTap = false
        
        ViewTools.setAlertControllerColor(alertController:alertController )
        self.present(alertController, animated: true, completion: nil)
    }
    
    func removeFileOrDirectory(models:[EntriesModel]){
      
        let title = "\(LocalizedString(forKey: "Remove"))"
        var message = "\(LocalizedString(forKey: "文件"))"
        if models.contains(where: {$0.type == FilesType.directory.rawValue}) && models.contains(where: {$0.type == FilesType.file.rawValue}){
            message = "\(LocalizedString(forKey: "文件和文件夹"))"
        }else  if models.contains(where: {$0.type == FilesType.directory.rawValue}) && models.contains(where: {$0.type != FilesType.file.rawValue}){
            message = "\(LocalizedString(forKey: "文件夹"))"
        }
        
        let messageString =  "\(models.count) 个\(message)\(LocalizedString(forKey: "将被删除"))"
        
        let alertController = MDCAlertController(title: title, message: messageString)
        
        let acceptAction = MDCAlertAction(title:LocalizedString(forKey: "Remove")) { [weak self] (_) in
            switch AppNetworkService.networkState {
            case .local?:
                self?.localNetStateFilesRemoveOptionRequest(names:models.map({$0.name!}))
            case .normal?:
                self?.normalNetStateFilesRemoveOptionRequest(names:models.map({$0.name!}))
            default:
                break
            }
        }
        alertController.addAction(acceptAction)
        
        let considerAction = MDCAlertAction(title:LocalizedString(forKey: "Cancel")) { (_) in print("Cancel") }
        alertController.addAction(considerAction)
        ViewTools.setAlertControllerColor(alertController:alertController)
        let presentationController =
            alertController.mdc_dialogPresentationController
        presentationController?.dismissOnBackgroundTap = false
        self.present(alertController, animated: true, completion: nil)
    }
}

extension FilesRootViewController:UINavigationControllerDelegate{
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = SearchTransition()
        return operation == .push ? toVC.isKind(of: SearchFilesViewController.self) ? transition : nil : fromVC.isKind(of: SearchFilesViewController.self) ? transition : nil
    }
}


extension FilesRootViewController:TextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.enterSearch()
    }
}

extension FilesRootViewController:DZNEmptyDataSetSource{
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage.init(named: "logo_gray")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = LocalizedString(forKey: "No Data")
        let attributes = [NSAttributedStringKey.font : MiddleTitleFont,NSAttributedStringKey.foregroundColor : LightGrayColor]
        return NSAttributedString.init(string: text, attributes: attributes)
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let text = LocalizedString(forKey: "Reload data")
        let attributes = [NSAttributedStringKey.font :MiddleTitleFont,NSAttributedStringKey.foregroundColor : COR1]
        return NSAttributedString.init(string: text, attributes: attributes)
    }
}

extension FilesRootViewController:DZNEmptyDataSetDelegate{
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        self.prepareData()
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        if self.dataSource?.count == 0 && self.isRequesting == false{
            return true
        }else{
            return false
        }
    }
}

extension FilesRootViewController:UIDocumentInteractionControllerDelegate{
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

extension FilesRootViewController:NewFolderViewControllerDelegate{
    func confirmButtonTap(_ sender: MDCFlatButton, type: InputAlertType, inputText: String,theFilesName:String?) {
        switch type {
        case .creatNewFolder:
            switch AppNetworkService.networkState {
            case .local?:
                localNetStateCreateNewFolderRequest(name:inputText)
            case .normal?:
                normalStateNetCreateNewFolderRequest(name: inputText)
            default:
                break
            }
        case .rename:
            switch AppNetworkService.networkState {
            case .local?:
                localNetStateRenameRequest(oldName:theFilesName, newName: inputText)
            case .normal?:
                normalNetRenameStateRequest(oldName:theFilesName, newName: inputText)
            default:
                break
            }
        default:
            break
        }
    }
    
    func localNetStateRenameRequest(oldName:String?,newName:String){
        let drive = self.driveUUID ?? AppUserService.currentUser?.userHome ?? ""
        let dir = self.directoryUUID ?? AppUserService.currentUser?.userHome ?? ""
        let op = FilesOptionType.rename.rawValue
        let name = "\(oldName ?? "")|\(newName)"
        DirOprationAPI.init(driveUUID: drive, directoryUUID: dir, name: name, op: op).startFormDataRequestJSONCompletionHandler(multipartFormData: { (formData) in
            let dic = [kRequestOpKey: op]
            do {
                let data = try JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions.prettyPrinted)
                formData.append(data, withName:name)
            }catch{
                Message.message(text: LocalizedString(forKey: ErrorLocalizedDescription.JsonModel.SwitchTODataFail))
            }
        }, {  [weak self] (response) in
            if response.error == nil{
                Message.message(text: "\(oldName ?? "") \(LocalizedString(forKey: "renamed to")) \(newName)")
                self?.prepareData()
            }else{
                if response.data != nil {
                    let errorDict =  dataToNSDictionary(data: response.data!)
                    if errorDict != nil{
                        Message.message(text: errorDict!["message"] != nil ? errorDict!["message"] as! String :  (response.error?.localizedDescription)!)
                    }else{
                        let backToString = String(data: response.data!, encoding: String.Encoding.utf8) as String?
                        Message.message(text: backToString ?? "error")
                    }
                }else{
                    Message.message(text: (response.error?.localizedDescription)!)
                }
            }
        }) { (error) -> (Void) in
            Message.message(text: error.localizedDescription)
        }
    }
    
    func normalNetRenameStateRequest(oldName:String?,newName:String){
        let drive = self.driveUUID ?? AppUserService.currentUser?.userHome ?? ""
        let dir = self.directoryUUID ?? AppUserService.currentUser?.userHome ?? ""
        let op = FilesOptionType.rename.rawValue
        let name = "\(oldName ?? "")|\(newName)"
        DirOprationAPI.init(driveUUID: drive, directoryUUID: dir, name: name, op: op).startRequestDataCompletionHandler { [weak self](response) in
            if response.error == nil{
                if response.data != nil {
                    let errorDict =  dataToNSDictionary(data: response.data!)
                    if errorDict != nil{
                        if errorDict!["code"] as? Int64 != 1{
                            Message.message(text: errorDict!["message"] != nil ? errorDict!["message"] as! String :  (response.error?.localizedDescription)!)
                            return
                        }
                    }
                }
            
                Message.message(text: "\(oldName ?? "") \(LocalizedString(forKey: "renamed to")) \(newName)")
                self?.prepareData()
            }else{
                if response.data != nil {
                    let errorDict =  dataToNSDictionary(data: response.data!)
                    if errorDict != nil{
                        Message.message(text: errorDict!["message"] != nil ? errorDict!["message"] as! String :  (response.error?.localizedDescription)!)
                    }else{
                          Message.message(text: (response.error?.localizedDescription)!)
                    }
                }else{
                    Message.message(text: (response.error?.localizedDescription)!)
                }
            }
        }
    
    }
    
    func localNetStateCreateNewFolderRequest(name:String) {
        let drive = self.driveUUID ?? AppUserService.currentUser?.userHome ?? ""
        let dir = self.directoryUUID ?? AppUserService.currentUser?.userHome ?? ""
        MkdirAPI.init(driveUUID: drive, directoryUUID: dir).startFormDataRequestJSONCompletionHandler(multipartFormData: {  (formData) in
            let dic = [kRequestOpKey: kRequestMkdirValue]
            do {
                let data = try JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions.prettyPrinted)
                formData.append(data, withName:name)
            }catch{
                Message.message(text: LocalizedString(forKey: ErrorLocalizedDescription.JsonModel.SwitchTODataFail))
            }
        }, { [weak self] (response) in
            if response.error == nil{
                Message.message(text: LocalizedString(forKey: "Folder created"))
                self?.prepareData()
            }else{
                if response.data != nil {
                    let errorDict =  dataToNSDictionary(data: response.data!)
                    if errorDict != nil{
                        Message.message(text: errorDict!["message"] != nil ? errorDict!["message"] as! String :  (response.error?.localizedDescription)!)
                    }else{
                        let backToString = String(data: response.data!, encoding: String.Encoding.utf8) as String?
                        Message.message(text: backToString ?? "error")
                    }
                }else{
                    Message.message(text: (response.error?.localizedDescription)!)
                }
            }
            }, errorHandler: { (error) -> (Void) in
                Message.message(text: error.localizedDescription)
        })
    }
    
    func normalStateNetCreateNewFolderRequest(name:String){
        let drive = self.driveUUID ?? AppUserService.currentUser?.userHome ?? ""
        let dir = self.directoryUUID ?? AppUserService.currentUser?.userHome ?? ""
        MkdirAPI.init(driveUUID: drive, directoryUUID: dir, name: name).startRequestJSONCompletionHandler { [weak self] (response) in
            if response.error == nil{
                Message.message(text: LocalizedString(forKey: "Folder created"))
                self?.prepareData()
            }else{
                if response.data != nil {
                    let errorDict =  dataToNSDictionary(data: response.data!)
                    if errorDict != nil{
                        Message.message(text: errorDict!["message"] != nil ? errorDict!["message"] as! String :  (response.error?.localizedDescription)!)
                    }else{
                        let backToString = String(data: response.data!, encoding: String.Encoding.utf8) as String?
                        Message.message(text: backToString ?? "error")
                    }
                }else{
                    Message.message(text: (response.error?.localizedDescription)!)
                }
            }
        }
    }
}

extension  FilesRootViewController:UIDocumentPickerDelegate{
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("cancel")
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        print(url)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        for url in urls {
            do{
                let fileData = try Data.init(contentsOf: url)
                print(fileData)
            }catch{
                print(error)
            }
        }
        print(urls)
    }
}

