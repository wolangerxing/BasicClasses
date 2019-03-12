//
//  NSString.m
//  BasicClasses
//
//  Created by 张政桢 on 2019/1/23.
//  Copyright © 2019 杨维. All rights reserved.
//

/* These options apply to the various search/find and comparison methods (except where noted).
 */
typedef NS_OPTIONS(NSUInteger, NSStringCompareOptions) {
    NSCaseInsensitiveSearch = 1, //不区分大小写比较
    NSLiteralSearch = 2,         //区分大小写比较
    NSBackwardsSearch = 4,       //从字符串末尾开始搜索
    NSAnchoredSearch = 8,        //搜索限制范围的字符串
    NSNumericSearch = 64,        //按照字符串里的数字为依据，算出顺序。例如 Foo2.txt < Foo7.txt < Foo25.txt
    NSDiacriticInsensitiveSearch API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0)) = 128, //忽略 "-" 符号的比较
    NSWidthInsensitiveSearch API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0)) = 256, //忽略字符串的长度，比较出结果
    NSForcedOrderingSearch API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0)) = 512, //忽略不区分大小写比较的选项，并强制返回 NSOrderedAscending 或者 NSOrderedDescending
    NSRegularExpressionSearch API_AVAILABLE(macos(10.7), ios(3.2), watchos(2.0), tvos(9.0)) = 1024 //只能应用于 rangeOfString:..., stringByReplacingOccurrencesOfString:...和 replaceOccurrencesOfString:... 方法。使用通用兼容的比较方法，如果设置此项，可以去掉 NSCaseInsensitiveSearch 和 NSAnchoredSearch
};

/* Note that in addition to the values explicitly listed below, NSStringEncoding supports encodings provided by CFString.
 See CFStringEncodingExt.h for a list of these encodings.
 See CFString.h for functions which convert between NSStringEncoding and CFStringEncoding.
 */
typedef NSUInteger NSStringEncoding;
NS_ENUM(NSStringEncoding) {
    NSASCIIStringEncoding = 1,        /* 0..127 only */
    NSNEXTSTEPStringEncoding = 2,
    NSJapaneseEUCStringEncoding = 3,
    NSUTF8StringEncoding = 4,
    NSISOLatin1StringEncoding = 5,
    NSSymbolStringEncoding = 6,
    NSNonLossyASCIIStringEncoding = 7,
    NSShiftJISStringEncoding = 8,          /* kCFStringEncodingDOSJapanese */
    NSISOLatin2StringEncoding = 9,
    NSUnicodeStringEncoding = 10,
    NSWindowsCP1251StringEncoding = 11,    /* Cyrillic; same as AdobeStandardCyrillic */
    NSWindowsCP1252StringEncoding = 12,    /* WinLatin1 */
    NSWindowsCP1253StringEncoding = 13,    /* Greek */
    NSWindowsCP1254StringEncoding = 14,    /* Turkish */
    NSWindowsCP1250StringEncoding = 15,    /* WinLatin2 */
    NSISO2022JPStringEncoding = 21,        /* ISO 2022 Japanese encoding for e-mail */
    NSMacOSRomanStringEncoding = 30,
    
    NSUTF16StringEncoding = NSUnicodeStringEncoding,      /* An alias for NSUnicodeStringEncoding */
    
    NSUTF16BigEndianStringEncoding = 0x90000100,          /* NSUTF16StringEncoding encoding with explicit endianness specified */
    NSUTF16LittleEndianStringEncoding = 0x94000100,       /* NSUTF16StringEncoding encoding with explicit endianness specified */
    
    NSUTF32StringEncoding = 0x8c000100,
    NSUTF32BigEndianStringEncoding = 0x98000100,          /* NSUTF32StringEncoding encoding with explicit endianness specified */
    NSUTF32LittleEndianStringEncoding = 0x9c000100        /* NSUTF32StringEncoding encoding with explicit endianness specified */
};

typedef NS_OPTIONS(NSUInteger, NSStringEncodingConversionOptions) {
    NSStringEncodingConversionAllowLossy = 1,
    NSStringEncodingConversionExternalRepresentation = 2
};

@interface NSString : NSObject <NSCopying, NSMutableCopying, NSSecureCoding>

#pragma mark *** String funnel methods ***

// 字符串长度
@property (readonly) NSUInteger length;
// 返回下标为index的字符
- (unichar)characterAtIndex:(NSUInteger)index;

@end

@interface NSString (NSStringExtensionMethods)

#pragma mark *** Substrings ***

// 下面是提取子串的方法，因为表情符号会占用2个位置，所以需要rangeOfComposedCharacterSequenceAtIndex方法，判断index是否合法。

/* To avoid breaking up character sequences such as Emoji, you can do:
 [str substringFromIndex:[str rangeOfComposedCharacterSequenceAtIndex:index].location]
 [str substringToIndex:NSMaxRange([str rangeOfComposedCharacterSequenceAtIndex:index])]
 [str substringWithRange:[str rangeOfComposedCharacterSequencesForRange:range]
 */
- (NSString *)substringFromIndex:(NSUInteger)from;
- (NSString *)substringToIndex:(NSUInteger)to;
- (NSString *)substringWithRange:(NSRange)range;                // Use with rangeOfComposedCharacterSequencesForRange: to avoid breaking up character sequences

