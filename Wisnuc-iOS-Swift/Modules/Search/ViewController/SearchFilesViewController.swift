//
//  SearchFilesViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/17.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Material
import MaterialComponents.MaterialChips
import Foundation
 enum SearhCellType {
    case searchWill
    case searchWithType
    case searching
    case searchingWithoutType
}

enum SearhOrder:String {
    case newest = "newest"
    case oldest = "oldest"
    case find = "find"
}

private var headerHeight:CGFloat = 48.0
private let chipsWidth:CGFloat = 110.0
private let chipsHeight:CGFloat = 36.0

class SearchFilesViewController: BaseViewController {
    private var cellIdentifier = "Identifier"
    var uuid:String?
    var cellCount = 0
    var cellHeight = 0
    var dataSouce:Array<EntriesModel>?
    var requests:Array<BaseRequest>?
    var types:String?
    var classes:String?
    var downloadTask:TRTask?
    var placesArray:Array<String>?
    var cellType:SearhCellType?{
        didSet{
            switch cellType{
            case .searchWill?:
                searchWillTypeAction()
            case .searchWithType?:
                searchWithTypeAction()
            case .searching?:
                searchingAction()
            case .searchingWithoutType?:
                searchingWithoutTypeTypeAction()
            default:
                break
            }
        }
    }
    
    lazy var transitionController: MDCDialogTransitionController = {
        let controller = MDCDialogTransitionController.init()
        return controller
    }()
    
