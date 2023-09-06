//
//  RSRooViewTool.m
//  RSRotatePage
//
//  Created by 黄雄荣 on 2023/9/6.
//

#import "RSRooViewTool.h"

@implementation RSRooViewTool

/// 获取当前屏幕显示的viewcontroller
+ (UIViewController *)getTopViewController {
    UIWindow *rootWindow =  [self getCurrentRootWindow];
    UIViewController *rootViewController = rootWindow.rootViewController;
    if (!rootViewController) {
        // 这里以后再来处理下
        NSLog(@"rootViewController为nil");
        return nil;
    }
    UIViewController *topViewController = rootViewController;
    // 只遍历present出来的的视图
    while (topViewController.presentedViewController) {
        UIViewController *tempTopController = topViewController.presentedViewController;
        if ([tempTopController isKindOfClass:[UIAlertController class]]) {
            //如果是UIAlertController，不再继续
            break;
        } else {
            topViewController = tempTopController;
        }
    }
    
    NSLog(@"getTopViewController topViewController=%@",topViewController);
    NSLog(@"getTopViewController mainScreen.bounds=%@",NSStringFromCGRect([UIScreen mainScreen].bounds));
    NSLog(@"getTopViewController rootWindow=%@",rootWindow);
    NSLog(@"getTopViewController rootWindow.frame=%@",NSStringFromCGRect(rootWindow.frame));
    NSLog(@"getTopViewController rootWindow.bounds=%@",NSStringFromCGRect(rootWindow.bounds));
    NSLog(@"getTopViewController topView=%@",topViewController.view);
    NSLog(@"getTopViewController topView.frame=%@",NSStringFromCGRect(topViewController.view.frame));
    NSLog(@"getTopViewController topView.bounds=%@",NSStringFromCGRect(topViewController.view.bounds));
    return topViewController;
}

/// 获取rootViewController，不处理prsent的controller
+ (UIViewController *)getRootViewController {
    UIWindow *rootWindow =  [self getCurrentRootWindow];
    UIViewController *rootViewController = rootWindow.rootViewController;
    if (!rootViewController) {
        //这里以后再来处理下
        NSLog(@"rootViewController为nil");
        return nil;
    }
    UIViewController *topViewController = rootViewController;
    return topViewController;
}


/// 获取当前屏幕显示的viewcontroller
+ (UIWindow *)getCurrentRootWindow {
    UIApplication *application = [UIApplication sharedApplication];
    UIWindow *rootWindow = nil;
    // 先获取delegate的window(部分宿主的delegate可能没有window属性)
    if ([application.delegate respondsToSelector:@selector(window)]) {
        rootWindow = application.delegate.window;
    } else {
        NSLog(@"Application.delegate respondsToSelector:@selector(window)] 失败");
        // 获取keyWindow
        UIWindow *window = [application keyWindow];
        // keyWindow有时为空
        BOOL isUIWindow = [NSStringFromClass([window class]) isEqualToString:@"UIWindow"];
        BOOL isNormalLevel = window.windowLevel == UIWindowLevelNormal;
        if (window && isUIWindow && isNormalLevel && window.rootViewController) {
            NSLog(@"keyWindow 符合要求");
            rootWindow = window;
        } else {
            NSLog(@"Application.delegate respondsToSelector:@selector(window)] 失败");
        }
        
        // 判断delegate的window是否是keywindow
        if (rootWindow && [rootWindow isKeyWindow]) {
            
        } else {
            NSLog(@"keyWindow不符合要求，从windows数组中找");
            // keyWindow不符合要求，从windows数组中找
            NSArray *windows = [application windows];
            for(UIWindow *tmpWin in windows) {
                BOOL isUIWindow = [tmpWin isKindOfClass:[UIWindow class]];
                BOOL isNormalLevel = tmpWin.windowLevel == UIWindowLevelNormal;
                if (isUIWindow && isNormalLevel) {
                    NSLog(@"遍历windows，找到了符合要求的window");
                    rootWindow = tmpWin;
                    break;
                }
            }
        }
    }
    
    if (rootWindow && rootWindow.rootViewController) {

    } else {
        NSLog(@"未合适的window，直接使用windows[0]");
        NSArray *windows = [application windows];
        if (windows.count > 0) {
            rootWindow = windows[0];
        } else {
            NSLog(@"windows为nil！！！");
        }
    }
    
    return rootWindow;
}

@end
