//
//  BSRelativeKeywordsCollector.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/02/12.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSRelativeKeywordsCollector.h"
#import <OgreKit/OgreKit.h>
#import <SGFoundation/SGFoundation.h>
#import <CocoMonar/CMRPropertyKeys.h>

NSString *const BSRelativeKeywordsCollectionKeywordStringKey = @"BSRKC_STR";
NSString *const BSRelativeKeywordsCollectionKeywordURLKey = @"BSRKC_URL";
NSString *const BSRelativeKeywordsCollectorErrorDomain = @"BSRelativeKeywordsCollectorErrorDomain";

@implementation BSRelativeKeywordsCollector
#pragma mark Accessors
- (id) delegate
{
	return m_delegate;
}
- (NSURL *) threadURL
{
	return m_threadURL;
}
- (NSMutableData *) receivedData
{
	return m_receivedData;
}
- (NSURLConnection *) currentConnection
{
	return m_currentConnection;
}
- (void) setCurrentConnection: (NSURLConnection *) con
{
	[con retain];
	[m_currentConnection release];
	m_currentConnection = con;
}
- (BOOL) isInProgress
{
	return m_isInProgress;
}
- (void) setIsInProgress: (BOOL) boolValue
{
	m_isInProgress = boolValue;
}

#pragma mark Public Methods
- (id) initWithThreadURL: (NSURL *) threadURL delegate: (id) aDelegate
{
	self = [super init];
	if (self != nil) {
		m_delegate = aDelegate;
		m_threadURL = [threadURL retain];
		m_receivedData = [[NSMutableData alloc] init];
		m_currentConnection = nil;
		m_isInProgress = NO;
	}
	return self;
}

- (void) startCollecting
{
    NSMutableURLRequest	*req;
    NSURLConnection		*connection;
	NSString			*strValue;
	NSURL				*convertedURL;

	strValue = [[self threadURL] absoluteString];
	convertedURL = [NSURL URLWithString: [NSString stringWithFormat: @"http://p2.2ch.io/getf.cgi?%@", strValue]];

    req = [NSMutableURLRequest requestWithURL: convertedURL
                                  cachePolicy: NSURLRequestReloadIgnoringCacheData
                              timeoutInterval: 15.0];
    
	[req setValue: [NSBundle monazillaUserAgent] forHTTPHeaderField: @"User-Agent"];

	connection = [[NSURLConnection alloc] initWithRequest: req delegate: self];
    [self setCurrentConnection: connection];
	[connection release];
}

- (NSArray *) analyzeKeywordsFromData: (NSData *) data
{
	NSString *str;
	NSMutableString *ampStr;
	NSEnumerator *iter_;
	NSMutableArray	*result_;
	NSString *url_;
	NSString *name_;
	OGRegularExpressionMatch *match;
	OGRegularExpression *regex = [OGRegularExpression regularExpressionWithString: @"<a href=\"(.*)\" target=\"_blank\">(.*)</a>"];

	str = [NSString stringWithDataUsingTEC: data encoding: kCFStringEncodingDOSJapanese];
	if (!str) return nil;
	ampStr = [[str mutableCopy] autorelease];
	[ampStr replaceOccurrencesOfString: @"&amp;" withString: @"&" options: NSLiteralSearch range: NSMakeRange(0, [ampStr length])];

	result_ = [NSMutableArray array];
			
	iter_ = [regex matchEnumeratorInString: ampStr];

	while (match = [iter_ nextObject]) {
		url_ = [match substringAtIndex:1];
		name_ = [match substringAtIndex:2];
		
		[result_ addObject: [NSDictionary dictionaryWithObjectsAndKeys: url_, BSRelativeKeywordsCollectionKeywordURLKey,
																		name_, BSRelativeKeywordsCollectionKeywordStringKey, NULL]];
	}

	return result_;
}

#pragma mark Override
- (void) dealloc
{
	[m_currentConnection release];
	[m_receivedData release];
	[m_threadURL release];
	m_delegate = nil;
	[super dealloc];
}

#pragma mark NSURLConnection Delegates
- (void) connection: (NSURLConnection *) connection didReceiveResponse: (NSURLResponse *) resp
{
    NSHTTPURLResponse *http = (NSHTTPURLResponse *)resp;
	int status = [http statusCode];

    switch (status) {
    case 200:
        break;
    default:
		[connection cancel];
		[self setCurrentConnection: nil];
		[self setIsInProgress: NO];

		id delegate_ = [self delegate];
		if (delegate_ && [delegate_ respondsToSelector: @selector(collector:didFailWithError:)]) {
			NSError *error = [NSError errorWithDomain: BSRelativeKeywordsCollectorErrorDomain code: status userInfo: nil];
			[delegate_ collector: self didFailWithError: error];
		}

        break;
    }
}

- (void) connection: (NSURLConnection *) connection didReceiveData: (NSData *) data
{
    [[self receivedData] appendData: data];
}

- (void) connection: (NSURLConnection *) connection didFailWithError: (NSError *) error
{
	[m_receivedData release];
	m_receivedData = nil;
	m_receivedData = [[NSMutableData alloc] init];

	[self setCurrentConnection: nil];
	[self setIsInProgress: NO];

	id delegate_ = [self delegate];
	if (delegate_ && [delegate_ respondsToSelector: @selector(collector:didFailWithError:)]) {
		[delegate_ collector: self didFailWithError: error];
	}
}

- (void) connectionDidFinishLoading: (NSURLConnection *) connection
{
	id delegate_ = [self delegate];
	SEL delegateSelector;
	id keywordsDict = [self analyzeKeywordsFromData: [self receivedData]];
	[m_receivedData release];
	m_receivedData = nil;
	m_receivedData = [[NSMutableData alloc] init];

	[self setCurrentConnection: nil];
	[self setIsInProgress: NO];
	
	if ([keywordsDict isKindOfClass: [NSArray class]]) {
		delegateSelector = @selector(collector:didCollectKeywords:);
	} else {
		delegateSelector = @selector(collector:didFailWithError:);
		keywordsDict = [NSError errorWithDomain: BSRelativeKeywordsCollectorErrorDomain code: -1 userInfo: nil];
	}

	if (delegate_ && [delegate_ respondsToSelector: delegateSelector]) {
		[delegate_ performSelector: delegateSelector withObject: self withObject: keywordsDict];
	}	
}
@end
