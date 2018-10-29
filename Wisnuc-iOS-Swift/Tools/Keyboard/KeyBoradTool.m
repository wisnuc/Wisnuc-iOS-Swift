//
//  KeyBoradTool.m
//  MyKeyBoard
//
//  Created by 李洪成 on 15-4-22.
//  Copyright (c) 2015年 李洪成. All rights reserved.
//

#import "KeyBoradTool.h"

@implementation KeyBoradTool

#pragma mark - 添加基础按钮
+ (UIButton *)setupBasicButtonsWithTitle:(NSString *)title image:(UIImage *)image highImage:(UIImage *)highImage {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setBackgroundImage:highImage forState:UIControlStateHighlighted];
    
    return button;
}

@end
