//
//  PagesView.h
//  PagesView
//  ！！！！！在使用时，很有可能需要把viewcontroller的automaticallyAdjustsScrollViewInsets这个属性改为no，才能正常使用！！！！！！
//  Created by zjl on 2017/11/9.
//  Copyright © 2017年 zjl. All rights reserved.
//
#define PVScreenWidth [UIScreen mainScreen].bounds.size.width
#define PVScreenHeight [UIScreen mainScreen].bounds.size.height
#import <UIKit/UIKit.h>

@interface PagesView : UIView
//上方滚动条的高度,默认是60
@property (nonatomic,assign) float collectionViewHeight;

//标题栏是否允许滚动，默认是no
@property (nonatomic,assign) BOOL isTitleScroll;

//每一个标题的宽度,只有当允许滚动的时候，该属性才生效
@property (nonatomic,assign) float titleWidth;

//滚动条标题的数组
@property (nonatomic,strong) NSArray *titleArray;

//viewcontroller的数组
@property (nonatomic,strong) NSArray *viewControllersArray;



//初始化一个默认的pagesview
- (instancetype)initDefaultPagesViewWithTitleArray:(NSArray *)titleArray
							  viewControllersArray:(NSArray *)viewControllersArray
									viewController:(UIViewController *)parentViewController;
@end