- (void)getCharacters:(unichar *)buffer range:(NSRange)range;   // Use with rangeOfComposedCharacterSequencesForRange: to avoid breaking up character sequences


#pragma mark *** String comparison and equality ***

// 字符串比较和相等的一些方法，会返回一个枚举值：NSOrderedAscending、NSOrderedSame、NSOrderedDescending

/* In the compare: methods, the range argument specifies the subrange, rather than the whole, of the receiver to use in the comparison. The range is not applied to the search string.  For example, [@"AB" compare:@"ABC" options:0 range:NSMakeRange(0,1)] compares "A" to "ABC", not "A" to "A", and will return NSOrderedAscending. It is an error to specify a range that is outside of the receiver's bounds, and an exception may be raised.
 */
- (NSComparisonResult)compare:(NSString *)string;
- (NSComparisonResult)compare:(NSString *)string options:(NSStringCompareOptions)mask;
- (NSComparisonResult)compare:(NSString *)string options:(NSStringCompareOptions)mask range:(NSRange)rangeOfReceiverToCompare;
- (NSComparisonResult)compare:(NSString *)string options:(NSStringCompareOptions)mask range:(NSRange)rangeOfReceiverToCompare locale:(nullable id)locale; // locale arg used to be a dictionary pre-Leopard. We now accept NSLocale. Assumes the current locale if non-nil and non-NSLocale. nil continues to mean canonical compare, which doesn't depend on user's locale choice.
- (NSComparisonResult)caseInsensitiveCompare:(NSString *)string;
- (NSComparisonResult)localizedCompare:(NSString *)string;
- (NSComparisonResult)localizedCaseInsensitiveCompare:(NSString *)string;

/* localizedStandardCompare:, added in 10.6, should be used whenever file names or other strings are presented in lists and tables where Finder-like sorting is appropriate.  The exact behavior of this method may be tweaked in future releases, and will be different under different localizations, so clients should not depend on the exact sorting order of the strings.
 */
- (NSComparisonResult)localizedStandardCompare:(NSString *)string API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));

- (BOOL)isEqualToString:(NSString *)aString;


#pragma mark *** String searching ***

// 字符串搜索的一些方法

/* These perform locale unaware prefix or suffix match. If you need locale awareness, use rangeOfString:options:range:locale:, passing NSAnchoredSearch (or'ed with NSBackwardsSearch for suffix, and NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch if needed) for options, NSMakeRange(0, [receiver length]) for range, and [NSLocale currentLocale] for locale.
 */
- (BOOL)hasPrefix:(NSString *)str;
- (BOOL)hasSuffix:(NSString *)str;

// 返回两个字符串相同的前缀，options：是比较类型的枚举，比如是否忽略大小写等
- (NSString *)commonPrefixWithString:(NSString *)str options:(NSStringCompareOptions)mask;

/* Simple convenience methods for string searching. containsString: returns YES if the target string is contained within the receiver. Same as calling rangeOfString:options: with no options, thus doing a case-sensitive, locale-unaware search. localizedCaseInsensitiveContainsString: is the case-insensitive variant which also takes the current locale into effect. Starting in 10.11 and iOS9, the new localizedStandardRangeOfString: or localizedStandardContainsString: APIs are even better convenience methods for user level searching.   More sophisticated needs can be achieved by calling rangeOfString:options:range:locale: directly.
 */
- (BOOL)containsString:(NSString *)str API_AVAILABLE(macos(10.10), ios(8.0), watchos(2.0), tvos(9.0));

// 本地化是否包含字符串(不区分大小写)因为本地化会定义一些相同的字符：File = 文件 等
- (BOOL)localizedCaseInsensitiveContainsString:(NSString *)str API_AVAILABLE(macos(10.10), ios(8.0), watchos(2.0), tvos(9.0));

// 本地化是否包含字符串(标准)
- (BOOL)localizedStandardContainsString:(NSString *)str API_AVAILABLE(macos(10.11), ios(9.0), watchos(2.0), tvos(9.0));

// 本地化搜索字符串范围(标准)
- (NSRange)localizedStandardRangeOfString:(NSString *)str API_AVAILABLE(macos(10.11), ios(9.0), watchos(2.0), tvos(9.0));

// 搜索(指定字符串)、条件、范围、本地化
- (NSRange)rangeOfString:(NSString *)searchString;
- (NSRange)rangeOfString:(NSString *)searchString options:(NSStringCompareOptions)mask;
- (NSRange)rangeOfString:(NSString *)searchString options:(NSStringCompareOptions)mask range:(NSRange)rangeOfReceiverToSearch;
- (NSRange)rangeOfString:(NSString *)searchString options:(NSStringCompareOptions)mask range:(NSRange)rangeOfReceiverToSearch locale:(nullable NSLocale *)locale API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));


/** 系统自带的，常用的字符集
+ controlCharacterSet
+ whitespaceCharacterSet              //空格
+ whitespaceAndNewlineCharacterSet    //空格和换行符
+ decimalDigitCharacterSet            //0-9的数字
+ letterCharacterSet                  //所有字母
+ lowercaseLetterCharacterSet         //小写字母
+ uppercaseLetterCharacterSet         //大写字母
+ alphanumericCharacterSet            //所有数字和字母（大小写不分）
+ punctuationCharacterSet             //标点符号
+ newlineCharacterSet                 //换行
*/

