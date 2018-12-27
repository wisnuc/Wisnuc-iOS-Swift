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
        AppNetworkService.getShareSpaceBuiltIn { [weak self](error, uuid) in
            if error == nil,let uuid = uuid{
                let nextViewController = FilesRootViewController.init(driveUUID: uuid, directoryUUID: uuid,style:.white)
                nextViewController.title = LocalizedString(forKey: "共享空间")
                let tab = retrieveTabbarController()
                tab?.setTabBarHidden(true, animated: true)
                self?.navigationController?.pushViewController(nextViewController, animated: true)
            }
        }
    }
    
    func backupBoxTap() {
        let deviceBackupRootViewController = DeviceBackupRootViewController.init(style:.highHeight,type:.files)
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
            if FilesHelper.sharedInstance().selectFilesArray?.count != 0 {
                self.downloadBarButtonItem.isEnabled = true
                self.moveBarButtonItem.isEnabled = true
                self.moreBarButtonItem.isEnabled = true
            }
            self.title = "\(String(describing: (FilesHelper.sharedInstance().selectFilesArray?.count)!))"
        }else{
            guard let dataSource = self.dataSource else {
                return
            }
            
            if dataSource.count <= 0{
                return
            }
            
            if let sectionArray:Array<EntriesModel> = dataSource[indexPath.section] as? Array{
                let model  = sectionArray[indexPath.item]
                let driveUUID = self.driveUUID ?? AppUserService.currentUser?.userHome ?? ""
                guard let uuid = model.uuid else{
                    return
                }
                
                if model.type == FilesType.directory.rawValue{
                    var nextViewController = FilesRootViewController.init(driveUUID: driveUUID, directoryUUID: uuid,style:.white)
                    nextViewController.title = model.backupRoot ? model.bname ?? model.name : model.name ?? ""
                    if self.selfState == .movecopy{
                        nextViewController = FilesRootViewController.init(style: .white, srcDictionary: srcDictionary, moveModelArray: moveModelArray, isCopy: isCopy,driveUUID:driveUUID,directoryUUID:uuid)
                        nextViewController.model = model
                       nextViewController.title = model.backupRoot ? model.bname ?? model.name : model.name ?? ""
                    }
                    let tab = retrieveTabbarController()
                    tab?.setTabBarHidden(true, animated: true)
                  
                    
                    self.navigationController?.pushViewController(nextViewController, animated: true)
                    defaultNotificationCenter().removeObserver(self, name: NSNotification.Name.Refresh.MoveRefreshNotiKey, object: nil)
            }else{
                let name = model.backupRoot ? model.bname ?? model.name ?? "" : model.name ?? ""
                if FilesRootViewController.downloadManager.cache.fileExists(fileName: name){
                    if let filePath = FilesRootViewController.downloadManager.cache.filePtah(fileName: name){
                        self.readFile(filePath:filePath)
                    }else{
                        Message.message(text: LocalizedString(forKey: "\(name)读取失败"))
                    }
                }else{
                    self.downloadFile(model: model, complete: { [weak self] (error, task) in
                        if error == nil{
                            let name = model.backupRoot ? model.bname ?? model.name ?? "" : model.name ?? ""
                            Message.message(text: LocalizedString(forKey: "\(name)下载完成"))
                            DispatchQueue.global(qos: .default).asyncAfter(deadline: DispatchTime.now() + 0.5) {
                                DispatchQueue.main.async {
                                    if let filePath = FilesRootViewController.downloadManager.cache.filePtah(fileName: name){
                                        self?.readFile(filePath:filePath)
                                    }else{
                                       Message.message(text: LocalizedString(forKey: "\(name)读取失败"))
                                    }
                                }
                            }
                        }else{
                            if let error = error {
                                 Message.message(text: error.localizedDescription)
                        
                            }else{
                                Message.message(text: LocalizedString(forKey: "\(name)下载失败"))
                            }
                        }
                    })
                }
                }
            }
        }
    }
    
    func downloadFile(model:EntriesModel,complete:@escaping ((_ error:Error?, _ task: TRTask?)->())){
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
        guard let requestURL = downloadRequestURL(model:model) else {
           return complete(NSError(domain: "requestURL error", code: 200001, userInfo: nil),nil)
        }
        let name = model.backupRoot ? model.bname ?? model.name ?? "" : model.name ?? ""
        let task =  FilesRootViewController.downloadManager.download(requestURL, fileName: name, filesModel: model)
        
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
        var filesBottomVC = FilesFilesBottomSheetContentTableViewController.init(style: UITableViewStyle.plain)
        if self.driveUUID == AppUserService.currentUser?.shareSpace{
            filesBottomVC = FilesFilesBottomSheetContentTableViewController.init(style: UITableViewStyle.plain, type: .shareSpaceMore)
        }
        filesBottomVC.delegate = self
        let bottomSheet = AppBottomSheetController.init(contentViewController: filesBottomVC)
        bottomSheet.trackingScrollView = filesBottomVC.tableView
        guard let dataSource = self.dataSource else {
            return
        }
        
        if dataSource.count <= 0{
            return
        }
        
        if  let sectionArray:Array<EntriesModel> = dataSource[indexPath.section] as? Array{
            let model  = sectionArray[indexPath.item]
            let name = model.backupRoot ? model.bname ?? model.name ?? "" : model.name ?? ""
            let exestr = (name as NSString).pathExtension
            filesBottomVC.headerTitleLabel.text = name
            filesBottomVC.headerImageView.image = UIImage.init(named: FileTools.switchFilesFormatType(type: FilesType(rawValue: model.type!), format: FilesFormatType(rawValue: exestr)))
            filesBottomVC.filesModel = model
            self.present(bottomSheet, animated: true, completion: {
            })
        }
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
            self.collcectionViewController?.isSelectModel = self.isSelectModel
        case 2:
            self.isSelectModel = true
            self.collcectionViewController?.isSelectModel = self.isSelectModel
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
        guard  let filesModel =  model as? EntriesModel else {
            return
        }
        
        let drive = self.driveUUID ?? AppUserService.currentUser?.userHome ?? ""
        let dir = self.directoryUUID ?? AppUserService.currentUser?.userHome ?? ""
        let filesInfoVC = FilesFileInfoTableViewController.init(style: NavigationStyle.imagery,model: filesModel,driveUUID:drive,dirUUID: dir,location:self.title)
        self.navigationController?.pushViewController(filesInfoVC, animated: true)
    }
    
    func filesBottomSheetContentSwitch(_ sender: UISwitch, model: Any) {
        let filesModel = model as! EntriesModel
        if sender.isOn{
            FilesRootViewController.downloadManager.isStartDownloadImmediately = true
            guard let requestURL = downloadRequestURL(model:model as! EntriesModel) else {
               return
            }
            let name = filesModel.backupRoot ? filesModel.bname ?? filesModel.name ?? "" : filesModel.name ?? ""
            let _ =  FilesRootViewController.downloadManager.download(requestURL, fileName: name, filesModel: filesModel, successHandler: { (task) in
                //                Message.message(text: LocalizedString(forKey: "\(filesModel.name!)离线可用完成"))
            }) { (task) in
                Message.message(text: LocalizedString(forKey: "\(name)离线可用失败"))
            }
            Message.message(text: LocalizedString(forKey: "正在使\(name)离线可用"))
        }else{
            let name = filesModel.backupRoot ? filesModel.bname ?? filesModel.name ?? "" : filesModel.name ?? ""
            if FilesRootViewController.downloadManager.cache.fileExists(fileName: name){
                for task in FilesRootViewController.downloadManager.completedTasks{
                    if task.fileName == name{
                        FilesRootViewController.downloadManager.remove(task.URLString, completely: true)
                        FilesRootViewController.downloadManager.cache.remove(task as! TRDownloadTask, completely: true)
                        Message.message(text: LocalizedString(forKey: "\(name) 离线已不可用"))
                    }
                }
            }
        }
    }
    
    func patchNodes(taskUUID:String,nodeUUID:String,policySameValue:String? = nil , policyDiffValue:String? = nil ,callback:@escaping ((_ error:Error?)->())){
        TasksAPI.init(taskUUID: taskUUID, nodeUUID: nodeUUID, policySameValue: policySameValue, policyDiffValue: policyDiffValue).startRequestJSONCompletionHandler {(response) in
            if response.error == nil{
                if let errorMessage = ErrorTools.responseErrorData(response.data){
                    let error = NSError(domain: response.request?.url?.absoluteString ?? "", code: 0, userInfo: [NSLocalizedDescriptionKey:errorMessage])
                    return callback(error)
                }
                return callback(nil)
            }else{
               return callback(response.error)
            }
        }
    }
    
    func getTask(taskUUID:String,callback:@escaping (_ task:FilesTasksModel)->()) {
        TasksAPI.init(taskUUID: taskUUID).startRequestJSONCompletionHandler {(response) in
            if response.error == nil{
                let isLocal = AppNetworkService.networkState == .local ? true : false
                if !isLocal{
                    if let errorMessage = ErrorTools.responseErrorData(response.data){
                        Message.message(text: errorMessage)
                        return
                    }
                }
                guard let dic = response.value as? NSDictionary else{
                    Message.message(text: LocalizedString(forKey: "error"))
                   return
                }
                var modelDic:NSDictionary = dic
                if !isLocal{
                    if let dataDic = dic["data"] as? NSDictionary{
                        modelDic = dataDic
                    }
                }
                if let taskModel = FilesTasksModel.deserialize(from: modelDic){
                    return callback(taskModel)
                }else{
                     Message.message(text: ErrorLocalizedDescription.JsonModel.SwitchTOModelFail)
                }
            }else{
                Message.message(text: (response.error?.localizedDescription)!)
            }
        }
    }
    
    func makeCopyTaskCreate(model:Any?){
        self.startActivityIndicator()
        if !(model is EntriesModel) || model == nil {
            return
        }
        let existModel = model as! EntriesModel
        let name = existModel.backupRoot ? existModel.bname ?? existModel.name ?? "" : existModel.name ?? ""
        let names = [name]
        TasksAPI.init(type: FilesTasksType.copy.rawValue, names: names, srcDrive:self.existDrive(), srcDir: self.existDir(), dstDrive:self.existDrive(), dstDir: self.existDir()).startRequestJSONCompletionHandler { [weak self] (response) in
            if response.error == nil{
                let rootDic = response.value as! NSDictionary
                switch AppNetworkService.networkState {
                case .local?:
                    if let taskModel = FilesTasksModel.deserialize(from: rootDic){
                        self?.taskHandle(creatCopy:true,taskModel: taskModel, callback: { (error) in
                            if let error = error{
                                Message.message(text: error.localizedDescription)
                            }else{
                                self?.stopActivityIndicator()
                                Message.message(text: LocalizedString(forKey: "创建副本成功"))
                                self?.prepareData(animation: false)
                            }
                        })
                    }
                case .normal?:
                    if let dataCode = rootDic["code"] as? Int64{
                        if dataCode == 1{
                            if let dic =  rootDic["data"] as? NSDictionary{
                                if let taskModel = FilesTasksModel.deserialize(from: dic){
                                    self?.taskHandle(taskModel: taskModel, callback: { (error) in
                                        if let error = error{
                                            Message.message(text: error.localizedDescription)
                                        }else{
                                            self?.stopActivityIndicator()
                                            Message.message(text: LocalizedString(forKey: "创建副本成功"))
                                            self?.prepareData(animation: false)
                                        }
                                    })
                                }
                            }
                        }else{
                            if response.data != nil {
                                let errorDict =  dataToNSDictionary(data: response.data!)
                                if errorDict != nil{
                                    Message.message(text: errorDict!["message"] != nil ? errorDict!["message"] as! String :  (response.error?.localizedDescription)!)
                                }else{
                                    Message.message(text: LocalizedString(forKey: "请求错误"))
                                }
                            }
                        }
                    }
                default:
                    break
                }
            }else{
                Message.message(text: (response.error?.localizedDescription)!)
            }
             self?.stopActivityIndicator()
        }
    }
    
  
    func taskHandle(isCopy:Bool = false,creatCopy:Bool = false,taskModel:FilesTasksModel,callback:@escaping (_ error:Error?)->()){
        self.getTask(taskUUID: taskModel.uuid!, callback: {[unowned self](model) in
            if model.finished == true{
                return callback(nil)
            }
            if model.nodes?.count != 0 {
                if model.nodes?.first?.state == .Conflict && model.nodes?.first?.error?.code == .EEXIST{
                    if let uuid = model.uuid,let srcuuid = model.nodes?.first?.src?.uuid {
                        if creatCopy == true{
                            self.patchNodes(taskUUID: uuid,nodeUUID: srcuuid, policySameValue: FilesTaskPolicy.rename.rawValue, callback: { (error)in
                                return callback(error)
                            })
                            return
                        }
                        if model.nodes?.first?.type == FilesType.directory.rawValue{
                            self.patchNodes(taskUUID: uuid,nodeUUID: srcuuid, policySameValue: FilesTaskPolicy.keep.rawValue, callback: { (error)in
                                if let error = error{
                                     return callback(error)
                                }else{
                                    self.taskHandle(isCopy:isCopy,creatCopy:creatCopy,taskModel: taskModel, callback: callback)
                                }
                            })
                            return
                        }
                        if !isCopy{
                            self.patchNodes(taskUUID: uuid,nodeUUID: srcuuid, policySameValue: FilesTaskPolicy.rename.rawValue, callback: { (error)in
                                return callback(error)
                            })
                        }else{
                            if let alertVC = self.filesConflictAlert(name: model.nodes?.first?.src?.name){
                                alertVC.confirmCallback = { [unowned self] (type) in
                                    if let type = type{
                                    self.patchNodes(taskUUID: uuid,nodeUUID: srcuuid, policySameValue: type, callback: { (error)in
                                        return callback(error)
                                    })
                                    }else{
                                        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey:LocalizedString(forKey: "Cancel")])
                                        return callback(error)
                                    }
                                }
                            }
                        }
                    }
                }else if model.nodes?.first?.state == .Working || model.nodes?.first?.state == .Preparing{
                    DispatchQueue.global(qos: .default).asyncAfter(deadline: DispatchTime.now() + 2) {
                        DispatchQueue.main.async {
                            self.taskHandle(isCopy:isCopy,creatCopy:creatCopy,taskModel: taskModel, callback: callback)
                        }
                    }
                }else if model.nodes?.first?.state == .Finish {
                    return callback(nil)
                }else if model.nodes?.first?.state == .Failed{
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey:LocalizedString(forKey: "Failed")])
                    return callback(error)
                }
            }
            
