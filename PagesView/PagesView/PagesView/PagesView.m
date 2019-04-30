//
//  PagesView.m
//  PagesView
//
//  Created by zjl on 2017/11/9.
//  Copyright © 2017年 zjl. All rights reserved.
//

#import "PagesView.h"
#import "TitleCollectionViewCell.h"
#import "ContentCollectionViewCell.h"

NSString * const SelectPageViewNotification = @"SelectPageViewNotification";
static NSString *const CellIdentifier = @"cell";
static NSString *const ContentCellidentifier = @"ContentCell";
static float const DefaultCurrentSelectLineHeight = 2;
static float const DefaultCollectionViewHeight = 44;
static float const DefaultTitleWidth = 40;
static float const DefaultTiltleFontSize = 14;
typedef NS_ENUM(NSInteger,CollectionViewTag){
	titleCollectionViewTag,
	contentCollectionViewTag
	
};
@interface PagesView()<UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate> {
    CGFloat contentOffSetX;
    CGFloat lastX;//上次的位置
    CGFloat scrollDistance;//当前滑动的距离
    CGRect lastFrame;//下划线view上次停靠的位置
}

//标题栏的collectionview的layout
@property (nonatomic,strong) UICollectionViewFlowLayout *layout;
//标题栏的collectionview
@property (nonatomic,strong) UICollectionView *collectionView;
//内容collectionview
@property (nonatomic,strong) UICollectionView *contentCollectionView;
////内容collectionview的layout
@property (nonatomic,strong) UICollectionViewFlowLayout *contentLayout;
//@property (nonatomic,strong) UIViewController *parentViewController;

@property (nonatomic,strong) UIView *currentSelectLineView;
@end
@implementation PagesView

- (instancetype)initPagesViewWithTitleArray:(NSArray *)titleArray
							  viewControllersArray:(NSArray *)viewControllersArray
                             viewController:(UIViewController *)parentViewController delegate:(id<PagesViewDelegate>)delegate frame:(CGRect)frame{
	self = [super initWithFrame:frame];
	if (self) {
		//设置初始化信息
        
		_currentSelectTitleColor = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1];
		_currentSelectLineColor = [UIColor blueColor];
        _normalTitleColor = [UIColor colorWithRed:133.0f/255.0f green:133.0f/255.0f blue:133.0f/255.0f alpha:1];
//        _parentViewController = parentViewController;
		_titleArray = titleArray;
		_viewControllersArray = viewControllersArray;
        _isTitleScroll = NO;
        _collectionViewHeight = DefaultCollectionViewHeight;
        _titleWidth = DefaultTitleWidth;
        _currentSelectLineHeight = DefaultCurrentSelectLineHeight;
        _titleFontSize = DefaultTiltleFontSize;
		//初始化collectview标题栏
		_layout = [[UICollectionViewFlowLayout alloc] init];
		_layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
		_layout.minimumLineSpacing = 0;
		_layout.minimumInteritemSpacing = 0;
		
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), _collectionViewHeight) collectionViewLayout:_layout];
//        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
		_collectionView.showsHorizontalScrollIndicator = NO;
		_collectionView.alwaysBounceHorizontal = YES;
		_collectionView.backgroundColor = [UIColor whiteColor];
		_collectionView.tag = titleCollectionViewTag;
		[_collectionView registerClass:[TitleCollectionViewCell class] forCellWithReuseIdentifier:CellIdentifier];
		
		[self addSubview:_collectionView];
		_collectionView.delegate = self;
		_collectionView.dataSource = self;
        //添加viewcontroller到父viewcontroller里面
        [_viewControllersArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIViewController *vc = (UIViewController *)obj;
            [parentViewController addChildViewController:vc];
            [vc didMoveToParentViewController:parentViewController];
            vc.realFrame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetHeight(_collectionView.frame));
            vc.index = idx;
        }];

		//初始化内容的collectionview
		_contentLayout = [[UICollectionViewFlowLayout alloc] init];
		_contentLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
		_contentLayout.itemSize = CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetHeight(_collectionView.frame));
		_contentLayout.minimumLineSpacing = 0;
		_contentLayout.minimumInteritemSpacing = 0;
		_contentCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_collectionView.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetHeight(_collectionView.frame)) collectionViewLayout:_contentLayout];
		_contentCollectionView.backgroundColor = [UIColor whiteColor];
		_contentCollectionView.showsHorizontalScrollIndicator = NO;
		_contentCollectionView.alwaysBounceHorizontal = YES;
		[self addSubview:_contentCollectionView];
		[_contentCollectionView registerClass:[ContentCollectionViewCell class] forCellWithReuseIdentifier:ContentCellidentifier];
		_contentCollectionView.tag = contentCollectionViewTag;
		_contentCollectionView.delegate = self;
		_contentCollectionView.dataSource = self;
		_contentCollectionView.pagingEnabled = YES;
        _contentCollectionView.bounces = NO;
		_currentSelectLineView = [[UIView alloc] init];
		_currentSelectLineView.backgroundColor = _currentSelectLineColor;
		[self.collectionView addSubview:_currentSelectLineView];
		
        self.delegate = delegate;
		[self addObserver:self forKeyPath:@"currentSelectIndex" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
	}
	return self;
}

