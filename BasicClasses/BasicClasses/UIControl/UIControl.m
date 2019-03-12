//
//  UIControl.m
//  BasicClasses
//
//  Created by 罗永平 on 2019/1/24.
//  Copyright © 2019年 杨维. All rights reserved.
//

#if USE_UIKIT_PUBLIC_HEADERS || !__has_include(<UIKitCore/UIControl.h>)
//
//  UIControl.h
//  UIKit
//
//  Copyright (c) 2005-2018 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIView.h>
#import <UIKit/UIKitDefines.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, UIControlEvents) {
    UIControlEventTouchDown                                         = 1 <<  0,      // 单点触摸
    UIControlEventTouchDownRepeat                                   = 1 <<  1,      // 多点触摸， Down->UpInside->Down->Repeat->UpInside->Down->Repeat->UpInside...，除第一次外，后面的Down必定紧跟Repeat
    UIControlEventTouchDragInside                                   = 1 <<  2,      // 触摸，并在控件内拖动
    UIControlEventTouchDragOutside                                  = 1 <<  3,      // 触摸，并在控件外拖动
    UIControlEventTouchDragEnter                                    = 1 <<  4,      // 拖动时，从控件外至内
    UIControlEventTouchDragExit                                     = 1 <<  5,      // 拖动时，从控件内至外
    UIControlEventTouchUpInside                                     = 1 <<  6,      // 在控件之内触摸并抬起，前提是先按下
    UIControlEventTouchUpOutside                                    = 1 <<  7,      // 在控件之外触摸并抬起，前提是先按下，然后拖动到控件外
    UIControlEventTouchCancel                                       = 1 <<  8,      // 所有触摸取消
    
    UIControlEventValueChanged                                      = 1 << 12,     // 控件的值发生改变，用于滑块、分段控件及其他取值的控件
    UIControlEventPrimaryActionTriggered NS_ENUM_AVAILABLE_IOS(9_0) = 1 << 13,     // 控件的首要行为被触发，如button的点击、slider的滑动等
    
    UIControlEventEditingDidBegin                                   = 1 << 16,     // 文本控件中开始编辑时的事件
    UIControlEventEditingChanged                                    = 1 << 17,     // 文本控件中b文本被改变时的事件
    UIControlEventEditingDidEnd                                     = 1 << 18,     // 文本控件中编辑结束时的事件
    UIControlEventEditingDidEndOnExit                               = 1 << 19,     // 文本控件中按下回车键结束编辑时的事件
    
    UIControlEventAllTouchEvents                                    = 0x00000FFF,  // 所有的触摸事件
    UIControlEventAllEditingEvents                                  = 0x000F0000,  // 文本控件的所有事件
    UIControlEventApplicationReserved                               = 0x0F000000,  // 应用程序可以使用的事件
    UIControlEventSystemReserved                                    = 0xF0000000,  // 内部框架可以使用的事件
    UIControlEventAllEvents                                         = 0xFFFFFFFF   // 所有的事件
};

typedef NS_ENUM(NSInteger, UIControlContentVerticalAlignment) {
    UIControlContentVerticalAlignmentCenter  = 0,
    UIControlContentVerticalAlignmentTop     = 1,
    UIControlContentVerticalAlignmentBottom  = 2,
    UIControlContentVerticalAlignmentFill    = 3,
};

typedef NS_ENUM(NSInteger, UIControlContentHorizontalAlignment) {
    UIControlContentHorizontalAlignmentCenter = 0,
    UIControlContentHorizontalAlignmentLeft   = 1,
    UIControlContentHorizontalAlignmentRight  = 2,
    UIControlContentHorizontalAlignmentFill   = 3,
    UIControlContentHorizontalAlignmentLeading  API_AVAILABLE(ios(11.0), tvos(11.0)) = 4,
    UIControlContentHorizontalAlignmentTrailing API_AVAILABLE(ios(11.0), tvos(11.0)) = 5,
};

