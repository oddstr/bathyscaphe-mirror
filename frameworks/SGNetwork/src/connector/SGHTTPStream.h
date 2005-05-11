//: SGHTTPStream.h
/**
  * $Id: SGHTTPStream.h,v 1.1 2005/05/11 17:51:50 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/NSObject.h>
#import <CoreServices/CoreServices.h>
#import <SGNetwork/SGHTTPConnector.h>

@class SGHTTPResponse;

@interface SGHTTPStream : SGHTTPConnector
{
	@private
	CFReadStreamRef			_readStreamRef;
}

- (CFReadStreamRef) getCFReadStreamRef;
@end