// 搜索包含字符集中出现字符的第一个位置
- (NSRange)rangeOfCharacterFromSet:(NSCharacterSet *)searchSet;
- (NSRange)rangeOfCharacterFromSet:(NSCharacterSet *)searchSet options:(NSStringCompareOptions)mask;
- (NSRange)rangeOfCharacterFromSet:(NSCharacterSet *)searchSet options:(NSStringCompareOptions)mask range:(NSRange)rangeOfReceiverToSearch;

// emoji表情在字符串中是以2个长度来处理的，当遇到字符串截取时，如果截断位置刚好在emoji表情的中间。此时emoji表情就会出现无法解码，所以需要用到下面方法去判断
- (NSRange)rangeOfComposedCharacterSequenceAtIndex:(NSUInteger)index;
- (NSRange)rangeOfComposedCharacterSequencesForRange:(NSRange)range API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));

// 两个字符串拼接
- (NSString *)stringByAppendingString:(NSString *)aString;
- (NSString *)stringByAppendingFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);


#pragma mark *** Extracting numeric values ***

// 可以将字符串转换成对应数字，如果不能转就返回0，如果是 33ss 就返回前缀能转的 33
@property (readonly) double doubleValue;
@property (readonly) float floatValue;
@property (readonly) int intValue;
@property (readonly) NSInteger integerValue API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));
@property (readonly) long long longLongValue API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));
@property (readonly) BOOL boolValue API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));  // Skips initial space characters (whitespaceSet), or optional -/+ sign followed by zeroes. Returns YES on encountering one of "Y", "y", "T", "t", or a digit 1-9. It ignores any trailing characters.


#pragma mark *** Case changing ***

// 转大写、小写、首字母大写
@property (readonly, copy) NSString *uppercaseString;
@property (readonly, copy) NSString *lowercaseString;
@property (readonly, copy) NSString *capitalizedString;

// 考虑用户当前区域的大小写转换
@property (readonly, copy) NSString *localizedUppercaseString API_AVAILABLE(macos(10.11), ios(9.0), watchos(2.0), tvos(9.0));
@property (readonly, copy) NSString *localizedLowercaseString API_AVAILABLE(macos(10.11), ios(9.0), watchos(2.0), tvos(9.0));
@property (readonly, copy) NSString *localizedCapitalizedString API_AVAILABLE(macos(10.11), ios(9.0), watchos(2.0), tvos(9.0));

// 不要使用 NSString 的 -uppercaseString 或者 -lowercaseString 的方法来处理 UI 显示的字符串，这样转换会考虑用户的本地化信息
- (NSString *)uppercaseStringWithLocale:(nullable NSLocale *)locale API_AVAILABLE(macos(10.8), ios(6.0), watchos(2.0), tvos(9.0));
- (NSString *)lowercaseStringWithLocale:(nullable NSLocale *)locale API_AVAILABLE(macos(10.8), ios(6.0), watchos(2.0), tvos(9.0));
- (NSString *)capitalizedStringWithLocale:(nullable NSLocale *)locale API_AVAILABLE(macos(10.8), ios(6.0), watchos(2.0), tvos(9.0));


#pragma mark *** Finding lines, sentences, words, etc ***

// 下面两个方法，没查到怎么用
- (void)getLineStart:(nullable NSUInteger *)startPtr end:(nullable NSUInteger *)lineEndPtr contentsEnd:(nullable NSUInteger *)contentsEndPtr forRange:(NSRange)range;
- (NSRange)lineRangeForRange:(NSRange)range;

- (void)getParagraphStart:(nullable NSUInteger *)startPtr end:(nullable NSUInteger *)parEndPtr contentsEnd:(nullable NSUInteger *)contentsEndPtr forRange:(NSRange)range;
- (NSRange)paragraphRangeForRange:(NSRange)range;

// 分割字符串的枚举类型
typedef NS_OPTIONS(NSUInteger, NSStringEnumerationOptions) {
    // Pass in one of the "By" options:
    NSStringEnumerationByLines = 0,                       // 按行
    NSStringEnumerationByParagraphs = 1,                  // 按段落
    NSStringEnumerationByComposedCharacterSequences = 2,  // 按字符顺序
    NSStringEnumerationByWords = 3,                       // 按单词,字
    NSStringEnumerationBySentences = 4,                   // 按句子
    // ...and combine any of the desired additional options:
    NSStringEnumerationReverse = 1UL << 8,                // 反向遍历
    NSStringEnumerationSubstringNotRequired = 1UL << 9,   // 不需要子字符串
    NSStringEnumerationLocalized = 1UL << 10              // 本地化
};

// 将上面枚举参数传入，回调方法中实现分段
- (void)enumerateSubstringsInRange:(NSRange)range options:(NSStringEnumerationOptions)opts usingBlock:(void (^)(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop))block API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));
// 相当于上面的bylines分段
- (void)enumerateLinesUsingBlock:(void (^)(NSString *line, BOOL *stop))block API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));