//            else if model.nodes?.count ?? 0 > 1{
//                let nodes = model.nodes!.filter({$0.state == .Conflict && $0.error?.code == .EEXIST})
////                for node in model.nodes!{
////                    self.taskHandle(isCopy:isCopy,creatCopy:creatCopy,node:node, taskModel: model, callback: callback)
////                }
//            }
        })
    }
    
     func taskHandle(isCopy:Bool = false,creatCopy:Bool = false,node:NodesModel,taskModel:FilesTasksModel,callback:@escaping (_ error:Error?)->()){
        if node.state == .Conflict && node.error?.code == .EEXIST{
            if let uuid = model?.uuid,let srcuuid = node.src?.uuid {
                if creatCopy == true{
                    self.patchNodes(taskUUID: uuid,nodeUUID: srcuuid, policySameValue: FilesTaskPolicy.rename.rawValue, callback: { (error)in
                        return callback(error)
                    })
                    return
                }
                if node.type == FilesType.directory.rawValue{
                    self.patchNodes(taskUUID: uuid,nodeUUID: srcuuid, policySameValue: FilesTaskPolicy.keep.rawValue, callback: { (error)in
                        if let error = error{
                            return callback(error)
                        }else{
                            self.taskHandle(isCopy:isCopy,creatCopy:creatCopy,taskModel: taskModel, callback: callback)
                        }
                    })
                    return
                }
                if !isCopy{
                    self.patchNodes(taskUUID: uuid,nodeUUID: srcuuid, policySameValue: FilesTaskPolicy.rename.rawValue, callback: { (error)in
                        return callback(error)
                    })
                }else{
                    if let alertVC = self.filesConflictAlert(name: node.src?.name){
                        alertVC.confirmCallback = { [unowned self] (type) in
                            if let type = type{
                                self.patchNodes(taskUUID: uuid,nodeUUID: srcuuid, policySameValue: type, callback: { (error)in
                                    return callback(error)
                                })
                            }else{
                                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey:LocalizedString(forKey: "Cancel")])
                                return callback(error)
                            }
                        }
                    }
                }
            }
        }else if node.state == .Working || node.state == .Preparing{
            DispatchQueue.global(qos: .default).asyncAfter(deadline: DispatchTime.now() + 2) {
                DispatchQueue.main.async {
                    self.taskHandle(isCopy:isCopy,creatCopy:creatCopy,taskModel: taskModel, callback: callback)
                }
            }
        }else if node.state == .Finish {
            return callback(nil)
        }else if node.state == .Failed{
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey:LocalizedString(forKey: "Failed")])
            return callback(error)
        }
    }
    
    func renameConflictAction(){
        
    }
    
    func filesConflictAlert(name:String?)->FilesConflictAlertViewController?{
        let bundle = Bundle.init(for: FilesConflictAlertViewController.self)
        let storyboard = UIStoryboard.init(name: "FilesConflictAlertViewController", bundle: bundle)
        let identifier = "FilesConflictAlertViewController"
        
        let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
        viewController.modalPresentationStyle = UIModalPresentationStyle.custom
        viewController.transitioningDelegate = self.transitionController
        
        weak var vc =  (viewController as? FilesConflictAlertViewController)
        vc?.name = name
        vc?.delegate = self
        self.present(viewController, animated: true, completion: {
            
        })
        let presentationController =
            viewController.mdc_dialogPresentationController
        if presentationController != nil{
            presentationController?.dismissOnBackgroundTap = false
        }
        return vc
    }

    func renamePrepare(model:EntriesModel){
        let filesType = model.type ?? ""
        let name = model.name ?? ""
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
            renamePrepare(model:filesModel)
        case 1:
            moveToAction(model:filesModel)
        case 2:
            if filesModel.type != FilesType.file.rawValue{
                self.makeCopyTaskCreate(model: model)
            }
        case 3 :
            let name = filesModel.backupRoot ? filesModel.bname ?? filesModel.name ?? "" : filesModel.name ?? ""
            if filesModel.type == FilesType.file.rawValue{
                
                if FilesRootViewController.downloadManager.cache.fileExists(fileName: name){
                    self.openForOtherApp(filesModel: filesModel)
                }else{
                    self.downloadFile(model: filesModel) { [weak self](error, task) in
                        if error == nil{
                            self?.openForOtherApp(filesModel: filesModel)
                        }else{
                            Message.message(text: LocalizedString(forKey: "\(name)下载失败"))
                        }
                    }
                }
               
            }else{
                if self.driveUUID == AppUserService.currentUser?.shareSpace || self.selfState == .share{
                    self.makeCopyTaskCreate(model: model)
                    return
                }
//                #warning("分享到共享空间")
                self.copyToAction(model: filesModel, isShare:true)
            }
        case 4:
            if filesModel.type == FilesType.file.rawValue{
                self.makeCopyTaskCreate(model: model)
            }else{
                if self.driveUUID == AppUserService.currentUser?.shareSpace || self.selfState == .share{
                    self.removeFileOrDirectory(model: filesModel)
                    return
                }
                self.copyToAction(model:filesModel)
            }
        case 5:
            if filesModel.type == FilesType.file.rawValue{
                if self.driveUUID == AppUserService.currentUser?.shareSpace || self.selfState == .share{
                    self.copyToAction(model:filesModel)
                    return
                }
                self.copyToAction(model: filesModel,isShare:true)
            }else{
                self.removeFileOrDirectory(model: filesModel)
            }
        case 6:
            if filesModel.type == FilesType.file.rawValue{
                if self.driveUUID == AppUserService.currentUser?.shareSpace || self.selfState == .share{
                     self.removeFileOrDirectory(model: filesModel)
                    return
                }
                self.copyToAction(model:filesModel)
            }
        case 7:
            self.removeFileOrDirectory(model: filesModel)
            
        default:
            break
        }
    }
    
    func openForOtherApp(filesModel:EntriesModel){
        let name = filesModel.backupRoot ? filesModel.bname ?? filesModel.name ?? "" : filesModel.name ?? ""
        if let filePath = FilesRootViewController.downloadManager.cache.filePtah(fileName: name){
            let documentController = UIDocumentInteractionController.init(url: URL.init(fileURLWithPath: filePath))
            documentController.delegate = self
            documentController.presentOpenInMenu(from: CGRect.zero, in: self.view, animated: true)
        }else{
            Message.message(text: LocalizedString(forKey: "无法打开"))
        }
    }
    
    func moveToAction(model:EntriesModel){
        let filesRootViewController = FilesRootViewController.init(style: NavigationStyle.white, srcDictionary: [kRequestTaskDriveKey : self.existDrive(),kRequestTaskDirKey:self.existDir()], moveModelArray:  [model], isCopy: isCopy)
        filesRootViewController.title = LocalizedString(forKey: "My Drive")
        self.registerNotification()
        let navi = UINavigationController.init(rootViewController: filesRootViewController)
        self.present(navi, animated: true, completion: nil)
    }
    
    func copyToAction(model:EntriesModel,isShare:Bool? = nil){
        var share:Bool = false
        var drive:String?
        var dir:String?
        var title = LocalizedString(forKey: "My Drive")
        if let isShare = isShare{
            if isShare{
                drive = AppUserService.currentUser?.shareSpace
                dir = AppUserService.currentUser?.shareSpace
                share = true
                title = LocalizedString(forKey: "共享空间")
            }
        }
        let filesRootViewController =  FilesRootViewController.init(style: NavigationStyle.white, srcDictionary: [kRequestTaskDriveKey : self.existDrive(),kRequestTaskDirKey:self.existDir()], moveModelArray:  [model], isCopy: true,isShare:share,driveUUID:drive,directoryUUID:dir)
        
        filesRootViewController.title = title
        self.registerNotification()
        filesRootViewController.isCopy = true
        filesRootViewController.selfState = .movecopy
        
        let navi = UINavigationController.init(rootViewController: filesRootViewController)
        self.present(navi, animated: true, completion: nil)
    }
    
    func removeFileOrDirectory(model:EntriesModel){
        let type = model.type
        let typeString = type == FilesType.directory.rawValue ? LocalizedString(forKey: "folder") : LocalizedString(forKey: "file")
        let title = "\(LocalizedString(forKey: "Remove")) \(typeString)"
        let name = model.backupRoot ? model.bname ?? model.name ?? "" : model.name ?? ""
        let messageString =  "\(name) \(LocalizedString(forKey: "will be moved"))"
        
        let alertController = MDCAlertController(title: title, message: messageString)
        
        let acceptAction = MDCAlertAction(title:LocalizedString(forKey: "Remove")) { [weak self] (_) in
            self?.filesRemoveOptionRequest(model:model)
//            switch AppNetworkService.networkState {
//            case .local?:
//                self?.localNetStateFilesRemoveOptionRequest(name:name)
//            case .normal?:
//                self?.normalNetStateFilesRemoveOptionRequest(name:name)
//            default:
//                break
//            }
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
//            switch AppNetworkService.networkState {
//            case .local?:
//                self?.localNetStateFilesRemoveOptionRequest(names:models.map({$0.name!}))
//            case .normal?:
//                self?.normalNetStateFilesRemoveOptionRequest(names:models.map({$0.name!}))
//            default:
//                break
//            }
            self?.filesRemoveOptionRequest(models:models)
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
        let text = LocalizedString(forKey: "没有发现文件")
        let attributes = [NSAttributedStringKey.font : MiddleTitleFont,NSAttributedStringKey.foregroundColor : LightGrayColor]
        return NSAttributedString.init(string: text, attributes: attributes)
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let text = LocalizedString(forKey: "重新加载")
        let attributes = [NSAttributedStringKey.font :MiddleTitleFont,NSAttributedStringKey.foregroundColor : COR1]
        return NSAttributedString.init(string: text, attributes: attributes)
    }
}

