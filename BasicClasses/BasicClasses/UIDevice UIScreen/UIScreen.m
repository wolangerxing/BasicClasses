//
//  UIScreen.m
//  
//
//  Created by Nick Yu on 2019/1/22.
//

#if USE_UIKIT_PUBLIC_HEADERS || !__has_include(<UIKitCore/UIScreen.h>)
//
//  UIScreen.h
//  UIKit
//
//  Copyright (c) 2007-2018 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKitDefines.h>
#import <UIKit/UITraitCollection.h>
#import <UIKit/UIView.h>

NS_ASSUME_NONNULL_BEGIN

@class UIScreenMode, CADisplayLink, UIView;

// Object is the UIScreen that represents the new screen. Connection notifications are not sent for screens present when the application is first launched
// 多个屏幕链接，投屏，默认是mirror模式
UIKIT_EXTERN NSNotificationName const UIScreenDidConnectNotification NS_AVAILABLE_IOS(3_2);
// Object is the UIScreen that represented the disconnected screen.
UIKIT_EXTERN NSNotificationName const UIScreenDidDisconnectNotification NS_AVAILABLE_IOS(3_2);

// Object is the UIScreen which changed. [object currentMode] is the new UIScreenMode.
UIKIT_EXTERN NSNotificationName const UIScreenModeDidChangeNotification NS_AVAILABLE_IOS(3_2);


UIKIT_EXTERN NSNotificationName const UIScreenBrightnessDidChangeNotification NS_AVAILABLE_IOS(5_0);
//监测亮度变化

// Object is the UIScreen which changed. [object isCaptured] is the new value of captured property.
UIKIT_EXTERN NSNotificationName const UIScreenCapturedDidChangeNotification NS_AVAILABLE_IOS(11_0);
//监测当前设备是否处于系统录屏状态 iOS11+


//描述了不同的补偿技术在屏幕的边缘像素的损失
// when the connected screen is overscanning, UIScreen can attempt to compensate for the overscan to avoid clipping
typedef NS_ENUM(NSInteger, UIScreenOverscanCompensation) {
    UIScreenOverscanCompensationScale,      //使所有像素在屏幕上可见。                     // the final composited framebuffer for the screen is scaled to avoid clipping
    UIScreenOverscanCompensationInsetBounds,     //屏幕范围缩小，所有像素在屏幕上是可见的。                // the screen's bounds will be inset in the framebuffer to avoid clipping. no scaling will occur
    UIScreenOverscanCompensationNone NS_ENUM_AVAILABLE_IOS(9_0), //没有发生补偿 // no scaling will occur. use overscanCompensationInsets to determine the necessary insets to avoid clipping
    
    UIScreenOverscanCompensationInsetApplicationFrame NS_ENUM_DEPRECATED_IOS(5_0, 9_0, "Use UIScreenOverscanCompensationNone") = 2, //缩小弥补过扫描，屏幕外的忽略
};

NS_CLASS_AVAILABLE_IOS(2_0) @interface UIScreen : NSObject <UITraitEnvironment>

#if UIKIT_DEFINE_AS_PROPERTIES
//返回屏幕数组 和主屏幕，一般只有一个主屏幕
@property(class, nonatomic, readonly) NSArray<UIScreen *> *screens NS_AVAILABLE_IOS(3_2);          // all screens currently attached to the device
@property(class, nonatomic, readonly) UIScreen *mainScreen;      // the device's internal screen
#else
+ (NSArray<UIScreen *> *)screens NS_AVAILABLE_IOS(3_2);          // all screens currently attached to the device
+ (UIScreen *)mainScreen;      // the device's internal screen
#endif

//bounds 屏幕大小（非物理分辨率）； scale 返回1，2，3，表示 1x、2x、3x倍屏
@property(nonatomic,readonly) CGRect  bounds;                // Bounds of entire screen in points
@property(nonatomic,readonly) CGFloat scale NS_AVAILABLE_IOS(4_0);

/* UIScreenMode 是屏幕模式的对象，里面包含 一像素大小和缩放比例
 NS_CLASS_AVAILABLE_IOS(3_2) @interface UIScreenMode : NSObject
 
 @property(readonly,nonatomic) CGSize  size;             // The width and height in pixels
 @property(readonly,nonatomic) CGFloat pixelAspectRatio; // The aspect ratio of a single pixel. The ratio is defined as X/Y.
 
 iPhone 7
 (lldb) po UIScreen.main.currentMode?.size
 ▿ Optional<CGSize>
 ▿ some : (750.0, 1334.0)
 - width : 750.0
 - height : 1334.0
 
 (lldb) po UIScreen.main.currentMode?.pixelAspectRatio
 ▿ Optional<CGFloat>
 - some : 1.0
 
 iPhone 8 Plus
 (lldb) po UIScreen.main.currentMode?.size
 ▿ Optional<CGSize>
 ▿ some : (1242.0, 2208.0)
 - width : 1242.0
 - height : 2208.0
 
 (lldb) po UIScreen.main.currentMode?.pixelAspectRatio
 ▿ Optional<CGFloat>
 - some : 1.0
 @end
 */
@property(nonatomic,readonly,copy) NSArray<UIScreenMode *> *availableModes NS_AVAILABLE_IOS(3_2) __TVOS_PROHIBITED;             // The list of modes that this screen supports
@property(nullable, nonatomic,readonly,strong) UIScreenMode *preferredMode NS_AVAILABLE_IOS(4_3) __TVOS_PROHIBITED;       // Preferred mode of this screen. Choosing this mode will likely produce the best results
#if TARGET_OS_TV
@property(nullable,nonatomic,readonly,strong) UIScreenMode *currentMode NS_AVAILABLE_IOS(3_2);                  // Current mode of this screen
#else
@property(nullable,nonatomic,strong) UIScreenMode *currentMode NS_AVAILABLE_IOS(3_2);                  // Current mode of this screen
#endif


