//
//  RSAppDelegateHandler.h
//  RSRotatePage
//
//  Created by 黄雄荣 on 2023/9/4.
//

#import <Foundation/Foundation.h>
#import "RSAppDelegateProxy.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSAppDelegateHandler : NSObject <RSAppDelegateHandler>

+ (instancetype)sharedHandler;

@end

NS_ASSUME_NONNULL_END
