//
//  RSAppDelegateHandler.m
//  RSRotatePage
//
//  Created by 黄雄荣 on 2023/9/4.
//

#import "RSAppDelegateHandler.h"

@implementation RSAppDelegateHandler

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 监听SDK初始化完成的通知，确保在APP已经启动完成后再进行加载
        [[NSNotificationCenter defaultCenter] addObserverForName:RS_SDK_FINISH_INIT
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *notification) {
            [[RSAppDelegateHandler sharedHandler] initializeManager];
        }];
    });
}


+ (instancetype)sharedHandler {
    static dispatch_once_t onceToken;
    static id sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)initializeManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RSAppDelegateProxy *proxy = [RSAppDelegateProxy sharedInstance];
        //设置代理
        [proxy setHandler:self];
    });
}

@end
