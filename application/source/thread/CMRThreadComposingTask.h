//:CMRThreadComposingTask.h
/**
  *
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (03/01/17  0:02:27 AM)
  *
  */
#import <Foundation/Foundation.h>
#import "CMRThreadLayoutTask.h"

@class CMRThreadContentsReader;
@class CMRThreadMessageBuffer;



@interface CMRThreadComposingTask : CMRThreadLayoutConcreateTask
{
	@private
	CMRThreadContentsReader	*_reader;
	
	unsigned				_willComposeLength;
	unsigned				_didComposedCount;
	
	unsigned int	_callbackIndex;
	NSString		*_threadTitle;
	id				_delegate;
}
+ (id) taskWithThreadReader : (CMRThreadContentsReader *) aReader;
- (id) initWithThreadReader : (CMRThreadContentsReader *) aReader;

- (id) delegate;
- (void) setDelegate : (id) aDelegate;

- (NSString *) threadTitle;
- (void) setThreadTitle : (NSString *) aThreadTitle;
- (CMRThreadContentsReader *) reader;
- (void) setReader : (CMRThreadContentsReader *) aReader;


/* 0 base, CMRThreadComposingCallbackNotification */
- (unsigned int) callbackIndex;
- (void) setCallbackIndex : (unsigned int) aCallbackIndex;
@end



@interface NSObject (CMRThreadComposingTaskDelegate)
/*
before this object add messages to its Layout object.
this delegate method would be performed on worker's thread.

cancel, if this method returns NO.
*/
- (BOOL) threadComposingTask : (CMRThreadComposingTask *) aTask
		willCompleteMessages : (CMRThreadMessageBuffer *) aMessageBuffer;
@end



extern NSString *const CMRThreadComposingDidFinishNotification;
extern NSString *const CMRThreadComposingCallbackNotification;
