//
//  FilesMoveToRootViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/6/27.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Material
import MaterialComponents.MaterialButtons
private let moveButtonWidth:CGFloat = 64.0
private let moveButtonHeight:CGFloat = 36.0
class FilesMoveToRootViewController: BaseViewController {
    var srcDictionary: Dictionary<String, String>?
    var moveModelArray: Array<EntriesModel>?
    var isCopy:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = LocalizedString(forKey: "Select destination")
        self.view.backgroundColor = lightGrayBackgroudColor
        prepareRootAppNavigtionBar()
        self.view.addSubview(mainTableView)
        self.view.addSubview(moveFilesBottomBar)
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
        appBar.headerViewController.headerView.trackingScrollView = mainTableView
        ViewTools.automaticallyAdjustsScrollView(scrollView: mainTableView, viewController: self)
        movetoButton.isEnabled = false
        let buttonTitle = isCopy ? LocalizedString(forKey: "复制到") : LocalizedString(forKey: "移动到")
        movetoButton.setTitle(buttonTitle, for: UIControlState.normal)
        moveFilesBottomBar.addSubview(movetoButton)
        moveFilesBottomBar.addSubview(cancelMovetoButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Application.statusBarStyle = .default
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func prepareRootAppNavigtionBar(){
        let leftItem = UIBarButtonItem.init(image: Icon.close?.byTintColor(LightGrayColor), style: UIBarButtonItemStyle.done, target: self, action: #selector(closeTap(_ :)))
        self.navigationItem.leftBarButtonItems = [leftItem]
    }
    
    @objc func closeTap(_ sender:UIBarButtonItem){
        self.presentingViewController?.dismiss(animated: true) {
            
        }
    }
    
    @objc func movetoButtonTap(_ sender:MDCFlatButton){
//        let names:Array<String> = []
//        TasksAPI.init(type: FilesTasksType.move, names: <#T##Array<String>#>, srcDrive: <#T##String#>, srcDir: <#T##String#>, dstDrive: <#T##String#>, dstDir: <#T##String#>)
    }
    
    @objc func cancelMovetoButtonTap(_ sender:MDCFlatButton){
        self.presentingViewController?.dismiss(animated: true) {
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    lazy var mainTableView: UITableView = {
        let tabelView  = UITableView.init(frame: CGRect(x: 0, y: 0, width: __kWidth, height: __kHeight), style: UITableViewStyle.plain)
        tabelView.delegate = self
        tabelView.dataSource = self
        tabelView.tableHeaderView = UIView.init()
        tabelView.tableFooterView = UIView.init()
        tabelView.backgroundColor = lightGrayBackgroudColor
        return tabelView
    }()
    
    lazy var moveFilesBottomBar: UIView = {
        let height:CGFloat = 56.0
        let view = UIView.init(frame: CGRect(x: 0, y: __kHeight - height, width: __kWidth, height: height))
        view.backgroundColor = UIColor.white
        view.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        view.layer.shadowRadius = 1
        view.layer.shadowOpacity = 0.5
        view.layer.shadowColor = DarkGrayColor.cgColor
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 2
        view.clipsToBounds = false
        return view
    }()
    
    lazy var movetoButton: MDCFlatButton = {
        let button = MDCFlatButton.init(frame: CGRect(x: self.moveFilesBottomBar.width - moveButtonWidth - MarginsWidth, y: self.moveFilesBottomBar.height/2 - moveButtonHeight/2, width: moveButtonWidth, height: moveButtonHeight))

        button.setTitle(LocalizedString(forKey: "Save Here"), for: UIControlState.normal)
        button.setTitleColor(COR1, for: UIControlState.normal)
        button.setTitleColor(LightGrayColor, for: UIControlState.disabled)
        button.addTarget(self, action: #selector(movetoButtonTap(_ :)), for: UIControlEvents.touchUpInside)
        button.sizeToFit()
        button.frame = CGRect(x: self.moveFilesBottomBar.width - button.width - MarginsWidth, y: self.moveFilesBottomBar.height/2 - button.height/2, width: button.width, height: button.height)
        return button
    }()
    
    lazy var cancelMovetoButton: MDCFlatButton = {
        let button = MDCFlatButton.init(frame: CGRect(x: self.moveFilesBottomBar.width - movetoButton.left - MarginsCloseWidth, y: movetoButton.top, width: moveButtonWidth, height: moveButtonHeight))
        button.setTitle(LocalizedString(forKey: "Cancel"), for: UIControlState.normal)
        button.setTitleColor(COR1, for: UIControlState.normal)
        button.addTarget(self, action: #selector(cancelMovetoButtonTap(_ :)), for: UIControlEvents.touchUpInside)
        button.sizeToFit()
        button.frame = CGRect(x: self.moveFilesBottomBar.width - ( MarginsCloseWidth + button.width*2 + MarginsWidth), y: self.moveFilesBottomBar.height/2 - button.height/2, width: button.width, height: button.height)
        return button
    }()
}

extension FilesMoveToRootViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "reuseIdentifier"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier , for: indexPath)
        switch  indexPath.row{
        case 0:
            cell.imageView?.image = #imageLiteral(resourceName: "files_folder.png")
            cell.textLabel?.text = LocalizedString(forKey: "My Drive")
        case 1:
            cell.imageView?.image = #imageLiteral(resourceName: "files_share.png")
            cell.textLabel?.text = LocalizedString(forKey: "Share")
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch  indexPath.row{
        case 0:
            let filesRootViewController = FilesRootViewController.init(style: NavigationStyle.whiteStyle)
            filesRootViewController.title = LocalizedString(forKey: "My Drive")
            filesRootViewController.srcDictionary = srcDictionary
            filesRootViewController.moveModelArray = moveModelArray
            filesRootViewController.isCopy = isCopy
            filesRootViewController.selfState = .movecopy
            self.navigationController?.pushViewController(filesRootViewController, animated: true)
        case 1:
            break
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
}
