/**
  * $Id: CMRMessageFilter.h,v 1.1.1.1.8.1 2006/08/31 10:18:40 tsawada2 Exp $
  * 
  * CMRMessageFilter.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <SGFoundation/SGFoundation.h>
#import <CocoMonar/CocoMonar.h>

@class CMRThreadMessage;
@class CMRThreadSignature;
@class SGBaseCArrayWrapper;



@interface CMRMessageDetecter : NSObject
/* primitive */
- (BOOL) detectMessage : (CMRThreadMessage *) aMessage;
@end



enum {
	kSampleAsNameMask		 = 1,
	kSampleAsMailMask		 = 2,
	kSampleAsIDMask			 = 4,
	kSampleAsHostMask		 = 8,
	kSampleAsMessageMask	 = 16,
	kSampleAsThreadLocalMask = 32,
	kSampleAsAny			 = 0x3f,
};



@interface CMRMessageSample : SGBaseObject<CMRPropertyListCoding>
{
	@private
	UInt32				_flags;
	UInt32				_matchedCount;
	CMRThreadMessage	*_message;
	CMRThreadSignature	*_threadIdentifier;
}
+ (id) sampleWithMessage : (CMRThreadMessage   *) aMessage
			  withThread : (CMRThreadSignature *) aThreadIdentifier;
- (id) initWithMessage : (CMRThreadMessage   *) aMessage
			withThread : (CMRThreadSignature *) aThreadIdentifier;

- (CMRThreadMessage *) message;
- (void) setMessage : (CMRThreadMessage *) aMessage;
- (CMRThreadSignature *) threadIdentifier;
- (void) setThreadIdentifier : (CMRThreadSignature *) aThreadIdentifier;

- (UInt32) flags;
- (void) setFlags : (UInt32) aFlags;

- (UInt32) matchedCount;
- (void) setMatchedCount : (UInt32) aMatchedCount;
- (void) incrementMatchedCount;
@end



@interface CMRSamplingDetecter : CMRMessageDetecter<CMRPropertyListCoding>
{
	@private
	NSMutableDictionary		*_table;	/* key: name or ID */
	SGBaseCArrayWrapper		*_samples;
	NSArray					*_corpus;
	NSSet					*_noNameSet;
}
- (id) initWithDictionaryRepresentation : (NSDictionary *) aDictionary;
- (NSDictionary *) dictionaryRepresentation;

- (unsigned) numberOfSamples;
- (void) clear;

- (NSArray *) corpus;
- (void) setCorpus : (NSArray *) aCorpus;

// MeteorSweeper Additions
- (NSSet *) noNameSetAtWorkingBoard;
- (void) setNoNameSetAtWorkingBoard: (NSSet *) aSet;

- (void) addNewMessageSample : (CMRMessageSample *) aSample;
- (void) addSamplesFromDetecter : (CMRSamplingDetecter *) aDetecter;
- (void) addSample : (CMRThreadMessage   *) aMessage
			  with : (CMRThreadSignature *) aThread;
- (void) removeSample : (CMRThreadMessage   *) aMessage
			     with : (CMRThreadSignature *) aThread;
- (BOOL) detectMessage : (CMRThreadMessage   *) aMessage
			      with : (CMRThreadSignature *) aThread;
@end