    deinit {
        print("deinit call search")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(mainTableView)
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
        dataSouce = Array.init()
        requests = Array.init()
        setCellType()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appBar.navigationBar.addSubview(searchTextField)
        appBar.headerViewController.headerView.trackingScrollView = self.mainTableView
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
        setCellType()
        searchTextField.text = nil
        mainTableView.reloadData()
        // 开启返回手势
           self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func setCellType(){
        cellType = .searchWill
        mainTableView.reloadData()
    }
    
    func searchAny(text:String? = nil,types:String? = nil,sClass:String? = nil,complete:@escaping (_ error:Error?)->()){
        var array:Array<EntriesModel> =  Array.init()
        var order:String?
        
        mainTableView.reloadEmptyDataSet()
        order = !isNilString(types) || !isNilString(sClass) ? nil : SearhOrder.find.rawValue
        var placesArray:Array<String> = Array.init()
        placesArray.append(uuid!)
        self.placesArray = placesArray
        let places = placesArray.joined(separator: ".")
        let request = SearchAPI.init(order:order, places: places,class:sClass, types:types, name:text)
            request.startRequestJSONCompletionHandler { [weak self] (response) in
            if response.error == nil{
                if response.value is NSArray{
                    let rootArray = response.value as! NSArray
                    for (_ , value) in rootArray.enumerated(){
                        if value is NSDictionary{
                            let dic = value as! NSDictionary
//
//                            if let model = EntriesModel.deserialize(from: dic) {
//                                array.append(model)
//                            }
                            
                            do{
                                let data = jsonToData(jsonDic: dic)
                                let model = try JSONDecoder().decode(EntriesModel.self, from: data!)
                                array.append(model)
                            }catch{
                                return  complete(BaseError(localizedDescription: ErrorLocalizedDescription.JsonModel.SwitchTOModelFail, code: ErrorCode.JsonModel.SwitchTOModelFail))
                            }
                        }
                    }
                    self?.dataSouce = array
                    return complete(nil)
                }
            }else{
                return complete(response.error)
            }
        }
        requests?.append(request)
    }
    
    func searchWillTypeAction(){
        cellIdentifier = "Identifier"
        self.mainTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        cellCount = 7
        cellHeight = 56
        mainTableView.separatorStyle = .none
        headerView.addSubview(headerViewTitleLabel)
        headerView.backgroundColor = UIColor.white
        chipsView.removeFromSuperview()
        headerHeight = 48.0
        for value in requests! {
            value.cancel()
        }
       requests?.removeAll()
    }
    
    
    func searchWithTypeAction(){
        cellIdentifier = "EndCellIdentifier"
        self.mainTableView.register(UINib.init(nibName: StringExtension.classNameAsString(targetClass: FilesOfflineTableViewCell.self), bundle: nil), forCellReuseIdentifier: cellIdentifier)
        cellCount = (dataSouce?.count)!
        cellHeight = 64
        mainTableView.separatorInset = UIEdgeInsets(top: 0, left: 72, bottom: 0, right: 0)
        mainTableView.separatorStyle = .singleLine
        headerHeight = 48.0
        requests?.removeAll()
    }
    
    func searchingAction(){
        cellCount = 0
        mainTableView.reloadData()
    }
    
    func searchingWithoutTypeTypeAction(){
        chipsView.removeFromSuperview()
        cellIdentifier = "EndCellIdentifier"
        self.mainTableView.register(UINib.init(nibName: StringExtension.classNameAsString(targetClass: FilesOfflineTableViewCell.self), bundle: nil), forCellReuseIdentifier: cellIdentifier)
        cellCount = (dataSouce?.count)!
        cellHeight = 64
        mainTableView.separatorInset = UIEdgeInsets(top: 0, left: 72, bottom: 0, right: 0)
        mainTableView.separatorStyle = .singleLine
        headerHeight = 0.1
        headerViewTitleLabel.removeFromSuperview()
        requests?.removeAll()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @objc func clearButtonTap(_ sender:UIButton?){
        searchTextField.text = nil
        cellType = .searchWill
        mainTableView.reloadData()
    }
    
    @objc func goSearch(_ anyObject: AnyObject?){
        if cellType != .searchWithType && (searchTextField.text?.count)!>0{
            self.searchAny(text: self.searchTextField.text!) { [weak self] (error) in
                if error != nil{
                    Message.message(text: (error?.localizedDescription)!)
                }
                self?.cellType = .searchingWithoutType
                self?.mainTableView.reloadData()
                self?.mainTableView.reloadEmptyDataSet()
            }
        }else if cellType == .searchWithType && (searchTextField.text?.count)!>0{
            self.searchAny(text: self.searchTextField.text!,types: types,sClass:classes) { [weak self] (error) in
                if error != nil{
                    Message.message(text: (error?.localizedDescription)!)
                }
                self?.cellType = .searchWithType
                self?.mainTableView.reloadData()
                self?.mainTableView.reloadEmptyDataSet()
            }
        }
    }
    
    @objc func textFieldTextChange(_ textField:UITextField){
        if textField.text?.count == 0 {
            if cellType != .searchWithType{
               clearButtonTap(nil)
            }
        }else{
                NSObject.cancelPreviousPerformRequests(withTarget: self)
                let subString:NSString = textField.text! as NSString
                self.perform(#selector(goSearch(_ :)), with: subString, afterDelay: 1.0)
        }
    }
    
    lazy var searchTextField: UITextField = {
        let left = MarginsWidth + 24 + MarginsWidth*2
        let height = MarginsSoFarWidth
        let textField = UITextField.init(frame: CGRect(x:left , y: (MDCAppNavigationBarHeight - StatusBarHeight)/2 - height/2, width: __kWidth - left - MarginsWidth, height: height))
        textField.borderStyle = .none
        textField.placeholder = LocalizedString(forKey: "Search Files")
        textField.rightViewMode = .whileEditing
        let clearButton = UIButton.init(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        clearButton.setImage(Icon.clear?.byTintColor(LightGrayColor), for: UIControlState.normal)
        clearButton.addTarget(self, action: #selector(clearButtonTap(_ :)), for: UIControlEvents.touchUpInside)
//        textField.rightView = clearButton
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldTextChange(_ :)), for: UIControlEvents.editingChanged)
//        textField.backgroundColor = UIColor.cyan
        return textField
    }()
    
    lazy var mainTableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect(x: 0, y: 0, width: __kWidth, height: __kHeight))
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        tableView.delegate = self
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        tableView.dataSource = self
        return tableView
    }()
    
    lazy var headerView: UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: __kWidth, height: headerHeight))
        view.addSubview(headerViewTitleLabel)
        view.backgroundColor = .white
        return view
    }()
    
    lazy var headerViewTitleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect(x: MarginsWidth, y: 0, width: __kWidth - MarginsWidth, height: headerHeight))
        label.textColor = LightGrayColor
        label.font = SmallTitleFont
        label.text = LocalizedString(forKey: "Files Type")
        return label
    }()
    
    lazy var chipsView: ChipsView = {
        let chips = ChipsView.init(frame: CGRect(x: MarginsCloseWidth, y: headerHeight/2 - chipsHeight/2 , width: chipsWidth, height: chipsHeight))
        chips.delegate = self
        return chips
    }()
    
}

