//
//  UINavigation+ZGCFixSpace.m
//  ZGC_BaseNavigation
//
//  Created by PangJunJie on 2018/4/12.
//  Copyright © 2018年 PangJunJie. All rights reserved.
//

#import "UINavigation+ZGCFixSpace.h"
#import "NSObject+ZGCRuntime.h"
#import <Availability.h>

#ifndef deviceVersion
#define deviceVersion [[[UIDevice currentDevice] systemVersion] floatValue]
#endif

static BOOL zgc_disableFixSpace = NO;

static BOOL zgc_tempDisableFixSpace = NO;

@implementation UINavigationController (ZGCFixSpace)

+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethodWithOriginSel:@selector(viewWillAppear:)
                                     swizzledSel:@selector(zgc_viewWillAppear:)];
        
        [self swizzleInstanceMethodWithOriginSel:@selector(viewWillDisappear:)
                                     swizzledSel:@selector(zgc_viewWillDisappear:)];
        //FIXME:修正iOS11之后push或者pop动画为NO 系统不主动调用UINavigationBar的layoutSubviews方法
        if (deviceVersion >= 11) {
            [self swizzleInstanceMethodWithOriginSel:@selector(pushViewController:animated:)
                                         swizzledSel:@selector(zgc_pushViewController:animated:)];
            
            [self swizzleInstanceMethodWithOriginSel:@selector(popViewControllerAnimated:)
                                         swizzledSel:@selector(zgc_popViewControllerAnimated:)];
            
            [self swizzleInstanceMethodWithOriginSel:@selector(popToViewController:animated:)
                                         swizzledSel:@selector(zgc_popToViewController:animated:)];
            
            [self swizzleInstanceMethodWithOriginSel:@selector(popToRootViewControllerAnimated:)
                                         swizzledSel:@selector(zgc_popToRootViewControllerAnimated:)];
            
            [self swizzleInstanceMethodWithOriginSel:@selector(setViewControllers:animated:)
                                         swizzledSel:@selector(zgc_setViewControllers:animated:)];
        }
    });
}


-(void)zgc_viewWillAppear:(BOOL)animated {
    if ([self isKindOfClass:[UIImagePickerController class]]) {
        zgc_tempDisableFixSpace = zgc_disableFixSpace;
        zgc_disableFixSpace = YES;
    }
    [self zgc_viewWillAppear:animated];
}

-(void)zgc_viewWillDisappear:(BOOL)animated{
    if ([self isKindOfClass:[UIImagePickerController class]]) {
        zgc_disableFixSpace = zgc_tempDisableFixSpace;
    }
    [self zgc_viewWillDisappear:animated];
}

//FIXME:修正iOS11之后push或者pop动画为NO 系统不主动调用UINavigationBar的layoutSubviews方法
-(void)zgc_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (!animated) {
        [self.navigationBar layoutSubviews];
    }
    
    //跳转时隐藏Tabbar
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    
    [self zgc_pushViewController:viewController animated:animated];
}

- (nullable UIViewController *)zgc_popViewControllerAnimated:(BOOL)animated{
    UIViewController *vc = [self zgc_popViewControllerAnimated:animated];
    if (!animated) {
        [self.navigationBar layoutSubviews];
    }
    return vc;
}

- (nullable NSArray<__kindof UIViewController *> *)zgc_popToViewController:(UIViewController *)viewController animated:(BOOL)animated{
    NSArray *vcs = [self zgc_popToViewController:viewController animated:animated];
    if (!animated) {
        [self.navigationBar layoutSubviews];
    }
    return vcs;
}

- (nullable NSArray<__kindof UIViewController *> *)zgc_popToRootViewControllerAnimated:(BOOL)animated{
    NSArray *vcs = [self zgc_popToRootViewControllerAnimated:animated];
    if (!animated) {
        [self.navigationBar layoutSubviews];
    }
    return vcs;
}

- (void)zgc_setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated NS_AVAILABLE_IOS(3_0){
    [self zgc_setViewControllers:viewControllers animated:animated];
    if (!animated) {
        [self.navigationBar layoutSubviews];
    }
}

