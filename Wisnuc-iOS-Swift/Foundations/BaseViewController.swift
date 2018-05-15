//
//  BaseViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/18.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents
enum NavigationStyle:Int{
    case defaultStyle = 0
    case whiteStyle
    
}
class BaseViewController: UIViewController {
    let appBar = MDCAppBar()
    var style:NavigationStyle?{
        didSet{
            switch style {
            case .defaultStyle?:
                defaultStyleAction()
            case .whiteStyle?:
                whiteStyleAction()
            default:
                break
            }
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setNaviStyle()
        self.addChildViewController(appBar.headerViewController)
    }
    
    init(style:NavigationStyle) {
        super.init(nibName: nil, bundle: nil)
        setNaviStyle(style: style)
        self.addChildViewController(appBar.headerViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setNaviStyle(style:NavigationStyle){
        self.style = style
    }
    
    func setNaviStyle(){
        style = .defaultStyle
    }
    
    func defaultStyleAction(){
        appBar.navigationBar.backgroundColor = COR1
        appBar.headerViewController.headerView.backgroundColor = COR1
        appBar.navigationBar.titleView?.backgroundColor = .white
        appBar.navigationBar.titleAlignment = .leading
        appBar.navigationBar.tintColor = UIColor.white
        appBar.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white] as [NSAttributedStringKey : Any]
    }
    
    func whiteStyleAction(){
        appBar.headerViewController.headerView.backgroundColor = .white
        appBar.navigationBar.backgroundColor = .white
        appBar.headerStackView.backgroundColor = .white
        let shadowLayer = CALayer.init()
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOffset = CGSize(width: 2, height: 4)
        shadowLayer.shadowRadius = 2
        appBar.headerViewController.headerView.setShadowLayer(MDCShadowLayer.init(layer: shadowLayer)) { (layer, intensity) in
            let shadowLayer = layer as? MDCShadowLayer
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            shadowLayer!.elevation = ShadowElevation(intensity * ShadowElevation.appBar.rawValue)
            CATransaction.commit()
        }
        appBar.headerViewController.headerView.clipsToBounds  = false
        self.appBar.navigationBar.tintColor = LightGrayColor
        self.appBar.headerViewController.headerView.tintColor = LightGrayColor
        self.appBar.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:DarkGrayColor]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appBar.addSubviewsToParent()
        self.view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
    }
    
    
    override var childViewControllerForStatusBarHidden: UIViewController? {
        return appBar.headerViewController
    }
    
    // Optional step: The Header View Controller does basic inspection of the header view's background
    //                color to identify whether the status bar should be light or dark-themed.
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return appBar.headerViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
