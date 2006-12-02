/**
  * $Id: CMRMessageFilter.h,v 1.1.1.1.8.2 2006/12/02 18:44:14 tsawada2 Exp $
  * 
  * CMRMessageFilter.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <SGFoundation/SGFoundation.h>
#import <CocoMonar/CocoMonar.h>
#import "CMRMessageSample.h"

//@class CMRThreadMessage;
//@class CMRThreadSignature;
@class SGBaseCArrayWrapper;

@interface CMRMessageDetecter : NSObject
/* primitive */
- (BOOL) detectMessage : (CMRThreadMessage *) aMessage;
@end

@interface CMRSamplingDetecter : CMRMessageDetecter<CMRPropertyListCoding>
{
	@private
	NSMutableDictionary		*_table;	/* key: name or ID */
	SGBaseCArrayWrapper		*_samples;
	NSArray					*_corpus;
	NSSet					*_noNameSet;
	BOOL					_nanashiAllowed;
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

// ReinforceII Additions
- (BOOL) nanashiAllowedAtWorkingBoard;
- (void) setNanashiAllowedAtWorkingBoard: (BOOL) allowed;
- (void) setupAppendingSampleForSample: (CMRMessageSample *) sample table: (NSMutableDictionary *) table;

- (void) addNewMessageSample : (CMRMessageSample *) aSample;
- (void) addSamplesFromDetecter : (CMRSamplingDetecter *) aDetecter;
- (void) addSample : (CMRThreadMessage   *) aMessage
			  with : (CMRThreadSignature *) aThread;
- (void) removeSample : (CMRThreadMessage   *) aMessage
			     with : (CMRThreadSignature *) aThread;
- (BOOL) detectMessage : (CMRThreadMessage   *) aMessage
			      with : (CMRThreadSignature *) aThread;
@end
