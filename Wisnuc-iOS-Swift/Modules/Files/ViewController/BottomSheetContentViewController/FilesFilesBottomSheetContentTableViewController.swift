//
//  FilesFilesBottomSheetContentTableViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/15.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

@objc protocol FilesBottomSheetContentVCDelegate{
    func filesBottomSheetContentTableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    func filesBottomSheetContentInfoButtonTap(_ sender:UIButton)
}
private let cellReuseIdentifier = "reuseIdentifier"
private let headerHeight:CGFloat = 56 + 8
class FilesFilesBottomSheetContentTableViewController: UITableViewController {
    weak var delegate:FilesBottomSheetContentVCDelegate?
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setData()
        self.tableView.register(UINib.init(nibName: "FilsBottomSheetTableViewCell", bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
        self.tableView.separatorStyle = .none
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func setData(){
        self.headerTitleLabel.text = "未命名文件.pdf"
        self.headerImageView.image = UIImage.init(named: "files_ppt_small.png")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func headerRightButtonTap(_ sender:UIButton){
        if let delegateOK = self.delegate {
            delegateOK.filesBottomSheetContentInfoButtonTap(sender)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 9
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:FilsBottomSheetTableViewCell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! FilsBottomSheetTableViewCell
        switch indexPath.row {
        case 0:
            cell.leftImageView.image = UIImage.init(named: "files_edit.png")
            cell.titleLabel.text = LocalizedString(forKey: "Rename")
            cell.mainSwitch.isHidden = true
        case 1:
            cell.leftImageView.image = UIImage.init(named: "files_move_gray.png")
            cell.titleLabel.text = LocalizedString(forKey: "Move to...")
            cell.mainSwitch.isHidden = true
        case 2:
            cell.leftImageView.image = UIImage.init(named: "files_offline_normal.png")
            cell.titleLabel.text = LocalizedString(forKey: "Offline available")
            cell.mainSwitch.isHidden = false
        case 3:
            cell.leftImageView.image = UIImage.init(named: "files_share_other_app.png")
            cell.titleLabel.text = LocalizedString(forKey: "Open with other apps")
            cell.mainSwitch.isHidden = true
        case 4:
            cell.leftImageView.image = UIImage.init(named: "files_creat_copy.png")
            cell.titleLabel.text = LocalizedString(forKey: "Create a copy")
            cell.mainSwitch.isHidden = true
        case 5:
            cell.leftImageView.image = UIImage.init(named: "files_edit_tag.png")
            cell.titleLabel.text = LocalizedString(forKey: "Edit tag")
            cell.mainSwitch.isHidden = true
        case 6:
            cell.leftImageView.image = UIImage.init(named: "files_share.png")
            cell.titleLabel.text = LocalizedString(forKey: "Share to shared folder")
            cell.mainSwitch.isHidden = true
        case 7:
            cell.leftImageView.image = UIImage.init(named: "files_copy_to.png")
            cell.titleLabel.text = LocalizedString(forKey: "Copy to...")
            cell.mainSwitch.isHidden = true
        case 8:
            cell.leftImageView.image = UIImage.init(named: "files_remove.png")
            cell.titleLabel.text = LocalizedString(forKey: "Remove")
            cell.mainSwitch.isHidden = true
        default:
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init()
        view.addSubview(headerImageView)
        view.addSubview(headerTitleLabel)
        view.addSubview(lineView)
        view.addSubview(headerRightButton)
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init()
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let delegateOK = self.delegate {
            delegateOK.filesBottomSheetContentTableView(tableView, didSelectRowAt: indexPath)
        }
    }

    lazy var headerImageView: UIImageView = {
        let imageView = UIImageView.init(frame: CGRect(x: MarginsWidth, y: (headerHeight - 8)/2 - 24/2, width: 24, height: 24))
        return imageView
    }()

    lazy var headerTitleLabel: UILabel = {
        let label = UILabel.init(frame:CGRect(x: headerImageView.right + MarginsWidth*2, y: (headerHeight - 8)/2 - 20/2, width: self.tableView.width - 24 - MarginsWidth*2 , height: 20))
        label.textColor = DarkGrayColor
        label.font = MiddleTitleFont
        return label
    }()
    
    lazy var lineView: UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: headerHeight - 8, width: tableView.width, height: 1))
        view.backgroundColor = lightGrayBackgroudColor
        return view
    }()
    
    lazy var headerRightButton: UIButton = {
        let button = UIButton.init(frame: CGRect(x: tableView.width - 24 - MarginsWidth, y: (headerHeight - 8)/2 - 24/2, width: 24, height: 24))
        button.setImage(UIImage.init(named: "files_info.png"), for: UIControlState.normal)
        button.addTarget(self, action: #selector(headerRightButtonTap(_ :)), for: UIControlEvents.touchUpInside)
        return button
    }()
}
