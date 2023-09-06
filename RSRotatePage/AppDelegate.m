//
//  AppDelegate.m
//  RSRotatePage
//
//  Created by 黄雄荣 on 2023/9/4.
//

#import "AppDelegate.h"
#import "RSSDK.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // 初始化过程会hook
    [RSSDK sdkInitWithParameters];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    ViewController *vc = [[ViewController alloc] init];
    UINavigationController *rootVC = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = rootVC;
    [self.window makeKeyAndVisible];
    
    return YES;
}

/**
 这个方法的优先级比Info.plist高，但是宿主不一定会显式实现
 */
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait;
}

@end
