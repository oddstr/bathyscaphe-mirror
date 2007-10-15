//
//  BSLoggedInDATDownloader.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/10/15.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//

#import "BSLoggedInDATDownloader.h"
#import <SGNetwork/SGHTTPDefines.h>
#import "AppDefaults.h"
#import "w2chConnect.h"

static NSString *const kResourceURLTemplate = @"http://%@/test/offlaw.cgi%@/%@/?raw=0.0&sid=%@";

@implementation BSLoggedInDATDownloader
- (id)initClusterWithIdentifier:(CMRThreadSignature *)signature
					threadTitle:(NSString *)aTitle
					  nextIndex:(unsigned int)aNextIndex
{
	if (self = [super initClusterWithIdentifier:signature threadTitle:aTitle nextIndex:aNextIndex]) {
//		NSLog(@"Getting session ID...");
		if (![self updateSessionID]) {
			[self autorelease];
			return nil;
		}
//		NSLog(@"Session ID Get!");
	}
	return self;
}

+ (id)downloaderWithIdentifier:(CMRThreadSignature *)signature threadTitle:(NSString *)aTitle
{
	return [[[self alloc] initClusterWithIdentifier:signature threadTitle:aTitle nextIndex:0] autorelease];
}

- (BOOL)updateSessionID
{
    id<w2chAuthenticationStatus>	authenticator_;
	NSString						*sessionID_;

    authenticator_ = [CMRPref shared2chAuthenticator];
	if (!authenticator_) return NO;

	sessionID_ = [authenticator_ sessionID];

	if (sessionID_) {
		m_sessionID = [sessionID_ retain];
	} else if ([authenticator_ recentErrorType] != w2chNoError) {
		[m_sessionID release];
		m_sessionID = nil;
		return NO;
	}
	
	return YES;
}

- (NSString *)sessionID
{
	return m_sessionID;
}

- (void)dealloc
{
	[m_sessionID release];
	[super dealloc];
}

- (NSURL *)resourceURL
{
	if(![self sessionID]) return [super resourceURL];

	NSString	*sidEscaped = [[self sessionID] stringByURLEncodingUsingEncoding:NSASCIIStringEncoding];
	NSURL		*boardURL = [self boardURL];

	return [NSURL URLWithString:[NSString stringWithFormat:kResourceURLTemplate,
									[boardURL host], [boardURL path], [[self threadSignature] identifier], sidEscaped]];
}
@end
