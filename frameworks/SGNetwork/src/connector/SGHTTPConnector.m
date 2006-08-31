/**
  * $Id: SGHTTPConnector.m,v 1.1.1.1.8.1 2006/08/31 10:18:41 tsawada2 Exp $
  * 
  * SGHTTPConnector.m
  *
  * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */


#import "SGHTTPConnector.h"

#import "FrameworkDefines.h"

#import <SGNetwork/SGHTTPConnector.h>
#import <SGNetwork/SGHTTPMessage.h>
#import <SGNetwork/SGHTTPRequest.h>
#import <SGNetwork/SGHTTPResponse.h>



@implementation SGHTTPConnector
+ (id) connectorWithURL : (NSURL    *) anURL
	             cached : (BOOL      ) willCache
	      requestMethod : (NSString *) method
	        HTTPVersion : (NSString *) httpVersion
{
	return [[[self alloc] initWithURL : anURL
							   cached : willCache
						requestMethod : method
						  HTTPVersion : httpVersion] autorelease];
}
+ (id) connectorWithURL : (NSURL    *) anURL
	      requestMethod : (NSString *) method
{
	return [[[self alloc] initWithURL : anURL
						requestMethod : method] autorelease];
}
- (id) initWithURL : (NSURL    *) anURL
            cached : (BOOL      ) willCache
     requestMethod : (NSString *) method
       HTTPVersion : (NSString *) httpVersion;
{
	CFStringRef version_;
	
	version_ = (CFStringRef)httpVersion;
	
	if(self == [self initWithURL:anURL cached:willCache]){
		SGHTTPRequest *myRequest;
		
		myRequest = [[SGHTTPRequest allocWithZone : [self zone]] 
							   initWithRequestURL : anURL 
							   requestMethod : method
							   HTTPVersion : version_];
		if(nil == myRequest){
			[self release];
			return nil;
		}
		[self setRequest : myRequest];
		[myRequest release];
	}
	return self;
}
- (id) initWithURL : (NSURL    *) anURL
     requestMethod : (NSString *) method
{
	return [self initWithURL : anURL
					  cached : NO
			   requestMethod : method
			     HTTPVersion : (NSString *)kCFHTTPVersion1_1];
}
- (void) dealloc
{	
	[m_request release];
	[m_response release];
	[super dealloc];
}



- (NSString *) description
{
	return [NSString stringWithFormat :
				@"<%@ %p>\n"
				@"Request:\n"
				@"----------------------------------------\n"
				@"%@\n"
				@"\n"
				@"Response:\n"
				@"----------------------------------------\n"
				@"%@",
				
				[self className], self,
				[[self request] description],
				[[self response] description]];
}

- (void) beginLoadInBackground
{
}
- (void) endLoadInBackground
{
}
- (void) cancelLoadInBackground
{
	[self setIsCanceledLoadInBackground : YES];
	[super cancelLoadInBackground];
}
@end



@implementation SGHTTPConnector(Private)
- (void) setRequest : (SGHTTPRequest *) aRequest
{
	[aRequest retain];
	[[self request] release];
	m_request = aRequest;
}
- (void) setResponse : (SGHTTPResponse *) aResponse
{
	[aResponse retain];
	[[self response] release];
	m_response = aResponse;
}


- (void) setIsCanceledLoadInBackground : (BOOL) anIsCanceledLoadInBackground
{
	m_isCanceledLoadInBackground = anIsCanceledLoadInBackground;
}
- (void) setStatus : (NSURLHandleStatus) aStatus
{
	_status = aStatus;
}
@end



@implementation SGHTTPConnector(Attributes)
- (SGHTTPRequest *) request
{
	return m_request;
}
- (SGHTTPResponse *) response
{
	return m_response;
}
- (BOOL) isCanceledLoadInBackground
{
	return m_isCanceledLoadInBackground;
}
- (BOOL) writeData : (NSData *) data
{
	if(nil == [self request] || nil == data)
		return NO;
	
	[[self request] writeBody : data];
	return YES;
}

- (BOOL) writeProperty : (id) value
                forKey : (id) field
{
	if(nil == [self request])
		return NO;
	if(nil == value || nil == field)
		return NO;
	if((NO == [value isKindOfClass : [NSString class]]) ||
	   (NO == [field isKindOfClass : [NSString class]]))
		return NO;
	
	[[self request] setHeaderFieldValue : value
							     forKey : field];
	return YES;
}
- (void) writePropertiesFromDictionary : (NSDictionary *) otherDictionary
{
	NSEnumerator		*keyEnumerator_;
	id					key_;
	
	keyEnumerator_ = [otherDictionary keyEnumerator];
	while(key_ = [keyEnumerator_ nextObject]){
		NSString		*value_;
		
		value_ = [otherDictionary objectForKey : key_];
		NSAssert1([value_ isKindOfClass : [NSString class]],
				@"dictionary contains non NSString entry(key = %@)",
				key_);
		[self writeProperty : value_
					 forKey : key_];
	}
}
- (id) propertyForKeyIfAvailable : (NSString *) field
{
	if(nil == [self response] || nil == field)
		return nil;
	
	return [[self response] headerFieldValueForKey : field];
}
- (id) propertyForKey : (NSString *) field
{
	if(nil == [self request])
		return nil;
	
	return [[self request] headerFieldValueForKey : field];
}
- (NSDictionary *) properties
{
	SGHTTPMessage *mes_;
	if(nil == [self response]){
		mes_ = [self request];
	}else{
		mes_ = [self response];
	}
	return (nil == mes_) ? [NSDictionary dictionary] : [mes_ allHeaderFields];
}
- (NSURL *) requestURL
{
	return [[self request] requestURL];
}
- (NSString *) requestMethod
{
	return [[self request] requestMethod];
}
- (void) setProxy : (NSString *) proxy
			 port : (CFIndex   ) port
{
	NSLog(@"Method setProxy:port: in SGHTTPConnector has been deprecated.");
}
- (void) setProxyIfNeeded
{
}
@end



@implementation SGHTTPConnector(ResourceManagement)
- (unsigned) readContentLength
{
	if(nil == [self response]) return 0;
	return [[self response] readContentLength];
}
- (unsigned) loadedBytesLength
{
	if(nil == [self availableResourceData]) return 0;
	return [[self availableResourceData] length];
}
@end
