//
//  RSOrientationViewController.m
//  RSRotatePage
//
//  Created by 黄雄荣 on 2023/9/6.
//

#import "RSOrientationViewController.h"
#import <objc/runtime.h>
#import "RSAppDelegateProxy.h"

@interface RSOrientationViewController ()
/// 记录原始的设备方向
@property (nonatomic, assign) UIInterfaceOrientation originalOrientation;
/// 方向是否发生改变，默认为NO
@property (nonatomic, assign) BOOL isOrientationChanged;
@end

@implementation RSOrientationViewController

- (void)dealloc {
    [self restoreOrientationIfNeeded];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // 必要时旋转方向
    [self changeOrientationIfNeeded];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // 恢复方向
    [self restoreOrientationIfNeeded];
}

#pragma mark - 改变页面方向
/// 改变页面方向
- (void)changeOrientationIfNeeded {
    // 检查设置开关
    if (![RSAppDelegateProxy shouldEnableSwizzleSupportedOrientationsFromSetting]) {
        return;
    }
    
    //
    if (!self.forcePortrait && !self.forceLandscape) {
        return;
    }
    
    // 先保存原来的设备方向
    self.originalOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (self.forcePortrait) {
        // 先修改支持方向
        [[RSAppDelegateProxy sharedInstance] setCurrentSupportOrientationMask:UIInterfaceOrientationMaskPortrait];
        // 再调整方向
        [self changeInterfaceOrientation:UIInterfaceOrientationPortrait];
        // 标记方向发生改变
        self.isOrientationChanged = YES;
        
    } else if (self.forceLandscape) {
        // 先修改支持方向
        [[RSAppDelegateProxy sharedInstance] setCurrentSupportOrientationMask:UIInterfaceOrientationMaskLandscape];
        // 再调整方向
        [self changeInterfaceOrientation:UIInterfaceOrientationLandscapeRight];
        // 标记方向发生改变
        self.isOrientationChanged = YES;
    }
}

/// 恢复页面方向
- (void)restoreOrientationIfNeeded {
    // 检查设置开关
    if (![RSAppDelegateProxy shouldEnableSwizzleSupportedOrientationsFromSetting]) {
        return;
    }
    
    //
    if (!self.forcePortrait && !self.forceLandscape) {
        return;
    }
    // 避免重复调用
    if (!self.isOrientationChanged) {
        return;
    }
    self.isOrientationChanged = NO;
    // 恢复为原始的支持方向
    [[RSAppDelegateProxy sharedInstance] restoreSupportedOrientationMaskIfNeeded];
    [self changeInterfaceOrientation:self.originalOrientation];
    
}

// 强制修改设备方向
- (void)changeInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if (orientation == UIInterfaceOrientationUnknown) {
        orientation = UIInterfaceOrientationPortrait;
    }
    
    if (@available(iOS 16.0, *)) {
        [self.navigationController setNeedsUpdateOfSupportedInterfaceOrientations];
        // 下面这句是很重要，不加可能会转屏失败
        [UIViewController attemptRotationToDeviceOrientation];
        
        NSArray *array = [[[UIApplication sharedApplication] connectedScenes] allObjects];
        UIWindowScene *windowScene = (UIWindowScene *)array[0];
        UIWindowSceneGeometryPreferencesIOS *preferences = [[UIWindowSceneGeometryPreferencesIOS alloc] init];
        if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) {
            preferences.interfaceOrientations = UIInterfaceOrientationMaskLandscape;
        } else {
            preferences.interfaceOrientations = UIInterfaceOrientationMaskPortrait;
        }
        [(UIWindowScene *)windowScene requestGeometryUpdateWithPreferences:preferences errorHandler:^(NSError * _Nonnull error) {
            if (error) {
                NSLog(@"requestGeometryUpdateWithPreferences failed: %@",error.userInfo[@"NSLocalizedDescription"]);
            }
        }];
        
    } else {
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            // 规避苹果对私有方法的静态扫描
            NSString *selectorStr = [NSString stringWithFormat:@"%@%@%@",@"set",@"Orient",@"ation:"];
            SEL selector = NSSelectorFromString(selectorStr);
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];
            int val = orientation;
            [invocation setArgument:&val atIndex:2];
            [invocation invoke];
        }
    }
}
@end
