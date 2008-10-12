//
//  CMRThreadVisibleRange.h
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/09/23.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <SGFoundation/SGFoundation.h>
#import <CocoMonar/CocoMonar.h>

/*!
 * @class       CMRThreadVisibleRange
 * @abstract    表示レス数
 * @discussion  表示レス数を指定するオブジェクト
 */
@interface CMRThreadVisibleRange : NSObject<NSCopying, CMRPropertyListCoding> {
	unsigned		_firstVisibleLength;
	unsigned		_lastVisibleLength;
}

+ (id)visibleRangeWithFirstVisibleLength:(unsigned)aFirstVisibleLength
					   lastVisibleLength:(unsigned)aLastVisibleLength;
- (id)initWithFirstVisibleLength:(unsigned)aFirstVisibleLength
			   lastVisibleLength:(unsigned)aLastVisibleLength;

- (NSDictionary *)dictionaryRepresentation;
- (BOOL)initializeFromDictionaryRepresentation:(NSDictionary *)rep;

- (BOOL)isShownAll;
- (BOOL)isEmpty;

- (unsigned)firstVisibleLength;
- (void)setFirstVisibleLength:(unsigned)aFirstVisibleLength;
- (unsigned)lastVisibleLength;
- (void)setLastVisibleLength:(unsigned)aLastVisibleLength;
- (unsigned)visibleLength;
@end


/*!
 * @enum       表示レス数
 * @discussion 表示レス数のうち、何らかのフラグ
 * @constant   CMRThreadShowAll, すべてを表示
 */
enum {
	CMRThreadShowAll = NSNotFound,
};


/*
@interface CMRThreadVisibleRange(Deprecated)
+ (CMRThreadVisibleRange *)defaultVisibleRange;
+ (void)setDefaultVisibleRange:(CMRThreadVisibleRange *)newVRange;

+ (id)visibleRangeWithUInt32Representation:(UInt32)uint32Value;
- (id)initWithUInt32Representation:(UInt32)uint32Value;

- (UInt32)UInt32Representation;
- (NSString *)stringRepresentation;

- (BOOL)initializeFromStringRepresentation:(NSString *)s;
- (BOOL)initializeFromUInt32Representation:(UInt32)n;
@end
*/
