//
//  LetterKeyBoardView.h
//  MyKeyBoard
//
//  Created by 李洪成 on 15-4-23.
//  Copyright (c) 2015年 李洪成. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyBoradTool.h"
@interface LetterKeyBoardView : UIView

@property (nonatomic, assign) id<CustomKeyBoardDelegate> delegate;

@end
