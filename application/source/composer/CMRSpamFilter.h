/**
  * $Id: CMRSpamFilter.h,v 1.2 2007/01/07 17:04:23 masakih Exp $
  * 
  * CMRSpamFilter.h
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
#import <Foundation/Foundation.h>
#import "CMRMessageFilter.h"
#import "CMRMessageSample.h"

@class CMRSamplingDetecter;
@class CMRThreadMessageBuffer;
@class CMRThreadMessage;
@class CMRThreadSignature;



@interface CMRSpamFilter : NSObject
{
	@private
	CMRSamplingDetecter		*_detecter;
	NSArray					*_spamCorpus;
}
+ (id) sharedInstance;
+ (NSString *) defaultFilepath;

- (void) resetSpamFilter;
- (CMRSamplingDetecter *) detecter;

- (NSArray *) spamCorpus;
- (void) setSpamCorpus : (NSArray *) aSpamCorpus;

- (void) addSample : (CMRThreadMessage   *) aMessage
			  with : (CMRThreadSignature *) aThread;
- (void) removeSample : (CMRThreadMessage   *) aMessage
			     with : (CMRThreadSignature *) aThread;

- (void) runFilterWithMessages : (CMRThreadMessageBuffer *) aBuffer
						  with : (CMRThreadSignature     *) aThread;
						  
- (void) runFilterWithMessages : (CMRThreadMessageBuffer *) aBuffer
						  with : (CMRThreadSignature     *) aThread
					byDetecter : (CMRSamplingDetecter    *) detecter;

@end


/*
// addSample:with: or removeSample:with:
extern NSString *const CMRSpamFilterDidChangeNotification;
*/
