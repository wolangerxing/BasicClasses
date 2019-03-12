//
//  NSProxy.m
//  BasicClasses
//
//  Created by 杨维 on 2019/2/21.
//  Copyright © 2019 杨维. All rights reserved.
//

#import <Foundation/NSObject.h>

@class NSMethodSignature, NSInvocation;

NS_ASSUME_NONNULL_BEGIN

NS_ROOT_CLASS
@interface NSProxy <NSObject> {
    Class    isa;
}

+ (id)alloc;
+ (id)allocWithZone:(nullable NSZone *)zone NS_AUTOMATED_REFCOUNT_UNAVAILABLE;
+ (Class)class;

//用于实现消息转发，参见： https://zhangbuhuai.com/message-forwarding/
- (void)forwardInvocation:(NSInvocation *)invocation;
- (nullable NSMethodSignature *)methodSignatureForSelector:(SEL)sel NS_SWIFT_UNAVAILABLE("NSInvocation and related APIs not available");

- (void)dealloc;
- (void)finalize;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
+ (BOOL)respondsToSelector:(SEL)aSelector;

- (BOOL)allowsWeakReference NS_UNAVAILABLE;
- (BOOL)retainWeakReference NS_UNAVAILABLE;

// - (id)forwardingTargetForSelector:(SEL)aSelector;

@end

NS_ASSUME_NONNULL_END
