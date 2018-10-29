//
//  LetterKeyBoardView.m
//  MyKeyBoard
//
//  Created by 李洪成 on 15-4-23.
//  Copyright (c) 2015年 李洪成. All rights reserved.
//

#import "LetterKeyBoardView.h"

#define Screen_Width [UIScreen mainScreen].bounds.size.width

@implementation LetterKeyBoardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createLetterKeyBoard];
        
    }
    return self;
}

#pragma mark - 创建字母键盘
-(void)createLetterKeyBoard
{
    UIImage *image = [UIImage imageNamed:@"XXXXX"];
    UIImage *highImage = [UIImage imageNamed:@"XXXXX"];
    NSMutableArray *letterArr = [[NSMutableArray alloc] initWithObjects:@"q",@"w",@"e",@"r",@"t",@"y",@"u",@"i",@"o",@"p",@"a",@"s",@"d",@"f",@"g",@"h",@"j",@"k",@"l",@"系统",@"z",@"x",@"c",@"v",@"b",@"n",@"m",@"X",@"隐藏",@"123",@"清空",@"确定", nil];
    int index = 0;
    for (int i = 0; i < 4; i++) {
        if (i == 0) {
            for (int j = 0; j < 10; j++){
                double w = (Screen_Width-22)/10;
                double h = (216-30)/4;
                double x = 2 + j*(w+2);
                double y = 6 + i*(h+6);
    
                NSString *title = letterArr[index];
                
                UIButton *letBtn = [KeyBoradTool setupBasicButtonsWithTitle:title image:image highImage:highImage];
                letBtn.frame = CGRectMake(x, y, w, h);
                letBtn.backgroundColor = [UIColor whiteColor];
                [letBtn addTarget:self action:@selector(charbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
                [letBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateHighlighted];
                [self addSubview:letBtn];
                index++;
            }
        }
        if (i == 1) {
            for (int j = 0; j < 9; j++){
                double w = (Screen_Width-22)/10;
                double h = (216-30)/4;
                double x = (4+w)/2 + j*(w+2);
                double y = 6 + i*(h+6);
                NSString *title = letterArr[index];
                
                UIButton *letBtn = [KeyBoradTool setupBasicButtonsWithTitle:title image:image highImage:highImage];
                letBtn.frame = CGRectMake(x, y, w, h);
                letBtn.backgroundColor = [UIColor whiteColor];
                [letBtn addTarget:self action:@selector(charbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
                [letBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateHighlighted];
                [self addSubview:letBtn];
                index++;
            }
        }
        if (i == 2) {
            for (int j = 0; j < 9; j++){
                double w = (Screen_Width-22)/10;
                double h = (216-30)/4;
                double x = 2 + j*(w+2);
                double y = 6 + i*(h+6);
                NSString *title = letterArr[index];
                
                UIButton *letBtn = [KeyBoradTool setupBasicButtonsWithTitle:title image:image highImage:highImage];
                if (j == 0 ) {
                    letBtn.frame = CGRectMake(x, y, w+(w+2)/2, h);
                    letBtn.backgroundColor = [UIColor lightGrayColor];
                    [letBtn addTarget:self action:@selector(charbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
                }
                else if (j == 8) {
                    letBtn.frame = CGRectMake(x+(w+2)/2, y, w+(w+2)/2, h);
                    letBtn.backgroundColor = [UIColor lightGrayColor];
                    [letBtn addTarget:self action:@selector(deleteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                }
                else{
                    letBtn.frame = CGRectMake(x+(w+2)/2, y, w, h);
                    letBtn.backgroundColor = [UIColor whiteColor];
                    [letBtn addTarget:self action:@selector(charbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
                }
                [letBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateHighlighted];
                [self addSubview:letBtn];
                index++;
            }
        }
        if (i == 3) {
            for (int j = 0; j < 4; j++){
                double w = (Screen_Width-10)/4;
                double h = (216-30)/4;
                double x = 2 + j*(w+2);
                double y = 6 + i*(h+6);
                NSString *title = letterArr[index];
                
                UIButton *letBtn = [KeyBoradTool setupBasicButtonsWithTitle:title image:image highImage:highImage];
                letBtn.frame = CGRectMake(x, y, w, h);
                letBtn.backgroundColor = [UIColor lightGrayColor];
                [letBtn addTarget:self action:@selector(charbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
                [letBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateHighlighted];
                [self addSubview:letBtn];
                index++;
            }
        }
    }
}

//点击字母，系统，隐藏，123，清空，确定等按钮
- (void)charbuttonClick:(UIButton *)charButton {
    if ([self.delegate respondsToSelector:@selector(letterKeyboard:didClickButton:)]) {
        [self.delegate letterKeyboard:self didClickButton:charButton];
    }
}

//点击删除按钮
- (void)deleteBtnClick:(UIButton *)deleteBtn {
    if ([self.delegate respondsToSelector:@selector(customKeyboardDidClickDeleteButton:)]) {
        [self.delegate customKeyboardDidClickDeleteButton:deleteBtn];
    }
}


@end
