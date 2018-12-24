//
//  BaseViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/18.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents
import MaterialComponents.MDCActivityIndicator
enum NavigationStyle:Int{
    case mainTheme = 0
    case white
    case whiteWithoutShadow
    case black
    case imagery
    case select
    case highHeight
}

class BaseViewController: UIViewController {
    var barMaximumHeight:CGFloat = kStatusBarHeight + 116
  
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
            case .black?:
                blackStyleAction()
            case .highHeight?:
                whiteHighHeightStyleAction()
            default:
                break
            }
        }
    }
    
    var largeTitle:String?{
        didSet{
            largeTitleLabel.text = largeTitle
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
    
    func whiteHighHeightStyleAction(){
        appBar.headerViewController.headerView.backgroundColor = .white
        appBar.navigationBar.backgroundColor = .white
        appBar.headerStackView.backgroundColor = .white
        self.appBar.navigationBar.tintColor = LightGrayColor
        self.appBar.headerViewController.headerView.tintColor = LightGrayColor
        self.appBar.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:DarkGrayColor]
        appBar.headerViewController.inferPreferredStatusBarStyle = false
        appBar.headerViewController.preferredStatusBarStyle = .default
        appBar.headerViewController.setNeedsStatusBarAppearanceUpdate()
        appBar.headerViewController.headerView.minimumHeight = MDCAppNavigationBarHeight
        appBar.headerViewController.headerView.maximumHeight = barMaximumHeight
        appBar.headerStackView.addSubview(self.largeTitleLabel)
        self.appBar.headerViewController.headerView.delegate = self
    }
    
    func blackStyleAction(){
        appBar.headerViewController.headerView.backgroundColor = .black
        appBar.navigationBar.backgroundColor = .black
        appBar.headerStackView.backgroundColor = .black
        self.appBar.navigationBar.tintColor = .white
        self.appBar.headerViewController.headerView.tintColor = .white
        self.appBar.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        appBar.headerViewController.inferPreferredStatusBarStyle = false
        appBar.headerViewController.preferredStatusBarStyle = .lightContent
        appBar.headerViewController.setNeedsStatusBarAppearanceUpdate()
    }
    
    func imageryStyleAction(){
        let headerView = appBar.headerViewController.headerView
        appBar.navigationBar.tintColor = UIColor.white
        // Create our custom image view and add it to the header view.
        
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
    
    func headerBackgroundImage(image:UIImage) -> UIImage?{
        let image = image
        return image
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
    
    lazy var imageView:UIImageView = {
       let innerImageView = UIImageView(image: UIImage.init(named: "mdc_theme.png"))
        return innerImageView
    }()
    
    lazy var largeTitleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect(x: MarginsWidth, y: barMaximumHeight - 20 - kStatusBarHeight - 20, width: __kWidth - MarginsWidth*2, height: 20))
        label.textColor = DarkGrayColor
        label.font = UIFont.boldSystemFont(ofSize: 21)
        return label
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

extension BaseViewController:MDCFlexibleHeaderViewDelegate{
    func flexibleHeaderViewNeedsStatusBarAppearanceUpdate(_ headerView: MDCFlexibleHeaderView) {
        
    }
    
    func flexibleHeaderViewFrameDidChange(_ headerView: MDCFlexibleHeaderView) {
        //       print(headerView.bottom)

        let viewOriginY:CGFloat = barMaximumHeight - 20 - kStatusBarHeight - 20
        let viewOriginX:CGFloat = MarginsWidth
//        print(headerView.bottom - headerView.maximumHeight)
        if headerView.maximumHeight > headerView.bottom{
            self.largeTitleLabel.origin.y = viewOriginY + (headerView.bottom - headerView.maximumHeight)
            self.largeTitleLabel.origin.x = viewOriginX - (0.8*(headerView.bottom - headerView.maximumHeight))
        }else{
            self.largeTitleLabel.origin.y = viewOriginY + (headerView.bottom - headerView.maximumHeight)
        }
    }
}

extension UIViewController{
    var activityIndicatorTag: Int { return 999999 }
    struct MDCPalette {
        static let blue: UIColor = UIColor(red: 0.129, green: 0.588, blue: 0.953, alpha: 1.0)
        static let red: UIColor = UIColor(red: 0.957, green: 0.263, blue: 0.212, alpha: 1.0)
        static let green: UIColor = UIColor(red: 0.298, green: 0.686, blue: 0.314, alpha: 1.0)
        static let yellow: UIColor = UIColor(red: 1.0, green: 0.922, blue: 0.231, alpha: 1.0)
    }
    func startActivityIndicator(location: CGPoint? = nil) {
        
        //Set the position - defaults to `center` if no`location`
        
        //argument is provided
        
        let loc = location ?? self.view.center
        
        //Ensure the UI is updated from the main thread
        
        //in case this method is called from a closure
        DispatchQueue.main.async {
            if let activityIndicator = self.view.subviews.filter(
                { $0.tag == self.activityIndicatorTag}).first as? MDCActivityIndicator {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                self.view.isUserInteractionEnabled = true
            }
            let width: CGFloat = __kWidth / 2
            let height: CGFloat = __kHeight / 2
            
            let activityIndicator = MDCActivityIndicator(frame:CGRect(x: 0, y: 0, width: 48, height: 48))
            //Initialize single color progress indicator
            activityIndicator.tag = self.activityIndicatorTag
            //Set the location
            #warning("center set")
            activityIndicator.center = CGPoint(x: width, y: height)

            // Pass colors you want to indicator to cycle through
            activityIndicator.cycleColors = [MDCPalette.blue, MDCPalette.red, MDCPalette.green, MDCPalette.yellow]
            activityIndicator.radius = 18.0
            activityIndicator.strokeWidth = 3.0
            activityIndicator.indicatorMode = .indeterminate
            activityIndicator.sizeToFit()
            activityIndicator.startAnimating()
            self.view.addSubview(activityIndicator)
            self.view.bringSubview(toFront: activityIndicator)
            self.view.isUserInteractionEnabled = false
        }
    }
    
    func stopActivityIndicator() {
        //Again, we need to ensure the UI is updated from the main thread!
        
        DispatchQueue.main.async {
            //Here we find the `UIActivityIndicatorView` and remove it from the view
            if let activityIndicator = self.view.subviews.filter(
                { $0.tag == self.activityIndicatorTag}).first as? MDCActivityIndicator {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                self.view.isUserInteractionEnabled = true
            }
        }
    }
}
