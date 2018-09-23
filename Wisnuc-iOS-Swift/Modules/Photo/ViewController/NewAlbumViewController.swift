//
//  NewAlbumViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by liupeng on 2018/9/23.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
enum NewAlbumViewControllerState {
    case normal
    case editing
}

@objc protocol NewAlbumViewControllerDelegate {
    func creatNewAlbumFinish(name:String)
}

class NewAlbumViewController: BaseViewController {
lazy var dataSource = Array<WSAsset>.init()

    weak var delegate:NewAlbumViewControllerDelegate?
    var state:NewAlbumViewControllerState?{
        didSet{
            switch state {
            case .normal?:
                nomarlStateAction()
            case .editing?:
                editingStateAction()
            default:
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    init(style: NavigationStyle,photos:Array<WSAsset>) {
        super.init(style: style)
        self.dataSource.append(contentsOf: photos)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func finishEditing(_ sender:UIBarButtonItem){
        self.state = .normal
        self.delegate?.creatNewAlbumFinish(name: "旅行")
    }
    
    func setState(_ state:NewAlbumViewControllerState){
        self.state = state
    }
    
    func editingStateAction(){
        self.style = .select
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "text_right.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(finishEditing(_:)))
    }
    
    func nomarlStateAction(){
        self.style = .whiteWithoutShadow
        self.navigationItem.leftBarButtonItem = nil
        
    }

}