extension SearchFilesViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellCount
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(cellHeight)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if let cell = cell as?  FilesOfflineTableViewCell {
            let model = dataSouce![indexPath.row]
            let exestr = (model.name! as NSString).pathExtension
            cell.leftImageView.image = UIImage.init(named: FileTools.switchFilesFormatType(type: FilesType(rawValue: model.type ?? FilesType.file.rawValue), format: FilesFormatType(rawValue: exestr)))
            cell.detailImageView.isHidden = true
            if cell.detailImageView.isHidden {
                cell.reloadLayout()
            }
            cell.moreButton.isHidden = false
            cell.titleLabel.text = model.name
            let time = model.mtime != nil ? timeString(TimeInterval(model.mtime!/1000)) : LocalizedString(forKey: "No time")
            let size = model.size != nil ? sizeString(Int64(model.size!)) : ""
            cell.detailLabel.text = "\(time) \(size)"
            cell.cellCallBack = { [weak self](callBackCell , button) in
                let filesBottomVC = FilesFilesBottomSheetContentTableViewController.init(style: UITableViewStyle.plain)
                filesBottomVC.delegate = self
                let bottomSheet = AppBottomSheetController.init(contentViewController: filesBottomVC)
                bottomSheet.trackingScrollView = filesBottomVC.tableView
                let exestr = (model.name! as NSString).pathExtension
                filesBottomVC.headerTitleLabel.text = model.name ?? ""
                filesBottomVC.headerImageView.image = UIImage.init(named: FileTools.switchFilesFormatType(type: FilesType(rawValue: model.type ?? FilesType.file.rawValue), format: FilesFormatType(rawValue: exestr)))
                self?.present(bottomSheet, animated: true, completion: {
                })
            }
        }else{
            cell.textLabel?.textColor = DarkGrayColor
            cell.textLabel?.font = BoldMiddlePlusTitleFont
            cell.indentationLevel = 1
            cell.indentationWidth = 16
            switch indexPath.row {
            case 0:
                cell.imageView?.image = UIImage.init(named: "files_pdf_small.png")
                cell.textLabel?.text = LocalizedString(forKey: "PDFs")
            case 1:
                cell.imageView?.image = UIImage.init(named: "files_word_small.png")
                cell.textLabel?.text = LocalizedString(forKey: "Word")
            case 2:
                cell.imageView?.image = UIImage.init(named: "files_excel_small.png")
                cell.textLabel?.text = LocalizedString(forKey: "Excel")
            case 3:
                cell.imageView?.image = UIImage.init(named: "files_ppt_small.png")
                cell.textLabel?.text = LocalizedString(forKey: "PPT")
            case 4:
                cell.imageView?.image = UIImage.init(named: "files_photo_small.png")
                cell.textLabel?.text = LocalizedString(forKey: "Photos & Images")
            case 5:
                cell.imageView?.image = UIImage.init(named: "files_video_small.png")
                cell.textLabel?.text = LocalizedString(forKey: "Video")
            case 6:
                cell.imageView?.image = UIImage.init(named: "files_audio_small.png")
                cell.textLabel?.text = LocalizedString(forKey: "Audio")
            default:
                break
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if cellType == .searchingWithoutType || cellType == .searchWithType{
            let model = dataSouce![indexPath.row]
//            print("place:\(String(describing: model.place))\n pdir:\(String(describing: model.pdir))")
            if FilesRootViewController.downloadManager.cache.fileExists(fileName: model.name ?? ""){
                self.readFile(filePath: FilesRootViewController.downloadManager.cache.filePtah(fileName: model.name!)!)
            }else{
            let driveUUID = placesArray![model.place!]
            let resource = "/drives/\(String(describing: driveUUID))/dirs/\(String(describing: model.pdir!))/entries/\(String(describing: model.uuid!))"
            let localUrl = "\(String(describing: RequestConfig.sharedInstance.baseURL!))/drives/\(String(describing: driveUUID))/dirs/\(String(describing: model.pdir!))/entries/\(String(describing: model.uuid!))?name=\(String(describing: model.name!))"
            var requestURL = AppNetworkService.networkState == .normal ? "\(kCloudBaseURL)\(kCloudCommonPipeUrl)?resource=\(resource.toBase64())&method=\(RequestMethodValue.GET)&name=\(model.name!)" : localUrl
            requestURL = requestURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                let bundle = Bundle.init(for: FilesDownloadAlertViewController.self)
                let storyboard = UIStoryboard.init(name: "FilesDownloadAlertViewController", bundle: bundle)
                let identifier = "FilesDownloadDialogID"

                let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
                viewController.modalPresentationStyle = UIModalPresentationStyle.custom
                viewController.transitioningDelegate = self.transitionController

                weak var vc =  (viewController as? FilesDownloadAlertViewController)
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
                let task =  FilesRootViewController.downloadManager.download(requestURL, fileName: model.name!, filesModel: model)

                task?.progressHandler = { (taskP)in
                    let float:Float = Float(taskP.progress.completedUnitCount)/Float(taskP.progress.totalUnitCount)
                    vc?.downloadProgressView.progress = Float(float)
                }

                task?.successHandler  = { [weak self] (taskS) in
                    vc?.dismiss(animated: true, completion: {
                        Message.message(text: LocalizedString(forKey: "\(model.name ?? "文件")下载完成"))
                        DispatchQueue.global(qos: .default).asyncAfter(deadline: DispatchTime.now() + 0.5) {
                            DispatchQueue.main.async {
                                self?.readFile(filePath:FilesRootViewController.downloadManager.cache.filePtah(fileName: model.name!)!)
                            }
                        }
                    })
                }
                
                task?.failureHandler  = { (taskF) in
                    vc?.dismiss(animated: true, completion: {
    
                    })
                }
                downloadTask = task
            }
        }else{
            var types:String?
            var sclass:String?
            switch  indexPath.row{
            case 0:
                chipsView.imageView.image = UIImage.init(named: "files_pdf_small.png")
                chipsView.titleTextLabel.text = LocalizedString(forKey: "PDFs")
                types = "\(FilesFormatType.PDF.rawValue)".uppercased()
            case 1:
                chipsView.imageView.image = UIImage.init(named: "files_word_small.png")
                chipsView.titleTextLabel.text = LocalizedString(forKey: "Word")
                types = "\(FilesFormatType.DOC.rawValue).\(FilesFormatType.DOCX.rawValue)".uppercased()
            case 2:
                chipsView.imageView.image = UIImage.init(named: "files_excel_small.png")
                chipsView.titleTextLabel.text = LocalizedString(forKey: "Excel")
                types = "\(FilesFormatType.XLS.rawValue).\(FilesFormatType.XLSX.rawValue)".uppercased()
            case 3:
                chipsView.imageView.image = UIImage.init(named: "files_pdf_small.png")
                chipsView.titleTextLabel.text = LocalizedString(forKey: "PPT")
                types = "\(FilesFormatType.PPT.rawValue).\(FilesFormatType.PPTX.rawValue)".uppercased()
            case 4:
                chipsView.imageView.image = UIImage.init(named: "files_photo_small.png")
                chipsView.titleTextLabel.text = LocalizedString(forKey: "Photos & Images")
                sclass = "image"
            case 5:
                chipsView.imageView.image = UIImage.init(named: "files_video_small.png")
                chipsView.titleTextLabel.text = LocalizedString(forKey: "video")
                sclass = "video"
//                types = "\(FilesFormatType.MP4.rawValue).\(FilesFormatType.RM.rawValue).\(FilesFormatType.RMVB.rawValue).\(FilesFormatType.MOV.rawValue).\(FilesFormatType.AVI.rawValue).\(FilesFormatType.MKV.rawValue).\(FilesFormatType.WMV.rawValue).\(FilesFormatType.SWF.rawValue).\(FilesFormatType.FLV.rawValue)".uppercased()
            case 6:
                chipsView.imageView.image = UIImage.init(named: "files_audio_small.png")
                chipsView.titleTextLabel.text = LocalizedString(forKey: "Audio")
//                types = "\(FilesFormatType.MP3.rawValue).\(FilesFormatType.AAC.rawValue).\(FilesFormatType.APE.rawValue).\(FilesFormatType.FLAC.rawValue).\(FilesFormatType.WAV.rawValue)".uppercased()
                sclass = "audio"
            default:
                break
            }
            
            chipsView.width = MarginsCloseWidth*3 + MarginsSoFarWidth + MarginsWidth + labelWidthFrom(title: chipsView.titleTextLabel.text!, font: chipsView.titleTextLabel.font) + 18
            headerViewTitleLabel.removeFromSuperview()
            headerView.addSubview(chipsView)
            headerView.backgroundColor = lightGrayBackgroudColor
            self.cellType = .searching
            self.searchAny(types: types,sClass:sclass) { [weak self] (error) in
                if error != nil{
                    Message.message(text: (error?.localizedDescription)!)
                }
                 self?.cellType = .searchWithType
                 self?.mainTableView.reloadData()
                 self?.mainTableView.reloadEmptyDataSet()
            }
            
            classes = sclass
            self.types = types
        }
    }
}

