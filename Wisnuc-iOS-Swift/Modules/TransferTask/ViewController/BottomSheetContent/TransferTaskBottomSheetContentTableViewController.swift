//
//  TransferTaskBottomSheetContentTableViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/17.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

@objc protocol TransferTaskBottomSheetContentVCDelegate{
   func transferTaskBottomSheettableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
}

class TransferTaskBottomSheetContentTableViewController: UITableViewController {
   weak var delegate:TransferTaskBottomSheetContentVCDelegate?
    var disables:[Int]?{
        didSet{
            tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    }
    
    init(style: UITableViewStyle,disables:[Int]?) {
        super.init(style: style)
        self.disables = disables
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.textColor = DarkGrayColor
        cell.textLabel?.font = MiddleTitleFont
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = LocalizedString(forKey: "Start all task")
            if (self.disables?.contains(0))!{
                cell.textLabel?.textColor = LightGrayColor
            }else{
                cell.textLabel?.textColor = DarkGrayColor
            }
        case 1:
            cell.textLabel?.text = LocalizedString(forKey: "Suspend all task")
            if (self.disables?.contains(1))!{
                cell.textLabel?.textColor = LightGrayColor
            }else{
                cell.textLabel?.textColor = DarkGrayColor
            }
        case 2:
            cell.textLabel?.text = LocalizedString(forKey: "Clear all task")
            if (self.disables?.contains(2))!{
                cell.textLabel?.textColor = LightGrayColor
            }else{
                cell.textLabel?.textColor = DarkGrayColor
            }
        default:
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (self.disables?.contains(indexPath.row))!{
            return
        }
      
        if let delegateOK = delegate {
            delegateOK.transferTaskBottomSheettableView(tableView, didSelectRowAt: indexPath)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

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
