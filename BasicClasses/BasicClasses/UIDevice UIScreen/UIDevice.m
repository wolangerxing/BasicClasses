//
//  UIDevice.m
//  
//
//  Created by Nick Yu on 2019/1/22.
//

#if USE_UIKIT_PUBLIC_HEADERS || !__has_include(<UIKitCore/UIDevice.h>)
//
//  UIDevice.h
//  UIKit
//
//  Copyright (c) 2007-2018 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>

NS_ASSUME_NONNULL_BEGIN

//屏幕方向，注意faceup facedown
typedef NS_ENUM(NSInteger, UIDeviceOrientation) {
    UIDeviceOrientationUnknown,
    UIDeviceOrientationPortrait,            // Device oriented vertically, home button on the bottom
    UIDeviceOrientationPortraitUpsideDown,  // Device oriented vertically, home button on the top
    UIDeviceOrientationLandscapeLeft,       // Device oriented horizontally, home button on the right
    UIDeviceOrientationLandscapeRight,      // Device oriented horizontally, home button on the left
    UIDeviceOrientationFaceUp,              // Device oriented flat, face up
    UIDeviceOrientationFaceDown             // Device oriented flat, face down
} __TVOS_PROHIBITED;

//电池状态
typedef NS_ENUM(NSInteger, UIDeviceBatteryState) {
    UIDeviceBatteryStateUnknown,
    UIDeviceBatteryStateUnplugged,   // on battery, discharging
    UIDeviceBatteryStateCharging,    // plugged in, less than 100%
    UIDeviceBatteryStateFull,        // plugged in, at 100%
} __TVOS_PROHIBITED;              // available in iPhone 3.0

//设备类别信息
typedef NS_ENUM(NSInteger, UIUserInterfaceIdiom) {
    UIUserInterfaceIdiomUnspecified = -1,
    UIUserInterfaceIdiomPhone NS_ENUM_AVAILABLE_IOS(3_2), // iPhone and iPod touch style UI
    UIUserInterfaceIdiomPad NS_ENUM_AVAILABLE_IOS(3_2), // iPad style UI
    UIUserInterfaceIdiomTV NS_ENUM_AVAILABLE_IOS(9_0), // Apple TV style UI
    UIUserInterfaceIdiomCarPlay NS_ENUM_AVAILABLE_IOS(9_0), // CarPlay style UI
};

//判断屏幕方向的几个便捷方法
static inline BOOL UIDeviceOrientationIsPortrait(UIDeviceOrientation orientation)  __TVOS_PROHIBITED {
    return ((orientation) == UIDeviceOrientationPortrait || (orientation) == UIDeviceOrientationPortraitUpsideDown);
}

static inline BOOL UIDeviceOrientationIsLandscape(UIDeviceOrientation orientation)  __TVOS_PROHIBITED {
    return ((orientation) == UIDeviceOrientationLandscapeLeft || (orientation) == UIDeviceOrientationLandscapeRight);
}

static inline __attribute__((always_inline)) BOOL UIDeviceOrientationIsFlat(UIDeviceOrientation orientation)  __TVOS_PROHIBITED {
    return ((orientation) == UIDeviceOrientationFaceUp || (orientation) == UIDeviceOrientationFaceDown);
}

static inline __attribute__((always_inline)) BOOL UIDeviceOrientationIsValidInterfaceOrientation(UIDeviceOrientation orientation)  __TVOS_PROHIBITED {
    return ((orientation) == UIDeviceOrientationPortrait || (orientation) == UIDeviceOrientationPortraitUpsideDown || (orientation) == UIDeviceOrientationLandscapeLeft || (orientation) == UIDeviceOrientationLandscapeRight);
}

NS_CLASS_AVAILABLE_IOS(2_0) @interface UIDevice : NSObject

#if UIKIT_DEFINE_AS_PROPERTIES
@property(class, nonatomic, readonly) UIDevice *currentDevice;
#else
+ (UIDevice *)currentDevice;
#endif

//self explained
@property(nonatomic,readonly,strong) NSString    *name;              // e.g. "My iPhone"
@property(nonatomic,readonly,strong) NSString    *model;             // e.g. @"iPhone", @"iPod touch"
@property(nonatomic,readonly,strong) NSString    *localizedModel;    // 本地化后的 model；localized version of model
@property(nonatomic,readonly,strong) NSString    *systemName;        // e.g. @"iOS"
@property(nonatomic,readonly,strong) NSString    *systemVersion;     // e.g. @"4.0"

