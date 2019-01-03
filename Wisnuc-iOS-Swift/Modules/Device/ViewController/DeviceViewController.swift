//
//  DeviceViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/15.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit
import Material
enum DeviceViewControllerState{
   case editing
   case normal
}

class DeviceViewController: BaseViewController {
   let legendHeight:CGFloat =  12
   var bootSpaceModel:BootSpaceModel?
   var statsModel:StatsModel?
   var infoModel:WinasdInfoModel?
   var inputTextFieldController:MDCTextInputControllerUnderline?
   var originName:String?
   var state:DeviceViewControllerState?{
      didSet{
         switch state {
         case .editing?:
            editingStateAction()
         case .normal?:
            normalStateAction()
         default:
            break
         }
      }
   }
   let identifier = "cellIdentifier"
   let headerHeight:CGFloat = 205
   override func viewDidLoad() {
      super.viewDidLoad()

      self.view.addSubview(deviceTableView)
      
      self.view.bringSubview(toFront: appBar.headerViewController.headerView)
      
      deviecNameTitleTextField.text = LocalizedString(forKey: "Loading...")
      
      self.state = .normal
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      appBar.headerViewController.headerView.trackingScrollView = self.deviceTableView
   }
   
   override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      setData()
      loadDeviceData()
      if let controller = UIViewController.currentViewController(){
         if !(controller is DeviceViewController){
            return
         }
      }
      if let tab = retrieveTabbarController(){
         if tab.tabBarHidden{
            tab.setTabBarHidden(false, animated: true)
         }
      }
   }
   func setData(){
       getBootData()
   }
   
   func setLabelFrame(text:String){
      let font = UIFont.boldSystemFont(ofSize: 14)
      let width = labelWidthFrom(title: text, font: font)
      self.capacityLabel.frame = CGRect(x:__kWidth - MarginsWidth - width - 2  , y:self.deviecNameTitleTextField.top + self.deviecNameTitleTextField.height/2 - 14/2 + 8, width: width + 2, height: 14)
      self.capacityLabel.textColor = LightGrayColor
      self.capacityLabel.font = font
      self.capacityLabel.text = text
   }
   
   
   func loadDeviceData(){
      DeviceHelper.fetchInasdInfo { [weak self](model) in
         self?.infoModel = model
         if let stationName =  model?.device?.name{
             self?.deviecNameTitleTextField.text = stationName
         }
      }
   }
   
   func getFruitmixStatsData(closure:@escaping (_ stats:StatsModel)->()){
      let requset = FruitmixStatsAPI.init()
      requset.startRequestJSONCompletionHandler({(response) in
         if let error =  response.error{
            Message.message(text: error.localizedDescription)
         }else{
            if let errorMessage = ErrorTools.responseErrorData(response.data){
               Message.message(text: errorMessage)
               return
            }
            if let rootDic = response.value as? NSDictionary {
               let  isLocal = AppNetworkService.networkState == .local ? true : false
               var dataDic = rootDic
               if !isLocal{
                  if let dic = rootDic["data"] as? NSDictionary{
                     dataDic = dic
                  }
               }
               do {
                  guard let data = jsonToData(jsonDic: dataDic) else{return}
                  let model = try JSONDecoder().decode(StatsModel.self, from: data)
                  return closure(model)
               }catch{
                  print(error as Any)
                  //error
               }
            }
         }
      })
   }
   
   func getBootData(){
      let requset = BootSpaceAPI.init()
      requset.startRequestJSONCompletionHandler({ [weak self](response) in
         if let error =  response.error{
            Message.message(text: error.localizedDescription)
         }else{
            if let errorMessage = ErrorTools.responseErrorData(response.data){
               Message.message(text: errorMessage)
               return
            }
            if let rootDic = response.value as? NSDictionary {
               let  isLocal = AppNetworkService.networkState == .local ? true : false
               var dataDic = rootDic
               if !isLocal{
                  if let dic = rootDic["data"] as? NSDictionary{
                     dataDic = dic
                  }
               }
               do {
                  guard let data = jsonToData(jsonDic: dataDic) else{
                     return
                  }
                  let model = try JSONDecoder().decode(BootSpaceModel.self, from: data)
                  if let total = model.total,let used = model.used{
                     if let usedString = self?.devieceString(base: Int64(used*1024)),let totalString = self?.devieceString(base: Int64(total*1024)){
                     self?.setLabelFrame(text:"已使用\(usedString) / \(totalString)")
                     }
                  }
                  self?.getFruitmixStatsData(closure: { [weak self](statsModel) in
                     self?.setHeaderContentFrame(statsModel: statsModel,bootSpaceModel:model)
                     self?.bootSpaceModel = model
                     self?.statsModel = statsModel
                  })
               }catch{
                  print(error as Any)
                  //error
               }
            }
         }
      })
   }
   
   func devieceString(base:Int64) -> String {
      let length = Double(base)
      if length >= pow(1024, 3) {
         return "\(String(format: "%.2f", length / pow(1024, 3)))GB"
      } else if length >= pow(1024, 2) {
         return "\(String(format: "%.2f", length / pow(1024, 2)))MB"
      } else if length >= 1024 {
         return "\(String(format: "%.0f", length / 1024))KB"
      } else {
         return "\(base)B"
      }
   }
   
   func renameStation(originName:String){
      guard let name  =  deviecNameTitleTextField.text else { return }
      if name.count == 0 { return }
      if name == originName { return }
      let requset = RenameStatiomNameAPI.init(name:name)
      requset.startRequestJSONCompletionHandler({ [weak self](response) in
         if let error =  response.error{
            Message.message(text: error.localizedDescription)
            self?.deviecNameTitleTextField.text = originName
         }else{
            if let errorMessage = ErrorTools.responseErrorData(response.data){
               Message.message(text: errorMessage)
               self?.deviecNameTitleTextField.text = originName
               return
            }
            self?.originName = self?.deviecNameTitleTextField.text
         }
      })
   }
   
   //计算磁盘使用情况进度条
   func setHeaderContentFrame(statsModel:StatsModel,bootSpaceModel:BootSpaceModel){
      guard  let documentSize = statsModel.document?.totalSize ,let imageSize = statsModel.image?.totalSize,let audioSize = statsModel.audio?.totalSize,let videoSize = statsModel.video?.totalSize,let otherSize = statsModel.others?.totalSize else {
         return
      }
      
      guard  var totalSize = bootSpaceModel.total else {
         return
      }
      
      guard  var usedSize = bootSpaceModel.used else {
         return
      }
      
      if totalSize == 0{
         return
      }
      totalSize = totalSize * 1024
      usedSize = usedSize * 1024
      let statsTotalSize = documentSize + imageSize + videoSize + otherSize + audioSize
      
      var totalProportion:CGFloat = 1
      
      if statsTotalSize != 0 && statsTotalSize > Int64(usedSize) {
         totalProportion = CGFloat(usedSize)/CGFloat(statsTotalSize)
      }
      
      var filesProportion:CGFloat = 0.0
      filesProportion = CGFloat(documentSize)/CGFloat(totalSize) * totalProportion
      
      var imageProportion:CGFloat = 0.0
      imageProportion = CGFloat(imageSize)/CGFloat(totalSize) * totalProportion
     
      var audioProportion:CGFloat = 0.0
      audioProportion = CGFloat(audioSize)/CGFloat(totalSize) * totalProportion
      
      var videoProportion:CGFloat = 0.0
      videoProportion = CGFloat(videoSize)/CGFloat(totalSize) * totalProportion
     
      var othersProportion:CGFloat = 0.0
      othersProportion = CGFloat(otherSize)/CGFloat(totalSize) * totalProportion
      
      let minProportion:CGFloat  = 0.01
      let minWidth:CGFloat  = 2
      let baseWith = (capacityProgressBackgroudView.width - 8)
      let capacityFilesProgressViewWidth:CGFloat = baseWith * filesProportion
      let capacityPhotoProgressViewWidth:CGFloat = baseWith * imageProportion
      let capacityAudioProgressViewWidth:CGFloat = baseWith * audioProportion
      let capacityVideoProgressViewWidth:CGFloat = baseWith * videoProportion
      let capacityOtherProgressViewWidth:CGFloat = baseWith * othersProportion
      let minProportionWidth:CGFloat = baseWith * minProportion
      
      let capacityFilesWidth:CGFloat = capacityFilesProgressViewWidth <= minWidth ? 0 : capacityFilesProgressViewWidth <= minProportionWidth ? minProportionWidth : capacityFilesProgressViewWidth
      let capacityPhotoWidth:CGFloat = capacityPhotoProgressViewWidth == minWidth ? 0 : capacityPhotoProgressViewWidth <= minProportionWidth ? minProportionWidth : capacityPhotoProgressViewWidth
      let capacityAudioWidth:CGFloat = capacityAudioProgressViewWidth == minWidth ? 0 : capacityPhotoProgressViewWidth <= minProportionWidth ? minProportionWidth : capacityAudioProgressViewWidth
      let capacityVideoWidth:CGFloat = capacityVideoProgressViewWidth == minWidth ? 0 : capacityVideoProgressViewWidth <= minProportionWidth ? minProportionWidth : capacityVideoProgressViewWidth
      let capacityOtherWidth:CGFloat = capacityOtherProgressViewWidth == 0 ? 0 : capacityOtherProgressViewWidth <= minProportionWidth ? minProportionWidth : capacityOtherProgressViewWidth
      
      capacityFilesProgressView.snp.makeConstraints { (make) in
         make.centerY.equalTo(capacityProgressBackgroudView.snp.centerY)
         make.left.equalTo(capacityProgressBackgroudView.snp.left)
         make.top.equalTo(capacityProgressBackgroudView.snp.top)
         make.bottom.equalTo(capacityProgressBackgroudView.snp.bottom)
         make.width.equalTo(capacityFilesWidth)
      }
      
      capacityPhotoProgressView.snp.makeConstraints { (make) in
         make.centerY.equalTo(capacityProgressBackgroudView.snp.centerY)
         make.left.equalTo(capacityFilesProgressView.snp.right).offset(capacityFilesWidth < minProportionWidth ? 0 : 2)
         make.top.equalTo(capacityProgressBackgroudView.snp.top)
         make.bottom.equalTo(capacityProgressBackgroudView.snp.bottom)
         make.width.equalTo(capacityPhotoWidth)
      }
      
      capacityAudioProgressView.snp.makeConstraints { (make) in
         make.centerY.equalTo(capacityProgressBackgroudView.snp.centerY)
         make.left.equalTo(capacityPhotoProgressView.snp.right).offset(capacityPhotoWidth < minProportionWidth ? 0 : 2)
         make.top.equalTo(capacityProgressBackgroudView.snp.top)
         make.bottom.equalTo(capacityProgressBackgroudView.snp.bottom)
         make.width.equalTo(capacityAudioWidth)
      }
      
      capacityVideoProgressView.snp.makeConstraints { (make) in
         make.centerY.equalTo(capacityProgressBackgroudView.snp.centerY)
         make.left.equalTo(capacityAudioProgressView.snp.right).offset(capacityAudioWidth < minProportionWidth ? 0 : 2)
         make.top.equalTo(capacityProgressBackgroudView.snp.top)
         make.bottom.equalTo(capacityProgressBackgroudView.snp.bottom)
         make.width.equalTo(capacityVideoWidth)
      }
      
      capacityOtherProgressView.snp.makeConstraints { (make) in
         make.centerY.equalTo(capacityProgressBackgroudView.snp.centerY)
         make.left.equalTo(capacityVideoProgressView.snp.right).offset(capacityVideoWidth < minProportionWidth ? 0 : 2)
         make.top.equalTo(capacityProgressBackgroudView.snp.top)
         make.bottom.equalTo(capacityProgressBackgroudView.snp.bottom)
         make.width.equalTo(capacityOtherWidth)
      }
   }
   
   func setHeaderLegendFrame(){
      capacityFilesLegendView.snp.makeConstraints { (make) in
         make.left.equalTo(capacityLegendView.snp.left)
         make.top.equalTo(capacityLegendView.snp.top).offset(8)
         make.size.equalTo(CGSize(width: legendHeight, height: legendHeight))
      }
      
      capacityFilesLegendLabel.snp.makeConstraints { (make) in
         make.left.equalTo(capacityFilesLegendView.snp.right).offset(MarginsCloseWidth)
         make.top.equalTo(capacityFilesLegendView.snp.top)
         make.size.equalTo(CGSize(width: labelWidthFrom(title: LocalizedString(forKey: capacityFilesLegendLabel.text!), font: capacityFilesLegendLabel.font), height: legendHeight))
      }
      
      capacityPhotoLegendView.snp.makeConstraints { (make) in
         make.left.equalTo(capacityFilesLegendLabel.snp.right).offset(MarginsWidth)
         make.top.equalTo(capacityFilesLegendView.snp.top)
         make.size.equalTo(CGSize(width: 12, height: legendHeight))
      }
      
      capacityPhotoLegendLabel.snp.makeConstraints { (make) in
         make.left.equalTo(capacityPhotoLegendView.snp.right).offset(MarginsCloseWidth)
         make.top.equalTo(capacityFilesLegendView.snp.top)
         make.size.equalTo(CGSize(width: labelWidthFrom(title: LocalizedString(forKey: capacityPhotoLegendLabel.text!), font: capacityPhotoLegendLabel.font), height: legendHeight))
      }
      
      capacityAudioLegendView.snp.makeConstraints { (make) in
         make.left.equalTo(capacityPhotoLegendLabel.snp.right).offset(MarginsWidth)
         make.top.equalTo(capacityPhotoLegendView.snp.top)
         make.size.equalTo(CGSize(width: 12, height: legendHeight))
      }
      
      capacityAudioLegendLabel.snp.makeConstraints { (make) in
         make.left.equalTo(capacityAudioLegendView.snp.right).offset(MarginsCloseWidth)
         make.top.equalTo(capacityPhotoLegendView.snp.top)
         make.size.equalTo(CGSize(width: labelWidthFrom(title: LocalizedString(forKey: capacityPhotoLegendLabel.text!), font: capacityPhotoLegendLabel.font), height: legendHeight))
      }
      
      capacityVideoLegendView.snp.makeConstraints { (make) in
         make.left.equalTo(capacityAudioLegendLabel.snp.right).offset(MarginsWidth)
          make.top.equalTo(capacityFilesLegendView.snp.top)
         make.size.equalTo(CGSize(width: 12, height: legendHeight))
      }
      
      capacityVideoLegendLabel.snp.makeConstraints { (make) in
         make.left.equalTo(capacityVideoLegendView.snp.right).offset(MarginsCloseWidth)
         make.top.equalTo(capacityFilesLegendView.snp.top)
         make.size.equalTo(CGSize(width: labelWidthFrom(title: LocalizedString(forKey: capacityVideoLegendLabel.text!), font: capacityVideoLegendLabel.font), height: legendHeight))
      }
      
      capacityOtherLegendView.snp.makeConstraints { (make) in
         make.left.equalTo(capacityVideoLegendLabel.snp.right).offset(MarginsWidth)
         make.top.equalTo(capacityFilesLegendView.snp.top)
         make.size.equalTo(CGSize(width: 12, height: legendHeight))
      }
      
      capacityOtherLegendLabel.snp.makeConstraints { (make) in
         make.left.equalTo(capacityOtherLegendView.snp.right).offset(MarginsCloseWidth)
         make.top.equalTo(capacityFilesLegendView.snp.top)
         make.size.equalTo(CGSize(width: labelWidthFrom(title: LocalizedString(forKey: capacityPhotoLegendLabel.text!), font: capacityPhotoLegendLabel.font), height: legendHeight))
      }
   }
   
   func setTextFieldNormal(){
      appBar.headerViewController.headerView.backgroundColor = .white
      appBar.navigationBar.backgroundColor = .white
      appBar.headerStackView.backgroundColor = .white
      appBar.navigationBar.titleTextColor = .black
      prepareRightNavigation()
       self.navigationItem.leftBarButtonItem = nil
      deviecNameTitleTextField.isEnabled = false
       deviecNameTitleTextField.frame = CGRect(origin: deviecNameTitleTextField.origin, size: CGSize(width: __kWidth/2, height: deviecNameTitleTextField.height))
      capacityProgressView.isHidden = false
      capacityLabel.isHidden = false
      self.inputTextFieldController  = nil
      self.inputTextFieldController = MDCTextInputControllerUnderline.init(textInput: deviecNameTitleTextField)
      self.inputTextFieldController?.isFloatingEnabled = false
      self.inputTextFieldController?.normalColor = .white
      self.inputTextFieldController?.disabledColor = .white
      self.inputTextFieldController?.underlineViewMode = .never
      self.view.endEditing(true)
      
      let tab = retrieveTabbarController()
      tab?.setTabBarHidden(false, animated: true)
      
      capacityProgressBackgroudView.isHidden = false
      capacityLegendView.isHidden = false
      storageInfoView.isHidden = false
      
      headerView.isUserInteractionEnabled = true
      deviceTableView.reloadData()
   }
   
   
   func setTextFieldEditing(){
      appBar.headerViewController.headerView.backgroundColor = .white
      appBar.navigationBar.backgroundColor = .white
      appBar.headerStackView.backgroundColor = .white
      appBar.navigationBar.titleTextColor = .white
      prepareLeftNavigation()
      self.navigationItem.rightBarButtonItems = nil
      deviecNameTitleTextField.isEnabled = true
      deviecNameTitleTextField.frame = CGRect(origin: deviecNameTitleTextField.origin, size: CGSize(width: __kWidth - MarginsWidth*2, height: deviecNameTitleTextField.height))
      capacityProgressView.isHidden = true
      capacityLabel.isHidden = true
      self.inputTextFieldController  = nil
      self.inputTextFieldController = MDCTextInputControllerUnderline.init(textInput: deviecNameTitleTextField)

      self.inputTextFieldController?.isFloatingEnabled = false
      self.inputTextFieldController?.activeColor = COR1
      deviecNameTitleTextField.becomeFirstResponder()
      let tab = retrieveTabbarController()
      tab?.setTabBarHidden(true, animated: true)
      
      capacityProgressBackgroudView.isHidden = true
      capacityLegendView.isHidden = true
      
      storageInfoView.isHidden = true
      deviceTableView.reloadData()
   }
   
   func editingStateAction(){
      setTextFieldEditing()
   }
   
   func normalStateAction(){
      setTextFieldNormal()
   }
   
   func prepareRightNavigation(){
      let addBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "add_gray.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(addBarButtonItemTap(_ :)))
      let editBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "edit_gray.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(editBarButtonItemTap(_ :)))
      let changeBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "exchange_gray.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(changeBarButtonItemTap(_ :)))
      self.navigationItem.rightBarButtonItems = [changeBarButtonItem,editBarButtonItem,addBarButtonItem]
   }
   
   func prepareLeftNavigation(){
      let editingConfirmBarButtonItem = UIBarButtonItem.init(image: MDCIcons.imageFor_ic_check()?.byTintColor(LightGrayColor), style: UIBarButtonItemStyle.plain, target: self, action: #selector(editingConfirmBarButtonItemTap(_ :)))
    
      self.navigationItem.leftBarButtonItem = editingConfirmBarButtonItem
   }
   
   @objc func addBarButtonItemTap(_ sender:UIBarButtonItem){
      let addDeviceViewController = DeviceAddDeviceViewController.init(style:.highHeight)
      let navigationController =  UINavigationController.init(rootViewController: addDeviceViewController)
      let tab = retrieveTabbarController()
      tab?.setTabBarHidden(true, animated: true)
      self.present(navigationController, animated: true) {
         
      }
   }
   
   @objc func editBarButtonItemTap(_ sender:UIBarButtonItem){
      if self.infoModel != nil{
         self.state = .editing
      }else{
         Message.message(text:LocalizedString(forKey: "Loading..."))
      }
   }
   
   
   @objc func changeBarButtonItemTap(_ sender:UIBarButtonItem){
      let changeDeviceVC = DeviceChangeDeviceViewController.init(style: NavigationStyle.white)
      let navigationController = UINavigationController.init(rootViewController: changeDeviceVC)
      self.present(navigationController, animated: true) {
         
      }
   }
   
   @objc func editingConfirmBarButtonItemTap(_ sender:UIBarButtonItem){
      self.state = .normal
      if let stationName =  self.infoModel?.device?.name{
          self.renameStation(originName: self.originName ?? stationName)
      }
   }
   
   @objc func deviceInfoTap(_ sender:UIGestureRecognizer){
      guard let statsModel = self.statsModel  else {
         return
      }
      guard let bootSpaceModel = self.bootSpaceModel  else {
         return
      }
      let deviceInfoViewController = DeviceDetailInfoViewController.init(style: .whiteWithoutShadow,statsModel:statsModel,bootSpaceModel:bootSpaceModel)
      let navigationController = UINavigationController.init(rootViewController: deviceInfoViewController)
      self.present(navigationController, animated: true) {
         
      }
   }
   
   lazy var deviceTableView: UITableView = {
      let tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: __kWidth, height: __kHeight), style: UITableViewStyle.plain)
      tableView.dataSource = self
      tableView.delegate = self
      tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
      tableView.tableFooterView = UIView.init(frame: CGRect.zero)
      tableView.isScrollEnabled = false
      return tableView
   }()
   
   lazy var headerView: UIView = {
      let view = UIView.init(frame: CGRect.zero)
      view.backgroundColor = .white
      return view
   }()
   
   lazy var deviecNameTitleTextField: MDCTextField = {
      let font = UIFont.boldSystemFont(ofSize: 28)
      let textField = MDCTextField.init(frame: CGRect(x:MarginsWidth , y:MarginsWidth , width: __kWidth/2, height: 50))
      textField.textColor = DarkGrayColor
      textField.clearButtonMode = .whileEditing
      textField.font = font
      if #available(iOS 10.0, *) {
         textField.adjustsFontForContentSizeCategory = true
      } else {
         textField.mdc_adjustsFontForContentSizeCategory = true
      }
      return textField
   }()
   
   lazy var capacityProgressView: UIProgressView = { [weak self] in
      let progressView = UIProgressView.init(frame: CGRect(x: MarginsWidth, y: (self?.deviecNameTitleTextField.bottom)! + MarginsWidth , width: __kWidth - MarginsWidth*2, height: 12))
      progressView.progress = 0
      progressView.transform = CGAffineTransform(scaleX: 1.0, y: 8.0)
      //设置进度条颜色和圆角
      progressView.setRadiusTrackColor(UIColor.white.withAlphaComponent(0.12), progressColor: UIColor.colorFromRGB(rgbValue: 0x04db6ac))
      return progressView
      }()
   
   lazy var capacityProgressBackgroudView: UIView = { [weak self] in
      let progressView = UIView.init(frame: CGRect(x: MarginsWidth, y: (self?.deviecNameTitleTextField.bottom)! + MarginsWidth , width: __kWidth - MarginsWidth*2, height: 24))
      progressView.layer.cornerRadius = 4
      progressView.clipsToBounds = true
      progressView.backgroundColor = UIColor.colorFromRGB(rgbValue: 0x0eceff1)
      progressView.addSubview((self?.capacityFilesProgressView)!)
      progressView.addSubview((self?.capacityPhotoProgressView)!)
      progressView.addSubview((self?.capacityAudioProgressView)!)
      progressView.addSubview((self?.capacityVideoProgressView)!)
      progressView.addSubview((self?.capacityOtherProgressView)!)
      return progressView
      }()
   
   lazy var capacityLabel: UILabel = { [weak self] in
      let label = UILabel.init()
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
   
   lazy var capacityAudioProgressView: UIView = {
      let progressView = UIView.init()
      progressView.backgroundColor = UIColor.red
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
   
   lazy var capacityAudioLegendView: UIView = {
      let view = UIView.init()
      view.layer.cornerRadius = 2
      view.clipsToBounds = true
      view.backgroundColor = UIColor.red
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
   
   lazy var capacityAudioLegendLabel: UILabel = {
      let label = UILabel.init()
      label.text = LocalizedString(forKey: "音乐")
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
   
   lazy var capacityLegendView: UIView = { [weak self] in
      let view = UIView.init(frame: CGRect(x: MarginsWidth, y: (self?.capacityProgressBackgroudView.bottom)!, width:(self?.capacityProgressBackgroudView.width)!, height: MarginsCloseWidth + legendHeight))
      view.addSubview(capacityFilesLegendView)
      view.addSubview(capacityFilesLegendLabel)
      view.addSubview(capacityPhotoLegendView)
      view.addSubview(capacityPhotoLegendLabel)
      view.addSubview(capacityAudioLegendView)
      view.addSubview(capacityAudioLegendLabel)
      view.addSubview(capacityVideoLegendView)
      view.addSubview(capacityVideoLegendLabel)
      view.addSubview(capacityOtherLegendView)
      view.addSubview(capacityOtherLegendLabel)
      return view
   }()
   
   lazy var storageInfoView: UIView = { [weak self] in
      let height:CGFloat = 40
      let rightImageViewWidth:CGFloat = 24
      let view = UIView.init(frame: CGRect(x: 0, y: (self?.capacityLegendView.bottom)! + 21, width: __kWidth, height: height))
      let label = UILabel.init(frame: CGRect(x: MarginsWidth, y: 0, width: __kWidth - MarginsWidth - rightImageViewWidth - 5, height: height))
      label.text = LocalizedString(forKey: "设备运行健康，存储详情查看")
      label.textColor = DarkGrayColor
      label.font = UIFont.systemFont(ofSize: 14)
      view.addSubview(label)
      let imageView = UIImageView.init(frame: CGRect(x: __kWidth - rightImageViewWidth - MarginsWidth + 4, y: view.height/2 - rightImageViewWidth/2, width: rightImageViewWidth, height: rightImageViewWidth))
      imageView.image = UIImage.init(named: "cell_arrow.png")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
      imageView.tintColor = LightGrayColor
      view.addSubview(imageView)
      let tapGestrue = UITapGestureRecognizer.init(target: self, action: #selector(deviceInfoTap(_:)))
      view.isUserInteractionEnabled = true
      view.addGestureRecognizer(tapGestrue)
      return view
   }()
}

extension DeviceViewController:UITableViewDataSource,UITableViewDelegate{
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      if self.state == .editing{
         return 0
      }else{
         return 3
      }
   }
   
   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return 64
   }
   
   func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      return headerHeight
   }
   
   func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      headerView.addSubview(deviecNameTitleTextField)
      headerView.addSubview(capacityProgressBackgroudView)
      headerView.addSubview(capacityLabel)
      headerView.addSubview(capacityLegendView)
      headerView.addSubview(storageInfoView)
      setHeaderLegendFrame()
      return headerView
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
      
      switch indexPath.row {
      case 0:
         cell.accessoryType = .disclosureIndicator
         cell.textLabel?.text = LocalizedString(forKey: "备份")
//      case 1:
//         cell.accessoryType = .disclosureIndicator
//         cell.textLabel?.text = LocalizedString(forKey: "USB")
      case 1:
         cell.accessoryType = .disclosureIndicator
         cell.textLabel?.text = LocalizedString(forKey: "网络")
      case 2:
         cell.accessoryType = .disclosureIndicator
         cell.textLabel?.text = LocalizedString(forKey: "高级")
      default:
         break
      }
      cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
      cell.textLabel?.textColor = DarkGrayColor
      return cell
   }
   
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      tableView.deselectRow(at: indexPath, animated: true)
      switch indexPath.row {
      case 0:
         let deviceBackupRootViewController = DeviceBackupRootViewController.init(style:.highHeight,type:.device)
         let tab = retrieveTabbarController()
         tab?.setTabBarHidden(true, animated: true)
         self.navigationController?.pushViewController(deviceBackupRootViewController, animated: true)
//      case 1:
//         let peripheralDeviceViewController = DevicePeripheralDeviceViewController.init(style:.highHeight)
//         let tab = retrieveTabbarController()
//         tab?.setTabBarHidden(true, animated: true)
//         self.navigationController?.pushViewController(peripheralDeviceViewController, animated: true)
      case 1:
         let networkSettingViewController = DeviceNetworkSettingViewController.init(style:.highHeight)
         let tab = retrieveTabbarController()
         tab?.setTabBarHidden(true, animated: true)
         self.navigationController?.pushViewController(networkSettingViewController, animated: true)
      case 2:
         let advancedSettingViewController = DeviceAdvancedSettingViewController.init(style:.highHeight)
         let tab = retrieveTabbarController()
         tab?.setTabBarHidden(true, animated: true)
         self.navigationController?.pushViewController(advancedSettingViewController, animated: true)
      
      default:
         break
      }
   }
}

