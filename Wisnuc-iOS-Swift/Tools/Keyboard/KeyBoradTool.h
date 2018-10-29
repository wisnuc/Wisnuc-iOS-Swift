//
//  KeyBoradTool.h
//  MyKeyBoard
//
//  Created by 李洪成 on 15-4-22.
//  Copyright (c) 2015年 李洪成. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class NumberKeyBoardView,LetterKeyBoardView;
@protocol CustomKeyBoardDelegate <NSObject>

- (void)numberKeyboard:(NumberKeyBoardView *)number didClickButton:(UIButton *)button;
- (void)letterKeyboard:(LetterKeyBoardView *)letter didClickButton:(UIButton *)button;

- (void)customKeyboardDidClickDeleteButton:(UIButton *)deleteBtn;

@end


@interface KeyBoradTool : NSObject

#pragma mark - 添加基础按钮
+ (UIButton *)setupBasicButtonsWithTitle:(NSString *)title image:(UIImage *)image highImage:(UIImage *)highImage;


@end
