//
//  UIImage+extension.m
//  Redious
//
//  Created by admin on 16/12/20.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "UIImage+extension.h"
#import <YYKit/YYKit.h>

@implementation UIImage (extension)
- (NSData *)compressQualityWithMaxLength:(NSInteger)maxLength {
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(self, compression);
    if (data.length < maxLength) return data;
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(self, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    return data;
}

+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize{
    
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
                                [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
                                UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
                                UIGraphicsEndImageContext();
                                
                                return scaledImage;
                                
}
                                
- (void)was_roundImageWithSize:(CGSize)size fillColor:(UIColor *)fillColor opaque:(BOOL)opaque completion:(void (^)(UIImage *))completion {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
//        NSTimeInterval start = CACurrentMediaTime();
        
        // 1. 利用绘图，建立上下文 BOOL选项为是否为不透明
        UIGraphicsBeginImageContextWithOptions(size, opaque, 0);
        
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        
        // 2. 设置填充颜色
        if (opaque) {
            [fillColor setFill];
            UIRectFill(rect);
        }
        
        // 3. 利用 贝赛尔路径 `裁切 效果
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
        
        [path addClip];
        
        // 4. 绘制图像 如果图片为空那么为单色渲染
        if (self) {
            [self drawInRect:rect];
        }
        
        // 5. 取得结果
        UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
        
        // 6. 关闭上下文
        UIGraphicsEndImageContext();
        
//        NSLog(@"%f", CACurrentMediaTime() - start);
        
        // 7. 完成回调
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion != nil) {
                completion(result);
            }
        });
    });
}

//圆角矩形
- (void)was_roundRectImageWithSize:(CGSize)size fillColor:(UIColor *)fillColor opaque:(BOOL)opaque radius:(CGFloat)radius completion:(void (^)(UIImage *))completion {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        //        NSTimeInterval start = CACurrentMediaTime();
        
        // 1. 利用绘图，建立上下文 BOOL选项为是否为不透明
        UIGraphicsBeginImageContextWithOptions(size, opaque, 0);
        
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        
        // 2. 设置填充颜色
        if (opaque) {
            [fillColor setFill];
            UIRectFill(rect);
        }
        
        // 3. 利用 贝赛尔路径 `裁切 效果
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
//        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
        
        [path addClip];
        
        // 4. 绘制图像
        if (self) {
            [self drawInRect:rect];
        }
        
        // 5. 取得结果
        UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
        
        // 6. 关闭上下文
        UIGraphicsEndImageContext();
        
        //        NSLog(@"%f", CACurrentMediaTime() - start);
        
        // 7. 完成回调
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion != nil) {
                completion(result);
            }
        });
    });
}

@end

#pragma mark - UIImageView
@implementation UIImageView (Extension)
//圆
- (void)was_setCircleImageWithUrlString:(NSString *)urlString placeholder:(UIImage *)image fillColor:(UIColor *)color{
    [self was_setCircleImageWithUrlString:urlString placeholder:image fillColor:color opaque:color];
}

//网络延迟下载--圆形 背景色为透明 无背景色
- (void)was_setCircleImageWithUrlString:(NSString *)urlString placeholder:(UIImage *)image{
    [self was_setCircleImageWithUrlString:urlString placeholder:image fillColor:nil opaque:NO];
}

//圆形矩阵
- (void)was_setRoundRectImageWithUrlString:(NSString *)urlString placeholder:(UIImage *)image fillColor:(UIColor *)color cornerRadius:(CGFloat) cornerRadius{
    [self was_setRoundRectImageWithUrlString:urlString placeholder:image fillColor:color opaque:color cornerRadius:cornerRadius];
}

//网络延迟下载--圆形矩阵 背景色为透明 无背景色
- (void)was_setRoundRectImageWithUrlString:(NSString *)urlString placeholder:(UIImage *)image cornerRadius:(CGFloat) cornerRadius{
    [self was_setRoundRectImageWithUrlString:urlString placeholder:image fillColor:nil opaque:NO cornerRadius:cornerRadius];
}

