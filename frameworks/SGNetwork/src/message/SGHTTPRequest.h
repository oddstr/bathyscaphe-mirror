//: SGHTTPRequest.h
/**
  * $Id: SGHTTPRequest.h,v 1.1.1.1 2005/05/11 17:51:50 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <SGNetwork/SGHTTPMessage.h>
#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>



@interface SGHTTPRequest : SGHTTPMessage
{

}
+ (id) HTTPRequestWithRequestURL : (NSURL     *) anURL
                   requestMethod : (NSString  *) method
                     HTTPVersion : (CFStringRef) version;
- (id) initWithRequestURL : (NSURL     *) anURL
            requestMethod : (NSString  *) method
              HTTPVersion : (CFStringRef) version;


- (NSURL *) requestURL;
- (NSString *) requstMethod;
- (NSString *) HTTPVersion;
@end
