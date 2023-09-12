//
//  RSAppDelegateProxy.m
//  RSRotatePage
//
//  Created by 黄雄荣 on 2023/9/4.
//

#import "RSAppDelegateProxy.h"
#import <objc/runtime.h>

@interface RSAppDelegateProxy ()
/// 应用代理
@property (nonatomic, strong) id<UIApplicationDelegate> appDelegate;
/// 记录原先AppDelegate支持的设备方向，还原时需要
@property (nonatomic, assign) UIInterfaceOrientationMask originalSupportOrientationMask;
/// 记录是否被修改了
@property (nonatomic, assign, readwrite) BOOL isSupportedOrientationMaskChanged;
@end

@implementation RSAppDelegateProxy

+ (nullable instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static RSAppDelegateProxy *_Nullable sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] initWithApplication:[UIApplication sharedApplication]];
    });
    return sharedInstance;
}

- (nullable instancetype)initWithApplication:(nullable UIApplication *)application {
    self = [super init];
    if (self) {
        // Application.delegate不存在时，不做设置
        _appDelegate = application.delegate;
        if (![_appDelegate conformsToProtocol:@protocol(UIApplicationDelegate)]) {
            NSLog(@"RSAppDelegateProxy _appDelegate有问题！");
            return nil;
        }
        
        // 检查是否允许hook
        if ([[self class] shouldEnableSwizzleSupportedOrientationsFromSetting]) {
            NSLog(@"RSSDK swizzle了界面支持方向的相关方法，正常情况下不会影响游戏的界面。如果出现界面异常问题，可在RSSDK-Info.plist中设置 37SwizzleSupportedOrientationsEnabled 为NO，来关闭该设置。如果您关闭了该设置，请联系SDK技术，因为关闭该设置可能会影响SDK部分界面的展示。");
            // hook设备支持方向
            [self hookSupportedInterfaceOrientations];
        }
        
        // 也可以根据需要hook其它UIApplicationDelegate方法，并抛出去给handler处理
        
        /**
         重要：重置application delegate，以清除系统对openURL等原始方法的实现缓存
         否则，如果其本身没有实现openURL等方法，我们添加的方法不会被系统认可
         */
        application.delegate = nil;
        application.delegate = _appDelegate;
    }
    return self;
}

+ (BOOL)shouldEnableSwizzleSupportedOrientationsFromSetting {
#warning TODO 在Info.plist中添加开关，或者动态下发配置
    return YES;
}

#pragma mark - 修改支持方向
- (void)hookSupportedInterfaceOrientations {
    // 先保存原始的支持方向
    [self saveOriginalSupportOrientation];
    // 设置当前支持方向为原始方向，否则启动时原始的支持方向会失效;注意不能用self.currentSupportOrientationMask
    _currentSupportOrientationMask = _originalSupportOrientationMask;
    
    // hook AppDelegate中的方法
    [self hookSupportedInterfaceOrientationsInAppDelegate];
    // hook UnityViewControllerBase+iOS中的方法
    [self hookSupportedInterfaceOrientationsInUnityDefaultViewController];
    
}

/// hook AppDelegate中的方法
- (void)hookSupportedInterfaceOrientationsInAppDelegate {
    SEL originalSelector = @selector(application:supportedInterfaceOrientationsForWindow:);
    SEL swizzledSelector = @selector(rs_new_application:supportedInterfaceOrientationsForWindow:);
    SEL noopSelector = @selector(rs_noop_application:supportedInterfaceOrientationsForWindow:);
        
    [self swizzlingInstance:_appDelegate originalSelector:originalSelector swizzledSelector:swizzledSelector noopSelector:noopSelector];
}

/// 新的实现，始终获取 currentSupportOrientationMask
- (UIInterfaceOrientationMask)rs_new_application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return [RSAppDelegateProxy sharedInstance].currentSupportOrientationMask;
}

/// 宿主的AppDelegate可能没有实现该方法，需要先添加一个占位方法实现
- (UIInterfaceOrientationMask)rs_noop_application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return [RSAppDelegateProxy sharedInstance].originalSupportOrientationMask;
}

