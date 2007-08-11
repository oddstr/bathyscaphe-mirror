//
//  CMRSpamFilter.h
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/08/12.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Foundation/Foundation.h>

@class CMRSamplingDetecter;
@class CMRThreadMessageBuffer;
@class CMRThreadMessage;
@class CMRThreadSignature;


@interface CMRSpamFilter : NSObject
{
	@private
	CMRSamplingDetecter		*_detecter;
	NSMutableArray			*_spamCorpus;
}

+ (id)sharedInstance;

- (void)resetSpamFilter;
- (CMRSamplingDetecter *)detecter;
- (NSMutableArray *)spamCorpus;
- (void)setSpamCorpus:(NSMutableArray *)aSpamCorpus;

- (void)saveDetecterAndCorpusToFiles;


- (void)addSample:(CMRThreadMessage *)aMessage with:(CMRThreadSignature *)aThread;
- (void)removeSample:(CMRThreadMessage *)aMessage with:(CMRThreadSignature *)aThread;

- (void)runFilterWithMessages:(CMRThreadMessageBuffer *)aBuffer with:(CMRThreadSignature *)aThread;
- (void)runFilterWithMessages:(CMRThreadMessageBuffer *)aBuffer with:(CMRThreadSignature *)aThread byDetecter:(CMRSamplingDetecter *)detecter;
@end
