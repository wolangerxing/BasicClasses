//
//  NSSet.m
//  BasicClasses
//
//  Created by 尚怀军 on 2019/1/23.
//  Copyright © 2019年 杨维. All rights reserved.
//

#import <Foundation/Foundation.h>

/*    NSSet.h
 Copyright (c) 1994-2018, Apple Inc. All rights reserved.
 */

#import <Foundation/NSObject.h>
#import <Foundation/NSEnumerator.h>

@class NSArray, NSDictionary, NSString;

/****************    Immutable Set    ****************/

/***
 1.顺序表存储
 
      原理：顺序表存储是将数据元素放到一块连续的内存存储空间，存取效率高，速度快。但是不可以动态增加长度
 
      优点：存取速度高效，通过下标来直接访问
 
      缺点：1.插入和删除比较慢，
           2.不可以增长长度
 
          比如：插入或者删除一个元素时，整个表需要遍历移动元素来重新排一次顺序
 
 2.链表存储
 
      原理：链表存储是在程序运行过程中动态的分配空间，只要存储器还有空间，就不会发生存储溢出问题
 
      优点：插入和删除速度快，保留原有的物理顺序，比如：插入或者删除一个元素时，只需要改变指针指向即可
 
      缺点：查找速度慢，因为查找时，需要循环链表访问
 ***/

/***
 NSSet：集合。是NSObject的子类，跟NSArray不一样在于，NSArray的元素是有序的，可以通过索引访问，而NSSet的元素是无序的，不能通过索引访问；NSArray的元素可以是重复的，而NSSet的元素不能重复，同一个元素只能有一个。
 NSMutableSet：可变集合。是NSSet的子类，跟NSSet不一样的地方在于NSMutableSet的元素是可以修改的，可以增加删除替换等操作。
 NSCountedSet：可计数集合。是NSMutableSet的子类，跟NSMutableSet不一样的地方在于，它的元素有个计数功能，添加同一个元素两次后该元素的计数为2，但是元素只能有一个不能重复，删除该元素的时候，当该元素的计数为0时删除它。
 ****/

/***
 对于NSSet来说，object是强引用的，和NSDictionary中的value是一样的。
 而NSDictionary中的key则是copy的，
 想要使NSSet的objects或者NSDictionary的values为weak，或者NSDictionary使用没有实现协议的对象作为key时，比较麻烦
 
 苹果为我们提供了相对于NSSet和NSDictionary更通用的两个类NSHashTable和NSMapTable
 ***/


NS_ASSUME_NONNULL_BEGIN

@interface NSSet<__covariant ObjectType> : NSObject <NSCopying, NSMutableCopying, NSSecureCoding, NSFastEnumeration>

@property (readonly) NSUInteger count;
- (nullable ObjectType)member:(ObjectType)object;
- (NSEnumerator<ObjectType> *)objectEnumerator;
- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithObjects:(const ObjectType _Nonnull [_Nullable])objects count:(NSUInteger)cnt NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end

@interface NSSet<ObjectType> (NSExtendedSet)

@property (readonly, copy) NSArray<ObjectType> *allObjects;
- (nullable ObjectType)anyObject;
//  是否包含某个对象
- (BOOL)containsObject:(ObjectType)anObject;
@property (readonly, copy) NSString *description;
- (NSString *)descriptionWithLocale:(nullable id)locale;
// 判断两个集合中的交集是否至少存在一个共同的元素
- (BOOL)intersectsSet:(NSSet<ObjectType> *)otherSet;
// 判断两个集合是否相等
- (BOOL)isEqualToSet:(NSSet<ObjectType> *)otherSet;
// 判断一个集合是不是另一个集合的子集
- (BOOL)isSubsetOfSet:(NSSet<ObjectType> *)otherSet;

- (void)makeObjectsPerformSelector:(SEL)aSelector NS_SWIFT_UNAVAILABLE("Use enumerateObjectsUsingBlock: or a for loop instead");
- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(nullable id)argument NS_SWIFT_UNAVAILABLE("Use enumerateObjectsUsingBlock: or a for loop instead");

