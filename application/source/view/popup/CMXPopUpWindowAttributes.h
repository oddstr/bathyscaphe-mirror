/**
  * $Id: CMXPopUpWindowAttributes.h,v 1.1.1.1 2005/05/11 17:51:09 tsawada2 Exp $
  * 
  * CMXPopUpWindowAttributes.h
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */

// 使用する範囲
#define CMRPopUpUsedMask			(0xfffff)		// 20bit
// デフォルト値
#define CMRPopUpDefaultAttributes	(0&CMRPopUpUsedMask&CMRPopUpScrollerVertical&CMRPopUpScrollerAutoHides)

// ユーザ定義
#define CMRPopUpUserDefinedMask				(0x3f)		// 6bit
#define CMRPopUpScrollerAttributesMask		(0x3c0)		// 7 - 10 (4bit)

// CMRPopUpScrollerAttributesMask
typedef enum {
	CMRPopUpScrollerVertical	= 1<<6,	// 7
	CMRPopUpScrollerAutoHides	= 1<<7,	// 8
	CMRPopUpScrollerSmall		= 1<<8,	// 9
	CMRPopUpScrollerReserved	= 1<<9	// 10
} CMRPopUpScrollerAttributes;


