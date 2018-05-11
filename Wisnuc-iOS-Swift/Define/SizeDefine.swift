
//
//  SizeDefine.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/16.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation
import UIKit

public let __kWidth = UIScreen.main.bounds.size.width
public let __kHeight = UIScreen.main.bounds.size.height

public let MarginsWidth:CGFloat = 16
public let MarginsCloseWidth:CGFloat = 8
public let MarginsFarWidth:CGFloat = 20
public let MarginsSoFarWidth:CGFloat = 24

public let SafeAreaBottomHeight:CGFloat = 34.0
public let CommonButtonHeight:CGFloat = 36
public let MarginsBottomHeight:CGFloat = UIDevice.current.isX() ? 20 + SafeAreaBottomHeight:20

public let NormalLabelWidth:CGFloat = __kWidth - MarginsWidth*2


public let MDCAppNavigationBarHeight:CGFloat =  UIDevice.current.isX() ? 76.0 + SafeAreaBottomHeight-10:76.0
public let TabBarHeight:CGFloat =  56.0
public let StatusBarHeight = UIApplication.shared.statusBarFrame.height

public let UserNameMax:NSInteger = 16
public let PasswordMax:NSInteger = 30

public var View_Width_Space:CGFloat  = 0
public var View_Height_Space:CGFloat  = 0
public var View_Width:CGFloat  = 0
public var View_Height:CGFloat  = 0
public var View_Start_X:CGFloat  = 0
public var View_Start_Y:CGFloat = 0