// 通过添加一个对象创建一个新的集合
- (NSSet<ObjectType> *)setByAddingObject:(ObjectType)anObject API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));
// 通过已有的两个集合创建一个新的集合
- (NSSet<ObjectType> *)setByAddingObjectsFromSet:(NSSet<ObjectType> *)other API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));
// 通过一个集合和一个数组创建一个新的集合
- (NSSet<ObjectType> *)setByAddingObjectsFromArray:(NSArray<ObjectType> *)other API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));

- (void)enumerateObjectsUsingBlock:(void (NS_NOESCAPE ^)(ObjectType obj, BOOL *stop))block API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));
- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (NS_NOESCAPE ^)(ObjectType obj, BOOL *stop))block API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));

- (NSSet<ObjectType> *)objectsPassingTest:(BOOL (NS_NOESCAPE ^)(ObjectType obj, BOOL *stop))predicate API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));
- (NSSet<ObjectType> *)objectsWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (NS_NOESCAPE ^)(ObjectType obj, BOOL *stop))predicate API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));

@end

@interface NSSet<ObjectType> (NSSetCreation)

+ (instancetype)set;
// 把自己清空然后接受另一个对象
+ (instancetype)setWithObject:(ObjectType)object;
// 把自己清空然后接受很多对象
+ (instancetype)setWithObjects:(const ObjectType _Nonnull [_Nonnull])objects count:(NSUInteger)cnt;
+ (instancetype)setWithObjects:(ObjectType)firstObj, ... NS_REQUIRES_NIL_TERMINATION;
// 把自己清空然后接受另一个set传过来的所有对象
+ (instancetype)setWithSet:(NSSet<ObjectType> *)set;
// 把自己清空然后接受另一个array传过来的所有对
+ (instancetype)setWithArray:(NSArray<ObjectType> *)array;

// 下面是与之对应的构造方法
- (instancetype)initWithObjects:(ObjectType)firstObj, ... NS_REQUIRES_NIL_TERMINATION;
- (instancetype)initWithSet:(NSSet<ObjectType> *)set;
- (instancetype)initWithSet:(NSSet<ObjectType> *)set copyItems:(BOOL)flag;
- (instancetype)initWithArray:(NSArray<ObjectType> *)array;

@end

/****************    Mutable Set    ****************/

@interface NSMutableSet<ObjectType> : NSSet<ObjectType>

// 添加对象
- (void)addObject:(ObjectType)object;
// 移除对象
- (void)removeObject:(ObjectType)object;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCapacity:(NSUInteger)numItems NS_DESIGNATED_INITIALIZER;

@end

@interface NSMutableSet<ObjectType> (NSExtendedMutableSet)

- (void)addObjectsFromArray:(NSArray<ObjectType> *)array;
// 交集
- (void)intersectSet:(NSSet<ObjectType> *)otherSet;
// 减法
- (void)minusSet:(NSSet<ObjectType> *)otherSet;
// 移除所有元素
- (void)removeAllObjects;
// 并集
- (void)unionSet:(NSSet<ObjectType> *)otherSet;

- (void)setSet:(NSSet<ObjectType> *)otherSet;

@end

@interface NSMutableSet<ObjectType> (NSMutableSetCreation)
// 创建一个有size大小的新集合
+ (instancetype)setWithCapacity:(NSUInteger)numItems;

@end

/****************    Counted Set    ****************/

@interface NSCountedSet<ObjectType> : NSMutableSet<ObjectType> {
@private
    id _table;
    void *_reserved;
}

// 由容量创建
- (instancetype)initWithCapacity:(NSUInteger)numItems NS_DESIGNATED_INITIALIZER;

// 由数组创建
- (instancetype)initWithArray:(NSArray<ObjectType> *)array;
// 由set创建
- (instancetype)initWithSet:(NSSet<ObjectType> *)set;

- (NSUInteger)countForObject:(ObjectType)object;
// 返回集合中所有对象到一个 NSEnumerator 类型的对象
- (NSEnumerator<ObjectType> *)objectEnumerator;
// 添加对象
- (void)addObject:(ObjectType)object;
// 移除对象
- (void)removeObject:(ObjectType)object;

@end

NS_ASSUME_NONNULL_END
