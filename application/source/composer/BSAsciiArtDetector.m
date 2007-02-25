//
// BSAsciiArtDetector.m
// BathyScaphe
//
// Written by Tsutomu Sawada on 06/09/10.
// Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSAsciiArtDetector.h"
#import "CMRThreadMessageBuffer.h"
#import "CMRThreadMessage.h"
#import "CMRThreadSignature.h"

#import <CocoMonar/CocoMonar.h>
#import <OgreKit/OgreKit.h>

static NSString *const kAADRegExpKey = @"Thread - AAD Regular Expression";

@implementation BSAsciiArtDetector
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(sharedInstance);

- (id) init
{
	if (self = [super init]) {
        ;
    }
	return self;
}

static BOOL detectIfAA(NSString *source)
{
	static OGRegularExpression *regExp = nil;

    if (!source || [source length] < 7) return NO;

	if (!regExp) {
		NSString *expStr = SGTemplateResource(kAADRegExpKey);
		regExp = [[OGRegularExpression alloc] initWithString: expStr];
	}

	OGRegularExpressionMatch *match = [regExp matchInString: source];
	return (match != nil);
}

- (void) runDetectorWithMessages: (CMRThreadMessageBuffer *) aBuffer
							with: (CMRThreadSignature     *) aThread
{
	NSEnumerator			*iter_;
	CMRThreadMessage		*m;
	
	if (nil == aBuffer || 0 == [aBuffer count])
		return;
	
	
	iter_ = [[aBuffer messages] objectEnumerator];
	while (m = [iter_ nextObject]) {
		if ([m isAsciiArt]) continue;
		
		if (detectIfAA([m messageSource])) {
			[m setAsciiArt: YES];
		}
	}
}
@end
