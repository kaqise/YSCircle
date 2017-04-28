//
//  LoopView.m
//  LoopView
//
//  Created by Milton on 16/9/25.
//  Copyright © 2016年 baoping.zhang. All rights reserved.
//

#import "LoopView.h"

#define kWidth self.bounds.size.width
#define kHeight self.bounds.size.height

@interface LoopView()<UIScrollViewDelegate>
/**滚动视图*/
@property (nonatomic, strong)UIScrollView *scrollView;
/**pageControl圆点*/
@property (nonatomic, strong)UIPageControl *pageControl;
/**定时器*/
@property (nonatomic, strong)NSTimer *myTimer;
@end

@implementation LoopView

{
    NSArray *_pictures;                ///照片数组
    UIImageView *_leftImageView;       ///左
    UIImageView *_currentImageView;    //中间
    UIImageView *_rightImageView;      ///右
    NSInteger _currentIndex;           ///当前照片数
}

- (instancetype)initWithFrame:(CGRect)frame andPictures:(NSArray<NSString *> *)pictures{
    self = [super initWithFrame:frame];
    if (self) {
        _pictures = pictures;
        _currentIndex = 0;
        [self addSubview:self.scrollView];
        [self addImageToScrollerView];
        [self addSubview:self.pageControl];
        [self initTimer];
        
    }return self;
}
#pragma mark - LazyLoad 懒加载
- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.bounces = YES;
        _scrollView.contentSize = CGSizeMake(kWidth * 3, kHeight);
        _scrollView.contentOffset = CGPointMake(kWidth, 0);
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UIPageControl *)pageControl{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake((kWidth - 100)/2, kHeight - 30, 100, 30)];
        _pageControl.numberOfPages = _pictures.count;
        _pageControl.currentPage = _currentIndex;
    }
    return _pageControl;
}
/**滚动视图添加imageView*/
- (void)addImageToScrollerView{
    _leftImageView = [UIImageView new];
    _currentImageView = [UIImageView new];
    _rightImageView = [UIImageView new];
    NSArray *arr = @[_leftImageView,_currentImageView,_rightImageView];
    for (NSInteger i = 0; i < 3; i++ ) {
        UIImageView *imageView = arr[i];
        imageView.frame = CGRectMake(kWidth * i, 0, kWidth, kHeight);
        imageView.backgroundColor = @[[UIColor redColor],[UIColor greenColor], [UIColor blueColor]][i];
        imageView.contentMode = UIViewContentModeScaleToFill;
        if (i == 0) {
            imageView.image = [UIImage imageNamed:_pictures[_pictures.count - 1]];
        }else{
            imageView.image = [UIImage imageNamed:_pictures[i]];
        }
        [_scrollView addSubview:imageView];
    }
}

#pragma mark - UIScrollViewDelegate
/**滚动视图手动拖拽停止滚动的时候*/
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.x > kWidth * 3/2 || scrollView.contentOffset.x < kWidth / 2) {
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

/**初始化定时器*/
- (void)initTimer{
    
    _myTimer = [NSTimer scheduledTimerWithTimeInterval:_interval ?: 3 target:self selector:@selector(changePicture) userInfo:nil repeats:YES];
}
/**定时器事件，修改滚动视图的偏移量*/
- (void)changePicture{
    [_scrollView setContentOffset:CGPointMake(_scrollView.contentOffset.x + kWidth, 0) animated:YES];
}
/**更新scrollView数据的逻辑处理*/
- (void)scrollViewUpdateSources:(UIScrollView*)scrollView{
    if (scrollView.contentOffset.x > kWidth) {//右移
        _currentIndex ++;
        if (_currentIndex == _pictures.count - 1) {
            _leftImageView.image = [UIImage imageNamed:_pictures[_currentIndex - 1]];
            _currentImageView.image= [UIImage imageNamed:_pictures[_currentIndex]];
            _rightImageView.image = [UIImage imageNamed:_pictures[0]];
        }else if (_currentIndex == _pictures.count){
            _currentIndex = 0;
            _leftImageView.image = [UIImage imageNamed:_pictures[_pictures.count - 1]];
            _currentImageView.image= [UIImage imageNamed:_pictures[_currentIndex]];
            _rightImageView.image = [UIImage imageNamed:_pictures[_currentIndex + 1]];
        }else{
            [self correctImage];
        }
    }else{//左移
        _currentIndex--;
        if (_currentIndex == 0) {
            _leftImageView.image = [UIImage imageNamed:_pictures[_pictures.count - 1]];
            _currentImageView.image= [UIImage imageNamed:_pictures[_currentIndex]];
            _rightImageView.image = [UIImage imageNamed:_pictures[_currentIndex + 1]];
        }else if (_currentIndex == -1){
            _currentIndex = _pictures.count - 1;
            _leftImageView.image = [UIImage imageNamed:_pictures[_currentIndex - 1]];
            _currentImageView.image= [UIImage imageNamed:_pictures[_currentIndex]];
            _rightImageView.image = [UIImage imageNamed:_pictures[0]];
        }else{
            [self correctImage];
        }
    }
    _pageControl.currentPage = _currentIndex;
    scrollView.contentOffset = CGPointMake(kWidth, 0);
}
/**当不是图片数组第一个，与最后一个的正常处理*/
- (void)correctImage{
    _leftImageView.image = [UIImage imageNamed:_pictures[_currentIndex - 1]];
    _currentImageView.image= [UIImage imageNamed:_pictures[_currentIndex]];
    _rightImageView.image = [UIImage imageNamed:_pictures[_currentIndex + 1]];
}

-(void)setCustomPageColor:(UIColor *)customPageColor{
    _customPageColor = customPageColor;
    _pageControl.pageIndicatorTintColor = customPageColor;
}
-(void)setSelectPageColor:(UIColor *)selectPageColor{
    _selectPageColor = selectPageColor;
    _pageControl.currentPageIndicatorTintColor = selectPageColor;
}
-(void)setInterval:(NSTimeInterval)interval{
    _interval = interval;
    [self invalidateTimer];
    [self initTimer];
}
-(void)invalidateTimer{
    [_myTimer invalidate];
    _myTimer = nil;
}


@end