extension FilesRootViewController:DZNEmptyDataSetDelegate{
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        self.prepareData(animation: true)
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        if self.collcectionViewController?.dataSource?.count == 0 && self.isRequesting == false{
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
            let drive = self.driveUUID ?? AppUserService.currentUser?.userHome ?? ""
            let dir = self.directoryUUID ?? AppUserService.currentUser?.userHome ?? ""
            createNewFolderRequest(name: inputText, drive: drive, dir: dir)
        case .rename:
            renameStateRequest(oldName:theFilesName, newName: inputText, callback: { [weak self](error) in
                if error == nil{
                    Message.message(text: "\(theFilesName ?? "") \(LocalizedString(forKey: "renamed to")) \(inputText)")
                    self?.prepareData(animation: false)
                }else{
                    if let message =  error?.localizedDescription{
                        Message.message(text:message)
                    }else{
                        Message.message(text:LocalizedString(forKey: "error"))
                    }
                }
            })
        default:
            break
        }
    }
    func renameStateRequest(oldName:String?,newName:String,callback:@escaping (_ error:Error?)->()){
        let drive = self.driveUUID ?? AppUserService.currentUser?.userHome ?? ""
        let dir = self.directoryUUID ?? AppUserService.currentUser?.userHome ?? ""
        let op = FilesOptionType.rename.rawValue
        let name = "\(oldName ?? "")|\(newName)"
        DirOprationAPI.init(driveUUID: drive, directoryUUID: dir).startFormDataRequestJSONCompletionHandler(multipartFormData: { (formData) in
            let dic = [kRequestOpKey: op]
            do {
                let data = try JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions.prettyPrinted)
                formData.append(data, withName:name)
            }catch{
                Message.message(text: LocalizedString(forKey: ErrorLocalizedDescription.JsonModel.SwitchTODataFail))
            }
        }, {  [weak self] (response) in
            if response.error == nil{
               return callback(nil)
            }else{
                if let errorDic = ErrorTools.dictResponseErrorData(response.data){
                    let message = (errorDic[kRequestResponseMessageKey] as? String) ?? ""
                    var code:Int = 0
                    let responseCode = errorDic[kRequestResponseCodeKey] as? Int
                    let codeString = errorDic[kRequestResponseCodeKey] as? String
                    if responseCode != nil{
                        code = responseCode ?? 0
                    }
                    if codeString == kRequestResponseErrorEExistKey{
                        code = ErrorCode.Request.EExist
                    }
                    let error  = NSError(domain: response.request?.url?.absoluteString ?? "", code: code, userInfo: [NSLocalizedDescriptionKey:message])
                    return callback(error)
                }
            }
        }) { (error) -> (Void) in
             return callback(error)
        }
    }
    
    
    func createNewFolderRequest(name:String,drive:String,dir:String){
        MkdirAPI.init(driveUUID: drive, directoryUUID: dir).startFormDataRequestJSONCompletionHandler(multipartFormData: {  (formData) in
            let dic = [kRequestOpKey: kRequestMkdirValue,kRequestTaskPolicyKey:[nil,FilesTaskPolicy.rename.rawValue],kRequestBctimeKey:Date.init().timeIntervalSince1970*1000,kRequestBmtimeKey:Date.init().timeIntervalSince1970] as [String : Any]
            do {
                let data = try JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions.prettyPrinted)
                formData.append(data, withName:name)
            }catch{
                Message.message(text: LocalizedString(forKey: ErrorLocalizedDescription.JsonModel.SwitchTODataFail))
            }
        }, { [weak self] (response) in
            if response.error == nil{
                if let errorMessage = ErrorTools.responseErrorData(response.data){
                    Message.message(text: LocalizedString(forKey: "创建文件夹失败"))
                    return
                }
                if let rootDic =  response.value as? NSDictionary{
                    if let code = rootDic["code"] as? String{
                        if code == "EEXIST"{
                            Message.message(text: LocalizedString(forKey: "创建文件夹失败，同名文件夹已存在"))
                        }
                        return
                    }
                }
                #warning ("Conflict")
                Message.message(text: LocalizedString(forKey: "文件夹已创建"))
                self?.prepareData(animation: false)
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


extension  FilesRootViewController:FilesConflictAlertViewControllerDelegate{
    func conflictAction(action: String?) {
        
    }
}
