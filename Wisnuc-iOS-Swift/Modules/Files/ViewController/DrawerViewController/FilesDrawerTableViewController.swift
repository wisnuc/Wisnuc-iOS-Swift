//
//  FilesDrawerTableViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/11.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Material
import MaterialComponents.MaterialButtons
@objc protocol FilesDrawerViewControllerDelegate {
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
   func settingButtonTap(_ sender:UIButton)
}
private let cellReuseIdentifier = "reuseIdentifier"
private let tableViewHeaderHeight:CGFloat =  StatusBarHeight + 64 + MarginsCloseWidth
private let cellHeight:CGFloat =  48
class FilesDrawerTableViewController: UITableViewController {
    override func willDealloc() -> Bool {
        return false
    }
    var cellCount = 4
    weak var delegate:FilesDrawerViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.backgroundColor = COR1
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.tableView.separatorStyle = .none
        self.tableView.isScrollEnabled = false
        self.tableView.backgroundColor = UIColor.white
        self.view.addSubview(settingView)
        settingView.addSubview(settingButton)
//        self.tableView.contentInset = UIEdgeInsets(top: MarginsCloseWidth, left: 0, bottom: 0, right: 0)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func settingButtonTap(_ sender:UIButton){
        if let delegateOK = self.delegate{
            delegateOK.settingButtonTap(sender)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cellCount
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        cell.indentationLevel = 2
        cell.indentationWidth = 12
        cell.textLabel?.textColor = DarkGrayColor
        cell.textLabel?.font = MiddleTitleFont
        switch indexPath.row {
        case 0:
            cell.imageView?.image = UIImage.init(named: "transfer.png")
            cell.textLabel?.text = LocalizedString(forKey:"files_transfer")
        case 1:
            cell.imageView?.image = UIImage.init(named: "files_share_folder.png")
            cell.textLabel?.text = LocalizedString(forKey:"files_share_folder")
        case 2:
            cell.imageView?.image = UIImage.init(named: "files_offline_file.png")
            cell.textLabel?.text = LocalizedString(forKey:"files_offline_file")
        case 3:
            cell.imageView?.image = UIImage.init(named: "files_tag.png")
            cell.textLabel?.text = LocalizedString(forKey:"files_tag")
        default:
            break
        }
        return cell
    }
  
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         return tableViewHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let bgView = UIView.init()
        let titleLabel = UILabel.init(frame: CGRect(x: MarginsWidth, y: StatusBarHeight, width: self.tableView.width-MarginsWidth*2 , height: tableViewHeaderHeight - StatusBarHeight-MarginsCloseWidth-1))
        titleLabel.text = LocalizedString(forKey: "files")
        titleLabel.textColor = DarkGrayColor
        titleLabel.font = BigTitleFont
        let lineView = UIView.init(frame: CGRect(x: 0, y: titleLabel.bottom+1, width: self.tableView.width, height: 1))
        lineView.backgroundColor = Gray12Color
        bgView.addSubview(titleLabel)
        bgView.addSubview(lineView)
        return bgView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let delegateOK = self.delegate {
            delegateOK.tableView(tableView, didSelectRowAt: indexPath)
        }
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    lazy var settingView: UIView = {
        let height:CGFloat = 56.0
        let view = UIView.init(frame: CGRect(x: 0, y: __kHeight - height, width: self.view.width, height: height))
        view.backgroundColor = UIColor.white
        view.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        view.layer.shadowRadius = 1
        view.layer.shadowOpacity = 0.5
        view.layer.shadowColor = DarkGrayColor.cgColor
        view.layer.masksToBounds = true
        view.clipsToBounds = false
        return view
    }()
    
    lazy var settingButton: UIButton = {
        let height:CGFloat = 24.0
        let button = UIButton.init(frame: CGRect(x: (self.navigationDrawerController?.leftViewWidth)! - MarginsWidth - height, y: settingView.height/2 - height/2, width: height, height: height))
        button.setImage(UIImage.init(named: "setting_gray"), for: UIControlState.normal)
        button.addTarget(self, action: #selector(settingButtonTap(_ :)), for: UIControlEvents.touchUpInside)
        return button
    }()
    

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
