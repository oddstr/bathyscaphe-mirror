//: CMRTaskItemController.m
/**
  * $Id: CMRTaskItemController.m,v 1.1.1.1 2005/05/11 17:51:07 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "CMRTaskItemController_p.h"


@implementation CMRTaskItemController
//////////////////////////////////////////////////////////////////////
/////////////////////// [ 初期化・後始末 ] ///////////////////////////
//////////////////////////////////////////////////////////////////////
- (id) initWithTask : (id<CMRTask>) aTask
{
	if(self = [self init]){
		[self setTask : aTask];
	}
	return self;
}
- (id) init
{
	if(self = [super init]){
		if(NO == [NSBundle loadNibNamed : APP_TASK_ITEM_CONTROLLER_NIB_NAME
								  owner : self]){
			NSLog(@"%@ failed loadNibNamed:%@",
						 NSStringFromClass([self class]),
						 APP_TASK_ITEM_CONTROLLER_NIB_NAME);
			
			[self autorelease];
			return nil;
		}
	}
	return self;
}
- (void) awakeFromNib
{
	[[self indicator] setIndeterminate : NO];
}
- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver : self];
	[self disposeUnnecessaryViews];
	
	[_task release];
	[_finishedDate release];
	[_contentView release];
		
	[super dealloc];
}


- (IBAction) stop : (id) sender
{
	if([[self task] isInProgress])
		[[self task] cancel : sender];
}

- (id<CMRTask>) task
{
	return _task;
}
- (NSView *) contentView
{
	return _contentView;
}
- (NSString *) title
{
	return [[self titleField] stringValue];
}
- (void) setTitle : (NSString *) aTitle
{
	[[self titleField] setStringValue : aTitle ? aTitle : @""];
}

- (NSString *) message
{
	return [[self messageField] stringValue];
}
- (void) setMessage : (NSString *) aMessage
{
	NSString	*message_;
	
	message_ = aMessage ? aMessage : @"";
	if([self finishedDate] != nil){
		NSString	*dateDesc_;
		
		dateDesc_ = [[CMXDateFormatter sharedInstance]
						stringForObjectValue : [self finishedDate]];
		if(nil == dateDesc_)
			dateDesc_ = [[self finishedDate] description];
		
		message_ = [NSString stringWithFormat : 
						@"%@ (%@)",
						message_,
						dateDesc_];
	}
	
	[[self messageField] setStringValue : message_];
}
@end



@implementation CMRTaskItemController(Private)
/* Accessor for _task */
- (void) setTask : (id<CMRTask>) aTask
{
	id tmp;
	
	tmp = _task;
	_task = [aTask retain];
	[tmp release];
	
	[self updateUIComponents];
}
/* Accessor for _finishedDate */
- (NSDate *) finishedDate
{
	return _finishedDate;
}
- (void) setFinishedDate : (NSDate *) aFinishedDate
{
	id tmp;
	
	tmp = _finishedDate;
	_finishedDate = [aFinishedDate retain];
	[tmp release];
}
@end



@implementation CMRTaskItemController(ViewSetting)
- (void) updateUIComponents
{
	double					amount_;
	id<CMRTask>				task_ = [self task];
	NSProgressIndicator		*indicator_ = [self indicator];
	
	if(nil == task_) return;
	
	amount_ = [task_ amount];
	[self setTitle : [task_ title]];
	[self setMessage : [task_ message]];
	[[self stopButton] setEnabled : [task_ isInProgress]];
	UTILRequireCondition([task_ isInProgress], ErrNoAmount);
	UTILRequireCondition(amount_ >= 0, ErrNoAmount);

	[indicator_ setIndeterminate : NO];
	[indicator_ setDoubleValue : amount_];
	return;
	
	
ErrNoAmount:
	
	if(NO == [indicator_ isIndeterminate]){
		[indicator_ startAnimation : self];
		[indicator_ setIndeterminate : YES];
	}
	
	return;
}

- (void) disposeUnnecessaryViews
{
	NSView					*containerView_;
	NSProgressIndicator		*indicator_;
	
	[self setTask : nil];
	
	// 
	// プログレスバーと停止ボタンは
	// もう必要ないので解放する。
	// 
	indicator_ = [self indicator];
	containerView_ = [indicator_ superview];
	
	[indicator_ setIndeterminate : NO];
	[indicator_ setDoubleValue : 0];
	[indicator_ stopAnimation : nil];
	
	[[self indicator] removeFromSuperviewWithoutNeedingDisplay];
	[[self stopButton] removeFromSuperviewWithoutNeedingDisplay];
	
	_indicator = nil;
	_stopButton = nil;
	
	[self sizeOfTextFieldsToFit : [self titleField]];
	[self sizeOfTextFieldsToFit : [self messageField]];
	
	[containerView_ setNeedsDisplay : YES];
}

- (void) sizeOfTextFieldsToFit : (NSTextField *) textField
{
	float		width_;
	float		px_;
	NSSize		vsize_;
	
	width_ = [[self contentView] frame].size.width;
	
	px_ = [textField frame].origin.x;
	vsize_ = [textField frame].size;
	vsize_.width = (width_ - px_ * 2);
	[textField setFrameSize : vsize_];
}

@end



@implementation CMRTaskItemController (CMRTaskNotification)
- (void) taskWillStartProcessing : (id<CMRTask>) aTask
{
	[self updateUIComponents];
	[[self indicator] startAnimation : self];
}
- (void) taskDidFinishProcessing : (id<CMRTask>) aTask
{
	[self setFinishedDate : [NSDate date]];
	[self updateUIComponents];
	[self disposeUnnecessaryViews];
	
	[self setTask : nil];
}

- (void) taskWillProgressProcessing : (id<CMRTask>) aTask
{
	[self updateUIComponents];
}
@end




@implementation CMRTaskItemController(ViewAccessor)
/* Accessor for _titleField */
- (NSTextField *) titleField
{
	return _titleField;
}

/* Accessor for _messageField */
- (NSTextField *) messageField
{
	return _messageField;
}

/* Accessor for _indicator */
- (NSProgressIndicator *) indicator
{
	return _indicator;
}

/* Accessor for _stopButton */
- (NSButton *) stopButton
{
	return _stopButton;
}

@end
