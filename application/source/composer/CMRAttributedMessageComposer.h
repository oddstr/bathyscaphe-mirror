/**
  * $Id: CMRAttributedMessageComposer.h,v 1.3 2007/02/07 13:26:13 tsawada2 Exp $
  * 
  * CMRAttributedMessageComposer.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Cocoa/Cocoa.h>
#import "CMRMessageComposer.h"



@interface CMRAttributedMessageComposer : CMRMessageComposer
{
	@private
	NSMutableAttributedString	*_contentsStorage;
	NSMutableAttributedString	*_nameCache;
	
	unsigned int	bs_targetIndex;
	
	UInt32			_mask;
	struct {
		unsigned int mask:31;
		unsigned int compose:1;
		unsigned int :0;
	} _CCFlags;
}
+ (id) composerWithContentsStorage : (NSMutableAttributedString *) storage;
- (id) initWithContentsStorage : (NSMutableAttributedString *) storage;



/* mask �Ŏw�肳�ꂽ�����𖳎����� */
- (UInt32) attributesMask;
- (void) setAttributesMask : (UInt32) mask;

/* flag: mask �Ɉ�v���鑮���������X�𐶐����邩�ǂ��� */
- (void) setComposingMask : (UInt32) mask
				  compose : (BOOL  ) flag;

/* index �ւ̎Q�Ƃ��܂ރ��X�݂̂𐶐� (index is 0-based) */
- (void) setComposingTargetIndex: (unsigned int) index;

- (NSMutableAttributedString *) contentsStorage;
- (void) setContentsStorage : (NSMutableAttributedString *) aContentsStorage;

- (BOOL) attrString: (NSAttributedString *) substring containsAnchorForMsgIndex: (unsigned int) index;
@end
