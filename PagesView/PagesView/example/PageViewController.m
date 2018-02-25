//
//  PageViewController.m
//  PagesView
//
//  Created by zjl on 2017/11/9.
//  Copyright © 2017年 zjl. All rights reserved.
//

#import "PageViewController.h"
#import "PagesView.h"
#import "ContentViewController.h"

@interface PageViewController ()

@end

@implementation PageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor whiteColor];
	self.automaticallyAdjustsScrollViewInsets = NO;//这句话一定要加
	[self initPagesView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initPagesView {
	NSArray *titleArray = @[@"标题1",@"标题2",@"标题3",@"标题4",@"标题5"];
	NSMutableArray *viewControllersArray = [[NSMutableArray alloc] init];
	[titleArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		ContentViewController *contentVC = [[ContentViewController alloc] init];
		contentVC.content = [NSString stringWithFormat:@"%@的页面",obj];
		[viewControllersArray addObject:contentVC];
	}];
	PagesView *pagesView = [[PagesView alloc] initPagesViewWithTitleArray:titleArray viewControllersArray:viewControllersArray viewController:self];
	pagesView.isTitleScroll = YES;
//	pagesView.collectionViewHeight = 30;
//	pagesView.titleWidth = 90;
//	pagesView.currentSelectLineHeight = 1;
	[self.view addSubview:pagesView];
}

@end
