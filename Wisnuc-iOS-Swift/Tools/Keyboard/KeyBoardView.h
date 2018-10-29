//
//  KeyBoardView.h
//  MyKeyBoard
//
//  Created by 李洪成 on 15-4-22.
//  Copyright (c) 2015年 李洪成. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KeyBoardView;
@protocol KeyBoardViewDelegate <NSObject>

@optional

- (void)keyboard:(KeyBoardView *)keyboard didClickTextButton:(UIButton *)textBtn string:(NSMutableString *)string;


- (void)changeKeyboardType;

@end

@interface KeyBoardView : UIView

@property (nonatomic, assign) id<KeyBoardViewDelegate> delegate;
@property (nonatomic, strong) NSMutableString *string;

@end
