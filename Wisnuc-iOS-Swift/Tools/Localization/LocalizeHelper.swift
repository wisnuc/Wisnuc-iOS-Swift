//
//  LocalizeHelper.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/29.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import Foundation
import UIKit

// 语言本地化-单例
class LocalizeHelper: NSObject {
    struct Static
    {
        static var instance: LocalizeHelper?
    }
    
    class var sharedInstance: LocalizeHelper
    {
        if Static.instance == nil
        {
            Static.instance = LocalizeHelper()
        }
        
        return Static.instance!
    }
    
    func dispose()
    {
        LocalizeHelper.Static.instance = nil
        print("Disposed Singleton instance")
    }
    
    private var myBundle: Bundle? = nil

    //单例对象
    internal static let instance = LocalizeHelper()
    
    override init() {
        super.init()
//        object_setClass(Bundle.main, BundleEx.self)
        myBundle = Bundle.main
    }
    
    //-------------------------------------------------------------
    // translate a string
    //-------------------------------------------------------------
    // you can use this macro:
    // LocalizedString(@"Text");
    func localizedString(forKey key: String) -> String? {
        // this is almost exactly what is done when calling the macro NSLocalizedString(@"Text",@"comment")
        // the difference is: here we do not use the systems main bundle, but a bundle
        // we selected manually before (see "setLanguage")
        return myBundle?.localizedString(forKey: key, value: "", table: nil)
    }
    func setLanguage(_ lang: String?) {
        // path to this languages bundle
        if  let path = Bundle.main.path(forResource: lang, ofType: "lproj"){
            if let bundle = Bundle(path: path){
               myBundle = bundle
            }else{
               myBundle = Bundle.main
            }
            
        }else{
             myBundle = Bundle.main
        }
    }
}
