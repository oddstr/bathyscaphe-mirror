//:IndexField.m
#import "IndexField.h"
#import <AppKit/NSTextFieldCell.h>



@implementation IndexField
- (void) mouseDown : (NSEvent *) theEvent
{
	[super mouseDown : theEvent];
	[self selectText : nil];
}
- (void) selectText : (id) sender
{
	SEL			responds_;
	NSRange		selectedRange_;
	
	[super selectText : sender];
	
	if(nil == [self delegate]) return;
	responds_ = @selector(selectRangeWithTextField:);
	if(NO == [[self delegate] respondsToSelector : responds_])
		return;
	
	selectedRange_ = [[self delegate] selectRangeWithTextField : self];
	[[self currentEditor] setSelectedRange : selectedRange_];
}
@end
