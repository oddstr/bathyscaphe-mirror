//
//  CMRThreadComposingTask.h
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/02/18.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Foundation/Foundation.h>
#import "CMRThreadLayoutTask.h"

@class CMRThreadContentsReader;
@class CMRThreadMessageBuffer;

@interface CMRThreadComposingTask : CMRThreadLayoutConcreateTask {
	@private
	CMRThreadContentsReader	*_reader;

	unsigned				_willComposeLength;
	unsigned				_didComposedCount;

	unsigned int	_callbackIndex;
	NSString		*_threadTitle;
	id				_delegate;
}

+ (id)taskWithThreadReader:(CMRThreadContentsReader *)aReader;
- (id)initWithThreadReader:(CMRThreadContentsReader *)aReader;

- (id)delegate;
- (void)setDelegate:(id)aDelegate;

- (NSString *)threadTitle;
- (void)setThreadTitle:(NSString *)aThreadTitle;
- (CMRThreadContentsReader *)reader;
- (void)setReader:(CMRThreadContentsReader *)aReader;

/* 0-based */
- (unsigned int)callbackIndex;
- (void)setCallbackIndex:(unsigned int)aCallbackIndex;
@end


@interface NSObject(CMRThreadComposingTaskDelegate)
/*
before this object add messages to its Layout object.
this delegate method would be performed on worker's thread.

cancel, if this method returns NO.
*/
- (BOOL)threadComposingTask:(CMRThreadComposingTask *)aTask willCompleteMessages:(CMRThreadMessageBuffer *)aMessageBuffer;

// Called on main thread. Sender will be self.
- (void)threadComposingDidFinish:(id)sender;

// Called on main thread. Sender will be self.
- (void)threadTaskDidInterrupt:(id)sender;
@end

//extern NSString *const CMRThreadComposingDidFinishNotification;
