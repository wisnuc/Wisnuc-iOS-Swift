//
//  UIImage+ScrollIndicatorExt.h
//  ScrollIndicatorView
//
//  Created by hupeng on 15/3/11.
//  Copyright (c) 2015年 hupeng. All rights reserved.
//

#import <UIKit/UIKit.h>

//#define isXObjc [UIScreen mainScreen].bounds.size.width == 375 &&  [UIScreen mainScreen].bounds.size.height == 812 ? YES : NO

const static NSInteger MDCAppNavigationBarHeight =  76.0;
const static NSInteger kILSDefaultSliderSize = 40;
const static NSInteger kILSDefaultSliderWidth = 35;
const static NSInteger kILSDefaultSliderHeight = 66*35/42;
const static NSInteger kILSDefaultSliderMargin = 70;

typedef enum {
    
    ILSSliderStatusTop,
    ILSSliderStatusCenter,
    ILSSliderStatusBottom

} ILSSliderStatus;

@interface ILSSlider : UIControl

@property (nonatomic, assign) ILSSliderStatus status;
@property (nonatomic) UIImageView * sliderIcon;

@property (nonatomic) UIControlState sliderState;
@property (nonatomic) UILabel * timeLabel;

@end

@interface ILSIndicatorView : UIControl

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) ILSSlider *slider;
@property (nonatomic, assign) float value;

@end

@interface UIScrollView (IndicatorExt)

@property (nonatomic, strong) ILSIndicatorView *indicator;

- (void)registerILSIndicator;

@end
