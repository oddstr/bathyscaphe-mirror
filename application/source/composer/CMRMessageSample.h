//
//  CMRMessageSample.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/12/03.
//  Copyright 2006-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <SGFoundation/SGFoundation.h>
#import <CocoMonar/CocoMonar.h>

@class CMRThreadMessage;
@class CMRThreadSignature;

enum {
	kSampleAsNameMask		 = 1,
	kSampleAsMailMask		 = 2,
	kSampleAsIDMask			 = 4,
	kSampleAsHostMask		 = 8,
	kSampleAsMessageMask	 = 16,
	kSampleAsThreadLocalMask = 32,
	kSampleAsAny			 = 0x3f,
};

@interface CMRMessageSample : NSObject<CMRPropertyListCoding> {
	@private
	UInt32				_flags;
	UInt32				_matchedCount;
	CMRThreadMessage	*_message;
	CMRThreadSignature	*_threadIdentifier;

	NSDate				*_sampledDate;
}

+ (id)sampleWithMessage:(CMRThreadMessage *)aMessage withThread:(CMRThreadSignature *)aThreadIdentifier;
- (id)initWithMessage:(CMRThreadMessage *)aMessage withThread:(CMRThreadSignature *)aThreadIdentifier;

- (CMRThreadMessage *)message;
- (void)setMessage:(CMRThreadMessage *)aMessage;
- (CMRThreadSignature *)threadIdentifier;
- (void)setThreadIdentifier:(CMRThreadSignature *)aThreadIdentifier;

- (UInt32)flags;
- (void)setFlags:(UInt32)aFlags;

- (UInt32)matchedCount;
- (void)setMatchedCount:(UInt32)aMatchedCount;
- (void)incrementMatchedCount;

// Available in BathyScaphe 1.6.2 and later.
- (NSDate *)sampledDate;
- (void)setSampledDate:(NSDate *)date;
@end
