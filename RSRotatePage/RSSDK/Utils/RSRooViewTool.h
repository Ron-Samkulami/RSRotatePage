//
//  RSRooViewTool.h
//  RSRotatePage
//
//  Created by 黄雄荣 on 2023/9/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RSRooViewTool : NSObject
/// 获取当前屏幕显示的viewcontroller
+ (UIViewController *)getTopViewController;

/// 获取当前显式的普通window
+ (UIWindow *)getCurrentRootWindow;

/// 获取rootViewController，不处理prsent的controller
+ (UIViewController *)getRootViewController;
@end

NS_ASSUME_NONNULL_END
