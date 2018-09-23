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
    case mainTheme = 0
    case white
    case whiteWithoutShadow
    case imagery
    case select
}
class BaseViewController: UIViewController {
    
    var style:NavigationStyle?{
        didSet{
            switch style {
            case .mainTheme?:
                defaultStyleAction()
            case .white?:
                whiteStyleAction()
            case .whiteWithoutShadow?:
                whiteWithoutShadowStyleAction()
            case .imagery?:
                imageryStyleAction()
            case .select?:
                selectStyleAction()
            default:
                break
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .default
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.addChildViewController(appBar.headerViewController)
        setNaviStyle(style:.mainTheme)
    }
    
    init(style:NavigationStyle) {
        super.init(nibName: nil, bundle: nil)
        self.addChildViewController(appBar.headerViewController)
        setNaviStyle(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setNaviStyle(style:NavigationStyle){
        self.style = style
    }
    
    func defaultStyleAction(){
        appBar.navigationBar.backgroundColor = COR1
        appBar.headerViewController.headerView.backgroundColor = COR1
        appBar.navigationBar.titleView?.backgroundColor = .white
        appBar.navigationBar.tintColor = UIColor.white
        appBar.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white] as [NSAttributedStringKey : Any]
        appBar.headerViewController.inferPreferredStatusBarStyle = false
        appBar.headerViewController.preferredStatusBarStyle = .lightContent
        appBar.headerViewController.setNeedsStatusBarAppearanceUpdate()
    }
    
    func whiteStyleAction(){
        appBar.headerViewController.headerView.backgroundColor = .white
        appBar.navigationBar.backgroundColor = .white
        appBar.headerStackView.backgroundColor = .white
        let shadowLayer = CALayer.init()
        shadowLayer.shadowOffset = CGSize(width: 0.5, height: 1)
        shadowLayer.shadowRadius = 1
        shadowLayer.shadowOpacity = 0.3
        shadowLayer.shadowColor = DarkGrayColor.cgColor
        shadowLayer.masksToBounds = true
        shadowLayer.cornerRadius = 2
//        appBar.navigationBar.layer.setLayerShadow(DarkGrayColor, offset: shadowLayer.shadowOffset, radius: shadowLayer.shadowRadius)
        appBar.headerViewController.headerView.setLayerShadow(DarkGrayColor, offset: shadowLayer.shadowOffset, radius: shadowLayer.shadowRadius)
        appBar.headerViewController.headerView.layer.shadowOpacity = shadowLayer.shadowOpacity
        self.appBar.navigationBar.tintColor = LightGrayColor
        self.appBar.headerViewController.headerView.tintColor = LightGrayColor
        self.appBar.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:DarkGrayColor]
        appBar.headerViewController.inferPreferredStatusBarStyle = false
        appBar.headerViewController.preferredStatusBarStyle = .default
        appBar.headerViewController.setNeedsStatusBarAppearanceUpdate()
    }
    
    func whiteWithoutShadowStyleAction(){
        appBar.headerViewController.headerView.backgroundColor = .white
        appBar.navigationBar.backgroundColor = .white
        appBar.headerStackView.backgroundColor = .white
        self.appBar.navigationBar.tintColor = LightGrayColor
        self.appBar.headerViewController.headerView.tintColor = LightGrayColor
        self.appBar.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:DarkGrayColor]
        appBar.headerViewController.inferPreferredStatusBarStyle = false
        appBar.headerViewController.preferredStatusBarStyle = .default
        appBar.headerViewController.setNeedsStatusBarAppearanceUpdate()
    }
    
    func imageryStyleAction(){
        let headerView = appBar.headerViewController.headerView
        appBar.navigationBar.tintColor = UIColor.white
        // Create our custom image view and add it to the header view.
        let imageView = UIImageView(image: self.headerBackgroundImage())
        imageView.frame = headerView.bounds
        
        // Ensure that the image view resizes in reaction to the header view bounds changing.
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Ensure that the image view is below other App Bar views (headerStackView).
        headerView.insertSubview(imageView, at: 0)
        
        // Scales up the image while the header is over-extending.
        imageView.contentMode = .scaleAspectFill
        
        // The header view does not clip to bounds by default so we ensure that the image is clipped.
        imageView.clipsToBounds = true
        
        MDCAppBarColorThemer.apply(appDelegate.colorScheme, to: appBar)

        // Make sure navigation bar background color is clear so the image view is visible.
        appBar.navigationBar.backgroundColor = UIColor.clear
        
        // Allow the header to show more of the image.
        headerView.maximumHeight = 160
        appBar.navigationBar.titleTextColor = UIColor.white
    }
    
    func selectStyleAction(){
        appBar.navigationBar.backgroundColor = COR3
        appBar.headerViewController.headerView.backgroundColor = COR3
        appBar.navigationBar.titleView?.backgroundColor = .white
        appBar.navigationBar.tintColor = UIColor.white
        appBar.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white] as [NSAttributedStringKey : Any]
        appBar.headerViewController.inferPreferredStatusBarStyle = false
        appBar.headerViewController.preferredStatusBarStyle = .lightContent
        appBar.headerViewController.setNeedsStatusBarAppearanceUpdate()
    }
    
    func setStatusBar(_ statusBarStyle:UIStatusBarStyle){
        appBar.headerViewController.inferPreferredStatusBarStyle = false
        appBar.headerViewController.preferredStatusBarStyle = statusBarStyle
        appBar.headerViewController.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appBar.addSubviewsToParent()
        appBar.navigationBar.titleAlignment = .leading
        self.view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        
    }
    
    func didBackAction(sel:Selector){
        appBar.navigationBar.backItem?.action = sel
    }
    
    func headerBackgroundImage() -> UIImage {
        let image = UIImage.init(named: "mdc_theme.png")
        return image!
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
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    lazy var appBar:MDCAppBar = {
        let mdcAppBar = MDCAppBar()
        return mdcAppBar
    }()

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
