//: CMXWorkerContext.h
/**
  * $Id: CMXWorkerContext.h,v 1.1 2005/05/11 17:51:05 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>


@class    SGInternalMessenger;
@protocol SGBaseQueue;


@protocol CMXRunnable <NSObject>
- (void) run;
- (void) cancel : (id) sender;
@end

/*!
 * @exception   CMRThreadTaskInterruptedException
 * @discussion
 *
 * �^�X�N���L�����Z������Ƃ��͂��̗�O�𓊂���B
 * CMXWorkerContext�͂��̗�O���L���b�`����ƒP�ɖ������A
 * ���̃^�X�N�ɐ�����ڂ��B
 */
extern NSString *const CMRThreadTaskInterruptedException;
extern NSString *const CMRThreadTaskInterruptedNotification;



@interface CMXWorkerContext : NSObject<CMXRunnable>
{
	@private
	BOOL				_usesDrawingThread;
	BOOL				_toBeContinued;
	id<SGBaseQueue>		_workQueue;
	
	NSLock				*_workLock;
	id					_work;
	
	NSConditionLock		*_queueLock;
	NSLock				*_workingLock;
}
- (id) initWithUsingDrawingThread : (BOOL) usesDrawingThread;

- (BOOL) usesDrawingThread;

- (void) push : (id<CMXRunnable>) newWork;

- (BOOL) isInProgress;
- (void) shutdown : (id) sender;
- (void) removeAll : (id) sender;
/*
// NOTE: This method can't stop wark immedially.
- (void) cancel : (id) sender;
*/
@end
