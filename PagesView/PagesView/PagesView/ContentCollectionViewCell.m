//
//  ContentCollectionViewCell.m
//  PagesView
//
//  Created by zjl on 2017/11/14.
//  Copyright © 2017年 zjl. All rights reserved.
//

#import "ContentCollectionViewCell.h"

@implementation ContentCollectionViewCell
- (void)configureWithViewController:(UIViewController *)vc {
	self.contentView.backgroundColor = [UIColor redColor];
	UIView *vcView = vc.view;
	vcView.frame = CGRectMake(0, 0, CGRectGetWidth(vcView.frame), CGRectGetHeight(self.contentView.frame));
	[self.contentView addSubview:vcView];
	
}
@end