extension SearchFilesViewController:ChipsViewDelegate{
    func closeButtonTap(_ sender: UIButton) {
        if searchTextField.text?.count == 0 {
            cellType = .searchWill
        }else{
            cellType = .searchingWithoutType
            goSearch(nil)
        }

        mainTableView.reloadData()
    }
}

extension SearchFilesViewController:UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print(textField.text ?? "空")
    
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
         return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if textField.text?.count != 0 {
//            NSObject.cancelPreviousPerformRequests(withTarget: self)
//            var subString:NSString = textField.text! as NSString
//            subString = subString.replacingCharacters(in: range, with: string) as NSString
//            self.perform(#selector(goSearch(_ :)), with: subString, afterDelay: 0.7)
//        }

        return true
    }
}

extension SearchFilesViewController:DZNEmptyDataSetSource{
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage.init(named: "logo_gray")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = LocalizedString(forKey: "Not found")
        let attributes = [NSAttributedStringKey.font : MiddleTitleFont,NSAttributedStringKey.foregroundColor : LightGrayColor]
        return NSAttributedString.init(string: text, attributes: attributes)
    }
    
}

extension SearchFilesViewController:DZNEmptyDataSetDelegate{
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
//        self.prepareData()
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        if self.dataSouce?.count == 0 && (cellType == .searchWithType || cellType == .searchingWithoutType){
            return true
        }else{
            return false
        }
    }
}

extension SearchFilesViewController:FilesBottomSheetContentVCDelegate{
    func filesBottomSheetContentInfoButtonTap(_ sender: UIButton, model: Any) {
        let filesInfoVC = FilesFileInfoTableViewController.init(style: NavigationStyle.imagery)
        filesInfoVC.model = model as! EntriesModel
        self.navigationController?.pushViewController(filesInfoVC, animated: true)
    }
    
    func filesBottomSheetContentSwitch(_ sender: UISwitch, model: Any) {
        
    }
    
    func filesBottomSheetContentTableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, model: Any?) {
        
    }
    
}

extension SearchFilesViewController:UIDocumentInteractionControllerDelegate{
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

extension SearchFilesViewController:FilesDownloadAlertViewControllerDelegate{
    func cancelButtonTap() {
        if downloadTask != nil{
            downloadTask?.cancel()
            downloadTask?.remove()
        }
    }
}

