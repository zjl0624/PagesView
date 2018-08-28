//
//  ContentViewController.m
//  PagesView
//
//  Created by zjl on 2017/11/10.
//  Copyright © 2017年 zjl. All rights reserved.
//

#import "ContentViewController.h"
#import "PagesView.h"

@interface ContentViewController () {
	UILabel *contentLabel;
	UIButton *testButton;
	UITapGestureRecognizer *tapGesture;
}

@end

@implementation ContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame =CGRectMake(0, 0, PVScreenWidth, PVScreenHeight - 64 - 48 - 56);
	[self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI {
	self.view.backgroundColor = [UIColor lightGrayColor];
	contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
	contentLabel.textAlignment = NSTextAlignmentCenter;
	contentLabel.text = self.content;
	contentLabel.userInteractionEnabled = YES;
	[self.view addSubview:contentLabel];
	
	testButton = [UIButton buttonWithType:UIButtonTypeSystem];
	testButton.frame = CGRectMake(0, 64, 120, 60);
	[testButton setTitle:@"测试" forState:UIControlStateNormal];
	[self.view addSubview:testButton];
	[testButton addTarget:self action:@selector(testButtonClick) forControlEvents:UIControlEventTouchUpInside];
	
	tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
	[contentLabel addGestureRecognizer:tapGesture];
}

- (void)testButtonClick {
	NSLog(@"点击了按钮");
}
- (void)tap {
	NSLog(@"点击了标签");
}
@end
