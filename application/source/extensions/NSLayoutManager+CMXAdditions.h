//: NSLayoutManager+CMXAdditions.h
/**
  * $Id: NSLayoutManager+CMXAdditions.h,v 1.1.1.1 2005/05/11 17:51:05 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Cocoa/Cocoa.h>

#define LAYOUTMANAGER_SHOULD_FIX_BAD_BEHAVIOR		YES


@interface NSLayoutManager(CMXAdditions)
/*!
 * @method      performsGlyphGenerationIfNeeded
 * @abstract    �K�v�ȏꍇ��Glyph�𐶐�����
 *
 * @discussion  ��������Ă��Ȃ�Glyph������ΐ������܂��B
 * @result      Glyph�̐�
 */
- (unsigned) performsGlyphGenerationIfNeeded;
- (NSRect) boundingRectForTextContainer : (NSTextContainer *) aContainer;

/*!
 * @method            isValidGlyphRange:
 * @abstract          �w�肵���͈͂��������ǂ����̔���
 *
 * @discussion        �w�肵���O���t�͈̔͂������Ȃ�YES��Ԃ�
 * @param glyphRange  �Q�Ƃ���O���t�͈̔�
 * @result            �w�肵���O���t�͈̔͂������Ȃ�YES��Ԃ�
 */
- (BOOL) isValidGlyphRange : (NSRange) glyphRange;

- (unsigned) glyphIndexForCharacterAtIndex : (unsigned) anIndex;
@end



@interface NSLayoutManager(FIX_BAD_BEHAVIOR)
- (void) changeTextStorage : (NSTextStorage *) newTextStorage;
@end