- (void)was_setCircleImageWithUrlString:(NSString *)urlString placeholder:(UIImage *)image fillColor:(UIColor *)color opaque:(BOOL)opaque{
    [self.superview layoutIfNeeded];
    NSURL *url = [NSURL URLWithString:urlString];
    //防止循环引用
    __weak typeof(self) weakSelf = self;
    CGSize size = self.frame.size;
    
    if (image) {
        //占位图片不为空的情况
        //1.现将占位图圆角化，这样就避免了如图片下载失败，使用占位图的时候占位图不是圆角的问题
        [image was_roundImageWithSize:size fillColor:color opaque:opaque completion:^(UIImage *radiusPlaceHolder) {
            //2.使用sd的方法缓存异步下载的图片
            [weakSelf setImageWithURL:url placeholder:radiusPlaceHolder options:YYWebImageOptionIgnoreFailedURL completion:^(UIImage * _Nullable img, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
//                3.如果下载成功那么讲下载成功的图进行圆角化
                if (img == nil || error){
//                    [image was_roundImageWithSize:size fillColor:color opaque:opaque completion:^(UIImage *radiusImage) {
                        weakSelf.image = image;
//                    }];
                }else{
                    [img was_roundImageWithSize:size fillColor:color opaque:opaque completion:^(UIImage *radiusImage) {
                        weakSelf.image = radiusImage;
                    }];
                }
            }];
            
            //2.使用sd的方法缓存异步下载的图片
//            [weakSelf sd_setImageWithURL:url placeholderImage:radiusPlaceHolder completed:^(UIImage *img, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//
//                //3.如果下载成功那么讲下载成功的图进行圆角化
//                [img was_roundImageWithSize:size fillColor:color opaque:opaque completion:^(UIImage *radiusImage) {
//                    weakSelf.image = radiusImage;
//                }];
//
//            }];
            
        }];
    } else {
        //占位图片为空的情况
        //2.使用sd的方法缓存异步下载的图片
       [weakSelf setImageWithURL:url placeholder:nil options:YYWebImageOptionIgnoreFailedURL completion:^(UIImage * _Nullable img, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            
            //3.如果下载成功那么讲下载成功的图进行圆角化
            [img was_roundImageWithSize:size fillColor:color opaque:opaque completion:^(UIImage *radiusImage) {
                weakSelf.image = radiusImage;
            }];
        }];
    }
}

- (void)was_setRoundRectImageWithUrlString:(NSString *)urlString placeholder:(UIImage *)image fillColor:(UIColor *)color opaque:(BOOL)opaque cornerRadius:(CGFloat) cornerRadius{
    [self.superview layoutIfNeeded];
    NSURL *url = [NSURL URLWithString:urlString];
    //防止循环引用
    __weak typeof(self) weakSelf = self;
    CGSize size = self.frame.size;
    
    if (image) {
        //占位图片不为空的情况
        //1.现将占位图圆角化，这样就避免了如图片下载失败，使用占位图的时候占位图不是圆角的问题
        [image was_roundRectImageWithSize:size fillColor:color opaque:opaque radius:cornerRadius completion:^(UIImage *roundRectPlaceHolder) {
            
            //2.使用sd的方法缓存异步下载的图片
            [weakSelf setImageWithURL:url placeholder:roundRectPlaceHolder options:YYWebImageOptionIgnoreFailedURL completion:^(UIImage * _Nullable img, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                
                //3.如果下载成功那么讲下载成功的图进行圆角化
                [img was_roundRectImageWithSize:size fillColor:color opaque:opaque radius:cornerRadius completion:^(UIImage *radiusImage) {
                    weakSelf.image = radiusImage;
                }];
                
            }];
            
        }];
    } else {
        //占位图片为空的情况
        //.使用sd的方法缓存异步下载的图片
       [weakSelf setImageWithURL:url placeholder:nil options:YYWebImageOptionIgnoreFailedURL completion:^(UIImage * _Nullable img, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            
            //3.如果下载成功那么讲下载成功的图进行圆角化
            [img was_roundRectImageWithSize:size fillColor:color opaque:opaque radius:cornerRadius completion:^(UIImage *radiusImage) {
                weakSelf.image = radiusImage;
            }];
        }];
    }
}

@end

#pragma mark - UIButton

@implementation UIButton (Extension)
//圆形
- (void)was_setCircleImageWithUrlString:(NSString *)urlString placeholder:(UIImage *)image fillColor:(UIColor *)color forState:(UIControlState)state {
    [self was_setCircleImageWithUrlString:urlString placeholder:image fillColor:color opaque:color forState:state];
}

