//
//  UINavigationController+ZGCFullScreen.h
//  ZGC_BaseNavigation
//
//  Created by PangJunJie on 2018/4/12.
//  Copyright © 2018年 PangJunJie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (SXFullScreen)

/**
 禁止右滑返回属性
 */
@property (nonatomic, assign)BOOL zgc_disableInteractivePop;

@end

@interface UINavigationController (ZGCFullScreen)

@end
