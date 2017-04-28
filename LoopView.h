//
//  LoopView.h
//  LoopView
//
//  Created by Milton on 16/9/25.
//  Copyright © 2016年 baoping.zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoopView : UIView
/**默认的pageControl颜色*/
@property (nonatomic, strong)UIColor *customPageColor;
/**选中的pageControl颜色*/
@property (nonatomic, strong)UIColor *selectPageColor;
/**轮播时间间隔*/
@property (nonatomic, assign)NSTimeInterval interval;

-(instancetype)initWithFrame:(CGRect)frame andPictures:(NSArray<NSString *>*)pictures;
@end
