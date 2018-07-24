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

extension FilesRootViewController:FilesRootCollectionViewControllerDelegate{
    func rootCollectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath, isSelectModel: Bool) {
        if isSelectModel == NSNumber.init(value: FilesStatus.select.rawValue).boolValue{
            self.title = "\(String(describing: (FilesHelper.sharedInstance().selectFilesArray?.count)!))"
        }else{
            let sectionArray:Array<EntriesModel> = dataSource![indexPath.section] as! Array
            let model  = sectionArray[indexPath.item]
            if model.type == FilesType.directory.rawValue{
                let nextViewController = FilesRootViewController.init(driveUUID: (AppUserService.currentUser?.userHome!)!, directoryUUID: model.uuid!,style:.whiteStyle)
                if self.selfState == .movecopy{
                    nextViewController.moveModelArray = moveModelArray
                    nextViewController.srcDictionary = srcDictionary
                    nextViewController.selfState = self.selfState
                }
                let tab = self.navigationDrawerController?.rootViewController as! WSTabBarController
                tab.setTabBarHidden(true, animated: true)
                nextViewController.title = model.name ?? ""
                self.navigationController?.pushViewController(nextViewController, animated: true)
                defaultNotificationCenter().removeObserver(self, name: NSNotification.Name.Refresh.MoveRefreshNotiKey, object: nil)
            }else{
                if FilesRootViewController.downloadManager.cache.fileExists(fileName: model.name ?? ""){
                    self.readFile(filePath: FilesRootViewController.downloadManager.cache.filePtah(fileName: model.name!)!)
                }
                //                for (_,value) in FilesRootViewController.downloadManager.completedTasks.enumerated(){
                //                    value
                //                }
            }
        }
    }
    
    func cellButtonCallBack(_ cell: MDCCollectionViewCell, _ button: UIButton, _ indexPath: IndexPath) {
        let bottomSheet = AppBottomSheetController.init(contentViewController: self.filesBottomVC)
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
    
    func sequenceButtonTap(_ sender: UIButton) {
        let bottomSheet = AppBottomSheetController.init(contentViewController: self.sequenceBottomVC)
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
                self.searchBar.origin.y = -(scrollView.contentOffset.y)-(SearchBarBottom + MarginsCloseWidth/2)+20
                //            }else{
                //                self.searchBar.origin.y = -(scrollView.contentOffset.y)
                //            }
            }
            
            if(translatedPoint.y > 0){
                //                print("mimimi")
                UIView.animate(withDuration: 0.3) {
                    self.searchBar.origin.y = 20 + MarginsCloseWidth
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
        let settingVC = SettingViewController.init(style: NavigationStyle.whiteStyle)
        let tab = self.navigationDrawerController?.rootViewController as! WSTabBarController
        tab.setTabBarHidden(true, animated: true)
        self.navigationController?.pushViewController(settingVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationDrawerController?.closeLeftView()
        switch indexPath.row {
        case 0:
            let transferTaskTableViewController = TransferTaskTableViewController.init(style:NavigationStyle.whiteStyle)
            let tab = self.navigationDrawerController?.rootViewController as! WSTabBarController
            tab.setTabBarHidden(true, animated: true)
            self.navigationController?.pushViewController(transferTaskTableViewController, animated: true)
        case 1:
            let shareVC = FileShareFolderViewController.init(style:.whiteStyle)
            let tab = self.navigationDrawerController?.rootViewController as! WSTabBarController
            tab.setTabBarHidden(true, animated: true)
            self.navigationController?.pushViewController(shareVC, animated: true)
        case 2:
            let offlineVC = FilesOfflineViewController.init(style:.whiteStyle)
            let tab = self.navigationDrawerController?.rootViewController as! WSTabBarController
            tab.setTabBarHidden(true, animated: true)
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
        self.fabButton.expand(true, completion: {
        })
    }
}

extension FilesRootViewController:FABBottomSheetDisplayVCDelegte{
    func folderButtonTap(_ sender: UIButton) {
            self.fabButton.expand(true, completion: { [weak self] in
                let bundle = Bundle.init(for: NewFolderViewController.self)
                let storyboard = UIStoryboard.init(name: "NewFolderViewController", bundle: bundle)
                let identifier = "inputNewFolderDialogID"

                let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
                viewController.modalPresentationStyle = UIModalPresentationStyle.custom
                viewController.transitioningDelegate = self?.transitionController

                let vc =  viewController as! NewFolderViewController
                vc.type = InputAlertType.creatNewFolder
                vc.titleString = LocalizedString(forKey:"New folder")
                vc.inputString =  LocalizedString(forKey: "Untitled folder")
                vc.inputPlaceholder =  LocalizedString(forKey: "Folder name")
                vc.confirmButtonName =  LocalizedString(forKey: "Create")
                vc.delegate = self
                self?.present(viewController, animated: true, completion: {
                    vc.inputTextField.becomeFirstResponder()
                })
                let presentationController =
                    viewController.mdc_dialogPresentationController
                if presentationController != nil{
                    presentationController?.dismissOnBackgroundTap = false
                }
            })
    }
    
    func uploadButtonTap(_ sender: UIButton) {
        self.fabButton.expand(true, completion: {
        })
    }
    
    func cllButtonTap(_ sender: UIButton) {
        self.fabButton.expand(true, completion: {
        })
    }
}

extension FilesRootViewController:SequenceBottomSheetContentVCDelegate{
    func sequenceBottomtableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, isDown: Bool) {
        self.setSortParameters(sortType:SortType(rawValue: Int64(indexPath.row))!, sortIsDown: isDown)
    }
}


extension FilesRootViewController:SearchMoreBottomSheetVCDelegate{
    func searchMoreBottomSheettableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        filesSearchMoreBottomVC.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension FilesRootViewController:FilesBottomSheetContentVCDelegate{
    func patchNodes(taskUUID:String,nodeUUID:String,policySameValue:String? = nil , policyDiffValue:String? = nil){
        TasksAPI.init(taskUUID: taskUUID, nodeUUID: nodeUUID, policySameValue: policySameValue, policyDiffValue: policyDiffValue).startRequestJSONCompletionHandler { [weak self] (response) in
            if response.error == nil{
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
    
    func getTask(taskUUID:String) {
        TasksAPI.init(taskUUID: taskUUID).startRequestJSONCompletionHandler {[weak self](response) in
            if response.error == nil{
                let dic = response.value as! NSDictionary
                if let taskModel = FilesTasksModel.deserialize(from: dic){
                    if taskModel.nodes?.count != 0 && taskModel.nodes?.first?.error != nil{
                        if taskModel.nodes?.first?.state == .Conflict && taskModel.nodes?.first?.error?.code == .EEXIST{
                            self?.patchNodes(taskUUID: taskModel.uuid!, nodeUUID: (taskModel.nodes?.first?.src?.uuid!)!, policySameValue: FilesTaskPolicy.rename.rawValue)
                        }
                    }
                }
            }else{
                
            }
        }
    }
    
    func makeCopyTaskCreate(model:Any?){
        if !(model is EntriesModel) || model == nil {
            return
        }
        let existModel = model as! EntriesModel
        let names = existModel.name != nil ? [existModel.name!] : []
        TasksAPI.init(type: FilesTasksType.copy.rawValue, names: names, srcDrive:self.existDrive(), srcDir: self.existDir(), dstDrive: self.existDrive(), dstDir: self.existDir()).startRequestJSONCompletionHandler { [weak self] (response) in
            if response.error == nil{
                let dic = response.value as! NSDictionary
                if let taskModel = FilesTasksModel.deserialize(from: dic){
                  self?.getTask(taskUUID: taskModel.uuid!)
                }
            }else{
                Message.message(text: (response.error?.localizedDescription)!)
            }
        }
    }
    
    func filesBottomSheetContentTableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, model: Any?) {
        filesBottomVC.presentingViewController?.dismiss(animated: true, completion: {
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
                let filesMoveToRootViewController = FilesMoveToRootViewController.init(style: NavigationStyle.whiteStyle)
               
                filesMoveToRootViewController.srcDictionary = [kRequestTaskDriveKey : self.existDrive(),kRequestTaskDirKey:self.existDir()]
                filesMoveToRootViewController.moveModelArray =  model != nil ? [model as! EntriesModel] : Array.init()
                self.registerNotification()
                let navi = UINavigationController.init(rootViewController: filesMoveToRootViewController)
                self.present(navi, animated: true, completion: nil)
            case 4:
                self.makeCopyTaskCreate(model: model)
            case 8:
                let type = (model as! EntriesModel).type
                let typeString = type == FilesType.directory.rawValue ? LocalizedString(forKey: "folder") : LocalizedString(forKey: "file")
                let title = "\(LocalizedString(forKey: "Remove")) \(typeString)"
                let name = model != nil ? (model as! EntriesModel).name! : ""
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
                self.present(alertController, animated: true, completion: nil)
                
            default:
                break
            }
        })
    }
    
    func filesBottomSheetContentInfoButtonTap(_ sender: UIButton) {
        filesBottomVC.presentingViewController?.dismiss(animated: true, completion:{
            let tab = self.navigationDrawerController?.rootViewController as! WSTabBarController
            tab.setTabBarHidden(true, animated: true)
            let filesInfoVC = FilesFileInfoTableViewController.init(style: NavigationStyle.imageryStyle)
            self.navigationController?.pushViewController(filesInfoVC, animated: true)
        })
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
        DirOprationAPI.init(driveUUID: drive, directoryUUID: dir, name: name, op: op).startRequestJSONCompletionHandler
            { [weak self] (response) in
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
