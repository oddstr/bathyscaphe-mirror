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
@class BSNGExpression;


@interface CMRSpamFilter : NSObject
{
	@private
	CMRSamplingDetecter		*_detecter;
	NSMutableArray			*_spamCorpus;

	BOOL	m_needsSaveToFiles;
	NSTimer	*m_timer;
}

+ (id)sharedInstance;

- (void)resetSpamFilter;
- (CMRSamplingDetecter *)detecter;
- (NSMutableArray *)spamCorpus;
- (void)setSpamCorpus:(NSMutableArray *)aSpamCorpus;

- (void)saveDetecterAndCorpusToFiles;
- (void)addNGExpression:(BSNGExpression *)expression;

- (BOOL)needsSaveToFiles;
- (void)setNeedsSaveToFiles:(BOOL)flag;

- (void)addSample:(CMRThreadMessage *)aMessage with:(CMRThreadSignature *)aThread;
- (void)removeSample:(CMRThreadMessage *)aMessage with:(CMRThreadSignature *)aThread;

- (void)runFilterWithMessages:(CMRThreadMessageBuffer *)aBuffer with:(CMRThreadSignature *)aThread;
- (void)runFilterWithMessages:(CMRThreadMessageBuffer *)aBuffer with:(CMRThreadSignature *)aThread byDetecter:(CMRSamplingDetecter *)detecter;
@end
