//:CMRStatusLineWindowController.m
/**
  *
  * @see CMRStatusLine.h
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (02/09/24  11:19:36 AM)
  *
  */
#import "CMRStatusLineWindowController_p.h"
#import "CocoMonar_Prefix.h"

#import "CMRTask.h"
#import "CMRTaskManager.h"



@implementation CMRStatusLineWindowController
- (void) dealloc
{
	[m_statusLine setDelegate : nil];
	[m_statusLine release];
	[super dealloc];
}

- (IBAction) toggleStatusLineShown : (id) sender
{
	[[self statusLine] toggleStatusLineShown : sender];
}
// board / thread signature for historyManager .etc
- (id) boardIdentifier
{
	UTILAbstractMethodInvoked;
	return nil;
}
- (id) threadIdentifier
{
	UTILAbstractMethodInvoked;
	return nil;
}

- (BOOL) validateMenuItem : (NSMenuItem *) theItem
{
	SEL action_;
	
	if (nil == theItem) return NO;
	action_ = [theItem action];
	
	if (action_ == @selector(toggleStatusLineShown:)) {
		NSString		*title_;
		
		title_ = [[self statusLine] isVisible]
					? NSLocalizedString(APP_STATUSLINE_WINDOW_HIDDEN_KEY, nil)
					: NSLocalizedString(APP_STATUSLINE_WINDOW_SHOWN_KEY, nil);
		UTILAssertNotNil(title_);
		
		[theItem setTitle : title_];
		return ([self statusLine] != nil);
	}
	// 「ウインドウの位置と領域を記憶」
	if (action_ == @selector(saveAsDefaultFrame:)) {
		return YES;
	}
	if (action_ == @selector(cancelCurrentTask:)) {
		id<CMRTask> tm = [CMRTaskManager defaultManager];
		return ([tm isInProgress] != NO);
	}	
	return NO;
}

- (BOOL) validateToolbarItem : (NSToolbarItem *) item_
{
	SEL	action_;
	action_ = [item_ action];
	if (action_ == @selector(cancelCurrentTask:))
	{ 
		return ([[CMRTaskManager defaultManager] isInProgress] != NO); 
	}
	
	return [super validateToolbarItem : item_];
}


// delegate
- (void) windowWillRunToolbarCustomizationPalette: (NSWindow *) sender
{
	[[[self statusLine] progressIndicator] setDisplayedWhenStopped : YES];
}

- (void)windowDidEndSheet:(NSNotification *)aNotification
{
	[[[self statusLine] progressIndicator] setDisplayedWhenStopped : NO];
}
@end



@implementation CMRStatusLineWindowController(ViewInitializer)
+ (Class) statusLineClass
{
	return [CMRStatusLine class];
}
- (NSString *) statusLineFrameAutosaveName
{
	UTILAbstractMethodInvoked;
	return nil;
}
- (void) setupStatusLine
{
	UTILAssertNotNil([self statusLine]);
	[[self statusLine] setWindow : [self window]];
}
- (void) setupUIComponents
{
	[super setupUIComponents];
	[[self window] setDelegate : self];
	[self setupStatusLine];
}
- (CMRStatusLine *) statusLine
{
	if (nil == m_statusLine) {
		m_statusLine = [[[[self class] statusLineClass] alloc] 
						initWithIdentifier : [self statusLineFrameAutosaveName]];
		[m_statusLine setDelegate : self];
	}
	return m_statusLine;
}
@end



@implementation CMRStatusLineWindowController(Action)
// 「ウインドウの位置と領域を記憶」
- (IBAction) saveAsDefaultFrame : (id) sender;
{
	UTILAbstractMethodInvoked;
}
- (IBAction) cancelCurrentTask : (id) sender;
{
	[[CMRTaskManager defaultManager] cancel : sender];
}
@end
