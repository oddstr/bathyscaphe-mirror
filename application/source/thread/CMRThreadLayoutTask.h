//
//  CMRThreadLayoutTask.h
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/03/11.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Foundation/Foundation.h>
#import "CMRTask.h"
#import "CMRThreadLayout.h"

@protocol CMRThreadLayoutTask<NSObject, CMRTask, CMXRunnable>
/**
  * @exception CMRThreadTaskInterruptedException
  *            キャンセルや予期しない状況により終了した。
  */
- (void)executeWithLayout:(CMRThreadLayout *)layout;
@end


@interface CMRThreadLayoutConcreateTask : NSObject<CMRThreadLayoutTask> {
	BOOL		_isInterrupted;
//	BOOL		_didFinished;
	BOOL		_isInProgress;
	
	id			_identifier;
	CMRThreadLayout	*_layout;

	NSString	*m_statusMsg;
	double		m_amount;
}
// initializer
+ (id)task;
+ (id)taskWithIndentifier:(id)anIdentifier;

- (id)identifier;
- (void)setIdentifier:(id)anIdentifier;

- (CMRThreadLayout *)layout;
- (void)setLayout:(CMRThreadLayout *)aLayout;

- (BOOL)isInterrupted;
- (void)setIsInterrupted:(BOOL)anIsInterrupted;
/**
  * @exception CMRThreadTaskInterruptedException
  *            [self isInterrupted] == YESなら例外を発生
  */
- (void)checkIsInterrupted;
// Deprecated. Use -isInProgress, -setIsInProgress: instead.
//- (BOOL) didFinished;
//- (void) setDidFinished : (BOOL) aDidFinished;
/**
  * 
  * 以下のメソッドはサブクラスに提供
  * 
  */
//- (NSString *) messageInProgress; // Deprecated. Use -message, -setMessage: instead.
- (void)doExecuteWithLayout:(CMRThreadLayout *)layout;
- (void)finalizeWhenInterrupted;
- (void)postInterruptedNotification;
@end

/* subclasses */
@interface CMRThreadClearTask : CMRThreadLayoutConcreateTask {
	id	_delegate;
}
- (id)delegate;
- (void)setDelegate:(id)aDelegate;
@end