@end

@implementation UINavigationBar (ZGCFixSpace)

+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethodWithOriginSel:@selector(layoutSubviews)
                                     swizzledSel:@selector(zgc_layoutSubviews)];
    });
}

-(void)zgc_layoutSubviews{
    [self zgc_layoutSubviews];
    
    if (deviceVersion >= 11 && !zgc_disableFixSpace) {//需要调节
        self.layoutMargins = UIEdgeInsetsZero;
        CGFloat space = zgc_defaultFixSpace;
        for (UIView *subview in self.subviews) {
            if ([NSStringFromClass(subview.class) containsString:@"ContentView"]) {
                subview.layoutMargins = UIEdgeInsetsMake(0, space, 0, space);//可修正iOS11之后的偏移
                break;
            }
        }
    }
}

@end

@implementation UINavigationItem (ZGCFixSpace)

+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethodWithOriginSel:@selector(setLeftBarButtonItem:)
                                     swizzledSel:@selector(zgc_setLeftBarButtonItem:)];
        
        [self swizzleInstanceMethodWithOriginSel:@selector(setLeftBarButtonItems:)
                                     swizzledSel:@selector(zgc_setLeftBarButtonItems:)];
        
        [self swizzleInstanceMethodWithOriginSel:@selector(setRightBarButtonItem:)
                                     swizzledSel:@selector(zgc_setRightBarButtonItem:)];
        
        [self swizzleInstanceMethodWithOriginSel:@selector(setRightBarButtonItems:)
                                     swizzledSel:@selector(zgc_setRightBarButtonItems:)];
    });
    
}

-(void)zgc_setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem {
    if (deviceVersion >= 11) {
        [self zgc_setLeftBarButtonItem:leftBarButtonItem];
    } else {
        if (!zgc_disableFixSpace && leftBarButtonItem) {//存在按钮且需要调节
            [self setLeftBarButtonItems:@[leftBarButtonItem]];
        } else {//不存在按钮,或者不需要调节
            [self zgc_setLeftBarButtonItem:leftBarButtonItem];
        }
    }
}

-(void)zgc_setLeftBarButtonItems:(NSArray<UIBarButtonItem *> *)leftBarButtonItems {
    if (leftBarButtonItems.count) {
        NSMutableArray *items = [NSMutableArray arrayWithObject:[self fixedSpaceWithWidth:zgc_defaultFixSpace-20]];//可修正iOS11之前的偏移
        [items addObjectsFromArray:leftBarButtonItems];
        [self zgc_setLeftBarButtonItems:items];
    } else {
        [self zgc_setLeftBarButtonItems:leftBarButtonItems];
    }
}

-(void)zgc_setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem{
    if (deviceVersion >= 11) {
        [self zgc_setRightBarButtonItem:rightBarButtonItem];
    } else {
        if (!zgc_disableFixSpace && rightBarButtonItem) {//存在按钮且需要调节
            [self setRightBarButtonItems:@[rightBarButtonItem]];
        } else {//不存在按钮,或者不需要调节
            [self zgc_setRightBarButtonItem:rightBarButtonItem];
        }
    }
}

-(void)zgc_setRightBarButtonItems:(NSArray<UIBarButtonItem *> *)rightBarButtonItems{
    if (rightBarButtonItems.count) {
        NSMutableArray *items = [NSMutableArray arrayWithObject:[self fixedSpaceWithWidth:zgc_defaultFixSpace-20]];//可修正iOS11之前的偏移
        [items addObjectsFromArray:rightBarButtonItems];
        [self zgc_setRightBarButtonItems:items];
    } else {
        [self zgc_setRightBarButtonItems:rightBarButtonItems];
    }
}

-(UIBarButtonItem *)fixedSpaceWithWidth:(CGFloat)width {
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                               target:nil
                                                                               action:nil];
    fixedSpace.width = width;
    return fixedSpace;
}

@end
