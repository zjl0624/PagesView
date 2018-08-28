//
//  UIViewController+AddProperties.h
//  YouJiaZhang
//  给UIViewController这个类添加两个属性
//  Created by zjl on 2018/8/12.
//  Copyright © 2018年 sky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (AddProperties)
@property (nonatomic,assign) NSInteger index;//当前的子viewcontroller是第几个
@property (nonatomic,assign) CGRect realFrame;//当前viewcontroller.view的frame
@end
