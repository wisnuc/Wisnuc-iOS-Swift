//
//  CollectionExtension.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/6/8.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
