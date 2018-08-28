//
//  UIViewController+AddProperties.m
//  YouJiaZhang
//
//  Created by zjl on 2018/8/12.
//  Copyright © 2018年 sky. All rights reserved.
//

#import "UIViewController+AddProperties.h"
#import <objc/runtime.h>
char indexKey;
char xKey;
char yKey;
char widthKey;
char heightKey;
@implementation UIViewController (AddProperties)
- (void)setIndex:(NSInteger)index {
    objc_setAssociatedObject(self, &indexKey, @(index), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)index {
    NSNumber *num = objc_getAssociatedObject(self, &indexKey);
    return [num integerValue];
}

- (void)setRealFrame:(CGRect)realFrame {
    objc_setAssociatedObject(self, &xKey, @(realFrame.origin.x), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &yKey, @(realFrame.origin.y), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &widthKey, @(realFrame.size.width), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &heightKey, @(realFrame.size.height), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGRect)realFrame {
    NSNumber *x = objc_getAssociatedObject(self, &xKey);
    NSNumber *y = objc_getAssociatedObject(self, &yKey);
    NSNumber *width = objc_getAssociatedObject(self, &widthKey);
    NSNumber *height = objc_getAssociatedObject(self, &heightKey);
    return CGRectMake([x floatValue], [y floatValue], [width floatValue], [height floatValue]);
}
@end
