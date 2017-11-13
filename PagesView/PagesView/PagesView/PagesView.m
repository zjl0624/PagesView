//
//  PagesView.m
//  PagesView
//
//  Created by zjl on 2017/11/9.
//  Copyright © 2017年 zjl. All rights reserved.
//

#import "PagesView.h"
#import "TitleCollectionViewCell.h"
NSString *const CellIdentifier = @"cell";
@interface PagesView()<UICollectionViewDelegate,UICollectionViewDataSource> {
	NSInteger currentSelectIndex;
}

@property (nonatomic,strong) UICollectionViewFlowLayout *layout;
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UIViewController *parentViewController;
@property (nonatomic,strong) UISwipeGestureRecognizer *leftSwipeGesture;
@property (nonatomic,strong) UISwipeGestureRecognizer *rightSwipeGesture;
@end
@implementation PagesView

- (instancetype)initDefaultPagesViewWithTitleArray:(NSArray *)titleArray
							  viewControllersArray:(NSArray *)viewControllersArray
									viewController:(UIViewController *)parentViewController{
	self = [super init];
	if (self) {
		//设置初始化信息
		self.frame = CGRectMake(0, 64, PVScreenWidth, PVScreenHeight - 64);
		[parentViewController.view addSubview:self];
		_parentViewController = parentViewController;
		_titleArray = titleArray;
		_viewControllersArray = viewControllersArray;
		_collectionViewHeight = 60;
		_titleWidth = 120;
		//初始化collectview标题栏
		_layout = [[UICollectionViewFlowLayout alloc] init];
		_layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
		if (_isTitleScroll) {
			_layout.itemSize = CGSizeMake(_titleWidth, _collectionViewHeight);
		}else {
			_layout.itemSize = CGSizeMake(PVScreenWidth/_titleArray.count, _collectionViewHeight);
		}
		_layout.minimumLineSpacing = 0;
		_layout.minimumInteritemSpacing = 0;
		
		_collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, PVScreenWidth, _collectionViewHeight) collectionViewLayout:_layout];
		_collectionView.showsHorizontalScrollIndicator = NO;
		_collectionView.alwaysBounceHorizontal = YES;
		_collectionView.backgroundColor = [UIColor whiteColor];
		[_collectionView registerClass:[TitleCollectionViewCell class] forCellWithReuseIdentifier:CellIdentifier];
		
		[self addSubview:_collectionView];
		_collectionView.delegate = self;
		_collectionView.dataSource = self;
		
		//添加viewcontroller到父viewcontroller里面
		[viewControllersArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			UIViewController *vc = (UIViewController *)obj;
			[parentViewController addChildViewController:vc];
			[vc didMoveToParentViewController:parentViewController];
			[vc.view setFrame:CGRectMake(0, CGRectGetMaxY(_collectionView.frame) + 64, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetHeight(_collectionView.frame))];
			[parentViewController.view addSubview:vc.view];
			//添加滑动手势
			UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
			[leftSwipeGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
			[vc.view addGestureRecognizer:leftSwipeGesture];
			
			UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
			[rightSwipeGesture setDirection:UISwipeGestureRecognizerDirectionRight];
			[vc.view addGestureRecognizer:rightSwipeGesture];
		}];
		
		//添加滑动手势
//		_leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
//		[_leftSwipeGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
//		[self addGestureRecognizer:_leftSwipeGesture];
//		
//		_rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
//		[_rightSwipeGesture setDirection:UISwipeGestureRecognizerDirectionRight];
//		[self addGestureRecognizer:_rightSwipeGesture];
	}
	return self;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [_titleArray count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	TitleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
	[cell configureCellWithTitle:_titleArray[indexPath.row] itemSize:_layout.itemSize];
	return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	if (currentSelectIndex == indexPath.row) {
		return;
	}
	[self transitionFromViewController:indexPath.row];
}

#pragma mark - UISwipeGestureRecognizer
- (void)swipe:(UISwipeGestureRecognizer *)swipeGes {
	UISwipeGestureRecognizerDirection direction = swipeGes.direction;
	if (direction == UISwipeGestureRecognizerDirectionRight) {
		if (currentSelectIndex > 0) {
			[self transitionFromViewController:(currentSelectIndex - 1)];
		}
	}else {
		if (currentSelectIndex < _viewControllersArray.count - 1) {
			[self transitionFromViewController:(currentSelectIndex + 1)];
		}
	}

}

#pragma mark - transitionFromViewController 
- (void)transitionFromViewController:(NSInteger)newControllerIndex {
//	[_parentViewController addChildViewController:_viewControllersArray[newControllerIndex]];
	
	[_parentViewController transitionFromViewController:_viewControllersArray[currentSelectIndex] toViewController:_viewControllersArray[newControllerIndex] duration:3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
		
	} completion:^(BOOL finished) {
		if (finished) {
//			[_viewControllersArray[newControllerIndex] didMoveToParentViewController:_parentViewController];
//			[_viewControllersArray[currentSelectIndex] willMoveToParentViewController:nil];
//			[_viewControllersArray[currentSelectIndex] removeFromParentViewController];
//			[self sendSubviewToBack:((UIViewController *)_viewControllersArray[newControllerIndex]).view];
//			[((UIViewController *)_viewControllersArray[newControllerIndex]).view bringSubviewToFront:self];
			
//			[_parentViewController.view insertSubview:((UIViewController *)_viewControllersArray[newControllerIndex]).view aboveSubview:self];
			currentSelectIndex = newControllerIndex;
		}

	}];

}
@end
