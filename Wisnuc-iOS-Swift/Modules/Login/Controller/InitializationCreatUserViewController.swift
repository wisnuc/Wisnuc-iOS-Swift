//
//  InitializationCreatUserViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/20.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents

class InitializationCreatUserViewController: BaseViewController {
    
    @IBOutlet weak var nextButton: MDCButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.backgroundColor = COR1
        nextButton.setTitle(LocalizedString(forKey: "next_step"), for: UIControlState.normal)
        
        // Do any additional setup after loading the view.
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextButtonClick(_ sender: MDCButton) {
        let creatUserVC = InitializationCreatUserViewController.init()
        self.navigationController?.pushViewController(creatUserVC, animated: true)
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