- (void)layoutSubviews {
    if (_isTitleScroll) {
        _layout.itemSize = CGSizeMake(_titleWidth, _collectionViewHeight);
        _collectionView.alwaysBounceHorizontal = YES;
    }else {
        _collectionView.alwaysBounceHorizontal = NO;
        _layout.itemSize = CGSizeMake(CGRectGetWidth(self.frame)/_titleArray.count, _collectionViewHeight);
    }

    _contentLayout.itemSize = CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - _collectionViewHeight);
    _collectionView.frame = CGRectMake(CGRectGetMinX(_collectionView.frame), CGRectGetMinY(_collectionView.frame), CGRectGetWidth(_collectionView.frame), _collectionViewHeight);
    [_viewControllersArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIViewController *vc = (UIViewController *)obj;
        vc.realFrame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetHeight(_collectionView.frame));
    }];
    _contentCollectionView.frame = CGRectMake(0, CGRectGetMaxY(_collectionView.frame),CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetHeight(_collectionView.frame));
    _currentSelectLineView.frame = [self getCurrentLineViewLocationWithScrollView:self.contentCollectionView];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tag == contentCollectionViewTag ) {
//        NSLog(@"%f",scrollView.contentOffset.x);
        self.currentSelectLineView.frame = [self getCurrentLineViewLocationWithScrollView:scrollView];
        [self.collectionView reloadData];
    }

}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView.tag == contentCollectionViewTag ) {
        self.currentSelectIndex = scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame);
        [self.collectionView reloadData];
    }

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.tag == contentCollectionViewTag ) {
        self.currentSelectIndex = scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame);
        [self.collectionView reloadData];
    }

}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	if (collectionView.tag == titleCollectionViewTag) {
		return [_titleArray count];
	}else {
		return [_viewControllersArray count];
	}

}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	if (collectionView.tag == titleCollectionViewTag) {
		TitleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];

        UIColor *textColor;
        if (self.isGradation) {
            if (_currentSelectIndex == indexPath.row) {
                CGFloat r = ([[self getRGBDictionaryByColor:self.currentSelectTitleColor][@"R"] floatValue] - [[self getRGBDictionaryByColor:self.normalTitleColor][@"R"] floatValue]) / CGRectGetWidth(self.frame) * scrollDistance;
                //            if (r < 0) {
                //                r = -r;
                //            }
                CGFloat g = ([[self getRGBDictionaryByColor:self.currentSelectTitleColor][@"G"] floatValue] - [[self getRGBDictionaryByColor:self.normalTitleColor][@"G"] floatValue]) / CGRectGetWidth(self.frame) * scrollDistance;
                //            if (g < 0) {
                //                g = -g;
                //            }
                CGFloat b = ([[self getRGBDictionaryByColor:self.currentSelectTitleColor][@"B"] floatValue] - [[self getRGBDictionaryByColor:self.normalTitleColor][@"B"] floatValue]) / CGRectGetWidth(self.frame) * scrollDistance;;
                //            if (b < 0) {
                //                b = -b;
                //            }
                if (scrollDistance > 0) {
                    textColor = [UIColor colorWithRed:([[self getRGBDictionaryByColor:self.currentSelectTitleColor][@"R"] floatValue] - r) green:([[self getRGBDictionaryByColor:self.currentSelectTitleColor][@"G"] floatValue] - g) blue:([[self getRGBDictionaryByColor:self.currentSelectTitleColor][@"B"] floatValue] - b) alpha:1];
                }else {
                    textColor = [UIColor colorWithRed:([[self getRGBDictionaryByColor:self.currentSelectTitleColor][@"R"] floatValue] + r) green:([[self getRGBDictionaryByColor:self.currentSelectTitleColor][@"G"] floatValue] + g) blue:([[self getRGBDictionaryByColor:self.currentSelectTitleColor][@"B"] floatValue] + b) alpha:1];
                }
                
            }else if (indexPath.row == _currentSelectIndex + 1 || _currentSelectIndex - 1 == indexPath.row){
                CGFloat r = ([[self getRGBDictionaryByColor:self.normalTitleColor][@"R"] floatValue] - [[self getRGBDictionaryByColor:self.currentSelectTitleColor][@"R"] floatValue]) / CGRectGetWidth(self.frame) * scrollDistance;
                //            if (r < 0) {
                //                r = -r;
                //            }
                CGFloat g = ([[self getRGBDictionaryByColor:self.normalTitleColor][@"G"] floatValue] - [[self getRGBDictionaryByColor:self.currentSelectTitleColor][@"G"] floatValue]) / CGRectGetWidth(self.frame) * scrollDistance;
                //            if (g < 0) {
                //                g = -g;
                //            }
                CGFloat b = ([[self getRGBDictionaryByColor:self.normalTitleColor][@"B"] floatValue] - [[self getRGBDictionaryByColor:self.currentSelectTitleColor][@"B"] floatValue]) / CGRectGetWidth(self.frame) * scrollDistance;;
                //            if (b < 0) {
                //                b = -b;
                //            }
                
                if (scrollDistance > 0) {
                    if (_currentSelectIndex + 1 == indexPath.row) {
                        textColor = [UIColor colorWithRed:([[self getRGBDictionaryByColor:self.normalTitleColor][@"R"] floatValue] - r) green:([[self getRGBDictionaryByColor:self.normalTitleColor][@"G"] floatValue] - g) blue:([[self getRGBDictionaryByColor:self.normalTitleColor][@"B"] floatValue] - b) alpha:1];
                    }else {
                        if (indexPath.row == self.currentSelectIndex) {
                            textColor = self.currentSelectTitleColor;
                        }else {
                            textColor = self.normalTitleColor;
                        }
                    }
                    
                }else {
                    if (_currentSelectIndex - 1 == indexPath.row) {
                        textColor = [UIColor colorWithRed:([[self getRGBDictionaryByColor:self.normalTitleColor][@"R"] floatValue] + r) green:([[self getRGBDictionaryByColor:self.normalTitleColor][@"G"] floatValue] + g) blue:([[self getRGBDictionaryByColor:self.normalTitleColor][@"B"] floatValue] + b) alpha:1];
                    }else {
                        if (indexPath.row == self.currentSelectIndex) {
                            textColor = self.currentSelectTitleColor;
                        }else {
                            textColor = self.normalTitleColor;
                        }
                    }
                    
                }
                
            }else {
                if (indexPath.row == self.currentSelectIndex) {
                    textColor = self.currentSelectTitleColor;
                }else {
                    textColor = self.normalTitleColor;
                }
            }
        }else {
            if (indexPath.row == self.currentSelectIndex) {
                textColor = self.currentSelectTitleColor;
            }else {
                textColor = self.normalTitleColor;
            }
        }

