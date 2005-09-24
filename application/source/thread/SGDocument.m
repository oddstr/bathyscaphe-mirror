//:SGDocument.m
#import "SGDocument.h"



@implementation SGDocument
- (void) removeWindowController : (NSWindowController *) windowController
{
	NSEnumerator		*iter_;
	NSWindowController	*controller_;
	SEL					selector_;
	
	selector_ = @selector(document:willRemoveController:);
	iter_ = [[self windowControllers] objectEnumerator];
	
	while(controller_ = [iter_ nextObject]){
		if(NO == [controller_ respondsToSelector : selector_])
			continue;
		
		[controller_ document:self willRemoveController:windowController];
	}
	
	[super removeWindowController : windowController];
}
@end