#pragma mark *** Character encoding and converting to/from c-string representations ***

// 返回UTF8编码值
@property (nullable, readonly) const char *UTF8String NS_RETURNS_INNER_POINTER;    // Convenience to return null-terminated UTF8 representation

// 返回一个编码值枚举类型，最快、最小编码
@property (readonly) NSStringEncoding fastestEncoding;        // Result in O(1) time; a rough estimate
@property (readonly) NSStringEncoding smallestEncoding;       // Result in O(n) time; the encoding in which the string is most compact

// 用相应编码类型进行编码，是否有损编码
- (nullable NSData *)dataUsingEncoding:(NSStringEncoding)encoding allowLossyConversion:(BOOL)lossy;   // External representation
- (nullable NSData *)dataUsingEncoding:(NSStringEncoding)encoding;                                    // External representation
// 判断是否可以无损编码
- (BOOL)canBeConvertedToEncoding:(NSStringEncoding)encoding;

// C字符编码转换
- (nullable const char *)cStringUsingEncoding:(NSStringEncoding)encoding NS_RETURNS_INNER_POINTER;    // "Autoreleased"; NULL return if encoding conversion not possible; for performance reasons, lifetime of this should not be considered longer than the lifetime of the receiving string (if the receiver string is freed, this might go invalid then, before the end of the autorelease scope). Use only with 8-bit encodings, and not encodings such as UTF-16 or UTF-32.
// 判读C字符转化是否可以成功
- (BOOL)getCString:(char *)buffer maxLength:(NSUInteger)maxBufferCount encoding:(NSStringEncoding)encoding;    // NO return if conversion not possible due to encoding errors or too small of a buffer. The buffer should include room for maxBufferCount bytes; this number should accomodate the expected size of the return value plus the NULL termination character, which this method adds. (So note that the maxLength passed to this method is one more than the one you would have passed to the deprecated getCString:maxLength:.) Use only with 8-bit encodings, and not encodings such as UTF-16 or UTF-32.

// 指定缓存区转换
- (BOOL)getBytes:(nullable void *)buffer maxLength:(NSUInteger)maxBufferCount usedLength:(nullable NSUInteger *)usedBufferCount encoding:(NSStringEncoding)encoding options:(NSStringEncodingConversionOptions)options range:(NSRange)range remainingRange:(nullable NSRangePointer)leftover;

/* These return the maximum and exact number of bytes needed to store the receiver in the specified encoding in non-external representation. The first one is O(1), while the second one is O(n). These do not include space for a terminating null.
 */
- (NSUInteger)maximumLengthOfBytesUsingEncoding:(NSStringEncoding)enc;    // Result in O(1) time; the estimate may be way over what's needed. Returns 0 on error (overflow)
- (NSUInteger)lengthOfBytesUsingEncoding:(NSStringEncoding)enc;        // Result in O(n) time; the result is exact. Returns 0 on error (cannot convert to specified encoding, or overflow)

@property (class, readonly) const NSStringEncoding *availableStringEncodings;

+ (NSString *)localizedNameOfStringEncoding:(NSStringEncoding)encoding;

// 默认C字符串编码
@property (class, readonly) NSStringEncoding defaultCStringEncoding;    // Should be rarely used

#pragma mark *** Other ***
// 使用Unicode归一化范式D标准对字符串内容进行规范化
@property (readonly, copy) NSString *decomposedStringWithCanonicalMapping;
// 这个方法是使用范式C对字符串进行归一化
@property (readonly, copy) NSString *precomposedStringWithCanonicalMapping;
// 这个方法的作用就是使用范式KD对字符串进行归一化
@property (readonly, copy) NSString *decomposedStringWithCompatibilityMapping;
// 这个方法是使用KC对字符串进行归一化
@property (readonly, copy) NSString *precomposedStringWithCompatibilityMapping;

// 按字符串切分成字符串数组
- (NSArray<NSString *> *)componentsSeparatedByString:(NSString *)separator;
// 按照字符集进行切分成字符串数组
- (NSArray<NSString *> *)componentsSeparatedByCharactersInSet:(NSCharacterSet *)separator API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));

// 修建字符串收尾的字符，比如： str.trimmingCharacters(in: .lowercaseLetters)  会把字符串收尾的小写字母都裁掉
- (NSString *)stringByTrimmingCharactersInSet:(NSCharacterSet *)set;

// 填充字符串
- (NSString *)stringByPaddingToLength:(NSUInteger)newLength withString:(NSString *)padString startingAtIndex:(NSUInteger)padIndex;

/* Returns a string with the character folding options applied. theOptions is a mask of compare flags with *InsensitiveSearch suffix.
 */
- (NSString *)stringByFoldingWithOptions:(NSStringCompareOptions)options locale:(nullable NSLocale *)locale API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));

/* Replace all occurrences of the target string in the specified range with replacement. Specified compare options are used for matching target. If NSRegularExpressionSearch is specified, the replacement is treated as a template, as in the corresponding NSRegularExpression methods, and no other options can apply except NSCaseInsensitiveSearch and NSAnchoredSearch.
 */
- (NSString *)stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));

/* Replace all occurrences of the target string with replacement. Invokes the above method with 0 options and range of the whole string.
 */
