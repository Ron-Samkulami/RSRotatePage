//
//  RSOrientationViewController.h
//  RSRotatePage
//
//  Created by 黄雄荣 on 2023/9/6.
//

#import <UIKit/UIKit.h>
/**
 支持横竖屏切换的UIViewController
 
 可作为基类，相比导入分类使用的方式更简便一些
 子类中必须在viewWillAppear:被调用之前设置好forcePortrait或forceLandscape，否则不生效
 */
NS_ASSUME_NONNULL_BEGIN

@interface RSOrientationViewController : UIViewController
/// 强制竖屏显示，默认为NO
@property (nonatomic, assign) BOOL forcePortrait;
/// 强制横屏显示，默认为NO
@property (nonatomic, assign) BOOL forceLandscape;

@end

NS_ASSUME_NONNULL_END
