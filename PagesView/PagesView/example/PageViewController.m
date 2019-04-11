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
	NSArray *titleArray = @[@"标签一",@"标签二二二二二",@"标签三",@"标签四"];
	NSMutableArray *viewControllersArray = [[NSMutableArray alloc] init];
	[titleArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		ContentViewController *contentVC = [[ContentViewController alloc] init];
		contentVC.content = [NSString stringWithFormat:@"%@的页面",obj];
		[viewControllersArray addObject:contentVC];
	}];
	PagesView *pagesView = [[PagesView alloc] initPagesViewWithTitleArray:titleArray viewControllersArray:viewControllersArray viewController:self delegate:nil frame:CGRectMake(0, 88, PVScreenWidth, PVScreenHeight - 88)];
//	pagesView.isTitleScroll = YES;
//	pagesView.collectionViewHeight = 20;
//	pagesView.titleWidth = 60;
//	pagesView.currentSelectLineHeight = 5;
    pagesView.normalTitleColor = [UIColor yellowColor];
    pagesView.currentSelectTitleColor = [UIColor redColor];
	[self.view addSubview:pagesView];
}

@end