- (NSString *)stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));

/* Replace characters in range with the specified string, returning new string.
 */
- (NSString *)stringByReplacingCharactersInRange:(NSRange)range withString:(NSString *)replacement API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));

typedef NSString *NSStringTransform NS_EXTENSIBLE_STRING_ENUM;

/* Perform string transliteration.  The transformation represented by transform is applied to the receiver. reverse indicates that the inverse transform should be used instead, if it exists. Attempting to use an invalid transform identifier or reverse an irreversible transform will return nil; otherwise the transformed string value is returned (even if no characters are actually transformed). You can pass one of the predefined transforms below (NSStringTransformLatinToKatakana, etc), or any valid ICU transform ID as defined in the ICU User Guide. Arbitrary ICU transform rules are not supported.
 */
- (nullable NSString *)stringByApplyingTransform:(NSStringTransform)transform reverse:(BOOL)reverse API_AVAILABLE(macos(10.11), ios(9.0), watchos(2.0), tvos(9.0));    // Returns nil if reverse not applicable or transform is invalid

FOUNDATION_EXPORT NSStringTransform const NSStringTransformLatinToKatakana         API_AVAILABLE(macos(10.11), ios(9.0), watchos(2.0), tvos(9.0));
FOUNDATION_EXPORT NSStringTransform const NSStringTransformLatinToHiragana         API_AVAILABLE(macos(10.11), ios(9.0), watchos(2.0), tvos(9.0));
FOUNDATION_EXPORT NSStringTransform const NSStringTransformLatinToHangul           API_AVAILABLE(macos(10.11), ios(9.0), watchos(2.0), tvos(9.0));
FOUNDATION_EXPORT NSStringTransform const NSStringTransformLatinToArabic           API_AVAILABLE(macos(10.11), ios(9.0), watchos(2.0), tvos(9.0));
FOUNDATION_EXPORT NSStringTransform const NSStringTransformLatinToHebrew           API_AVAILABLE(macos(10.11), ios(9.0), watchos(2.0), tvos(9.0));
FOUNDATION_EXPORT NSStringTransform const NSStringTransformLatinToThai             API_AVAILABLE(macos(10.11), ios(9.0), watchos(2.0), tvos(9.0));
FOUNDATION_EXPORT NSStringTransform const NSStringTransformLatinToCyrillic         API_AVAILABLE(macos(10.11), ios(9.0), watchos(2.0), tvos(9.0));
FOUNDATION_EXPORT NSStringTransform const NSStringTransformLatinToGreek            API_AVAILABLE(macos(10.11), ios(9.0), watchos(2.0), tvos(9.0));
FOUNDATION_EXPORT NSStringTransform const NSStringTransformToLatin                 API_AVAILABLE(macos(10.11), ios(9.0), watchos(2.0), tvos(9.0));
FOUNDATION_EXPORT NSStringTransform const NSStringTransformMandarinToLatin         API_AVAILABLE(macos(10.11), ios(9.0), watchos(2.0), tvos(9.0));
FOUNDATION_EXPORT NSStringTransform const NSStringTransformHiraganaToKatakana      API_AVAILABLE(macos(10.11), ios(9.0), watchos(2.0), tvos(9.0));
FOUNDATION_EXPORT NSStringTransform const NSStringTransformFullwidthToHalfwidth    API_AVAILABLE(macos(10.11), ios(9.0), watchos(2.0), tvos(9.0));
FOUNDATION_EXPORT NSStringTransform const NSStringTransformToXMLHex                API_AVAILABLE(macos(10.11), ios(9.0), watchos(2.0), tvos(9.0));
FOUNDATION_EXPORT NSStringTransform const NSStringTransformToUnicodeName           API_AVAILABLE(macos(10.11), ios(9.0), watchos(2.0), tvos(9.0));
FOUNDATION_EXPORT NSStringTransform const NSStringTransformStripCombiningMarks     API_AVAILABLE(macos(10.11), ios(9.0), watchos(2.0), tvos(9.0));
FOUNDATION_EXPORT NSStringTransform const NSStringTransformStripDiacritics         API_AVAILABLE(macos(10.11), ios(9.0), watchos(2.0), tvos(9.0));


/* Write to specified url or path using the specified encoding.  The optional error return is to indicate file system or encoding errors.
 */
- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc error:(NSError **)error;
- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc error:(NSError **)error;

@property (readonly, copy) NSString *description;

@property (readonly) NSUInteger hash;


#pragma mark *** Initializers ***

/* In general creation methods in NSString do not apply to subclassers, as subclassers are assumed to provide their own init methods which create the string in the way the subclass wishes.  Designated initializers of NSString are thus init and initWithCoder:.
 */
