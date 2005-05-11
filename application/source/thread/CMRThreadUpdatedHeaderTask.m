//:CMRThreadUpdatedHeaderTask.m
/**
  *
  * @see CMRThreadLayout.h
  * @see CMRMessageAttributesTemplate.h
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (03/01/17  6:55:59 PM)
  *
  */
#import "CMRThreadUpdatedHeaderTask.h"
#import "CMRThreadLayout.h"



@implementation CMRThreadUpdatedHeaderTask
- (void) doExecuteWithLayout : (CMRThreadLayout *) layout
{
	NSTextStorage		*textStorage_;
	
	textStorage_ = [layout textStorage];
	
	[self checkIsInterrupted];
	[textStorage_ beginEditing];
		[layout clearLastUpdatedHeader];
		[layout appendLastUpdatedHeader];
	[textStorage_ endEditing];
}
// CMRTask:
- (id) identifier
{
	return nil;
}

@end
