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
   var inputTextFieldController:MDCTextInputControllerUnderline?
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
   let headerHeight:CGFloat = 165
   override func viewDidLoad() {
      super.viewDidLoad()

      self.view.addSubview(deviceTableView)
      
      self.view.bringSubview(toFront: appBar.headerViewController.headerView)
      
      deviecNameTitleTextField.text = "Wisnuc office"
      capacityLabel.text = "123GB / 4TB"
      self.state = .normal
     
      // Do any additional setup after loading the view.
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      appBar.headerViewController.headerView.trackingScrollView = self.deviceTableView
      let tab = retrieveTabbarController()
      tab?.setTabBarHidden(false, animated: true)
   }
   
   func setTextFieldNormal(){
      appBar.headerViewController.headerView.backgroundColor = .white
      appBar.navigationBar.backgroundColor = .white
      appBar.headerStackView.backgroundColor = .white
      appBar.navigationBar.titleTextColor = .black
      appBar.headerViewController.preferredStatusBarStyle = .default
      appBar.headerViewController.setNeedsStatusBarAppearanceUpdate()
      prepareRightNavigation()
       self.navigationItem.leftBarButtonItem = nil
      deviecNameTitleTextField.isEnabled = false
      capacityProgressView.isHidden = false
      capacityLabel.isHidden = false
      self.inputTextFieldController  = nil
      self.inputTextFieldController = MDCTextInputControllerUnderline.init(textInput: deviecNameTitleTextField)
      self.inputTextFieldController?.isFloatingEnabled = false
      self.inputTextFieldController?.normalColor = .white
      self.inputTextFieldController?.disabledColor = COR1
      self.inputTextFieldController?.underlineViewMode = .never
      self.inputTextFieldController?.activeColor = COR3
      self.view.endEditing(true)
      
      let tab = retrieveTabbarController()
      tab?.setTabBarHidden(false, animated: true)
      
      deviceTableView.backgroundColor = .white
      deviceTableView.reloadData()
   }
   
   
   func setTextFieldEditing(){
      appBar.headerViewController.headerView.backgroundColor = COR1
      appBar.navigationBar.backgroundColor = COR1
      appBar.headerStackView.backgroundColor = COR1
      appBar.navigationBar.titleTextColor = COR1
      appBar.headerViewController.preferredStatusBarStyle = .lightContent
      appBar.headerViewController.setNeedsStatusBarAppearanceUpdate()
      prepareLeftNavigation()
      self.navigationItem.rightBarButtonItems = nil
      deviecNameTitleTextField.isEnabled = true
      capacityProgressView.isHidden = true
      capacityLabel.isHidden = true
      self.inputTextFieldController  = nil
      self.inputTextFieldController = MDCTextInputControllerUnderline.init(textInput: deviecNameTitleTextField)

      self.inputTextFieldController?.isFloatingEnabled = false
      self.inputTextFieldController?.activeColor = .white
      deviecNameTitleTextField.becomeFirstResponder()
      let tab = retrieveTabbarController()
      tab?.setTabBarHidden(true, animated: true)
      
      deviceTableView.backgroundColor = COR1
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
      let editingConfirmBarButtonItem = UIBarButtonItem.init(image: MDCIcons.imageFor_ic_check()?.byTintColor(.white), style: UIBarButtonItemStyle.plain, target: self, action: #selector(editingConfirmBarButtonItemTap(_ :)))
    
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
       self.state = .editing
   }
   
   
   @objc func changeBarButtonItemTap(_ sender:UIBarButtonItem){
      let changeDeviceVC = DeviceChangeDeviceViewController.init(style: NavigationStyle.white)
      let navigationController = UINavigationController.init(rootViewController: changeDeviceVC)
      self.present(navigationController, animated: true) {
         
      }
   }
   
   @objc func editingConfirmBarButtonItemTap(_ sender:UIBarButtonItem){
      self.state = .normal
   }
   
   @objc func deviceInfoTap(_ sender:UIGestureRecognizer){
      let deviceInfoViewController = DeviceDetailInfoViewController.init(style: .whiteWithoutShadow)
      let navigationController = UINavigationController.init(rootViewController: deviceInfoViewController)
      self.present(navigationController, animated: true) {
         
      }
//
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
      view.backgroundColor = COR1
      view.isUserInteractionEnabled = true
      let tapGestrue = UITapGestureRecognizer.init(target: self, action: #selector(deviceInfoTap(_:)))
      view.addGestureRecognizer(tapGestrue)
      return view
   }()
   
   lazy var deviecNameTitleTextField: MDCTextField = {
      let textField = MDCTextField.init(frame: CGRect(x:MarginsWidth , y:20 , width: __kWidth - MarginsWidth*2, height: 60))
      textField.textColor = .white
      textField.clearButtonMode = .whileEditing
      textField.font = UIFont.boldSystemFont(ofSize: 34)
      if #available(iOS 10.0, *) {
         textField.adjustsFontForContentSizeCategory = true
      } else {
         textField.mdc_adjustsFontForContentSizeCategory = true
      }
      return textField
   }()
   
   lazy var capacityProgressView: UIProgressView = { [weak self] in
      let progressView = UIProgressView.init(frame: CGRect(x: MarginsWidth, y: (self?.deviecNameTitleTextField.bottom)! + MarginsWidth , width: __kWidth - MarginsWidth*2, height: 12))
      progressView.progress = 0.4
      progressView.transform = CGAffineTransform(scaleX: 1.0, y: 8.0)
      //设置进度条颜色和圆角
      progressView.setRadiusTrackColor(UIColor.white.withAlphaComponent(0.12), progressColor: UIColor.colorFromRGB(rgbValue: 0x04db6ac))
      return progressView
      }()
   
   lazy var capacityLabel: UILabel = { [weak self] in
      let label = UILabel.init(frame: CGRect(x:MarginsWidth , y:(self?.capacityProgressView.bottom)! + 10, width: __kWidth - MarginsWidth*2, height: 14))
      label.textColor = UIColor.white.withAlphaComponent(0.87)
      label.font = UIFont.boldSystemFont(ofSize: 14)
      
      return label
      }()
}

