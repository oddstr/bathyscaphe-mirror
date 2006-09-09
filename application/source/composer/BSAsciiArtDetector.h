//
// BSAsciiArtDetector.h
// BathyScaphe
//
// Written by Tsutomu Sawada on 06/09/10.
// Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMRThreadMessageBuffer;
@class CMRThreadSignature;

@interface BSAsciiArtDetector: NSObject
{
	//@private
	//NSSet      *m_sampleAAs; // 一行AAの判定精度向上用
}

+ (id) sharedInstance;
//+ (NSString *) defaultFilepath;

//- (void) resetSampleAAs;

//- (void) addSample: (NSString *) aSampleAA;
//- (void) removeSample: (NSString *) aSampleAA;

- (void) runDetectorWithMessages: (CMRThreadMessageBuffer *) aBuffer
				            with: (CMRThreadSignature     *) aThread;
@end
