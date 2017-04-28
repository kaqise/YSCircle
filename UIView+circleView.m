//
//  UIView+circleView.m
//  LoopView
//
//  Created by Milton on 16/9/26.
//  Copyright © 2016年 baoping.zhang. All rights reserved.
//

#import "UIView+circleView.h"
#import <objc/message.h>

#define kSelf_W self.bounds.size.width
#define kSelf_H self.bounds.size.height

static char *const BP_PicturesKey = "BP_PicturesKey";
static char *const BP_ScrollViewKey = "BP_ScrollViewKey";
static char *const BP_CurrentIndexKey = "BP_CurrentIndexKey";
static char *const BP_PageControlKey = "BP_PageControlKey";
static char *const BP_TimerKey = "BP_TimerKey";


@implementation UIView (circleView)

- (UIScrollView *)bp_ScrollView{
    UIScrollView *scrollView = objc_getAssociatedObject(self, BP_ScrollViewKey);
    if (!scrollView) {
        scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.bounces = YES;
        scrollView.contentSize = CGSizeMake(kSelf_W * 3, kSelf_H);
        scrollView.contentOffset = CGPointMake(kSelf_W, 0);
        scrollView.pagingEnabled = YES;
        scrollView.delegate = self;
        objc_setAssociatedObject(self, BP_ScrollViewKey, scrollView, OBJC_ASSOCIATION_RETAIN);
        [self configImageView];
    }
    return scrollView;
}
- (UIPageControl*)bp_PageControl{
    UIPageControl *pageControl = objc_getAssociatedObject(self, BP_PageControlKey);
    if (!pageControl) {
        pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake((kSelf_W - 100)/2, kSelf_H - 30, 100, 30)];
        pageControl.numberOfPages = self.bp_Pictures.count;
        pageControl.currentPage = self.bp_CurrentIndex;
        objc_setAssociatedObject(self, BP_PageControlKey, pageControl, OBJC_ASSOCIATION_RETAIN);
    }
    return pageControl;
}

- (void)configImageView{
    for (NSInteger index; index < 3; index ++) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(kSelf_W * index, 0, kSelf_W, kSelf_H)];
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.tag = 100 + index;
        if (index == 0) {
            imageView.image = [UIImage imageNamed:self.bp_Pictures[self.bp_Pictures.count - 1]];
        }else{
            imageView.image = [UIImage imageNamed:self.bp_Pictures[index]];
        }
        [self.bp_ScrollView addSubview:imageView];
    }
}
-(void)setBp_Pictures:(NSArray<NSString *> *)bp_Pictures{
    
    objc_setAssociatedObject(self, BP_PicturesKey, bp_Pictures, OBJC_ASSOCIATION_RETAIN);
    self.bp_CurrentIndex = 0;
    [self addSubview:self.bp_ScrollView];
    [self addSubview:self.bp_PageControl];
    [self initTimer];
}
-(NSArray<NSString *> *)bp_Pictures{
    return objc_getAssociatedObject(self, BP_PicturesKey);
}
- (void)setBp_CurrentIndex:(NSInteger)bp_CurrentIndex{
    objc_setAssociatedObject(self, BP_CurrentIndexKey, @(bp_CurrentIndex), OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSInteger)bp_CurrentIndex{
    return [objc_getAssociatedObject(self, BP_CurrentIndexKey) integerValue];
}
- (void)setBp_timer:(NSTimer*)bp_timer{
    objc_setAssociatedObject(self, BP_TimerKey, bp_timer, OBJC_ASSOCIATION_RETAIN);
}
- (NSTimer*)bp_timer{
    return objc_getAssociatedObject(self, BP_TimerKey);
}
/**更新scrollView数据的逻辑处理*/
- (void)scrollViewUpdateSources:(UIScrollView*)scrollView{
    UIImageView *leftImageView = [scrollView viewWithTag:100];
    UIImageView *currentImageView = [scrollView viewWithTag:101];
    UIImageView *rightImageView = [scrollView viewWithTag:102];
    if (scrollView.contentOffset.x > kSelf_W) {//右移
        self.bp_CurrentIndex ++;
        if (self.bp_CurrentIndex == self.bp_Pictures.count - 1) {
            leftImageView.image = [UIImage imageNamed:self.bp_Pictures[self.bp_CurrentIndex - 1]];
            currentImageView.image= [UIImage imageNamed:self.bp_Pictures[self.bp_CurrentIndex]];
            rightImageView.image = [UIImage imageNamed:self.bp_Pictures[0]];
        }else if (self.bp_CurrentIndex == self.bp_Pictures.count){
            self.bp_CurrentIndex = 0;
            leftImageView.image = [UIImage imageNamed:self.bp_Pictures[self.bp_Pictures.count - 1]];
            currentImageView.image= [UIImage imageNamed:self.bp_Pictures[self.bp_CurrentIndex]];
            rightImageView.image = [UIImage imageNamed:self.bp_Pictures[self.bp_CurrentIndex + 1]];
        }else{
            leftImageView.image = [UIImage imageNamed:self.bp_Pictures[self.bp_CurrentIndex - 1]];
            currentImageView.image= [UIImage imageNamed:self.bp_Pictures[self.bp_CurrentIndex]];
            rightImageView.image = [UIImage imageNamed:self.bp_Pictures[self.bp_CurrentIndex + 1]];
        }
    }else{//左移
        self.bp_CurrentIndex--;
        if (self.bp_CurrentIndex == 0) {
            leftImageView.image = [UIImage imageNamed:self.bp_Pictures[self.bp_Pictures.count - 1]];
            currentImageView.image= [UIImage imageNamed:self.bp_Pictures[self.bp_CurrentIndex]];
            rightImageView.image = [UIImage imageNamed:self.bp_Pictures[self.bp_CurrentIndex + 1]];
        }else if (self.bp_CurrentIndex == -1){
            self.bp_CurrentIndex = self.bp_Pictures.count - 1;
            leftImageView.image = [UIImage imageNamed:self.bp_Pictures[self.bp_CurrentIndex - 1]];
            currentImageView.image= [UIImage imageNamed:self.bp_Pictures[self.bp_CurrentIndex]];
            rightImageView.image = [UIImage imageNamed:self.bp_Pictures[0]];
        }else{
            leftImageView.image = [UIImage imageNamed:self.bp_Pictures[self.bp_CurrentIndex - 1]];
            currentImageView.image= [UIImage imageNamed:self.bp_Pictures[self.bp_CurrentIndex]];
            rightImageView.image = [UIImage imageNamed:self.bp_Pictures[self.bp_CurrentIndex + 1]];
        }
    }
    self.bp_PageControl.currentPage = self.bp_CurrentIndex;
    scrollView.contentOffset = CGPointMake(kSelf_W, 0);
}
- (void)initTimer{
    self.bp_timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(changeImage) userInfo:nil repeats:YES];
}
- (void)invalidateTimer{
    [self.bp_timer invalidate];
    self.bp_timer = nil;
}

- (void)changeImage{
    [self.bp_ScrollView setContentOffset:CGPointMake(self.bp_ScrollView.contentOffset.x + kSelf_W, 0) animated:YES];
}
#pragma mark - UIScrollViewDelegate
/**滚动视图手动拖拽停止滚动的时候*/
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.x > kSelf_W * 3/2 || scrollView.contentOffset.x < kSelf_W / 2) {
        [self scrollViewUpdateSources:scrollView];
    }
    [self initTimer];
}
/**滚动视图由定时器控制移动停止时*/
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self scrollViewUpdateSources:scrollView];
}
/**拖拽时关掉定时器*/
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self invalidateTimer];
}




@end
