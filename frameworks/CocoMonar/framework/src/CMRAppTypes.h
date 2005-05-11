//: CMRAppTypes.h
/**
  * $Id: CMRAppTypes.h,v 1.1 2005/05/11 17:51:19 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>


typedef enum _ThreadStatus {
	ThreadStandardStatus    = 0,		
	ThreadNoCacheStatus     = 1,		
	ThreadLogCachedStatus   = 1 << 1,	
	
	ThreadUpdatedStatus     = (1 << 2) | ThreadLogCachedStatus,	
	
	ThreadNewCreatedStatus  = (1 << 3) | ThreadNoCacheStatus,
} ThreadStatus;

typedef enum _ThreadViewerLinkType{
	ThreadViewerMoveToIndexLinkType,
	ThreadViewerOpenBrowserLinkType,
	ThreadViewerResPopUpLinkType,
} ThreadViewerLinkType;


enum {
	CMRAutoscrollNone             = 0,
	CMRAutoscrollWhenTLUpdate     = 1,
	CMRAutoscrollWhenTLSort       = 1 << 1,
	CMRAutoscrollWhenThreadUpdate = 1 << 2,
	CMRAutoscrollAny			  = 0xffffffffU
};


typedef enum _CMRSearchMask{
	CMRSearchOptionNone						= 0,
	CMRSearchOptionCaseInsensitive			= 1,
	CMRSearchOptionBackwards				= 1 << 1,
	CMRSearchOptionZenHankakuInsensitive	= 1 << 2,
	CMRSearchOptionIgnoreSpecified			= 1 << 3,
	CMRSearchOptionLinkOnly					= 1 << 4
} CMRSearchMask;