extension DeviceViewController:UITableViewDataSource,UITableViewDelegate{
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      if self.state == .editing{
         return 0
      }else{
         return 4
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
      headerView.addSubview(capacityProgressView)
      headerView.addSubview(capacityLabel)
      return headerView
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
      
      switch indexPath.row {
      case 0:
         cell.accessoryType = .disclosureIndicator
         cell.textLabel?.text = LocalizedString(forKey: "备份")
      case 1:
         cell.accessoryType = .disclosureIndicator
         cell.textLabel?.text = LocalizedString(forKey: "USB")
      case 2:
         cell.accessoryType = .disclosureIndicator
         cell.textLabel?.text = LocalizedString(forKey: "网络")
      case 3:
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
         let deviceBackupRootViewController = DeviceBackupRootViewController.init(style:.highHeight)
         let tab = retrieveTabbarController()
         tab?.setTabBarHidden(true, animated: true)
         self.navigationController?.pushViewController(deviceBackupRootViewController, animated: true)
      case 1:
         let peripheralDeviceViewController = DevicePeripheralDeviceViewController.init(style:.highHeight)
         let tab = retrieveTabbarController()
         tab?.setTabBarHidden(true, animated: true)
         self.navigationController?.pushViewController(peripheralDeviceViewController, animated: true)
      case 2:
         let networkSettingViewController = DeviceNetworkSettingViewController.init(style:.highHeight)
         let tab = retrieveTabbarController()
         tab?.setTabBarHidden(true, animated: true)
         self.navigationController?.pushViewController(networkSettingViewController, animated: true)
      case 3:
         let advancedSettingViewController = DeviceAdvancedSettingViewController.init(style:.highHeight)
         let tab = retrieveTabbarController()
         tab?.setTabBarHidden(true, animated: true)
         self.navigationController?.pushViewController(advancedSettingViewController, animated: true)
      
      default:
         break
      }
   }
}