//button--圆形    背景为透明 无背景色
- (void)was_setCircleImageWithUrlString:(NSString *)urlString placeholder:(UIImage *)image forState:(UIControlState)state{
    [self was_setCircleImageWithUrlString:urlString placeholder:image fillColor:nil opaque:NO forState:state];
}

//圆角矩阵
- (void)was_setRoundRectImageWithUrlString:(NSString *)urlString placeholder:(UIImage *)image fillColor:(UIColor *)color cornerRadius:(CGFloat) cornerRadius forState:(UIControlState)state{

    [self was_setRoundRectImageWithUrlString:urlString placeholder:image fillColor:color opaque:color cornerRadius:cornerRadius forState:state];
}

//button--圆角矩形 背景为透明 无背景色
- (void)was_setRoundRectImageWithUrlString:(NSString *)urlString placeholder:(UIImage *)image cornerRadius:(CGFloat) cornerRadius forState:(UIControlState)state{
    [self was_setRoundRectImageWithUrlString:urlString placeholder:image fillColor:nil opaque:NO cornerRadius:cornerRadius forState:state];
}

- (void)was_setRoundRectImageWithUrlString:(NSString *)urlString placeholder:(UIImage *)image fillColor:(UIColor *)color opaque:(BOOL)opaque cornerRadius:(CGFloat) cornerRadius forState:(UIControlState)state{
    NSURL *url = [NSURL URLWithString:urlString];
    [self.superview layoutIfNeeded];
    __weak typeof(self) weakSelf = self;
    CGSize size = self.frame.size;
    
    if (image) {
        //占位图片不为空的情况
        //占位处理
        [image was_roundRectImageWithSize:size fillColor:color opaque:opaque radius:cornerRadius completion:^(UIImage *roundRectPlaceHolder) {
            //sd
            
            [weakSelf setImageWithURL:url forState:state placeholder:roundRectPlaceHolder options:YYWebImageOptionRefreshImageCache completion:^(UIImage * _Nullable img, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                //3.如果下载成功那么讲下载成功的图进行圆角化
                [img was_roundRectImageWithSize:size fillColor:color opaque:opaque radius:cornerRadius completion:^(UIImage *roundRectImage) {
                    [weakSelf setImage:roundRectImage forState:state];
                }];
                
            }];
            
        }];
    } else {
        //占位图片为空的情况
           [weakSelf setImageWithURL:url forState:state placeholder:nil options:YYWebImageOptionRefreshImageCache completion:^(UIImage * _Nullable img, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            //3.如果下载成功那么讲下载成功的图进行圆角化
            [img was_roundRectImageWithSize:size fillColor:color opaque:opaque radius:cornerRadius completion:^(UIImage *roundRectImage) {
                [weakSelf setImage:roundRectImage forState:state];
            }];
            
        }];
    }

}

- (void)was_setCircleImageWithUrlString:(NSString *)urlString placeholder:(UIImage *)image fillColor:(UIColor *)color opaque:(BOOL)opaque forState:(UIControlState)state{
    NSURL *url = [NSURL URLWithString:urlString];
    [self.superview layoutIfNeeded];
    __weak typeof(self) weakSelf = self;
    CGSize size = self.frame.size;
    
    if (image) {
        //占位图片不为空的情况
        //占位处理
        [image was_roundImageWithSize:size fillColor:color opaque:opaque completion:^(UIImage *radiusPlaceHolder) {
            //sd
               [weakSelf setImageWithURL:url forState:state placeholder:radiusPlaceHolder options:YYWebImageOptionRefreshImageCache completion:^(UIImage * _Nullable img, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                //3.如果下载成功那么讲下载成功的图进行圆角化
                [img was_roundImageWithSize:size fillColor:color opaque:opaque completion:^(UIImage *radiusImage) {
                    [weakSelf setImage:radiusImage forState:state];
                }];
                
            }];
            
        }];
    } else {
        //占位图片为空的情况
          [weakSelf setImageWithURL:url forState:state placeholder:nil options:YYWebImageOptionRefreshImageCache completion:^(UIImage * _Nullable img, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            //3.如果下载成功那么讲下载成功的图进行圆角化
            [img was_roundImageWithSize:size fillColor:color opaque:opaque completion:^(UIImage *radiusImage) {
                [weakSelf setImage:radiusImage forState:state];
            }];
            
        }];
    }
    
}


@end
