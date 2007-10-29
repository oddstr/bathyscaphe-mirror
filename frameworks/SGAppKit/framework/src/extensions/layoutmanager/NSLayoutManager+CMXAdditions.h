//: NSLayoutManager+CMXAdditions.h
/**
  * $Id: NSLayoutManager+CMXAdditions.h,v 1.2 2007/10/29 05:54:46 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import <AppKit/NSLayoutManager.h>

@class NSTextContainer, NSTextStorage;

#define LAYOUTMANAGER_SHOULD_FIX_BAD_BEHAVIOR		YES


@interface NSLayoutManager(CMXAdditions)
/*!
 * @method      performsGlyphGenerationIfNeeded
 * @abstract    必要な場合はGlyphを生成する
 *
 * @discussion  生成されていないGlyphがあれば生成します。
 * @result      Glyphの数
 */
- (unsigned) performsGlyphGenerationIfNeeded;
- (NSRect) boundingRectForTextContainer : (NSTextContainer *) aContainer;

/*!
 * @method            isValidGlyphRange:
 * @abstract          指定した範囲が正当かどうかの判定
 *
 * @discussion        指定したグリフの範囲が正当ならYESを返す
 * @param glyphRange  参照するグリフの範囲
 * @result            指定したグリフの範囲が正当ならYESを返す
 */
- (BOOL) isValidGlyphRange : (NSRange) glyphRange;

- (unsigned) glyphIndexForCharacterAtIndex : (unsigned) anIndex;
@end



@interface NSLayoutManager(FIX_BAD_BEHAVIOR)
- (void) changeTextStorage : (NSTextStorage *) newTextStorage;
@end