- (instancetype)initWithCharactersNoCopy:(unichar *)characters length:(NSUInteger)length freeWhenDone:(BOOL)freeBuffer;    /* "NoCopy" is a hint */
- (instancetype)initWithCharacters:(const unichar *)characters length:(NSUInteger)length;
- (nullable instancetype)initWithUTF8String:(const char *)nullTerminatedCString;
- (instancetype)initWithString:(NSString *)aString;
- (instancetype)initWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (instancetype)initWithFormat:(NSString *)format arguments:(va_list)argList NS_FORMAT_FUNCTION(1,0);
- (instancetype)initWithFormat:(NSString *)format locale:(nullable id)locale, ... NS_FORMAT_FUNCTION(1,3);
- (instancetype)initWithFormat:(NSString *)format locale:(nullable id)locale arguments:(va_list)argList NS_FORMAT_FUNCTION(1,0);
- (nullable instancetype)initWithData:(NSData *)data encoding:(NSStringEncoding)encoding;
- (nullable instancetype)initWithBytes:(const void *)bytes length:(NSUInteger)len encoding:(NSStringEncoding)encoding;
- (nullable instancetype)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)len encoding:(NSStringEncoding)encoding freeWhenDone:(BOOL)freeBuffer;    /* "NoCopy" is a hint */

+ (instancetype)string;
+ (instancetype)stringWithString:(NSString *)string;
+ (instancetype)stringWithCharacters:(const unichar *)characters length:(NSUInteger)length;
+ (nullable instancetype)stringWithUTF8String:(const char *)nullTerminatedCString;
+ (instancetype)stringWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
+ (instancetype)localizedStringWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

- (nullable instancetype)initWithCString:(const char *)nullTerminatedCString encoding:(NSStringEncoding)encoding;
+ (nullable instancetype)stringWithCString:(const char *)cString encoding:(NSStringEncoding)enc;

/* These use the specified encoding.  If nil is returned, the optional error return indicates problem that was encountered (for instance, file system or encoding errors).
 */
- (nullable instancetype)initWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)enc error:(NSError **)error;
- (nullable instancetype)initWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError **)error;
+ (nullable instancetype)stringWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)enc error:(NSError **)error;
+ (nullable instancetype)stringWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError **)error;

/* These try to determine the encoding, and return the encoding which was used.  Note that these methods might get "smarter" in subsequent releases of the system, and use additional techniques for recognizing encodings. If nil is returned, the optional error return indicates problem that was encountered (for instance, file system or encoding errors).
 */
- (nullable instancetype)initWithContentsOfURL:(NSURL *)url usedEncoding:(nullable NSStringEncoding *)enc error:(NSError **)error;
- (nullable instancetype)initWithContentsOfFile:(NSString *)path usedEncoding:(nullable NSStringEncoding *)enc error:(NSError **)error;
+ (nullable instancetype)stringWithContentsOfURL:(NSURL *)url usedEncoding:(nullable NSStringEncoding *)enc error:(NSError **)error;
+ (nullable instancetype)stringWithContentsOfFile:(NSString *)path usedEncoding:(nullable NSStringEncoding *)enc error:(NSError **)error;

@end
    
    typedef NSString * NSStringEncodingDetectionOptionsKey NS_STRING_ENUM;
    
    @interface NSString (NSStringEncodingDetection)

#pragma mark *** Encoding detection ***

/* This API is used to detect the string encoding of a given raw data. It can also do lossy string conversion. It converts the data to a string in the detected string encoding. The data object contains the raw bytes, and the option dictionary contains the hints and parameters for the analysis. The opts dictionary can be nil. If the string parameter is not NULL, the string created by the detected string encoding is returned. The lossy substitution string is emitted in the output string for characters that could not be converted when lossy conversion is enabled. The usedLossyConversion indicates if there is any lossy conversion in the resulted string. If no encoding can be detected, 0 is returned.
 
 The possible items for the dictionary are:
 1) an array of suggested string encodings (without specifying the 3rd option in this list, all string encodings are considered but the ones in the array will have a higher preference; moreover, the order of the encodings in the array is important: the first encoding has a higher preference than the second one in the array)
 2) an array of string encodings not to use (the string encodings in this list will not be considered at all)
 3) a boolean option indicating whether only the suggested string encodings are considered
 4) a boolean option indicating whether lossy is allowed
 5) an option that gives a specific string to substitude for mystery bytes
 6) the current user's language
 7) a boolean option indicating whether the data is generated by Windows
 
 If the values in the dictionary have wrong types (for example, the value of NSStringEncodingDetectionSuggestedEncodingsKey is not an array), an exception is thrown.
 If the values in the dictionary are unknown (for example, the value in the array of suggested string encodings is not a valid encoding), the values will be ignored.
 */
+ (NSStringEncoding)stringEncodingForData:(NSData *)data
                          encodingOptions:(nullable NSDictionary<NSStringEncodingDetectionOptionsKey, id> *)opts
                          convertedString:(NSString * _Nullable * _Nullable)string
                      usedLossyConversion:(nullable BOOL *)usedLossyConversion API_AVAILABLE(macos(10.10), ios(8.0), watchos(2.0), tvos(9.0));

/* The following keys are for the option dictionary for the string encoding detection API.
 */
