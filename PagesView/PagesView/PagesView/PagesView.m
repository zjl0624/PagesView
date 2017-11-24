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

NSString *const CellIdentifier = @"cell";
NSString *const ContentCellidentifier = @"ContentCell";
float const CurrentSelectLineHeight = 3;
typedef NS_ENUM(NSInteger,CollectionViewTag){
	titleCollectionViewTag,
	contentCollectionViewTag
	
};
@interface PagesView()<UICollectionViewDelegate,UICollectionViewDataSource>

//标题栏的collectionview的layout
@property (nonatomic,strong) UICollectionViewFlowLayout *layout;
//标题栏的collectionview
@property (nonatomic,strong) UICollectionView *collectionView;
//内容collectionview
@property (nonatomic,strong) UICollectionView *contentCollectionView;
////内容collectionview的layout
@property (nonatomic,strong) UICollectionViewFlowLayout *contentLayout;
@property (nonatomic,strong) UIViewController *parentViewController;

@property (nonatomic,strong) UIView *currentSelectLineView;
@end
@implementation PagesView

- (instancetype)initPagesViewWithTitleArray:(NSArray *)titleArray
							  viewControllersArray:(NSArray *)viewControllersArray
									viewController:(UIViewController *)parentViewController{
	self = [super init];
	if (self) {
		//设置初始化信息
		self.frame = CGRectMake(0, 64, PVScreenWidth, PVScreenHeight - 64);
//		[parentViewController.view addSubview:self];
		_currentSelectTitleColor = [UIColor redColor];
		_currentSelectLineColor = [UIColor blackColor];
		_parentViewController = parentViewController;
		_titleArray = titleArray;
		_viewControllersArray = viewControllersArray;

		//初始化collectview标题栏
		_layout = [[UICollectionViewFlowLayout alloc] init];
		_layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
		self.isTitleScroll = NO;
		self.collectionViewHeight = 60;
		self.titleWidth = 120;
		self.currentSelectLineHeight = 1;
//		if (_isTitleScroll) {
//			_layout.itemSize = CGSizeMake(_titleWidth, _collectionViewHeight);
//		}else {
//			_layout.itemSize = CGSizeMake(PVScreenWidth/_titleArray.count, _collectionViewHeight);
//		}
		_layout.minimumLineSpacing = 0;
		_layout.minimumInteritemSpacing = 0;
		
		_collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, PVScreenWidth, _collectionViewHeight) collectionViewLayout:_layout];
		_collectionView.showsHorizontalScrollIndicator = NO;
		_collectionView.alwaysBounceHorizontal = YES;
		_collectionView.backgroundColor = [UIColor whiteColor];
		_collectionView.tag = titleCollectionViewTag;
		[_collectionView registerClass:[TitleCollectionViewCell class] forCellWithReuseIdentifier:CellIdentifier];
		
		[self addSubview:_collectionView];
		_collectionView.delegate = self;
		_collectionView.dataSource = self;
		
		//添加viewcontroller到父viewcontroller里面
		[viewControllersArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			UIViewController *vc = (UIViewController *)obj;
			[parentViewController addChildViewController:vc];
			[vc didMoveToParentViewController:parentViewController];
			[vc.view setFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetHeight(_collectionView.frame))];
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
//		_contentCollectionView.allowsSelection = NO;
//		_contentCollectionView.decelerationRate = 0;
//		_contentCollectionView.bounces = NO;
		_currentSelectLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_collectionView.frame) - _currentSelectLineHeight,_layout.itemSize.width, _currentSelectLineHeight)];
		_currentSelectLineView.backgroundColor = _currentSelectLineColor;
		[self.collectionView addSubview:_currentSelectLineView];
		
		
		[self addObserver:self forKeyPath:@"currentSelectIndex" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
	}
	return self;
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
		if (_currentSelectIndex == indexPath.row) {
			textColor = _currentSelectTitleColor;
		}else {
			textColor = [UIColor blackColor];
		}
		[cell configureCellWithTitle:_titleArray[indexPath.row] itemSize:_layout.itemSize color:textColor];
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
		}
		[self scrollItemWithIndexPath:indexPath];
	}else {
		
	}

}
#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	if (scrollView.tag == contentCollectionViewTag) {
		self.currentSelectIndex = scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame);
		[_collectionView reloadData];
	}

}

#pragma mark - ScrollItem
- (void)scrollItemWithIndexPath:(NSIndexPath *)indexPath{

	[_contentCollectionView setContentOffset:CGPointMake(indexPath.row * CGRectGetWidth(self.frame), 0) animated:YES];
	self.currentSelectIndex = indexPath.row;
	[_collectionView reloadData];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
	NSLog(@"%@",change[@"new"]);
	[UIView animateWithDuration:0.25 animations:^{
		self.currentSelectLineView.frame = CGRectMake(self.currentSelectIndex * CGRectGetWidth(self.currentSelectLineView.frame), CGRectGetMinY(self.currentSelectLineView.frame), CGRectGetWidth(self.currentSelectLineView.frame), CGRectGetHeight(self.currentSelectLineView.frame));
	} completion:^(BOOL finished) {
		
	}];
}

#pragma mark - Setter Method
- (void)setIsTitleScroll:(BOOL)isTitleScroll {
	_isTitleScroll = isTitleScroll;
	if (_isTitleScroll) {
		_layout.itemSize = CGSizeMake(_titleWidth, _collectionViewHeight);
		_collectionView.alwaysBounceHorizontal = YES;
	}else {
		_collectionView.alwaysBounceHorizontal = NO;
		_layout.itemSize = CGSizeMake(PVScreenWidth/_titleArray.count, _collectionViewHeight);
	}
	[self updateUI];

}

- (void)setCollectionViewHeight:(float)collectionViewHeight {
	_collectionViewHeight = collectionViewHeight;
	self.isTitleScroll = _isTitleScroll;
}

- (void)setTitleWidth:(float)titleWidth {
	_titleWidth = titleWidth;
	self.isTitleScroll = _isTitleScroll;
}

- (void)setCurrentSelectLineHeight:(float)currentSelectLineHeight {
	_currentSelectLineHeight = currentSelectLineHeight;
	self.isTitleScroll = _isTitleScroll;
}
- (void)updateUI {
	_collectionView.frame = CGRectMake(CGRectGetMinX(_collectionView.frame), CGRectGetMinY(_collectionView.frame), CGRectGetWidth(_collectionView.frame), _collectionViewHeight);
	_contentCollectionView.frame = CGRectMake(0, CGRectGetMaxY(_collectionView.frame),CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetHeight(_collectionView.frame));
	_currentSelectLineView.frame = CGRectMake(0, CGRectGetMaxY(_collectionView.frame) - _currentSelectLineHeight,_layout.itemSize.width, _currentSelectLineHeight);
}
- (void)dealloc {
	[self removeObserver:self forKeyPath:@"currentSelectIndex"];
}
@end
