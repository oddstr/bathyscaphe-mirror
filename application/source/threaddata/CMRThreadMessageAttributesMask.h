/**
  * $Id: CMRThreadMessageAttributesMask.h,v 1.1.1.1 2005/05/11 17:51:08 tsawada2 Exp $
  * 
  * CMRThreadMessageAttributesMask.h
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */

// 一時フラグは保存しない
#define MA_FL_NOT_TEMP_MASK		(0xfffff)		// 20bit
#define MA_VERSION_1_0_MAGIC	(0x28000)		// version 1.0 magic number
#define MA_VERSION_1_1_MAGIC	(0x800000U)		// version 1.1 magic number

#define MA_FL_USER_USED_MASK	(0x3f)			// 6bit
#define ABONED_FLAG				(0x40)			// 7
#define LOCAL_ABONED_FLAG		(0x80)			// 8
#define INVISIBLE_ABONED_FLAG	(0x100)			// 9
#define ASCII_ART_FLAG			(0x200)			// 10
#define SPAM_FLAG				(0x400)			// 11
#define INVALID_FLAG			(0x800)			// 12 [ここ壊れてます]

#define BOOKMARK_FLAG			(0x7000)		// 13 - 15 (3bit)
#define INT2BOOKMARK(v)			(((v)<<12)&BOOKMARK_FLAG)
#define BOOKMARK2INT(v)			((v>>12)&0x7)



// 一時フラグ、保存時にはバージョン番号に使われる
#define MA_FL_RESERVED2_MASK	(0x700000U)		// 21 - 23 (3bit)
#define TEMP_POST1_FLAG			(0x800000U)		// 24
#define TEMP_INVISIBLE_FLAG		(0x1000000U)	// 25
#define MA_VERSION_MASK			(0x3800000)		// 24-26 (3bit)

enum { /* masks for the types of attributes */
	CMRAbonedMask				= ABONED_FLAG,
	CMRLocalAbonedMask			= LOCAL_ABONED_FLAG,
	CMRInvisibleAbonedMask		= INVISIBLE_ABONED_FLAG,
	CMRAsciiArtMask				= ASCII_ART_FLAG,
	CMRBookmarkMask				= BOOKMARK_FLAG,
	CMRInvalidContentsMask		= INVALID_FLAG,
	CMRSpamMask					= SPAM_FLAG,
	
	CMRTemporaryInvisibleMask	= TEMP_INVISIBLE_FLAG,
	
	CMRInvisibleMask			= (CMRInvisibleAbonedMask|CMRTemporaryInvisibleMask),
	CMRAnyAttributesMask		= 0xffffffffU
};
	
	