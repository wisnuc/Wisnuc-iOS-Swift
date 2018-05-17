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

private let cellIdentifier = "Identifier"
private let headerHeight:CGFloat = 48.0
private let chipsWidth:CGFloat = 110.0
private let chipsHeight:CGFloat = 36.0
class SearchFilesViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(mainTableView)
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appBar.navigationBar.addSubview(searchTextField)
        appBar.headerViewController.headerView.trackingScrollView = self.mainTableView
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func clearButtonTap(_ sender:UIButton){
      searchTextField.text = nil
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
        textField.rightView = clearButton
//        textField.backgroundColor = UIColor.cyan
        return textField
    }()
    
    lazy var mainTableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect(x: 0, y: 0, width: __kWidth, height: __kHeight))
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
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
    
   
    

}

extension SearchFilesViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.textColor = DarkGrayColor
        cell.textLabel?.font = BoldMiddlePlusTitleFont
        cell.indentationLevel = 1
        cell.indentationWidth = 16
        switch indexPath.row {
        case 0:
            cell.imageView?.image = UIImage.init(named: "files_pdf.png")
            cell.textLabel?.text = LocalizedString(forKey: "PDFs")
        case 1:
            cell.imageView?.image = UIImage.init(named: "files_word_small.png")
            cell.textLabel?.text = LocalizedString(forKey: "Word")
        case 2:
            cell.imageView?.image = UIImage.init(named: "files_excel.png")
            cell.textLabel?.text = LocalizedString(forKey: "Excel")
        case 3:
            cell.imageView?.image = UIImage.init(named: "files_ppt_small.png")
            cell.textLabel?.text = LocalizedString(forKey: "PPT")
        case 4:
            cell.imageView?.image = UIImage.init(named: "files_photo_imges.png")
            cell.textLabel?.text = LocalizedString(forKey: "Photos & Images")
        case 5:
            cell.imageView?.image = UIImage.init(named: "files_video.png")
            cell.textLabel?.text = LocalizedString(forKey: "video")
        case 6:
            cell.imageView?.image = UIImage.init(named: "files_audio.png")
            cell.textLabel?.text = LocalizedString(forKey: "Audio")
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch  indexPath.row{
        case 0:
            headerViewTitleLabel.removeFromSuperview()
//            chips.imageView.image = UIImage.init(named: "files_pdf.png")
//            chips.titleLabel.text = LocalizedString(forKey: "PPT")
//            chips.showde
//            headerView.addSubview(chips)
            mainTableView.reloadData()
        default:
            break
        }
    }
}

//class ChipsView: UIView {
//    lazy var chips: uiv = {
//        let chip = MDCChipView.init(frame: CGRect(x: 0, y: 0, width: 111, height: 36))
//        return chip
//    }()
//}