//        UIColor *textColor;
//        if (indexPath.row == self.currentSelectIndex) {
//            textColor = self.currentSelectTitleColor;
//        }else {
//            textColor = self.normalTitleColor;
//        }
        [cell configureCellWithTitle:_titleArray[indexPath.row] itemSize:_layout.itemSize color:textColor];
        cell.titleLabel.font = [UIFont systemFontOfSize:self.titleFontSize];
		return cell;
	}else {
		ContentCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ContentCellidentifier forIndexPath:indexPath];
		
		[cell configureWithViewController:_viewControllersArray[indexPath.row]];
		return cell;
	}


}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	if (collectionView.tag == titleCollectionViewTag) {
		if (_currentSelectIndex == indexPath.row) {
			return;
        }else if (_currentSelectIndex > indexPath.row) {
            [self scrollItemWithIndexPath:indexPath isRight:NO];
        }else if (_currentSelectIndex < indexPath.row) {
            [self scrollItemWithIndexPath:indexPath isRight:YES];
        }
	}else {
		
	}

}

#pragma mark - ScrollItem
- (void)scrollItemWithIndexPath:(NSIndexPath *)indexPath isRight:(BOOL)isRight{
	[_contentCollectionView setContentOffset:CGPointMake(indexPath.row * CGRectGetWidth(self.frame), 0) animated:YES];
//    NSInteger startIndex = labs(indexPath.row - _currentSelectIndex);
//    if (isRight) {
//        for (NSInteger i = 0; i < indexPath.row - startIndex; i++) {
//            [self getCurrentLineViewLocationWithScrollView:self.contentCollectionView];
//            self.currentSelectIndex++;
//        }
//    }else {
//        for (NSInteger i = 0; i <startIndex - indexPath.row; i++) {
//            [self getCurrentLineViewLocationWithScrollView:self.contentCollectionView];
//
//            self.currentSelectIndex--;
//        }
//    }
}


