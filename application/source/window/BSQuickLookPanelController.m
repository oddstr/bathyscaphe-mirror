//
//  BSQuickLookPanelController.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/02/02.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSQuickLookPanelController.h"
#import "AppDefaults.h"
#import <CocoMonar/CocoMonar.h>

@implementation BSQuickLookPanelController
static void *kBSQLPCContext = @"Hidamari_Sketch";

APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(sharedInstance);

- (NSObjectController *)objectController
{
	return m_objectController;
}

#pragma mark Override
- (id) init
{
	if (self = [super initWithWindowNibName:@"BSQuickLookPanel"]) {
	
	}
	return self;
}

- (void) awakeFromNib
{
	[[self window] setFrameAutosaveName : @"BathyScaphe:QuickLook Panel Autosave"];
	[[self objectController] addObserver:self forKeyPath:@"selection.isLoading" options:NSKeyValueObservingOptionNew context:kBSQLPCContext];
	[m_textView setTextContainerInset:NSMakeSize(8,8)];
	[m_textView setFont:[[CMRPref threadViewTheme] messageFont]];
}

- (void)showWindow:(id)sender
{
	if ([self isWindowLoaded] && [[self window] isVisible]) {// && [[self window] isKeyWindow]) {
		[[self window] orderOut:sender];
	} else {
		[super showWindow:sender];
	}
}

- (void)dealloc
{
	[[self objectController] removeObserver:self forKeyPath:@"selection.isLoading"];
	[super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ((context == kBSQLPCContext) && (object == [self objectController]) && ([keyPath isEqualToString:@"selection.isLoading"])) {
		id hoge = [[object content] valueForKey:@"isLoading"];
		BOOL isLoading = [hoge boolValue];
		if (!isLoading && ![[object content] valueForKey:@"lastError"]) {
			[m_tabView selectTabViewItemAtIndex:0];
		} else {
			[m_tabView selectTabViewItemAtIndex:1];
		}
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)windowWillClose:(NSNotification *)aNotification
{
	NSObjectController *controller = [self objectController];
	[controller setContent:nil];
}
@end
