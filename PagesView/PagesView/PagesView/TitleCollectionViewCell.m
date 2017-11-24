//
//  TitleCollectionViewCell.m
//  PagesView
//
//  Created by zjl on 2017/11/9.
//  Copyright © 2017年 zjl. All rights reserved.
//

#import "TitleCollectionViewCell.h"
@interface TitleCollectionViewCell()
@property (nonatomic,strong) UILabel *titleLabel;
@end
@implementation TitleCollectionViewCell


- (void)configureCellWithTitle:(NSString *)title itemSize:(CGSize)itemSize color:(UIColor *)color{
	if (!_titleLabel) {
		self.contentView.backgroundColor = [UIColor whiteColor];
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, itemSize.width, itemSize.height)];
		[self.contentView addSubview:_titleLabel];
		_titleLabel.textAlignment = NSTextAlignmentCenter;
	}
	_titleLabel.textColor = color;
	_titleLabel.text = title;


}
@end