//屏幕补偿，默认是UIScreenOverscanCompensationScale 使所有像素在屏幕上可见
@property(nonatomic) UIScreenOverscanCompensation overscanCompensation NS_AVAILABLE_IOS(5_0); // Default is UIScreenOverscanCompensationScale. Determines how the screen behaves if the connected display is overscanning

@property(nonatomic,readonly) UIEdgeInsets overscanCompensationInsets NS_AVAILABLE_IOS(9_0);  // The amount that should be inset to avoid clipping

//镜像的屏幕 如果没有镜像则为nil
@property(nullable, nonatomic,readonly,strong) UIScreen *mirroredScreen NS_AVAILABLE_IOS(4_3);          // The screen being mirrored by the receiver. nil if mirroring is disabled or unsupported. Moving a UIWindow to this screen will disable mirroring

//当前是否在录屏
@property(nonatomic,readonly,getter=isCaptured) BOOL captured NS_AVAILABLE_IOS(11_0); // True if this screen is being captured (e.g. recorded, AirPlayed, mirrored, etc.)


//亮度，可调节
@property(nonatomic) CGFloat brightness NS_AVAILABLE_IOS(5_0) __TVOS_PROHIBITED;        // 0 .. 1.0, where 1.0 is maximum brightness. Only supported by main screen.

//是由系统来dim屏幕 还是app，默认是NO，由系统控制
@property(nonatomic) BOOL wantsSoftwareDimming NS_AVAILABLE_IOS(5_0) __TVOS_PROHIBITED; // Default is NO. If YES, brightness levels lower than that of which the hardware is capable are emulated in software, if neccessary. Having enabled may entail performance cost.

//坐标系变换
/*
 @protocol UICoordinateSpace <NSObject>
 
 - (CGPoint)convertPoint:(CGPoint)point toCoordinateSpace:(id <UICoordinateSpace>)coordinateSpace NS_AVAILABLE_IOS(8_0);
 - (CGPoint)convertPoint:(CGPoint)point fromCoordinateSpace:(id <UICoordinateSpace>)coordinateSpace NS_AVAILABLE_IOS(8_0);
 - (CGRect)convertRect:(CGRect)rect toCoordinateSpace:(id <UICoordinateSpace>)coordinateSpace NS_AVAILABLE_IOS(8_0);
 - (CGRect)convertRect:(CGRect)rect fromCoordinateSpace:(id <UICoordinateSpace>)coordinateSpace NS_AVAILABLE_IOS(8_0);
 
 @property (readonly, nonatomic) CGRect bounds NS_AVAILABLE_IOS(8_0);
 
 @end
 */
@property (readonly) id <UICoordinateSpace> coordinateSpace NS_AVAILABLE_IOS(8_0);
@property (readonly) id <UICoordinateSpace> fixedCoordinateSpace NS_AVAILABLE_IOS(8_0);


//设备的 大小和scale，不随屏幕rotate
@property(nonatomic,readonly) CGRect  nativeBounds NS_AVAILABLE_IOS(8_0);  // Native bounds of the physical screen in pixels
@property(nonatomic,readonly) CGFloat nativeScale  NS_AVAILABLE_IOS(8_0);  // Native scale factor of the physical screen

//触发定时器，16ms一次，和屏幕刷新率一致
- (nullable CADisplayLink *)displayLinkWithTarget:(id)target selector:(SEL)sel NS_AVAILABLE_IOS(4_0);

//最大刷新率 iOS 一般是60 tvOS可能更高 （新iPad 120Hz？）
@property (readonly) NSInteger maximumFramesPerSecond  NS_AVAILABLE_IOS(10_3); // The maximumFramesPerSecond this screen is capable of

//focus view 获得焦点的view，iOS不支持，主要用在tvOS
@property (nullable, nonatomic, weak, readonly) id<UIFocusItem> focusedItem NS_AVAILABLE_IOS(10_0); // Returns the focused item for this screen's focus system. Use UIFocusSystem's focusedItem property instead – this property will be deprecated in a future release.
@property (nullable, nonatomic, weak, readonly) UIView *focusedView NS_AVAILABLE_IOS(9_0); // If focusedItem is not a view, this returns that item's containing view. Otherwise they are equal. Use UIFocusSystem's focusedItem property instead – this property will be deprecated in a future release.
@property (readonly, nonatomic) BOOL supportsFocus NS_AVAILABLE_IOS(9_0);


//已废弃
@property(nonatomic,readonly) CGRect applicationFrame NS_DEPRECATED_IOS(2_0, 9_0, "Use -[UIScreen bounds]") __TVOS_PROHIBITED;

@end


//截屏方法，afterUpdates 标明原内容变化后 图像是否跟着改变
@interface UIScreen (UISnapshotting)
// Please see snapshotViewAfterScreenUpdates: in UIView.h for some important details on the behavior of this method when called from layoutSubviews.
- (UIView *)snapshotViewAfterScreenUpdates:(BOOL)afterUpdates NS_AVAILABLE_IOS(7_0);
@end

NS_ASSUME_NONNULL_END

#else
#import <UIKitCore/UIScreen.h>
#endif
