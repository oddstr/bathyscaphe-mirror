//
// BSAsciiArtDetector.m
// BathyScaphe
//
// Written by Tsutomu Sawada on 06/09/10.
// Copyright 2006 BathyScaphe Project. All rights reserved.
// encoding="UTF-8"
//

#import "BSAsciiArtDetector.h"
#import "CMRThreadMessageBuffer.h"
#import "CMRThreadMessage.h"
#import "CMRThreadSignature.h"
#import "AppDefaults.h"
#import <CocoMonar/CocoMonar.h>
#import <OgreKit/OgreKit.h>

static NSString *const kAADRegExpKey = @"Thread - AAD Regular Expression";

@implementation BSAsciiArtDetector
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(sharedInstance);

- (id)init
{
	if (self = [super init]) {
        ;
    }
	return self;
}

static BOOL detectIfAA(NSString *source)
{
	static OGRegularExpression *regExp = nil;
	static BOOL shouldContinue = YES;

    if (!source || [source length] < 7 || !shouldContinue) return NO;

	if (!regExp) {
		NSString *expStr = SGTemplateResource(kAADRegExpKey);
		if (!expStr || [expStr isEqualToString: @""] || ![OGRegularExpression isValidExpressionString:expStr]) {
			NSBeep();
			NSLog(@"WARNING - Your AAD Regular Expression String is invalid or empty!");
			shouldContinue = NO;
			return NO;
		}
		regExp = [[OGRegularExpression alloc] initWithString:expStr];
	}

	OGRegularExpressionMatch *match = [regExp matchInString:source];
	return (match != nil);
}

- (void)runDetectorWithMessages:(CMRThreadMessageBuffer *)aBuffer with:(CMRThreadSignature *)aThread
{
	NSEnumerator			*iter_;
	CMRThreadMessage		*m;
	BOOL					treatAsSpamFlag = [CMRPref treatsAsciiArtAsSpam];
	
	if (!aBuffer || [aBuffer count] == 0) return;
	
	iter_ = [[aBuffer messages] objectEnumerator];
	while (m = [iter_ nextObject]) {
		if ([m isAsciiArt]) {
			if (treatAsSpamFlag) [m setSpam:YES];
			continue;
		}
		
		if (detectIfAA([m messageSource])) {
			[m setAsciiArt:YES];
			if (treatAsSpamFlag) [m setSpam:YES];
		}
	}
}
@end
