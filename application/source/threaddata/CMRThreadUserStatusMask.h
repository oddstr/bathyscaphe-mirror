/**
  * $Id: CMRThreadUserStatusMask.h,v 1.2 2006/01/24 11:00:54 tsawada2 Exp $
  * 
  * CMRThreadUserStatusMask.h
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */


// ˆêŽžƒtƒ‰ƒO‚Í•Û‘¶‚µ‚È‚¢
#define TUS_FL_NOT_TEMP_MASK	(0xfffff)		// 20bit
#define TUS_VERSION_1_0_MAGIC	(0x800000U)		// version 1.0 magic number
#define TUS_VERSION_MASK		(0x3800000)		// 24-26 (3bit)

#define TUS_FL_USER_USED_MASK	(0x3f)			// 6bit
#define TUS_ASCII_ART_FLAG		(0x40)			// 7

#define TUS_DAT_OCHI_FLAG		(0x80)
#define TUS_MARKED_FLAG			(0x01)