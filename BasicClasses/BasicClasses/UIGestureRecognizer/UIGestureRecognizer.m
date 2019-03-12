//
//  UIGestureRecognizer.m
//
//  Created by lingqineng on 2019/1/23.
//

#if USE_UIKIT_PUBLIC_HEADERS || !__has_include(<UIKitCore/UIGestureRecognizer.h>)
//
//  UIGestureRecognizer.h
//  UIKit
//
//  Copyright (c) 2008-2018 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@protocol UIGestureRecognizerDelegate;
@class UIView, UIEvent, UITouch, UIPress;

typedef NS_ENUM(NSInteger, UIGestureRecognizerState) {
    UIGestureRecognizerStatePossible,   // 尚未识别是哪种手势操作，为默认状态，也有可能已经触发了触摸事件
    
    UIGestureRecognizerStateBegan,      // 手势已经开始，且已经被识别
    UIGestureRecognizerStateChanged,    // 手势的状态发生改变
    UIGestureRecognizerStateEnded,      // 手势识别已经完成，此时已经松开手指
    UIGestureRecognizerStateCancelled,  // 手势被取消，恢复到默认的possible状态
    UIGestureRecognizerStateFailed,     // 手势识别失败，恢复到默认的possible状态
    UIGestureRecognizerStateRecognized = UIGestureRecognizerStateEnded
};

/*
 * 基本的子类
 * UITapGestureRecognizer -- 点击手势
 * UIPinchGestureRecognizer -- 捏合手势
 * UIPanGestureRecognzer -- 拉拽手势
 * UISwipeGestureRecognizer -- 滑动手势
 * UIRotationGestureRecognizer -- 旋转手势
 * UILongPressGestureRecognizer -- 长按手势
 */

NS_CLASS_AVAILABLE_IOS(3_2) @interface UIGestureRecognizer : NSObject


//最为基本的三个方法
- (instancetype)initWithTarget:(nullable id)target action:(nullable SEL)action NS_DESIGNATED_INITIALIZER; // designated initializer
/*
 *一般可以给一个gesture加很多个target/action对，且触发的时候，所有的selector都会被执行
 * UITapGestureRecognizer * gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(foo:)];
 * [gesture addTarget:self action:@selector(bar)];
 */
- (void)addTarget:(id)target action:(SEL)action;    // add a target/action pair. you can call this multiple times to specify multiple target/actions
- (void)removeTarget:(nullable id)target action:(nullable SEL)action; // remove the specified target/action pair. passing nil for target matches all targets, and the same for actions

@property(nonatomic,readonly) UIGestureRecognizerState state;  // the current state of the gesture recognizer

@property(nullable,nonatomic,weak) id <UIGestureRecognizerDelegate> delegate; // the gesture recognizer's delegate
//判断手势识别是否可用
@property(nonatomic, getter=isEnabled) BOOL enabled;  // default is YES. disabled gesture recognizers will not receive touches. when changed to NO the gesture recognizer will be cancelled if it's currently recognizing a gesture

//拿到识别该手势的视图
@property(nullable, nonatomic,readonly) UIView *view;           // the view the gesture is attached to. set by adding the recognizer to a UIView using the addGestureRecognizer: method
/*
 * 设置为YES时，屏蔽掉touch的事件，设置成NO的话，不会屏蔽touch的事件
 *  UIPanGestureRecognizer * gesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(foo:)];;
 *   [self.view addGestureRecognizer:gesture];
 *  ges.cancelsTouchesInView = NO;
 * -(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
 *   NSLog(@"触摸事件");
 * }
 * -(void)foo:(UIGestureRecognizer *)gesture{
 *   NSLog(@"手势触发");
 * }
 */
@property(nonatomic) BOOL cancelsTouchesInView;
/*
 * 默认是NO，这种情况下当发生一个触摸时，手势识别器先捕捉到到触摸，然后发给触摸到的控件，两者各自做出响应。如果设置为YES，
 * 手势识别器在识别的过程中（注意是识别过程），不会将触摸发给触摸到的控件，即控件不会有任何触摸事件。只有在识别失败之后才
 * 会将触摸事件发给触摸到的控件，这种情况下控件view的响应会延迟约0.15ms。
 */
