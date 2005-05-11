//:SGContextHelpPanel.m

#import "SGContextHelpPanel.h"
#import "CMXPopUpWindowController.h"



@implementation NSWindow(PopUpWindow)
- (BOOL) isPopUpWindow
{
	return NO;
}
@end



@implementation SGContextHelpPanel
- (BOOL) isPopUpWindow
{
	return YES;
}
- (BOOL) canBecomeKeyWindow
{
	return YES;
}
- (BOOL) canBecomeMainWindow
{
	return NO;
}

- (NSWindow *) ownerWindow
{
	CMXPopUpWindowController	*c;
	
	c = [self windowController];
	if(NO == [c isKindOfClass : [CMXPopUpWindowController class]]){
		return nil;
	}
	return [c ownerWindow];
}
- (void) performMiniaturize : (id) sender
{
	[[self ownerWindow] performMiniaturize : sender];
}
- (void) performClose : (id)sender
{
	[[self ownerWindow] performClose : sender];
}
@end
