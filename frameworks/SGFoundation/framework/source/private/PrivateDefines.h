//: PrivateDefines.h
/**
  * $Id: PrivateDefines.h,v 1.2 2007/01/22 02:23:29 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>
#import "UTILKit.h"
#import <SGFoundation/SGBase.h>
#import <SGFoundation/SGFileRef.h>


#define FRWK_SGFILEREF_PATHSIZE				4096

#define RFC1123_CALENDAR_FORMAT	@"%a, %d %b %Y %H:%M:%S %Z"
#define RFC1036_CALENDAR_FORMAT	@"%A, %d-%b-%Y %H:%M:%S %Z"
#define ASCTIME_CALENDAR_FORMAT	@"%a %b %d %H:%M:%S %Y"
#define DATE_1904_JUN_1_FORMAT	@"1904-01-01 00:00:00 +0000"




#define kSGFoundationBundle		[NSBundle bundleForClass : [SGFileRef class]]