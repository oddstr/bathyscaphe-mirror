//: SGHTTPConnector.h
/**
  * $Id: SGHTTPConnector.h,v 1.1.1.1 2005/05/11 17:51:50 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>


@class SGHTTPRequest;
@class SGHTTPResponse;



@interface SGHTTPConnector : NSURLHandle
{
	@private
	SGHTTPRequest		*m_request;
	SGHTTPResponse		*m_response;
	
	BOOL			m_isCanceledLoadInBackground;
}
+ (id) connectorWithURL : (NSURL	*) anURL
				 cached : (BOOL      ) willCache
		  requestMethod : (NSString *) method
			HTTPVersion : (NSString *) httpVersion;

+ (id) connectorWithURL : (NSURL	*) anURL
		  requestMethod : (NSString *) method;

- (id) initWithURL : (NSURL    *) anURL
			cached : (BOOL      ) willCache
	 requestMethod : (NSString *) method
	   HTTPVersion : (NSString *) httpVersion;

- (id) initWithURL : (NSURL    *) anURL
	 requestMethod : (NSString *) method;
@end



@interface SGHTTPConnector(Attributes)
- (SGHTTPRequest *) request;
- (SGHTTPResponse *) response;
- (BOOL) isCanceledLoadInBackground;
- (NSDictionary *) properties;
- (NSURL *) requestURL;
- (NSString *) requestMethod;
- (void) writePropertiesFromDictionary : (NSDictionary *) otherDictionary;

- (void) setProxy : (NSString *) proxy
			 port : (CFIndex   ) port;
@end



@interface SGHTTPConnector(ResourceManagement)
- (unsigned) readContentLength;
- (unsigned) loadedBytesLength;
@end



@interface SGHTTPConnector(Private)
- (void) setRequest : (SGHTTPRequest *) aRequest;
- (void) setResponse : (SGHTTPResponse *) aResponse;
- (void) setIsCanceledLoadInBackground : (BOOL) anIsCanceledLoadInBackground;
- (void) setStatus : (NSURLHandleStatus) aStatus;
@end
