/**
  * $Id: CMRStatusLineWindowController.m,v 1.13 2007/04/19 14:13:43 tsawada2 Exp $
  * BathyScaphe
  *
  * 旧 CMRStatusLineWindowController と CMRToolbarWindowController を統合
  * Copyright 2006 BathyScaphe Project. All rights reserved.
  *
  */

#import "CMRStatusLineWindowController.h"
#import "CMRTask.h"
#import "CMRTaskManager.h"

@implementation CMRStatusLineWindowController
- (void) dealloc
{
	[m_statusLine setDelegate: nil];
	[m_statusLine release];
	[m_toolbarDelegateImp release];
	[super dealloc];
}

+ (Class) toolbarDelegateImpClass
{
	return Nil;
}

- (id<CMRToolbarDelegate>) toolbarDelegate
{
	if(nil == m_toolbarDelegateImp){
		Class		class_;
		
		class_ = [[self class] toolbarDelegateImpClass];
		UTILAssertConformsTo(class_, @protocol(CMRToolbarDelegate));

		m_toolbarDelegateImp = [[class_ alloc] init];
	}
	return m_toolbarDelegateImp;
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

// Keybinding support
- (void) selectNextKeyView : (id) sender
{
	[[self window] selectNextKeyView : sender];
}
- (void) selectPreviousKeyView : (id) sender
{
	[[self window] selectPreviousKeyView : sender];
}

// Window Management
- (void) windowDidLoad
{
	[super windowDidLoad];
	[[self window] setAutodisplay : NO];
	[[self window] setViewsNeedDisplay : NO];
	[self setupUIComponents];
	[[self window] setViewsNeedDisplay : YES];
	[[self window] setAutodisplay : YES];
}
/*
- (BOOL) validateMenuItem : (NSMenuItem *) theItem
{
	SEL action_;
	
	if (nil == theItem) return NO;
	action_ = [theItem action];
	
	// 「ウインドウの位置と領域を記憶」
	if (action_ == @selector(saveAsDefaultFrame:)) {
		return YES;
	}
	if (action_ == @selector(cancelCurrentTask:)) {
		id<CMRTask> tm = [CMRTaskManager defaultManager];
		return ([tm isInProgress]);
	}	
	return NO;
}

- (BOOL) validateToolbarItem : (NSToolbarItem *) item_
{
	SEL	action_;
	action_ = [item_ action];
	if (action_ == @selector(cancelCurrentTask:)) { 
		return ([[CMRTaskManager defaultManager] isInProgress]); 
	} else {	
		NSString		*identifier_;
		NSToolbarItem	*theItem_;
		
		identifier_ = [item_ itemIdentifier];
		theItem_ = [[self toolbarDelegate] itemForItemIdentifier: identifier_];
		
		return (theItem_ == item_);
	}
}
*/
- (BOOL) validateUserInterfaceItem: (id <NSValidatedUserInterfaceItem>) anItem
{
	SEL action_ = [anItem action];
	if (action_ == @selector(cancelCurrentTask:)) {
		return [[CMRTaskManager defaultManager] isInProgress];
	}
	
	return YES; // For Example, @selector(saveAsDefaultFrame:) -- always YES.
}
@end

@implementation CMRStatusLineWindowController(ViewInitializer)
- (void) setupUIComponents
{
	[[self toolbarDelegate] attachToolbarWithWindow : [self window]];
	[[self window] setDelegate : self];
	[self setupStatusLine];
}

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
}

- (CMRStatusLine *) statusLine
{
	if (nil == m_statusLine) {
		m_statusLine = [[[[self class] statusLineClass] alloc] initWithIdentifier: [self statusLineFrameAutosaveName]];
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