//设备方向
//UIDeviceOrientation 是机器硬件的当前旋转方向 这个你只能取值 不能设置
//UIInterfaceOrientation 是你程序界面的当前旋转方向 这个可以设置
@property(nonatomic,readonly) UIDeviceOrientation orientation __TVOS_PROHIBITED;       // return current device orientation.  this will return UIDeviceOrientationUnknown unless device orientation notifications are being generated.

//udid 用户可以设置不传，则为全0
@property(nullable, nonatomic,readonly,strong) NSUUID      *identifierForVendor NS_AVAILABLE_IOS(6_0);      // a UUID that may be used to uniquely identify the device, same across apps from a single vendor.

//Device orientation发生变化的时候 发出通知 默认是true，如果false UIDeviceOrientationDidChangeNotification  通知不会发出。
@property(nonatomic,readonly,getter=isGeneratingDeviceOrientationNotifications) BOOL generatesDeviceOrientationNotifications __TVOS_PROHIBITED;
- (void)beginGeneratingDeviceOrientationNotifications __TVOS_PROHIBITED;      // nestable
- (void)endGeneratingDeviceOrientationNotifications __TVOS_PROHIBITED;

//电量监控，默认关
@property(nonatomic,getter=isBatteryMonitoringEnabled) BOOL batteryMonitoringEnabled NS_AVAILABLE_IOS(3_0) __TVOS_PROHIBITED;  // default is NO
@property(nonatomic,readonly) UIDeviceBatteryState          batteryState NS_AVAILABLE_IOS(3_0) __TVOS_PROHIBITED;  // UIDeviceBatteryStateUnknown if monitoring disabled

//电量 0.0-1.0
@property(nonatomic,readonly) float                         batteryLevel NS_AVAILABLE_IOS(3_0) __TVOS_PROHIBITED;  // 0 .. 1.0. -1.0 if UIDeviceBatteryStateUnknown

//近距离感应器相关
@property(nonatomic,getter=isProximityMonitoringEnabled) BOOL proximityMonitoringEnabled NS_AVAILABLE_IOS(3_0); // default is NO
@property(nonatomic,readonly)                            BOOL proximityState NS_AVAILABLE_IOS(3_0);  // always returns NO if no proximity detector

//多任务支持 iOS4之后都支持
@property(nonatomic,readonly,getter=isMultitaskingSupported) BOOL multitaskingSupported NS_AVAILABLE_IOS(4_0);

//设备名称
@property(nonatomic,readonly) UIUserInterfaceIdiom userInterfaceIdiom NS_AVAILABLE_IOS(3_2);

- (void)playInputClick NS_AVAILABLE_IOS(4_2);  // Plays a click only if an enabling input view is on-screen and user has enabled input clicks.

@end

//自定义的输入页面 点击时是否支持系统的按键音
/*
 NerdKeyboard *nerdKeyboard = [[NerdKeyboard alloc] initWithNibName:@"NerdKeyboard"
 bundle:nil];
 [self.myTextField setInputView:nerdKeyboard.view];
 */
@protocol UIInputViewAudioFeedback <NSObject>
@optional

@property (nonatomic, readonly) BOOL enableInputClicksWhenVisible; // If YES, an input view will enable playInputClick.

@end

/* The UI_USER_INTERFACE_IDIOM() function is provided for use when deploying to a version of the iOS less than 3.2. If the earliest version of iPhone/iOS that you will be deploying for is 3.2 or greater, you may use -[UIDevice userInterfaceIdiom] directly.
 */
static inline UIUserInterfaceIdiom UI_USER_INTERFACE_IDIOM() {
    return ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] ?
            [[UIDevice currentDevice] userInterfaceIdiom] :
            UIUserInterfaceIdiomPhone);
}

//设备屏幕方向变化
UIKIT_EXTERN NSNotificationName const UIDeviceOrientationDidChangeNotification __TVOS_PROHIBITED;
//充电状态改变
UIKIT_EXTERN NSNotificationName const UIDeviceBatteryStateDidChangeNotification   NS_AVAILABLE_IOS(3_0) __TVOS_PROHIBITED;
//电量改变
UIKIT_EXTERN NSNotificationName const UIDeviceBatteryLevelDidChangeNotification   NS_AVAILABLE_IOS(3_0) __TVOS_PROHIBITED;

//近距离感应触发，比如打电话，听筒贴近耳朵
UIKIT_EXTERN NSNotificationName const UIDeviceProximityStateDidChangeNotification NS_AVAILABLE_IOS(3_0);

NS_ASSUME_NONNULL_END

#else
#import <UIKitCore/UIDevice.h>
#endif
