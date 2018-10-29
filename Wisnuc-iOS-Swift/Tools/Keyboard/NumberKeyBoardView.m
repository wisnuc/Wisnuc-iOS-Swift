//
//  NumberKeyBoardView.m
//  MyKeyBoard
//
//  Created by 李洪成 on 15-4-22.
//  Copyright (c) 2015年 李洪成. All rights reserved.
//

#import "NumberKeyBoardView.h"
#import "UIImage+YYAdd.h"
#import "UIColor+YYAdd.h"
#define Screen_Width [UIScreen mainScreen].bounds.size.width

@implementation NumberKeyBoardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self createButton];
    }
    return self;
}

#pragma mark - 创建数字键盘
-(void)createButton
{
    NSMutableArray *arrM = [[NSMutableArray alloc] initWithObjects:@"W",@"!",@"3",@"S",@"%",@"6",@"A",@"#",@"8",@"",@"Ω",@"", nil];
    UIImage *image = [UIImage imageNamed:@"XXXXX"];
    UIImage *highImage = [UIImage imageNamed:@"XXXXX"];
    int index = 0;
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 3; j++) {
            
            double w = (Screen_Width-20)/3;
            double h = (196-25)/4;
            double x = 5 + j*(w+5);
            double y = 6 + i*(h+6);
      
            NSString *title = arrM[index];
            
            UIButton *numBtn = [KeyBoradTool setupBasicButtonsWithTitle:title image:image highImage:highImage];
            
            if (index == 9){
                numBtn.enabled = false;
            }
            else
            if (index == 11) {
                [numBtn setImage:[UIImage imageNamed:@"delete_keyboard.png"] forState:UIControlStateNormal];
                //给删除按钮一个事件处理方法
                [numBtn addTarget:self action:@selector(deleteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            }
            else{
                //添加一个事件处理方法
                [numBtn addTarget:self action:@selector(numBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            }
//            if (index < 18) {
                numBtn.frame = CGRectMake(x, y, w, h);
//            }
//            else{
//                numBtn.frame = CGRectMake(x, y, 2*w+6, h);
//            }
            //123  678  11 12 13  17 控制数字的背景颜色
//            if (index == 1 || index == 2 || index == 3 || index == 6 || index == 7 || index == 8 || index == 11 || index == 12 || index == 13 || index == 17 ) {
            if (index == 9 || index == 11 ){
             numBtn.backgroundColor = [UIColor clearColor];
               
            }
            else{
                numBtn.backgroundColor = [UIColor whiteColor];
                numBtn.layer.cornerRadius = 4;
                numBtn.layer.shadowOffset = CGSizeMake(0, 0.5);
                numBtn.layer.shadowColor = [UIColor blackColor].CGColor;
                numBtn.layer.shadowOpacity = 0.2;
                numBtn.layer.shadowRadius = 1;
                numBtn.clipsToBounds = false;
//                numBtn.layer.masksToBounds = true;
                [numBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRGB:0x0b8c6d3]] forState:UIControlStateHighlighted];
            }
            //设置点击时按钮背景图片
        
           
            [self addSubview:numBtn];
            index++;
            //没有第19个按钮，直接返回
            if (index == 12) {
                break;
            }
        }
    }
}

//点击数字，隐藏，ABC，清空，确定等按钮
- (void)numBtnClick:(UIButton *)numBtn {
    
    if ([self.delegate respondsToSelector:@selector(numberKeyboard:didClickButton:)]) {
        [self.delegate numberKeyboard:self didClickButton:numBtn];
    }
}

//点击删除按钮
- (void)deleteBtnClick:(UIButton *)deleteBtn {
    if ([self.delegate respondsToSelector:@selector(customKeyboardDidClickDeleteButton:)]) {
        [self.delegate customKeyboardDidClickDeleteButton:deleteBtn];
    }
}


@end