/// hook UnityViewControllerBase+iOS中的方法
- (void)hookSupportedInterfaceOrientationsInUnityDefaultViewController
{
    SEL originalSelector = @selector(supportedInterfaceOrientations);
    SEL swizzledSelector = @selector(rs_new_supportedInterfaceOrientations);
    SEL noopSelector = @selector(rs_noop_supportedInterfaceOrientations);
    
    // 对UnityViewControllerBase+iOS下的所有基类控制器做swizzle
    NSArray *classArr = @[@"UnityDefaultViewController",
                          @"UnityPortraitOnlyViewController",
                          @"UnityPortraitUpsideDownOnlyViewController",
                          @"UnityLandscapeLeftOnlyViewController",
                          @"UnityLandscapeRightOnlyViewController"
    ];
    for (NSString *className in classArr) {
        // hook每一个supportedInterfaceOrientations方法
        [self swizzlingClass:className originalSelector:originalSelector swizzledSelector:swizzledSelector noopSelector:noopSelector];
    }
}

- (NSUInteger)rs_new_supportedInterfaceOrientations {
    if ([RSAppDelegateProxy sharedInstance].isSupportedOrientationMaskChanged) {
//        NSLogWarn(@"supportedInterfaceOrientations 返回了修改后的方向，%lu",(unsigned long)[RSAppDelegateProxy sharedInstance].currentSupportOrientationMask);
        return [RSAppDelegateProxy sharedInstance].currentSupportOrientationMask;
    } else {
//        NSLogWarn(@"supportedInterfaceOrientations 返回了预设的方向，%lu",(unsigned long)[self rs_new_supportedInterfaceOrientations]);
        return [self rs_new_supportedInterfaceOrientations];
    }
}

- (NSUInteger)rs_noop_supportedInterfaceOrientations {
    return [RSAppDelegateProxy sharedInstance].originalSupportOrientationMask;
}

/// 保存原始的支持方向
- (void)saveOriginalSupportOrientation {
    // 如果宿主AppDelegate实现了application:supportedInterfaceOrientationsForWindow:，优先获取，因为这个方法的优先级比Info.plist高
    if (_appDelegate && [_appDelegate respondsToSelector:@selector(application:supportedInterfaceOrientationsForWindow:)]) {
        // ❌这种方式不一定能正确获取到AppDelegate配置的值
        // UIInterfaceOrientationMask supportedOrientationsInAppDelegate = [[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:[[UIApplication sharedApplication] keyWindow]];
        // ✅
        UIInterfaceOrientationMask supportedOrientationsInAppDelegate = [_appDelegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:[[UIApplication sharedApplication] keyWindow]];
        self.originalSupportOrientationMask = supportedOrientationsInAppDelegate;
        
    } else {
        // 从Info.plist文件中读取设置
        NSDictionary *infoDict = [NSBundle mainBundle].infoDictionary;
        NSArray *supportedOrientations = [infoDict objectForKey:@"UISupportedInterfaceOrientations"];
        BOOL isPortrait = [supportedOrientations containsObject:@"UIInterfaceOrientationPortrait"];
        BOOL isLandscapeLeft = [supportedOrientations containsObject:@"UIInterfaceOrientationLandscapeLeft"];
        BOOL isLandscapeRight = [supportedOrientations containsObject:@"UIInterfaceOrientationLandscapeRight"];
        BOOL isPortraitUpsideDown = [supportedOrientations containsObject:@"UIInterfaceOrientationPortraitUpsideDown"];
        
        if (isPortrait ) {
            if (!isLandscapeLeft && !isLandscapeRight) {
                self.originalSupportOrientationMask = UIInterfaceOrientationMaskPortrait;
            } else if (isLandscapeLeft && isLandscapeRight && isPortraitUpsideDown) {
                self.originalSupportOrientationMask = UIInterfaceOrientationMaskAll;
            } else if ((isLandscapeLeft || isLandscapeRight) && !isPortraitUpsideDown) {
                self.originalSupportOrientationMask = UIInterfaceOrientationMaskAllButUpsideDown;
            }
        } else {
            if (isLandscapeLeft && isLandscapeRight) {
                self.originalSupportOrientationMask = UIInterfaceOrientationMaskLandscape;
            } else if (isLandscapeLeft) {
                self.originalSupportOrientationMask = UIInterfaceOrientationMaskLandscapeLeft;
            } else if (isLandscapeRight) {
                self.originalSupportOrientationMask = UIInterfaceOrientationMaskLandscapeRight;
            } else if (isPortraitUpsideDown) {
                self.originalSupportOrientationMask = UIInterfaceOrientationMaskPortraitUpsideDown;
            }
        }
    }
}

