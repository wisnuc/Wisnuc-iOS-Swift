//
//  DeviceViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/15.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit
import Material

class DeviceViewController: BaseViewController {
   let identifier = "cellIdentifier"
   let headerHeight:CGFloat = 165
   override func viewDidLoad() {
      super.viewDidLoad()
      prepareNavigation()
      self.view.addSubview(deviceTableView)
      
      self.view.bringSubview(toFront: appBar.headerViewController.headerView)
      
      deviecNameTitleLabel.text = "Wisnuc office"
      capacityLabel.text = "123GB / 4TB"
      
      // Do any additional setup after loading the view.
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      appBar.headerViewController.headerView.trackingScrollView = self.deviceTableView
      let tab = retrieveTabbarController()
      tab?.setTabBarHidden(false, animated: true)
   }
   
   func prepareNavigation(){
      let addBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "add_gray.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(addBarButtonItemTap(_ :)))
      let editBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "edit_gray.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(editBarButtonItemTap(_ :)))
      let changeBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "exchange_gray.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(changeBarButtonItemTap(_ :)))
      self.navigationItem.rightBarButtonItems = [changeBarButtonItem,editBarButtonItem,addBarButtonItem]
   }
   
   @objc func addBarButtonItemTap(_ sender:UIBarButtonItem){
      
   }
   
   @objc func editBarButtonItemTap(_ sender:UIBarButtonItem){
      
   }
   
   @objc func changeBarButtonItemTap(_ sender:UIBarButtonItem){
      let changeDeviceVC = DeviceChangeDeviceViewController.init(style: NavigationStyle.white)
      let navigationController = UINavigationController.init(rootViewController: changeDeviceVC)
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
      view.backgroundColor = COR1
      
      return view
   }()
   
   lazy var deviecNameTitleLabel: UILabel = {
      let label = UILabel.init(frame: CGRect(x:MarginsWidth , y:48 , width: __kWidth - MarginsWidth*2, height: 26))
      label.textColor = UIColor.white.withAlphaComponent(0.87)
      label.font = UIFont.boldSystemFont(ofSize: 28)
      return label
   }()
   
   lazy var capacityProgressView: UIProgressView = { [weak self] in
      let progressView = UIProgressView.init(frame: CGRect(x: MarginsWidth, y: (self?.deviecNameTitleLabel.bottom)! + MarginsWidth , width: __kWidth - MarginsWidth*2, height: 12))
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
      return 4
   }
   
   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return 64
   }
   
   func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      return headerHeight
   }
   
   func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      headerView.addSubview(deviecNameTitleLabel)
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
      default:
         break
      }
   }
}