#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
	NSLog(@"%@",change[@"new"]);
    lastX = self.contentCollectionView.contentOffset.x;
    lastFrame = self.currentSelectLineView.frame;
	NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentSelectIndex inSection:0];
	[_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    [self.delegate currentSelectIndex:self.currentSelectIndex];
    self.currentSelectLineView.frame = [self getCurrentLineViewLocationWithScrollView:self.contentCollectionView];
    [[NSNotificationCenter defaultCenter] postNotificationName:SelectPageViewNotification object:nil userInfo:@{@"currentSelectIndex":@(self.currentSelectIndex)}];
//    [UIView animateWithDuration:0.3 animations:^{
//        self.currentSelectLineView.frame = [self getCurrentLineViewLocationWithScrollView:self.contentCollectionView];
//    } completion:^(BOOL finished) {
//
//    }];
}

#pragma mark - Setter Method
- (void)setTitleArray:(NSArray *)titleArray {
    _titleArray = titleArray;
    [self.collectionView reloadData];
    lastFrame = CGRectZero;

    [self layoutSubviews];
}

- (void)setTitleFontSize:(CGFloat)titleFontSize {
    _titleFontSize = titleFontSize;
    [_collectionView reloadData];
    [self layoutIfNeeded];
}

- (void)setCurrentSelectTitleColor:(UIColor *)currentSelectTitleColor {
    _currentSelectTitleColor = currentSelectTitleColor;
    [_collectionView reloadData];
//    [self layoutIfNeeded];
}

- (void)setNormalTitleColor:(UIColor *)normalTitleColor {
    _normalTitleColor = normalTitleColor;
    [_collectionView reloadData];
}

- (void)setIsTitleScroll:(BOOL)isTitleScroll {
	_isTitleScroll = isTitleScroll;
    [self layoutIfNeeded];

}

