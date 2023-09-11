//
//  UIViewController+RSOrientation.h
//  RSOrientation
//
//  Created by 黄雄荣 on 2023/9/5.
//

#import <UIKit/UIKit.h>
/**
 使特定UIViewController具备横竖屏切换能力
 使用方式：
    1、在SomeUIViewController的.h中添加 #import "UIViewController+RVOrientation.h"
    2、在SomeUIViewController的 -[viewWillAppear:] 或 -[viewDidLoad] 中调用 [self changeOrientationIfNeeded];
    3、在SomeUIViewController的 -[viewWillDisappear:] 中调用 [self restoreOrientationIfNeeded]，可以在页面退出时恢复原始的页面方向;
    4、外界调用时，需要显式设置 SomeUIViewController实例对象的 forcePortrait 或 forceLandscape属性为YES。
 */
NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (RSOrientation)

/// 强制竖屏显示，默认为NO
@property (nonatomic, assign) BOOL forcePortrait;
/// 强制横屏显示，默认为NO
@property (nonatomic, assign) BOOL forceLandscape;

#pragma mark - 改变页面方向
/// 改变页面方向
- (void)changeOrientationIfNeeded;
/// 恢复页面方向
- (void)restoreOrientationIfNeeded;

@end

NS_ASSUME_NONNULL_END
