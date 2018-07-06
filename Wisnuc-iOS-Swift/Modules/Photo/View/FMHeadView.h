//
//  FMHeadView.h
//  FruitMix
//
//  Created by 杨勇 on 16/4/5.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FMHeadView;
@protocol FMHeadViewDelegate <NSObject>

-(void)FMHeadView:(FMHeadView *)headView isChooseBtn:(BOOL)isChoose;

@end

@interface FMHeadView : UICollectionReusableView

@property (nonatomic ,weak) id<FMHeadViewDelegate> fmDelegate;

@property (nonatomic) NSString * headTitle;

@property (nonatomic) NSIndexPath * fmIndexPath;//捆绑自身indexPath

@property (nonatomic) BOOL isChoose;//是否选中状态

@property (nonatomic) BOOL isSelectMode;

@property (nonatomic,strong) UIButton * choosebtn;
- (NSString *)getImageWithChoose:(BOOL)isChoose;

@end
