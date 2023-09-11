//
//  RSAppDelegateProxy.h
//  RSRotatePage
//
//  Created by 黄雄荣 on 2023/9/4.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

NS_ASSUME_NONNULL_BEGIN

#define RS_SDK_FINISH_INIT @"RSSDKFinishInit"

@protocol RSAppDelegateHandler <NSObject>
// 定义一些代理方法，将hook到的方法抛出去给handler处理
//- (BOOL)rs_Application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation;
//- (BOOL)rs_Application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options;
//
//- (void)rs_Application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
//- (void)rs_Application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
//- (void)rs_UserNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler  __API_AVAILABLE(ios(10.0));;
//
//- (void)rs_scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts  API_AVAILABLE(ios(13.0));
@end



@interface RSAppDelegateProxy : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (nullable instancetype)sharedInstance;

/// 可以抛出去给代理处理
@property (nonatomic, weak) id<RSAppDelegateHandler> handler;


#pragma mark 调整应用支持方向

/// 修改支持的设备方向
/// 修改后会全局生效
/// 如需恢复初始状态，需要调用[[RSAppDelegateProxy sharedInstance] restoreSupportedOrientationMaskIfNeed];
@property (nonatomic, assign, setter=setCurrentSupportOrientationMask:) UIInterfaceOrientationMask currentSupportOrientationMask;

/// 检查是否允许交换
+ (BOOL)shouldEnableSwizzleSupportedOrientationsFromSetting;

/// 必要时恢复初始AppDelegate支持的设备方向
- (void)restoreSupportedOrientationMaskIfNeed;

@end

NS_ASSUME_NONNULL_END