typedef NS_OPTIONS(NSUInteger, UIControlState) {
    UIControlStateNormal       = 0,                             // 控件正常状态或者默认状态，即已启用但未选中未高亮
    UIControlStateHighlighted  = 1 << 0,                        // 高亮状态
    UIControlStateDisabled     = 1 << 1,                        // 未启用状态
    UIControlStateSelected     = 1 << 2,                        // 选中状态，当分别设置Normal和Selected时，需要设置Selected与Highlighted为相同的
    UIControlStateFocused NS_ENUM_AVAILABLE_IOS(9_0) = 1 << 3,  // 获得焦点状态
    UIControlStateApplication  = 0x00FF0000,                    // 附加的控制状态，可供应用程序使用
    UIControlStateReserved     = 0xFF000000                     // 内部框架使用保留的状态
};

@class UITouch;
@class UIEvent;

//______________________________________________________

NS_CLASS_AVAILABLE_IOS(2_0) @interface UIControl : UIView

/// MARK: 属性
@property(nonatomic,getter=isEnabled) BOOL enabled; // 接受事件，默认为Yes
@property(nonatomic,getter=isSelected) BOOL selected; // 控件选中，默认No
@property(nonatomic,getter=isHighlighted) BOOL highlighted; // 控件高亮，默认No
// 控件如何在垂直/水平方向上布置自身的内容
@property(nonatomic) UIControlContentVerticalAlignment contentVerticalAlignment; // 默认居中
@property(nonatomic) UIControlContentHorizontalAlignment contentHorizontalAlignment; // 默认居中
@property(nonatomic, readonly) UIControlContentHorizontalAlignment effectiveContentHorizontalAlignment;

@property(nonatomic,readonly) UIControlState state; // 控件的状态
@property(nonatomic,readonly,getter=isTracking) BOOL tracking; // 当前对象是否在追踪触摸操作
@property(nonatomic,readonly,getter=isTouchInside) BOOL touchInside; // 判断触摸是否在控件区域内，仅触摸时有效，YES的区域会比控件区域大

/// MARK: 跟踪触摸，拦截用户自定义事件
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(nullable UIEvent *)event;
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(nullable UIEvent *)event;
- (void)endTrackingWithTouch:(nullable UITouch *)touch withEvent:(nullable UIEvent *)event; // 如果取消跟踪，则touch为nil
- (void)cancelTrackingWithEvent:(nullable UIEvent *)event;   // 由于非事件原因（从window中移除）导致的取消，则event为nil

// 添加特定的事件（可以采用or逻辑添加多个）发生时执行的动作
- (void)addTarget:(nullable id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

// 删除一个或多个事件的相应动作，使用nil值可以将给定事件目标的所有动作删除
- (void)removeTarget:(nullable id)target action:(nullable SEL)action forControlEvents:(UIControlEvents)controlEvents;

/// MARK: 获取目标和动作的信息
#if UIKIT_DEFINE_AS_PROPERTIES
@property(nonatomic,readonly) NSSet *allTargets;
@property(nonatomic,readonly) UIControlEvents allControlEvents;
#else
// 控件的所有指定动作的列表，可能包含nil
- (NSSet *)allTargets;
// 控件响应的所有事件，至少包含一个事件
- (UIControlEvents)allControlEvents;
#endif
// 获取针对某一个事件的全部动作列表
- (nullable NSArray<NSString *> *)actionsForTarget:(nullable id)target forControlEvent:(UIControlEvents)controlEvent;

// 针对指定事件，通知目标对象，执行对应的动作，可以处理事件分发
- (void)sendAction:(SEL)action to:(nullable id)target forEvent:(nullable UIEvent *)event;
// 执行与指定事件相关的动作方法
- (void)sendActionsForControlEvents:(UIControlEvents)controlEvents;

@end

NS_ASSUME_NONNULL_END

#else
#import <UIKitCore/UIControl.h>
#endif
