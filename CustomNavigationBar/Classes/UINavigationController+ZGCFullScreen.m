//
//  UINavigationController+ZGCFullScreen.m
//  ZGC_BaseNavigation
//
//  Created by PangJunJie on 2018/4/12.
//  Copyright © 2018年 PangJunJie. All rights reserved.
//

#import "UINavigationController+ZGCFullScreen.h"
#import "NSObject+ZGCRuntime.h"

@interface UINavigationController()<UIGestureRecognizerDelegate>

@end

@implementation UIViewController (ZGCFullScreen)

-(BOOL)zgc_disableInteractivePop{
    return [objc_getAssociatedObject(self, @selector(zgc_disableInteractivePop)) boolValue];
}

-(void)setZgc_disableInteractivePop:(BOOL)zgc_disableInteractivePop{
    objc_setAssociatedObject(self, @selector(zgc_disableInteractivePop), @(zgc_disableInteractivePop), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UINavigationController (SXFullScreen)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethodWithOriginSel:@selector(viewDidLoad)
                                     swizzledSel:@selector(zgc_viewDidLoad)];
    });
}

-(void)zgc_viewDidLoad {
    //接替系统滑动返回手势
    NSArray *internalTargets = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
    id internalTarget = [internalTargets.firstObject valueForKey:@"target"];
    SEL handler = NSSelectorFromString(@"handleNavigationTransition:");
    
    UIPanGestureRecognizer * fullScreenGesture = [[UIPanGestureRecognizer alloc]initWithTarget:internalTarget action:handler];
    fullScreenGesture.delegate = self;
    fullScreenGesture.maximumNumberOfTouches = 1;
    
    UIView *targetView = self.interactivePopGestureRecognizer.view;
    [targetView addGestureRecognizer:fullScreenGesture];
    
    [self.interactivePopGestureRecognizer setEnabled:NO];
    
    [self zgc_viewDidLoad];
}

/**
 全屏滑动返回判断
 
 @param gestureRecognizer 手势
 @return 是否响应
 */
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    if (self.topViewController.zgc_disableInteractivePop) {
        return NO;
    }
    
    if ([gestureRecognizer translationInView:gestureRecognizer.view].x <= 0) {
        return NO;
    }
    
    if ([[self valueForKey:@"_isTransitioning"] boolValue]) {
        return NO;
    }
    
    return (self.childViewControllers.count != 1);
}

//修复有水平方向滚动的ScrollView时边缘返回手势失效的问题
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return (otherGestureRecognizer.state == UIGestureRecognizerStateBegan && [otherGestureRecognizer.view isKindOfClass:NSClassFromString(@"UILayoutContainerView")]);
}

@end
