/**
  * $Id: SG2chConnector.h,v 1.1.1.1 2005/05/11 17:51:12 tsawada2 Exp $
  * 
  * SG2chConnector.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Foundation/Foundation.h>
#import "w2chConnect.h"



@interface SG2chConnector : NSObject<NSURLHandleClient, w2chConnect>
{
	SGHTTPConnector		*m_connector;
	id					m_delegate;
}
+ (Class) connectorClass;

+ (id) connectorWithURL : (NSURL        *) anURL
   additionalProperties : (NSDictionary *) properties;

- (id)     initWithURL : (NSURL        *) anURL
  additionalProperties : (NSDictionary *) properties;

+ (BOOL) canInitWithURL : (NSURL *) anURL;
+ (NSString *) userAgent;

- (SGHTTPConnector *) connector;
- (void) setConnector : (SGHTTPConnector *) aConnector;
- (id) delegate;
- (void) setDelegate : (id) newDelegate;
- (w2chConnectMode) mode;

- (NSData *) availableResourceData;
- (void) loadInBackground;

// zero-terminated list
+ (const CFStringEncoding *) availableURLEncodings;
// @"%@=%@&" from dictionary
- (NSString *) parameterWithForm : (NSDictionary *) forms;

- (NSString *) stringByURLEncodedWithString : (NSString *) str;
- (NSString *) stringWithDataUsingAvailableURLEncodings : (NSData *) data;
@end
