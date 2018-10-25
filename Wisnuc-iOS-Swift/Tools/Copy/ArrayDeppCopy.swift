//
//  ArrayDeppCopy.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/25.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import Foundation
//Protocal that copyable class should conform
protocol Copying {
    init(original: Self)
}

//Concrete class extension
extension Copying {
    func copy() -> Self {
        return Self.init(original: self)
    }
}

//Array extension for elements conforms the Copying protocol
extension Array where Element: Copying {
    func clone() -> Array {
        var copiedArray = Array<Element>()
        for element in self {
            copiedArray.append(element.copy())
        }
        return copiedArray
    }
}
