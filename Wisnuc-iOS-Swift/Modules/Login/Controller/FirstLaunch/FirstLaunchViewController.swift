//
//  FirstLaunchViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/12.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialButtons

let numOfPages = 4

class FirstLaunchViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(mainScrollView)
        self.view.addSubview(pageControl)
        self.view.addSubview(startButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func startButtonClick(){
        let type:LoginState?
        type = TokenManager.wechatLoginToken() != nil && (TokenManager.wechatLoginToken()?.count)!>0 ? .token:.wechat
        let loginController = LoginViewController.init(type!)
        UIApplication.shared.statusBarStyle = .lightContent
        let navigationController = UINavigationController.init(rootViewController:loginController)
        let window =  UIApplication.shared.keyWindow
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    lazy var mainScrollView: UIScrollView = {
  
        let frame = self.view.bounds
        let scrollView = UIScrollView.init(frame: CGRect(x: 0, y: 0, width: __kWidth, height: __kHeight))
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.bounces = false
        scrollView.contentOffset = CGPoint.zero
        // 将 scrollView 的 contentSize 设为屏幕宽度的3倍(根据实际情况改变)
        scrollView.contentSize = CGSize(width: frame.size.width * CGFloat(numOfPages), height: frame.size.height)
        
        scrollView.delegate = self
        
        for index  in 0..<numOfPages {
            let imageView = UIImageView(image: UIImage(named: "FirstScreen-\(index + 1)"))
            imageView.frame = CGRect(x: frame.size.width * CGFloat(index), y: 0, width: frame.size.width, height: frame.size.height)
            scrollView.addSubview(imageView)
        }
        
        self.view.insertSubview(scrollView, at: 0)

        return scrollView
    }()
   
    lazy var pageControl: UIPageControl = {
        let page = UIPageControl.init(frame: CGRect(x: 0, y: __kHeight - 48, width: __kWidth, height: 20))
        page.numberOfPages = numOfPages//指定页面个数
        page.currentPage = 0
        return page
    }()
    
    lazy var startButton:MDCRaisedButton  = {
        let button = MDCRaisedButton.init(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        button.center = CGPoint.init(x: self.view.center.x, y: self.pageControl.frame.minY - 50)
        button.setBackgroundColor(COR1, for: .normal)
        button.setElevation(.raisedButtonResting, for: UIControlState.normal)
        button.tintColor = UIColor.white
        button.addTarget(self, action: #selector(startButtonClick), for: UIControlEvents.touchUpInside)
        button.layer.cornerRadius = 2
        button.setTitle(LocalizedString(forKey: "Start"), for: UIControlState.normal)
        button.alpha = 0
        return button
    }()
}
 // MARK: - UIScrollViewDelegate
extension FirstLaunchViewController:UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        // 随着滑动改变pageControl的状态
        pageControl.currentPage = Int(offset.x / view.bounds.width)
        
        // 因为currentPage是从0开始，所以numOfPages减1
        if pageControl.currentPage == numOfPages - 1 {
            UIView.animate(withDuration: 0.5, animations: {
                self.startButton.alpha = 1.0
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.startButton.alpha = 0.0
            })
        }
    }
}
