//
//  StringExtension.swift
//  FruitMix-Swift
//
//  Created by wisnuc-imac on 2018/3/21.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

extension String{
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
}

class StringExtension: NSObject {
    class func classNameAsString(obj: Any) -> String {
        //prints more readable results for dictionaries, arrays, Int, etc
        return String(describing: type(of: obj))
    }
    
    class func classNameAsString(targetClass: AnyClass) -> String {
        //prints more readable results for dictionaries, arrays, Int, etc
        return String(describing: type(of:targetClass))
    }
}
