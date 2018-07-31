//
//  ArrayExtension.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/7/31.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation
extension Array where Element: Equatable {
    func contains(array: [Element]) -> Bool {
        for item in array {
            if !self.contains(item) { return false }
        }
        return true
    }
}
