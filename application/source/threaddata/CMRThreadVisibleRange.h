//: CMRThreadVisibleRange.h
/**
  * $Id: CMRThreadVisibleRange.h,v 1.2 2007/01/22 02:23:29 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <SGFoundation/SGFoundation.h>
#import <CocoMonar/CocoMonar.h>


/*!
 * @class       CMRThreadVisibleRange
 * @abstract    表示レス数
 * @discussion  表示レス数を指定するオブジェクト
 */
@interface CMRThreadVisibleRange : NSObject<NSCopying, CMRPropertyListCoding>
{
	unsigned		_firstVisibleLength;
	unsigned		_lastVisibleLength;
}

+ (CMRThreadVisibleRange *) defaultVisibleRange;
+ (void) setDefaultVisibleRange : (CMRThreadVisibleRange *) newVRange;

+ (id) visibleRangeWithFirstVisibleLength : (unsigned) aFirstVisibleLength
						lastVisibleLength : (unsigned) aLastVisibleLength;
- (id) initWithFirstVisibleLength : (unsigned) aFirstVisibleLength
				lastVisibleLength : (unsigned) aLastVisibleLength;

+ (id) visibleRangeWithUInt32Representation : (UInt32) uint32Value;
- (id) initWithUInt32Representation : (UInt32) uint32Value;

+ (id) objectWithPropertyListRepresentation : (id) rep;
- (id) initWithPropertyListRepresentation : (id) rep;

- (id) propertyListRepresentation;
- (BOOL) initializeFromPropertyListRepresentation : (id) rep;

- (NSDictionary *) dictionaryRepresentation;
- (UInt32) UInt32Representation;
- (NSString *) stringRepresentation;

- (BOOL) initializeFromDictionaryRepresentation : (NSDictionary *) rep;
- (BOOL) initializeFromStringRepresentation : (NSString *) s;
- (BOOL) initializeFromUInt32Representation : (UInt32) n;

- (BOOL) isShownAll;
- (BOOL) isEmpty;

- (unsigned) firstVisibleLength;
- (unsigned) lastVisibleLength;
- (unsigned) visibleLength;
@end



/*!
 * @enum       表示レス数
 * @discussion 表示レス数のうち、何らかのフラグ
 * @constant   CMRThreadShowAll, すべてを表示
 */
enum {
	CMRThreadShowAll = NSNotFound,
};