FOUNDATION_EXPORT NSStringEncodingDetectionOptionsKey const NSStringEncodingDetectionSuggestedEncodingsKey           API_AVAILABLE(macos(10.10), ios(8.0), watchos(2.0), tvos(9.0));   // NSArray of NSNumbers which contain NSStringEncoding values; if this key is not present in the dictionary, all encodings are weighted the same
FOUNDATION_EXPORT NSStringEncodingDetectionOptionsKey const NSStringEncodingDetectionDisallowedEncodingsKey          API_AVAILABLE(macos(10.10), ios(8.0), watchos(2.0), tvos(9.0));   // NSArray of NSNumbers which contain NSStringEncoding values; if this key is not present in the dictionary, all encodings are considered
FOUNDATION_EXPORT NSStringEncodingDetectionOptionsKey const NSStringEncodingDetectionUseOnlySuggestedEncodingsKey    API_AVAILABLE(macos(10.10), ios(8.0), watchos(2.0), tvos(9.0));   // NSNumber boolean value; if this key is not present in the dictionary, the default value is NO
FOUNDATION_EXPORT NSStringEncodingDetectionOptionsKey const NSStringEncodingDetectionAllowLossyKey                   API_AVAILABLE(macos(10.10), ios(8.0), watchos(2.0), tvos(9.0));   // NSNumber boolean value; if this key is not present in the dictionary, the default value is YES
FOUNDATION_EXPORT NSStringEncodingDetectionOptionsKey const NSStringEncodingDetectionFromWindowsKey                  API_AVAILABLE(macos(10.10), ios(8.0), watchos(2.0), tvos(9.0));   // NSNumber boolean value; if this key is not present in the dictionary, the default value is NO
FOUNDATION_EXPORT NSStringEncodingDetectionOptionsKey const NSStringEncodingDetectionLossySubstitutionKey            API_AVAILABLE(macos(10.10), ios(8.0), watchos(2.0), tvos(9.0));   // NSString value; if this key is not present in the dictionary, the default value is U+FFFD
FOUNDATION_EXPORT NSStringEncodingDetectionOptionsKey const NSStringEncodingDetectionLikelyLanguageKey               API_AVAILABLE(macos(10.10), ios(8.0), watchos(2.0), tvos(9.0));   // NSString value; ISO language code; if this key is not present in the dictionary, no such information is considered

@end
    
    
    @interface NSString (NSItemProvider) <NSItemProviderReading, NSItemProviderWriting>
@end
    
    
    @interface NSMutableString : NSString

#pragma mark *** Mutable string ***

/* NSMutableString primitive (funnel) method. See below for the other mutation methods.
 */
- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)aString;

@end
    
    @interface NSMutableString (NSMutableStringExtensionMethods)

/* Additional mutation methods.  For subclassers these are all available implemented in terms of the primitive replaceCharactersInRange:range: method.
 */
- (void)insertString:(NSString *)aString atIndex:(NSUInteger)loc;
- (void)deleteCharactersInRange:(NSRange)range;
- (void)appendString:(NSString *)aString;
- (void)appendFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (void)setString:(NSString *)aString;

/* This method replaces all occurrences of the target string with the replacement string, in the specified range of the receiver string, and returns the number of replacements. NSBackwardsSearch means the search is done from the end of the range (the results could be different); NSAnchoredSearch means only anchored (but potentially multiple) instances will be replaced. NSLiteralSearch and NSCaseInsensitiveSearch also apply. NSNumericSearch is ignored. Use NSMakeRange(0, [receiver length]) to process whole string. If NSRegularExpressionSearch is specified, the replacement is treated as a template, as in the corresponding NSRegularExpression methods, and no other options can apply except NSCaseInsensitiveSearch and NSAnchoredSearch.
 */
- (NSUInteger)replaceOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange;

/* Perform string transliteration.  The transformation represented by transform is applied to the given range of string in place. Only the specified range will be modified, but the transform may look at portions of the string outside that range for context. If supplied, resultingRange is modified to reflect the new range corresponding to the original range. reverse indicates that the inverse transform should be used instead, if it exists. Attempting to use an invalid transform identifier or reverse an irreversible transform will return NO; otherwise YES is returned, even if no characters are actually transformed. You can pass one of the predefined transforms listed above (NSStringTransformLatinToKatakana, etc), or any valid ICU transform ID as defined in the ICU User Guide. Arbitrary ICU transform rules are not supported.
 */
- (BOOL)applyTransform:(NSStringTransform)transform reverse:(BOOL)reverse range:(NSRange)range updatedRange:(nullable NSRangePointer)resultingRange API_AVAILABLE(macos(10.11), ios(9.0), watchos(2.0), tvos(9.0));

/* In addition to these two, NSMutableString responds properly to all NSString creation methods.
 */
- (NSMutableString *)initWithCapacity:(NSUInteger)capacity;
+ (NSMutableString *)stringWithCapacity:(NSUInteger)capacity;

@end
    
    
    
    FOUNDATION_EXPORT NSExceptionName const NSCharacterConversionException;
    FOUNDATION_EXPORT NSExceptionName const NSParseErrorException; // raised by -propertyList
#define NSMaximumStringLength    (INT_MAX-1)
    
#pragma mark *** Deprecated/discouraged APIs ***
    
    @interface NSString (NSExtendedStringPropertyListParsing)

/* These methods are no longer recommended since they do not work with property lists and strings files in binary plist format. Please use the APIs in NSPropertyList.h instead.
 */
- (id)propertyList;
- (nullable NSDictionary *)propertyListFromStringsFileFormat;