- (void)setCollectionViewHeight:(float)collectionViewHeight {
	_collectionViewHeight = collectionViewHeight;
    [self layoutIfNeeded];
	
}

- (void)setTitleWidth:(float)titleWidth {
	_titleWidth = titleWidth;
    [self layoutIfNeeded];
    
}

- (void)setCurrentSelectLineHeight:(float)currentSelectLineHeight {
	_currentSelectLineHeight = currentSelectLineHeight;
    [self layoutIfNeeded];
}

- (void)setCurrentSelectLineColor:(UIColor *)currentSelectLineColor {
    _currentSelectLineColor = currentSelectLineColor;
    _currentSelectLineView.backgroundColor = _currentSelectLineColor;
    [self layoutIfNeeded];
}

- (void)setIsGradation:(BOOL)isGradation {
    _isGradation = isGradation;
    [self.collectionView reloadData];
}

- (void)setIsFitSelectLineViewWidth:(BOOL)isFitSelectLineViewWidth {
    _isFitSelectLineViewWidth = isFitSelectLineViewWidth;
}

- (void)setCurrentSelectLineWidth:(float)currentSelectLineWidth {
    _currentSelectLineWidth = currentSelectLineWidth;
    _currentSelectLineView.frame = [self getCurrentLineViewLocationWithScrollView:self.contentCollectionView];

}

#pragma mark - private method
- (void)updateUI {
	_collectionView.frame = CGRectMake(CGRectGetMinX(_collectionView.frame), CGRectGetMinY(_collectionView.frame), CGRectGetWidth(_collectionView.frame), _collectionViewHeight);
	_contentCollectionView.frame = CGRectMake(0, CGRectGetMaxY(_collectionView.frame),CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetHeight(_collectionView.frame));
	_currentSelectLineView.frame = CGRectMake(0, CGRectGetMaxY(_collectionView.frame) - _currentSelectLineHeight,_layout.itemSize.width, _currentSelectLineHeight);
}