- (void)setCurrentSupportOrientationMask:(UIInterfaceOrientationMask)currentSupportOrientationMask {
    _currentSupportOrientationMask = currentSupportOrientationMask;
    self.isSupportedOrientationMaskChanged = YES;
}

/// 恢复初始AppDelegate支持的设备方向
- (void)restoreSupportedOrientationMaskIfNeeded {
    if (!self.isSupportedOrientationMaskChanged) {
        return;
    }
    self.currentSupportOrientationMask = self.originalSupportOrientationMask;
    self.isSupportedOrientationMaskChanged = NO;
}

#pragma mark - Common

/// hook instance对象所在类的originalSelector方法，如果方法不存在，将会先注入一个方法
- (void)swizzlingClass:(NSString *)className 
      originalSelector:(SEL)originalSelector
      swizzledSelector:(SEL)swizzledSelector
          noopSelector:(SEL)noopSelector
{
    [self swizzlingWithInstance:nil 
                      className:className
               originalSelector:originalSelector
               swizzledSelector:swizzledSelector
                   noopSelector:noopSelector];
}

/// hook instance对象所在类的originalSelector方法，如果方法不存在，将会先注入一个方法
- (void)swizzlingInstance:(id)instance 
         originalSelector:(SEL)originalSelector
         swizzledSelector:(SEL)swizzledSelector
             noopSelector:(SEL)noopSelector
{
    [self swizzlingWithInstance:instance 
                      className:nil
               originalSelector:originalSelector
               swizzledSelector:swizzledSelector
                   noopSelector:noopSelector];
}

/// hook instance对象所在类的originalSelector方法，如果方法不存在，将会先注入一个方法
- (void)swizzlingWithInstance:(id)instance 
                    className:(NSString *)className
             originalSelector:(SEL)originalSelector
             swizzledSelector:(SEL)swizzledSelector
                 noopSelector:(SEL)noopSelector
{
    // 获取对应的Class
    Class originalClass = NSClassFromString(className);
    if (className == nil) {
        originalClass = [instance class]; // 被hook的类
    }
    
    Class swizzledClass = [self class];
    
    if (!originalClass) {
        NSLog(@"originalClass不存在");
        return;
    }
    if (!swizzledClass) {
        NSLog(@"swizzledClass不存在");
        return;
    }
    
    // 获取对应的Mehtod
    Method originalMethod = class_getInstanceMethod(originalClass, originalSelector); // 被hook的方法
    Method swizzledMethod = class_getInstanceMethod(swizzledClass, swizzledSelector); // 我们用来交换的方法
    Method noopMethod = class_getInstanceMethod(swizzledClass, noopSelector); // 用来占位的空方法
    
    if (!swizzledMethod) {
        NSLog(@"swizzledMethod不存在%@",NSStringFromSelector(swizzledSelector));
        return;
    }
    if (!noopMethod) {
        NSLog(@"noopMethod不存在%@",NSStringFromSelector(noopSelector));
        return;
    }
    
    // 如果原方法没有实现，注入一个空方法，并更新Method
    if (!originalMethod) {
        class_addMethod(originalClass, originalSelector, method_getImplementation(noopMethod), method_getTypeEncoding(noopMethod));
        originalMethod = class_getInstanceMethod(originalClass, originalSelector);
    }
    
    // 将swizzled方法注入到被hook的类中，并更新Method
    class_addMethod(originalClass, swizzledSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    swizzledMethod = class_getInstanceMethod(originalClass, swizzledSelector);
    
    // 以下为经典的代码，同一个类中的方法交换
    BOOL didAddMethod = class_addMethod(originalClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(originalClass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