@end
    
    @interface NSString (NSStringDeprecated)

/* The following methods are deprecated and will be removed from this header file in the near future. These methods use NSString.defaultCStringEncoding as the encoding to convert to, which means the results depend on the user's language and potentially other settings. This might be appropriate in some cases, but often these methods are misused, resulting in issues when running in languages other then English. UTF8String in general is a much better choice when converting arbitrary NSStrings into 8-bit representations. Additional potential replacement methods are being introduced in NSString as appropriate.
 */
- (nullable const char *)cString NS_RETURNS_INNER_POINTER API_DEPRECATED("Use -cStringUsingEncoding: instead", macos(10.0,10.4), ios(2.0,2.0), watchos(2.0,2.0), tvos(9.0,9.0));
- (nullable const char *)lossyCString NS_RETURNS_INNER_POINTER API_DEPRECATED("Use -cStringUsingEncoding: instead", macos(10.0,10.4), ios(2.0,2.0), watchos(2.0,2.0), tvos(9.0,9.0));
- (NSUInteger)cStringLength API_DEPRECATED("Use -lengthOfBytesUsingEncoding: instead", macos(10.0,10.4), ios(2.0,2.0), watchos(2.0,2.0), tvos(9.0,9.0));
- (void)getCString:(char *)bytes API_DEPRECATED("Use -getCString:maxLength:encoding: instead", macos(10.0,10.4), ios(2.0,2.0), watchos(2.0,2.0), tvos(9.0,9.0));
- (void)getCString:(char *)bytes maxLength:(NSUInteger)maxLength API_DEPRECATED("Use -getCString:maxLength:encoding: instead", macos(10.0,10.4), ios(2.0,2.0), watchos(2.0,2.0), tvos(9.0,9.0));
- (void)getCString:(char *)bytes maxLength:(NSUInteger)maxLength range:(NSRange)aRange remainingRange:(nullable NSRangePointer)leftoverRange API_DEPRECATED("Use -getCString:maxLength:encoding: instead", macos(10.0,10.4), ios(2.0,2.0), watchos(2.0,2.0), tvos(9.0,9.0));

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile API_DEPRECATED("Use -writeToFile:atomically:error: instead", macos(10.0,10.4), ios(2.0,2.0), watchos(2.0,2.0), tvos(9.0,9.0));
- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)atomically API_DEPRECATED("Use -writeToURL:atomically:error: instead", macos(10.0,10.4), ios(2.0,2.0), watchos(2.0,2.0), tvos(9.0,9.0));

- (nullable id)initWithContentsOfFile:(NSString *)path API_DEPRECATED("Use -initWithContentsOfFile:encoding:error: instead", macos(10.0,10.4), ios(2.0,2.0), watchos(2.0,2.0), tvos(9.0,9.0));
- (nullable id)initWithContentsOfURL:(NSURL *)url API_DEPRECATED("Use -initWithContentsOfURL:encoding:error: instead", macos(10.0,10.4), ios(2.0,2.0), watchos(2.0,2.0), tvos(9.0,9.0));
+ (nullable id)stringWithContentsOfFile:(NSString *)path API_DEPRECATED("Use +stringWithContentsOfFile:encoding:error: instead", macos(10.0,10.4), ios(2.0,2.0), watchos(2.0,2.0), tvos(9.0,9.0));
+ (nullable id)stringWithContentsOfURL:(NSURL *)url API_DEPRECATED("Use +stringWithContentsOfURL:encoding:error: instead", macos(10.0,10.4), ios(2.0,2.0), watchos(2.0,2.0), tvos(9.0,9.0));

- (nullable id)initWithCStringNoCopy:(char *)bytes length:(NSUInteger)length freeWhenDone:(BOOL)freeBuffer API_DEPRECATED("Use -initWithCString:encoding: instead", macos(10.0,10.4), ios(2.0,2.0), watchos(2.0,2.0), tvos(9.0,9.0));
- (nullable id)initWithCString:(const char *)bytes length:(NSUInteger)length API_DEPRECATED("Use -initWithCString:encoding: instead", macos(10.0,10.4), ios(2.0,2.0), watchos(2.0,2.0), tvos(9.0,9.0));
- (nullable id)initWithCString:(const char *)bytes API_DEPRECATED("Use -initWithCString:encoding: instead", macos(10.0,10.4), ios(2.0,2.0), watchos(2.0,2.0), tvos(9.0,9.0));
+ (nullable id)stringWithCString:(const char *)bytes length:(NSUInteger)length API_DEPRECATED("Use +stringWithCString:encoding:", macos(10.0,10.4), ios(2.0,2.0), watchos(2.0,2.0), tvos(9.0,9.0));
+ (nullable id)stringWithCString:(const char *)bytes API_DEPRECATED("Use +stringWithCString:encoding: instead", macos(10.0,10.4), ios(2.0,2.0), watchos(2.0,2.0), tvos(9.0,9.0));

/* This method is unsafe because it could potentially cause buffer overruns. You should use -getCharacters:range: instead.
 */
- (void)getCharacters:(unichar *)buffer;

@end
    
    NS_ENUM(NSStringEncoding) {
        NSProprietaryStringEncoding = 65536    /* Installation-specific encoding */
    };