@property(nonatomic) BOOL delaysTouchesBegan;
/*
 * 这种情况下发生一个触摸时，在手势识别成功后，发送给touchesCancelled消息给触摸控件view，手势识别失败时，会延迟大概0.15ms，
 * 如果设置为NO，则不会延迟，即会立即发送touchesEnded以结束当前触摸。
 */
@property(nonatomic) BOOL delaysTouchesEnded;

@property(nonatomic, copy) NSArray<NSNumber *> *allowedTouchTypes NS_AVAILABLE_IOS(9_0); // Array of UITouchTypes as NSNumbers.
@property(nonatomic, copy) NSArray<NSNumber *> *allowedPressTypes NS_AVAILABLE_IOS(9_0); // Array of UIPressTypes as NSNumbers.

// Indicates whether the gesture recognizer will consider touches of different touch types simultaneously.
// If NO, it receives all touches that match its allowedTouchTypes.
// If YES, once it receives a touch of a certain type, it will ignore new touches of other types, until it is reset to UIGestureRecognizerStatePossible.
/* 手势识别器是否同时考虑不同类型的触摸。
 当此属性的值为YES时，手势识别器会自动忽略其类型与初始触摸类型不匹配的新触摸。 如果值为NO，则手势识别器将接收其类型在allowedTouchTypes属性中列出的所有触摸。 */
@property (nonatomic) BOOL requiresExclusiveTouchType NS_AVAILABLE_IOS(9_2); // defaults to YES

/*
 * 指定一个手势需要另一个手势执行失败才会执行，同时触发多个手势使用其中一个手势的解决办法
 * 例如在双击检测失败时才会触发单击事件
 * [singleRecognizer requireGestureRecognizerToFail:doubleRecognizer];
 */
- (void)requireGestureRecognizerToFail:(UIGestureRecognizer *)otherGestureRecognizer;

//获取当前触摸在指定视图上的点
- (CGPoint)locationInView:(nullable UIView*)view;

#if UIKIT_DEFINE_AS_PROPERTIES
@property(nonatomic, readonly) NSUInteger numberOfTouches;                                          // number of touches involved for which locations can be queried
#else
- (NSUInteger)numberOfTouches;                                          // number of touches involved for which locations can be queried
#endif

//多指触摸时获取指定touch在屏幕上的位置
- (CGPoint)locationOfTouch:(NSUInteger)touchIndex inView:(nullable UIView*)view; // the location of a particular touch

@property (nullable, nonatomic, copy) NSString *name API_AVAILABLE(ios(11.0), tvos(11.0)); // name for debugging to appear in logging

@end


@protocol UIGestureRecognizerDelegate <NSObject>
@optional
/*
 * 开始手势识别时调用的方法，返回NO，将不再触发手势
 * 可能会用到的场景：例如可以规定手势在控件的指定区域会识别
 */
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer;

/*
 * 是否支持多手势触发场景，返回YES，则可以多个手势一起触发方法
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;

/*
 * 该方法返回YES，第一个手势和第二个手势互斥时，第一个手势会失效
 * 可能会用到的场景：处理一些手势画互斥及手势优先级的场景
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer NS_AVAILABLE_IOS(7_0);
/*
 * 该方法返回YES，第一个手势和第二个手势互斥时，第二个手势会失效
 * 可能会用到的场景：处理一些手势画互斥及手势优先级的场景
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer NS_AVAILABLE_IOS(7_0);

/*
 * 触摸屏幕的回调方法，NO将不再是进行手势识别
 * 可能会用到的场景：例如手势和控件的点击事件冲突
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;

// called before pressesBegan:withEvent: is called on the gesture recognizer for a new press. return NO to prevent the gesture recognizer from seeing this press
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceivePress:(UIPress *)press;

@end

NS_ASSUME_NONNULL_END

#else
#import <UIKitCore/UIGestureRecognizer.h>
#endif
