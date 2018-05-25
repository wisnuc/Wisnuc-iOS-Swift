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
    case searchEnd
    case searchingWithoutType
}


private var headerHeight:CGFloat = 48.0
private let chipsWidth:CGFloat = 110.0
private let chipsHeight:CGFloat = 36.0
class SearchFilesViewController: BaseViewController {
    private var cellIdentifier = "Identifier"
    var cellCount = 0
    var cellHeight = 0
    var dataSouce:Array<FilesModel>?
    var cellType:SearhCellType?{
        didSet{
            switch cellType{
            case .searchWill?:
                searchWillTypeAction()
            case .searchEnd?:
                searchEndTypeAction()
            case .searchingWithoutType?:
                searchingWithoutTypeTypeAction()
            default:
                break
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(mainTableView)
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
        setData()
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
    
    func setData(){
        let model1 = FilesModel.init()
        model1.name = "mj.pdf"
        let model2 = FilesModel.init()
        model2.name = "mj.pptx"
        let model3 = FilesModel.init()
        model3.name = "文档1.doc"
        dataSouce = [model1,model2,model3]
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
    }
    
    func searchEndTypeAction(){
        cellIdentifier = "EndCellIdentifier"
        self.mainTableView.register(UINib.init(nibName: StringExtension.classNameAsString(targetClass: FilesOfflineTableViewCell.self), bundle: nil), forCellReuseIdentifier: cellIdentifier)
        cellCount = (dataSouce?.count)!
        cellHeight = 64
        mainTableView.separatorInset = UIEdgeInsets(top: 0, left: 72, bottom: 0, right: 0)
        mainTableView.separatorStyle = .singleLine
        headerHeight = 48.0
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func clearButtonTap(_ sender:UIButton?){
        searchTextField.text = nil
        cellType = .searchWill
        mainTableView.reloadData()
    }
    
    @objc func goSearch(_ anyObject: AnyObject){
        if cellType != .searchEnd && (searchTextField.text?.count)!>0{
            cellType = .searchingWithoutType
        }
        
        mainTableView.reloadData()
    }
    
    @objc func textFieldTextChange(_ textField:UITextField){
        if textField.text?.count == 0 {
            if cellType != .searchEnd{
               clearButtonTap(nil)
            }
        }else{
                NSObject.cancelPreviousPerformRequests(withTarget: self)
                let subString:NSString = textField.text! as NSString
                self.perform(#selector(goSearch(_ :)), with: subString, afterDelay: 0.7)
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
        textField.rightView = clearButton
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldTextChange(_ :)), for: UIControlEvents.editingChanged)
//        textField.backgroundColor = UIColor.cyan
        return textField
    }()
    
    lazy var mainTableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect(x: 0, y: 0, width: __kWidth, height: __kHeight))
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        tableView.delegate = self
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
            cell.leftImageView.image = UIImage.init(named: "files_ppt_small.png")
            cell.detailImageView.isHidden = true
            if cell.detailImageView.isHidden {
                cell.reloadLayout()
            }
            cell.moreButton.isHidden = false
            cell.titleLabel.text = model.name
            cell.detailLabel.text = "2016.03.04 300KB"
        }else{
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
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch  indexPath.row{
        case 0:
            chipsView.imageView.image = UIImage.init(named: "files_pdf.png")
            chipsView.titleTextLabel.text = LocalizedString(forKey: "PDFs")
        case 1:
            chipsView.imageView.image = UIImage.init(named: "files_word_small.png")
            chipsView.titleTextLabel.text = LocalizedString(forKey: "Word")
        case 2:
            chipsView.imageView.image = UIImage.init(named: "files_excel.png")
            chipsView.titleTextLabel.text = LocalizedString(forKey: "Excel")
        case 3:
            chipsView.imageView.image = UIImage.init(named: "files_pdf.png")
            chipsView.titleTextLabel.text = LocalizedString(forKey: "PPT")
        case 4:
            chipsView.imageView.image = UIImage.init(named: "files_photo_imges.png")
            chipsView.titleTextLabel.text = LocalizedString(forKey: "Photos & Images")
        case 5:
            chipsView.imageView.image = UIImage.init(named: "files_video.png")
            chipsView.titleTextLabel.text = LocalizedString(forKey: "video")
        case 6:
            chipsView.imageView.image = UIImage.init(named: "files_audio.png")
            chipsView.titleTextLabel.text = LocalizedString(forKey: "Audio")
        default:
            break
        }
        
        chipsView.width = MarginsCloseWidth*3 + MarginsSoFarWidth + MarginsWidth + labelWidthFrom(title: chipsView.titleTextLabel.text!, font: chipsView.titleTextLabel.font) + 18
        headerViewTitleLabel.removeFromSuperview()
        headerView.addSubview(chipsView)
        headerView.backgroundColor = lightGrayBackgroudColor
        cellType = .searchEnd
        self.mainTableView.reloadData()
    }
}

extension SearchFilesViewController:ChipsViewDelegate{
    func closeButtonTap(_ sender: UIButton) {
        if searchTextField.text?.count == 0 {
            cellType = .searchWill
        }else{
            cellType = .searchingWithoutType
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

