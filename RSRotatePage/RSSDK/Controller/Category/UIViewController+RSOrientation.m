//
//  UIViewController+RSOrientation.m
//  RSOrientation
//
//  Created by 黄雄荣 on 2023/9/5.
//

#import "UIViewController+RSOrientation.h"
#import <objc/runtime.h>
#import "RSAppDelegateProxy.h"

@interface UIViewController ()
/// 记录原始的设备方向
@property (nonatomic, assign) UIInterfaceOrientation originalOrientation;
/// 方向是否发生改变，默认为NO
@property (nonatomic, assign) BOOL isOrientationChanged;

@end

@implementation UIViewController (RSOrientation)

#pragma mark - 关联对象新增属性
/// 关联对象唯一标识，字符串地址作为字符串内容
static void *kForcePortrait = &kForcePortrait;
static void *kForceLandscape = &kForceLandscape;
static void *kOriginalOrientation = &kOriginalOrientation;
static void *kIsOrientationChanged = &kIsOrientationChanged;

/// 强制竖屏
- (void)setForcePortrait:(BOOL)forcePortrait {
    objc_setAssociatedObject(self, kForcePortrait, [NSNumber numberWithBool:forcePortrait], OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)forcePortrait {
    return [objc_getAssociatedObject(self, kForcePortrait) boolValue];
}

/// 强制横屏
- (void)setForceLandscape:(BOOL)forceLandscape {
    objc_setAssociatedObject(self, kForceLandscape, [NSNumber numberWithBool:forceLandscape], OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)forceLandscape {
    return [objc_getAssociatedObject(self, kForceLandscape) boolValue];
}

/// 原始方向
- (void)setOriginalOrientation:(UIInterfaceOrientation)originalOrientation {
    objc_setAssociatedObject(self, kOriginalOrientation, [NSNumber numberWithInteger:(NSInteger)originalOrientation], OBJC_ASSOCIATION_RETAIN);
}

- (UIInterfaceOrientation)originalOrientation {
    return [objc_getAssociatedObject(self, kOriginalOrientation) integerValue];
}

/// 强制竖屏
- (void)setIsOrientationChanged:(BOOL)isOrientationChanged {
    objc_setAssociatedObject(self, kIsOrientationChanged, [NSNumber numberWithBool:isOrientationChanged], OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)isOrientationChanged {
    return [objc_getAssociatedObject(self, kIsOrientationChanged) boolValue];
}

#pragma mark - 改变页面方向
/// 改变页面方向
- (void)changeOrientationIfNeeded {
    // 检查设置开关
    if (![RSAppDelegateProxy shouldEnableSwizzleSupportedOrientationsFromSetting]) {
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
    if (![RSAppDelegateProxy shouldEnableSwizzleSupportedOrientationsFromSetting]) {
        return;
    }
    if (!self.forcePortrait && !self.forceLandscape) {
        return;
    }
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


#pragma mark - 主类方法重写

// 未启用当前类，先注释掉dealloc方法
//- (void)dealloc
//{
//    // 如果当前控制器是navigationController的RootViewController，则直接移除navigationController不会触发viewWillDisappear，因此在dealloc里调用
//    [self restoreOrientationIfNeeded];
//}

/// 调用主类方法
- (void)callPrimaryClassMethod:(SEL)primarySel {
    u_int count;
    Method *methods = class_copyMethodList([self class], &count);
    NSInteger index = 0;
    
    for (int i = 0; i < count; i++) {
        SEL aSel = method_getName(methods[i]);
//        if (sel_isEqual(aSel, primarySel)) {
//            index = i;
//        }
        // 先获取原类方法在方法列表中的索引
        NSString *aSelName = [NSString stringWithCString:sel_getName(aSel) encoding:NSUTF8StringEncoding];
        NSString *primarySelName = [NSString stringWithCString:sel_getName(primarySel) encoding:NSUTF8StringEncoding];
//        NSLog(@"目标方法：%@，当前方法：%@",primarySelName,aSelName);
        if ([aSelName isEqualToString:primarySelName]) {
            index = i;
        }
    }
    
    // 调用方法
    SEL sel = method_getName(methods[index]);
    IMP imp = method_getImplementation(methods[index]);
    ((void (*)(id, SEL))imp)(self,sel);
}


/**
 这种方式要求AppDelegate中必须实现 application:supportedInterfaceOrientationsForWindow: ，所以不采用，改为hook方式
 */
//- (void)changeInterfaceOrientation:(UIInterfaceOrientationMask)interfaceOrientationMask
//{
//    RSAppDelegateProxy *proxy = [RSAppDelegateProxy sharedInstance];
//    id<UIApplicationDelegate> appDelegate = proxy.appDelegate;
//    __weak __typeof(self) weakSelf = self;
//    IMP originalIMP = method_getImplementation(class_getInstanceMethod([appDelegate class], @selector(application:supportedInterfaceOrientationsForWindow:)));
//
//    self.originalIMP = originalIMP;
//    IMP newIMP = imp_implementationWithBlock(^(id obj, UIApplication *application, UIWindow *window){
//        if (!weakSelf) {
//            class_replaceMethod([appDelegate class], @selector(application:supportedInterfaceOrientationsForWindow:), originalIMP, method_getTypeEncoding(class_getInstanceMethod([appDelegate class], @selector(application:supportedInterfaceOrientationsForWindow:))));
//        }
//        return interfaceOrientationMask;
//    });
//
//    class_replaceMethod([appDelegate class], @selector(application:supportedInterfaceOrientationsForWindow:), newIMP, method_getTypeEncoding(class_getInstanceMethod([appDelegate class], @selector(application:supportedInterfaceOrientationsForWindow:))));
//}
@end
