//
//  RSSDK.m
//  RSRotatePage
//
//  Created by 黄雄荣 on 2023/9/4.
//

#import "RSSDK.h"
#import "RSAppDelegateProxy.h"
#import "SampleViewController.h"
#import "RSRooViewTool.h"

@implementation RSSDK

+ (void)sdkInitWithParameters {
    // Do some init
    
    // Notify finish
    [[NSNotificationCenter defaultCenter] postNotificationName:RS_SDK_FINISH_INIT object:nil];
}

/// 打开SDK界面
+ (void)sdkPushController:(SDKControllerType)type {
    SampleViewController *vc = [[SampleViewController alloc] init];
    if (type == SDKControllerTypeForcePortrait) {
        vc.forcePortrait = YES;
    } else if (type == SDKControllerTypeForceLandscape) {
        vc.forceLandscape = YES;
    }
    UIViewController *topVC = [RSRooViewTool getTopViewController];
    if ([topVC isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *)topVC pushViewController:vc animated:YES];
    } else {
        [topVC.navigationController pushViewController:vc animated:YES];
    }
}

@end
