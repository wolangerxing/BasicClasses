//
//  UITextView.m
//  BasicClasses
//
//  Created by 罗永平 on 2019/1/28.
//  Copyright © 2019年 杨维. All rights reserved.
//

#if USE_UIKIT_PUBLIC_HEADERS || !__has_include(<UIKitCore/UITextView.h>)
//
//  UITextView.h
//  UIKit
//
//  Copyright (c) 2007-2018 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIScrollView.h>
#import <UIKit/UIStringDrawing.h>
#import <UIKit/UITextDragging.h>
#import <UIKit/UITextDropping.h>
#import <UIKit/UITextInput.h>
#import <UIKit/UIKitDefines.h>
#import <UIKit/UIDataDetectors.h>
#import <UIKit/UITextItemInteraction.h>
#import <UIKit/UIContentSizeCategoryAdjusting.h>
#import <UIKit/UITextPasteConfigurationSupporting.h>

NS_ASSUME_NONNULL_BEGIN

@class UIFont, UIColor, UITextView, NSTextContainer, NSLayoutManager, NSTextStorage, NSTextAttachment;

@protocol UITextViewDelegate <NSObject, UIScrollViewDelegate>

@optional

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView; // 将要开始编辑
- (BOOL)textViewShouldEndEditing:(UITextView *)textView; // 将要结束编辑

- (void)textViewDidBeginEditing:(UITextView *)textView; // 开始编辑
- (void)textViewDidEndEditing:(UITextView *)textView; // 结束编辑

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text; // 内容将要发生改变，可在此加入对文本长度和内容的控制
- (void)textViewDidChange:(UITextView *)textView; // 内容发生改变，可在此加入调整控件大小的方法，实现控件高度自适应

- (void)textViewDidChangeSelection:(UITextView *)textView; // 焦点发生改变

// 是否允许对文本中的URL进行操作
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction NS_AVAILABLE_IOS(10_0);
// 是否允许对文本中的富文本进行操作
- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction NS_AVAILABLE_IOS(10_0);

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange NS_DEPRECATED_IOS(7_0, 10_0, "Use textView:shouldInteractWithURL:inRange:forInteractionType: instead");
- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange NS_DEPRECATED_IOS(7_0, 10_0, "Use textView:shouldInteractWithTextAttachment:inRange:forInteractionType: instead");

@end

NS_CLASS_AVAILABLE_IOS(2_0) @interface UITextView : UIScrollView <UITextInput, UIContentSizeCategoryAdjusting>

@property(nullable,nonatomic,weak) id<UITextViewDelegate> delegate; // 代理

@property(null_resettable,nonatomic,copy) NSString *text; // 内容
@property(nullable,nonatomic,strong) UIFont *font; // 字体
@property(nullable,nonatomic,strong) UIColor *textColor; // 内容颜色
@property(nonatomic) NSTextAlignment textAlignment; // 内容对齐方式，默认左对齐
@property(nonatomic) NSRange selectedRange; // 选中范围
@property(nonatomic,getter=isEditable) BOOL editable __TVOS_PROHIBITED; // 是否可以编辑，默认Yes，注：可编辑状态下是不能点击链接的
@property(nonatomic,getter=isSelectable) BOOL selectable NS_AVAILABLE_IOS(7_0); // 是否可以选中，默认Yes
@property(nonatomic) UIDataDetectorTypes dataDetectorTypes NS_AVAILABLE_IOS(3_0) __TVOS_PROHIBITED; // 使电话号码、网址、电子邮件和符合格式的日期等文字变为链接文字

@property(nonatomic) BOOL allowsEditingTextAttributes NS_AVAILABLE_IOS(6_0); // 是否允许改变文本属性字典，默认No
@property(null_resettable,copy) NSAttributedString *attributedText NS_AVAILABLE_IOS(6_0); // 富文本
@property(nonatomic,copy) NSDictionary<NSAttributedStringKey, id> *typingAttributes NS_AVAILABLE_IOS(6_0); // 设置新输入的文本的属性，当光标的位置改变时将会自动重置

- (void)scrollRangeToVisible:(NSRange)range; // 滚动到文本的某个段落


@property (nullable, readwrite, strong) UIView *inputView; // 通过设置该属性可以弹出自定义控件，不弹出系统键盘
@property (nullable, readwrite, strong) UIView *inputAccessoryView; // 在inputView中添加附加控件，通常用于点击附加控件后收回inputView

@property(nonatomic) BOOL clearsOnInsertion NS_AVAILABLE_IOS(6_0); // 控件获取焦点后是否清空内容，默认No

- (instancetype)initWithFrame:(CGRect)frame textContainer:(nullable NSTextContainer *)textContainer NS_AVAILABLE_IOS(7_0) NS_DESIGNATED_INITIALIZER; // 从代码中加载控件时执行
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER; // 从文件中加载控件时执行

@property(nonatomic,readonly) NSTextContainer *textContainer NS_AVAILABLE_IOS(7_0); // 用于存放已经排版且设置好属性的本字
@property(nonatomic, assign) UIEdgeInsets textContainerInset NS_AVAILABLE_IOS(7_0); // 文本内容与边界的间距

@property(nonatomic,readonly) NSLayoutManager *layoutManager NS_AVAILABLE_IOS(7_0); // 管理textStorage中的文本内容的排版布局
@property(nonatomic,readonly,strong) NSTextStorage *textStorage NS_AVAILABLE_IOS(7_0); // 保存控件要展示的文本内容

@property(null_resettable, nonatomic, copy) NSDictionary<NSAttributedStringKey,id> *linkTextAttributes NS_AVAILABLE_IOS(7_0); // 链接文本的样式设置

@end

#if TARGET_OS_IOS

@interface UITextView () <UITextDraggable, UITextDroppable, UITextPasteConfigurationSupporting>
@end

#endif
/// MARK: 通知
UIKIT_EXTERN NSNotificationName const UITextViewTextDidBeginEditingNotification; // 开始编辑的通知
UIKIT_EXTERN NSNotificationName const UITextViewTextDidChangeNotification; // 文本发生改变的通知
UIKIT_EXTERN NSNotificationName const UITextViewTextDidEndEditingNotification; // 编辑结束的通知

NS_ASSUME_NONNULL_END

#else
#import <UIKitCore/UITextView.h>
#endif
