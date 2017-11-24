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
	[self.contentView addSubview:vc.view];
	
}
@end
