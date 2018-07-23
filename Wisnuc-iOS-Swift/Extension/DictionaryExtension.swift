//
//  DictionaryExtension.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/7/23.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation

extension Dictionary {
    
    mutating func merge(with dictionary: Dictionary) {
        dictionary.forEach { updateValue($1, forKey: $0) }
    }
    
    func merged(with dictionary: Dictionary) -> Dictionary {
        var dict = self
        dict.merge(with: dictionary)
        return dict
    }
}

