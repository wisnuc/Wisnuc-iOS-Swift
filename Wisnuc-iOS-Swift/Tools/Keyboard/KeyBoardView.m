//
//  KeyBoardView.m
//  MyKeyBoard
//
//  Created by 李洪成 on 15-4-22.
//  Copyright (c) 2015年 李洪成. All rights reserved.
//

#import "KeyBoardView.h"
#import "NumberKeyBoardView.h"
#import "LetterKeyBoardView.h"
#import "KeyBoradTool.h"

#define LVScreen_Size [UIScreen mainScreen].bounds.size

@interface KeyBoardView ()<CustomKeyBoardDelegate>

@property (nonatomic,strong) LetterKeyBoardView *letterKeyboard;
@property (nonatomic, strong) NumberKeyBoardView *numberKeyboard;

@end

@implementation KeyBoardView

- (NumberKeyBoardView *)numberKeyboard {
    if (!_numberKeyboard) {
        _numberKeyboard = [[NumberKeyBoardView alloc] initWithFrame:self.bounds];
        _numberKeyboard.delegate = self;
    }
    return _numberKeyboard;
}

- (LetterKeyBoardView *)letterKeyboard {
    if (!_letterKeyboard) {
        _letterKeyboard = [[LetterKeyBoardView alloc] initWithFrame:self.bounds];
        _letterKeyboard.delegate = self;
    }
    return _letterKeyboard;
}

//创建自定义键盘的View
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = CGRectMake(0, LVScreen_Size.height - 196, LVScreen_Size.width, 196);
        self.string = [NSMutableString string];
        self.backgroundColor = [UIColor colorWithRed:194/255.0f green:210/255.0f blue:218/255.0f alpha:1];
        [self addSubview:self.numberKeyboard];
        
    }
    return self;
}
#pragma mark - 按钮相应事件
//数字键盘按钮响应事件
- (void)numberKeyboard:(NumberKeyBoardView *)number didClickButton:(UIButton *)button {
   if ([button.currentTitle isEqualToString:@"ABC"]) {
        [number removeFromSuperview];
        [self addSubview:self.letterKeyboard];
    }
    else if ([button.currentTitle isEqualToString:@"清空"]) {
        if (self.string.length > 0) {
            [self.string deleteCharactersInRange:NSMakeRange(0, self.string.length)];
            if ([self.delegate respondsToSelector:@selector(keyboard:didClickTextButton:string:)]) {
                [self.delegate keyboard:self didClickTextButton:button string:self.string];
            }
        }
    }
    else if ([button.currentTitle isEqualToString:@"隐藏"]) {
        [self.nextResponder resignFirstResponder];
    }
    else if ([button.currentTitle isEqualToString:@"确定"]) {
        [self.nextResponder resignFirstResponder];
    }
    else {
        [self appendString:button];
    }
}
//字母键盘按钮的响应事件
- (void)letterKeyboard:(LetterKeyBoardView *)letter didClickButton:(UIButton *)button
{
    if ([button.currentTitle isEqualToString:@"系统"]){
        [letter removeFromSuperview];
        //改变键盘（改变成系统键盘）
        [self.delegate changeKeyboardType];
    }
    else if ([button.currentTitle isEqualToString:@"123"]){
        [self.letterKeyboard removeFromSuperview];
        [self addSubview:self.numberKeyboard];
    }
    else if ([button.currentTitle isEqualToString:@"清空"]){
        if (self.string.length > 0){
            [self.string deleteCharactersInRange:NSMakeRange(0, self.string.length)];
            if ([self.delegate respondsToSelector:@selector(keyboard:didClickTextButton:string:)]) {
                [self.delegate keyboard:self didClickTextButton:button string:self.string];
            }
        }
    }
    else if ([button.currentTitle isEqualToString:@"隐藏"]){
        [self.nextResponder resignFirstResponder];
    }
    else if ([button.currentTitle isEqualToString:@"确定"]){
        [self.nextResponder resignFirstResponder];
    }
    else{
        [self appendString:button];
    }
}

#pragma mark - 删除方法
- (void)customKeyboardDidClickDeleteButton:(UIButton *)deleteBtn {
    
    if (self.string.length > 0) {
        [self.string deleteCharactersInRange:NSMakeRange(self.string.length - 1, 1)];
        if ([self.delegate respondsToSelector:@selector(keyboard:didClickTextButton:string:)]) {
            [self.delegate keyboard:self didClickTextButton:deleteBtn string:self.string];
        }

    }
}

#pragma mark - 按钮title转换成string
- (void)appendString:(UIButton *)button {
    
    [self.string appendString:button.currentTitle];
    if ([self.delegate respondsToSelector:@selector(keyboard:didClickTextButton:string:)]) {
            [self.delegate keyboard:self didClickTextButton:button string:self.string];
    }

}

@end