- (CGRect)getCurrentLineViewLocationWithScrollView:(UIScrollView *)scrollView {
    scrollDistance = scrollView.contentOffset.x - lastX;
    
    contentOffSetX = scrollView.contentOffset.x / [_titleArray count];
    CGRect re;
    if (self.isFitSelectLineViewWidth) {
        NSString *currentTitle = _titleArray[_currentSelectIndex];
        CGSize currentTitleSize = [currentTitle boundingRectWithSize:CGSizeMake(1000, 1000) options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.titleFontSize]} context:nil].size;
        
        NSString *nextTitle;
        CGSize nextTitleSize = CGSizeZero;
        if (scrollDistance > 0 && _currentSelectIndex < [_titleArray count]) {
            nextTitle = _titleArray[_currentSelectIndex + 1];
        }else if (scrollDistance < 0 && _currentSelectIndex > 0){
            nextTitle = _titleArray[_currentSelectIndex - 1];
        }
        nextTitleSize = [nextTitle boundingRectWithSize:CGSizeMake(1000, 1000) options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.titleFontSize]} context:nil].size;
        CGFloat distance = nextTitleSize.width - currentTitleSize.width;
        
        if (contentOffSetX <= 0) {
            contentOffSetX = 0;
        }
        
        if (contentOffSetX > CGRectGetWidth(self.frame) / [_titleArray count]) {
            
            contentOffSetX = CGRectGetWidth(self.frame) / [_titleArray count];
        }
        CGFloat titleCellWidth = CGRectGetWidth(self.frame)/[_titleArray count];
        if (lastFrame.size.height == 0) {
            lastFrame = CGRectMake(titleCellWidth / 2 - currentTitleSize.width/2, CGRectGetHeight(self.collectionView.frame) - self.currentSelectLineHeight, currentTitleSize.width, self.currentSelectLineHeight);
        }
        
        if (scrollDistance < 0) {
            re = CGRectMake(scrollDistance/[_titleArray count] * (titleCellWidth +  distance / 2)  /  titleCellWidth + CGRectGetMinX(lastFrame), CGRectGetMinY(lastFrame), (distance / titleCellWidth) * fabs(scrollDistance / [_titleArray count]) + currentTitleSize.width, CGRectGetHeight(lastFrame));
        }else {
            re = CGRectMake(scrollDistance/[_titleArray count] * (titleCellWidth -  distance / 2)  /  titleCellWidth + CGRectGetMinX(lastFrame), CGRectGetMinY(lastFrame), (distance / titleCellWidth) * fabs(scrollDistance / [_titleArray count]) + currentTitleSize.width, CGRectGetHeight(lastFrame));
        }
        //    NSLog(@"x=%f,y=%f,w=%f,h=%f",re.origin.x,re.origin.y,re.size.width,re.size.height);
    }else {
        
        if (contentOffSetX <= 0) {
            contentOffSetX = 0;
        }
        
        if (contentOffSetX > CGRectGetWidth(self.frame) / [_titleArray count]) {
            
            contentOffSetX = CGRectGetWidth(self.frame) / [_titleArray count];
        }
        CGFloat titleCellWidth = CGRectGetWidth(self.frame)/[_titleArray count];
        CGFloat selectLineWidth = 0;
        if (self.isTitleScroll) {
            titleCellWidth = self.titleWidth;
            if (self.currentSelectLineWidth <= 0) {
                selectLineWidth = titleCellWidth;
            }else {
                selectLineWidth = self.currentSelectLineWidth;
            }
        }else {
            titleCellWidth = CGRectGetWidth(self.frame)/[_titleArray count];
            if (self.currentSelectLineWidth <= 0) {
                selectLineWidth = titleCellWidth;
            }else {
                selectLineWidth = self.currentSelectLineWidth;
            }
        }

        if (lastFrame.size.width != selectLineWidth) {
            lastFrame = CGRectMake(titleCellWidth / 2 - selectLineWidth/2, CGRectGetHeight(self.collectionView.frame) - self.currentSelectLineHeight, selectLineWidth, self.currentSelectLineHeight);
        }
        
        if (scrollDistance < 0) {
            re = CGRectMake(scrollDistance/CGRectGetWidth(self.frame) * titleCellWidth + CGRectGetMinX(lastFrame), CGRectGetMinY(lastFrame),selectLineWidth, CGRectGetHeight(lastFrame));
        }else {
            re = CGRectMake(scrollDistance/CGRectGetWidth(self.frame) * titleCellWidth + CGRectGetMinX(lastFrame), CGRectGetMinY(lastFrame),selectLineWidth, CGRectGetHeight(lastFrame));
        }
    }


    return re;

}

//获取navigationBar的高度
- (CGFloat)getNavigationBarHeight {
    if (([UIScreen mainScreen].bounds.size.width == 375.0f && [UIScreen mainScreen].bounds.size.height == 812.0f)) {
        return 88;
    }else {
        return 64;
    }
}
//获取下面的高度
- (CGFloat)getTabbarHeight {
    if (([UIScreen mainScreen].bounds.size.width == 375.0f && [UIScreen mainScreen].bounds.size.height == 812.0f)) {
        return 34;
    }else {
        return 0;
    }
}


- (NSDictionary *)getRGBDictionaryByColor:(UIColor *)originColor

{
    
    CGFloat r=0,g=0,b=0,a=0;
    
    if ([self respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        
        [originColor getRed:&r green:&g blue:&b alpha:&a];
        
    }
    
    else {
        
        const CGFloat *components = CGColorGetComponents(originColor.CGColor);
        
        r = components[0];
        
        g = components[1];
        
        b = components[2];
        
        a = components[3];
        
    }
    
    
    
    return @{@"R":@(r),
             
             @"G":@(g),
             
             @"B":@(b),
             
             @"A":@(a)};
    
}
- (void)dealloc {
	[self removeObserver:self forKeyPath:@"currentSelectIndex"];
}
@end
