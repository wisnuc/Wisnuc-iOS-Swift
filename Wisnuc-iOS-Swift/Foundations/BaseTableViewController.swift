//
//  BaseTableViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by liupeng on 2018/5/12.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents

class BaseTableViewController: UITableViewController {
    let appBar = MDCAppBar()
    override init(style: UITableViewStyle) {
        super.init(style: style)
        self.appBar.navigationBar.backgroundColor = COR1
        appBar.headerViewController.headerView.backgroundColor = COR1
        appBar.navigationBar.titleView?.backgroundColor = .white
        // Step 2: Add the headerViewController as a child.
        self.addChildViewController(appBar.headerViewController)
        //        print(appBar.headerViewController.headerView.height)
        //        let color = UIColor(white: 0.2, alpha:1)
        //        appBar.headerViewController.headerView.backgroundColor = color
        appBar.navigationBar.tintColor = UIColor.white
        appBar.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white] as [NSAttributedStringKey : Any]
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.appBar.navigationBar.backgroundColor = COR1
        appBar.headerViewController.headerView.backgroundColor = COR1
        appBar.navigationBar.titleView?.backgroundColor = .white
        // Step 2: Add the headerViewController as a child.
        self.addChildViewController(appBar.headerViewController)
        //        print(appBar.headerViewController.headerView.height)
        //        let color = UIColor(white: 0.2, alpha:1)
        //        appBar.headerViewController.headerView.backgroundColor = color
        appBar.navigationBar.tintColor = UIColor.white
        appBar.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white] as [NSAttributedStringKey : Any]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appBar.addSubviewsToParent()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override var childViewControllerForStatusBarHidden: UIViewController? {
        return appBar.headerViewController
    }
    
    // Optional step: The Header View Controller does basic inspection of the header view's background
    //                color to identify whether the status bar should be light or dark-themed.
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return appBar.headerViewController
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
