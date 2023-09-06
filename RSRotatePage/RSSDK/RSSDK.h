//
//  RSSDK.h
//  RSRotatePage
//
//  Created by 黄雄荣 on 2023/9/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SDKControllerType) {
    SDKControllerTypeNormal, // 普通界面，跟随应用设置
    SDKControllerTypeForcePortrait, // 强制竖屏
    SDKControllerTypeForceLandscape, // 强制横屏
};
@interface RSSDK : NSObject

/// 初始化方法
+ (void)sdkInitWithParameters;

/// 打开SDK界面
+ (void)sdkPushController:(SDKControllerType)type;
@end

NS_ASSUME_NONNULL_END
