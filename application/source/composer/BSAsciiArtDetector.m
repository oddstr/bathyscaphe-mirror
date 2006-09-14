//
// BSAsciiArtDetector.m
// BathyScaphe
//
// Written by Tsutomu Sawada on 06/09/10.
// Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSAsciiArtDetector.h"
#import "CocoMonar_Prefix.h"
#import "CMRThreadMessageBuffer.h"
#import "CMRThreadMessage.h"
#import "CMRThreadSignature.h"

//将来、AA のサンプルなどをカスタマイズ／拡張可能にする際に使う予定
//static NSString *const kAASamplesFile = @"BSAADetector.plist";

@implementation BSAsciiArtDetector
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(sharedInstance);

/*
+ (NSString *) defaultFilepath
{
	return [[CMRFileManager defaultManager] supportFilepathWithName: kAASamplesFile
                                                   resolvingFileRef: NULL];
}
*/

- (id) init
{
	if (self = [super init]) {
        ;
    }
	return self;
}

static BOOL detectIfAA(NSString *source)
{
    //static NSString *pattern1 = nil;
    static NSString *pattern2 = nil;
    
    if (!pattern2) {
        //pattern1 = [[NSString alloc] initWithFormat: @" %C", 0x3000];
        pattern2 = [[NSString alloc] initWithFormat: @"%C ", 0x3000];
    }

    if (!source || [source length] < 7) return NO;
    
    NSMutableString *mSource;
    unsigned int    numOfParagraphs;
    mSource = [source mutableCopy];
    numOfParagraphs = [mSource replaceOccurrencesOfString: @" <br> "
                                               withString: @"\n"
                                                  options: NSLiteralSearch|NSCaseInsensitiveSearch
                                                    range: NSMakeRange(0, [mSource length])];

    if(numOfParagraphs < 1) {
        [mSource release];
        return NO;    
    }

    //if ([source rangeOfString: pattern1 options: NSLiteralSearch].length != 0) return YES;
    if ([mSource rangeOfString: pattern2 options: NSLiteralSearch].length != 0) {
        [mSource release];
        return YES;
    }
    
    [mSource release];
    return NO;
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
