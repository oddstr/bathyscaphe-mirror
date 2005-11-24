//:CMRThreadViewer-MoveAction.m
/**
  *
  * @see CMRIndexingStepper.h
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (02/09/28  4:27:37 PM)
  *
  */
#import "CMRThreadViewer_p.h"
#import "CMRThreadLayout.h"



@implementation CMRThreadViewer(MoveActionSupport)
- (void) updateIndexField
{
	int		index_;
	int		maxValue_;
	int		minValue_;
	
	if (nil == [self threadLayout]) {
		minValue_ = 0;
		maxValue_ = 0;
	} else {
		maxValue_ = [[self threadLayout] firstUnlaidMessageIndex];
	}
	
	if (0 == maxValue_) {
		index_ = 0;
		minValue_ = 0;
	} else {
		index_ = [[self threadLayout] messageIndexForDocuemntVisibleRect];
		if (index_ == NSNotFound) index_ = 0;
		
		index_++;
		minValue_ = 1;
	}
	
	[[self indexingStepper] setMinValue : minValue_];
	[[self indexingStepper] setMaxValue : maxValue_];
	[[self indexingStepper] setIntValue : index_];
}



- (void) scrollMessageAtIndex : (int) index
{
	[[self threadLayout] scrollMessageAtIndex : index];
}

//////////////////////////////////////////////////////////////////////
/////////////////////////// [ DELEGATE] //////////////////////////////
//////////////////////////////////////////////////////////////////////
/* ScrollView-ContentView: NSViewBoundsDidChangeNotification */
- (void) contentViewBoudnsDidChange : (NSNotification *) notification
{
	UTILAssertNotificationName(
		notification,
		NSViewBoundsDidChangeNotification);
	UTILAssertNotificationObject(
		notification,
		[[self scrollView] contentView]);
	// update index
	[self updateIndexField];
}
@end



@implementation CMRThreadViewer(MoveAction)
/* 最初／最後のレス */
- (IBAction) scrollFirstMessage : (id) sender
{
	[self scrollMessageAtIndex : 0];
}
- (IBAction) scrollLastMessage : (id) sender
{
	[self scrollMessageAtIndex : [[self threadLayout] firstUnlaidMessageIndex] -1];
}

/* 次／前のレス */
- (IBAction) scrollPreviousMessage : (id) sender 
{
	[self scrollPrevMessage : sender];
}
- (IBAction) scrollPrevMessage : (id) sender
{
	[self scrollMessageAtIndex : 
		[[self threadLayout] previousVisibleMessageIndex]];
}
- (IBAction) scrollNextMessage : (id) sender
{
	[self scrollMessageAtIndex : 
		[[self threadLayout] nextVisibleMessageIndex]];
}


/* 次／前のブックマーク */
- (IBAction) scrollPreviousBookmark : (id) sender 
{
	[self scrollMessageAtIndex : 
		[[self threadLayout] previousBookmarkIndex]];
}
- (IBAction) scrollNextBookmark : (id) sender
{
	[self scrollMessageAtIndex : 
		[[self threadLayout] nextBookmarkIndex]];
}


- (IBAction) scrollToLastReadedIndex : (id) sender;
{
	if ([self canScrollToLastReadedMessage]) {
		[self scrollMessageAtIndex : [[self threadAttributes] lastIndex]];
	}
}
- (IBAction) scrollToLastUpdatedIndex : (id) sender
{
	[[self threadLayout] scrollToLastUpdatedIndex : sender];
}
@end



@implementation CMRThreadViewer(CMRIndexingStepperDelegate)
- (void) indexingStepperDidUpdate : (CMRIndexingStepper *) stepper
{
}
- (void) indexingStepperDidEndEditing : (CMRIndexingStepper *) stepper
{
	int		num_;
	int		index_;
	int		length_;
	
	if (nil == stepper) return;
	if (nil == [self threadLayout]) return;
	
	num_ = [[self threadLayout] numberOfReadedMessages];
	index_ = [stepper intValue];
	length_ = [stepper maxValue];
	
	if (index_ < 1 || index_ > num_ || length_ != num_) return;
	
	[self scrollMessageAtIndex : (index_ -1)];
	[[self window] makeFirstResponder : [self textView]];
}
- (void) indexingStepperDidIncrement : (CMRIndexingStepper *) stepper
{
	[self scrollNextMessage : stepper];
}
- (void) indexingStepperDidDecrement : (CMRIndexingStepper *) stepper
{
	[self scrollPrevMessage : stepper];
}
- (void) indexingStepperDidBecomeMin : (CMRIndexingStepper *) stepper
{
	unsigned	index_ = [[self threadLayout] previousBookmarkIndex];
	
	if (index_ != NSNotFound)
		[self scrollPreviousBookmark : stepper];
	else
		[self scrollFirstMessage : stepper];
}
- (void) indexingStepperDidBecomeMax : (CMRIndexingStepper *) stepper
{
	unsigned	index_ = [[self threadLayout] nextBookmarkIndex];
	
	if (index_ != NSNotFound)
		[self scrollNextBookmark : stepper];
	else
		[self scrollLastMessage : stepper];
}
- (void) indexingStepperDidBecomeUpdated : (CMRIndexingStepper *) stepper
{
	[self scrollToLastUpdatedIndex:stepper];
}
@end



@implementation CMRThreadViewer(MoveActionValidation)

- (BOOL) canScrollToMessage
{
	return ([self threadLayout] != nil && [[self threadLayout] firstUnlaidMessageIndex] != 0);
}
- (BOOL) canScrollFirstMessage
{
	if (NO == [self canScrollToMessage]) return NO;
	return ([[self indexingStepper] intValue] != [[self indexingStepper] minValue]);
}
- (BOOL) canScrollLastMessage
{
	if (NO == [self canScrollToMessage]) return NO;
	return ([[self indexingStepper] intValue] != [[self indexingStepper] maxValue]);
}
- (BOOL) canScrollPrevMessage
{
	return [self canScrollFirstMessage];
}
- (BOOL) canScrollNextMessage
{
	return [self canScrollLastMessage];
}

- (BOOL) canScrollToLastReadedMessage
{
	if (NO == [self canScrollToMessage]) {
		return NO;
	}
	if (NSNotFound == [[self threadAttributes] lastIndex]) {
		return NO;
	}
	
	return YES;
}
- (BOOL) canScrollToLastUpdatedMessage
{
	NSRange		range_;
	
	if (NO == [self canScrollToMessage]) return NO;
	
	range_ = [[self threadLayout] firstLastUpdatedHeaderAttachmentRange];
	if (NSNotFound == range_.location) return NO;
	
	return YES;
}
@end
