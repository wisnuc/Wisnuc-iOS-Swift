//
//  WSNavigationController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/11.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import CatalogByConvention
import MaterialComponents.MDCNavigationBar

class WSNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let navBar = MDCNavigationBar()
        navBar.observe(navigationItem)
        
        navBar.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        let mutator = MDCNavigationBarTextColorAccessibilityMutator()
        mutator.mutate(navBar)
        
        view.addSubview(navBar)
        
        navBar.translatesAutoresizingMaskIntoConstraints = false
        
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

