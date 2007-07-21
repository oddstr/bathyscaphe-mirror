//: CMXPopUpWindowManager.m
/**
  * $Id: CMXPopUpWindowManager.m,v 1.7 2007/07/21 19:32:55 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "CMXPopUpWindowManager.h"
#import "CocoMonar_Prefix.h"
#import "CMXPopUpWindowController.h"
#import "AppDefaults.h"
#import "CMRPopUpTemplateKeys.h"



@implementation CMXPopUpWindowManager
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(defaultManager);

- (void) dealloc
{
	[bs_controllersArray release];
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[super dealloc];
}

- (NSMutableArray *) controllerArray
{
	if (nil == bs_controllersArray) {
		CFArrayCallBacks arrayCallBacks = kCFTypeArrayCallBacks;
		arrayCallBacks.retain = NULL;
		arrayCallBacks.release = NULL;
		bs_controllersArray = (NSMutableArray *)CFArrayCreateMutable(NULL, 0, &arrayCallBacks);
	}
	return bs_controllersArray;
}

- (CMXPopUpWindowController *) availableController
{
	CMXPopUpWindowController	*controller_ = nil;
	NSMutableArray	*array_= [self controllerArray];
	NSEnumerator *iter_ = [array_ objectEnumerator];
	
	while (controller_ = [iter_ nextObject]) {
		if ([controller_ canPopUpWindow]) {
			break;
		}
	}
	
	if(nil == controller_ || (NO == [controller_ canPopUpWindow])){
		// 
		// すべて使用中
		// 
		controller_ = [[CMXPopUpWindowController alloc] init];
		[controller_ window];

		[array_ addObject: controller_];
	}
	return controller_;
}

- (BOOL) isPopUpWindowVisible
{
	CMXPopUpWindowController	*controller_ = nil;
	NSMutableArray *array_ = [self controllerArray];
	NSEnumerator *iter_ = [array_ objectEnumerator];
	
	while (controller_ = [iter_ nextObject]) {
		if (NO == [controller_ canPopUpWindow]) return YES;
	}
	return NO;
}

- (CMXPopUpWindowController *) controllerForObject : (id) object
{
	CMXPopUpWindowController	*controller_ = nil;
	NSMutableArray *array_ = [self controllerArray];
	NSEnumerator *iter_ = [array_ objectEnumerator];
	
	while (controller_ = [iter_ nextObject]) {
		if ([[controller_ object] isEqual: object]) return controller_;
	}
	return nil;
}

- (NSWindow *) windowForObject : (id) object
{
	return [[self controllerForObject : object] window];
}
- (BOOL) popUpWindowIsVisibleForObject : (id) object
{
	return [[self windowForObject : object] isVisible];
}

#pragma mark PopUp or Close PopUp
- (id) showPopUpWindowWithContext : (NSAttributedString *) context
                        forObject : (id                  ) object
                            owner : (id                  ) owner
                     locationHint : (NSPoint             ) point
{
	CMXPopUpWindowController	*controller_;
	
	UTILAssertNotNilArgument(context, @"context");
	controller_ = [self availableController];
	[controller_ setObject : object];
	
	// setup UI
	[controller_ setUsesSmallScroller: [self popUpUsesSmallScroller]];	
	[controller_ setShouldAntialias: [self popUpShouldAntialias]];
	[controller_ setLinkTextHasUnderline: [self popUpLinkTextHasUnderline]];
	[controller_ setTheme:[self theme]];

	[controller_ showPopUpWindowWithContext : context
					                  owner : owner
							   locationHint : point];
	return controller_;
}

- (void) closePopUpWindowForOwner : (id) owner;
{
	CMXPopUpWindowController	*controller_ = nil;
	NSMutableArray *array_ = [self controllerArray];
	NSEnumerator *iter_ = [array_ objectEnumerator];
	
	while (controller_ = [iter_ nextObject]) {
		if ([(id)[controller_ owner] isEqual: owner]) [controller_ performClose];
	}
}
- (BOOL) performClosePopUpWindowForObject : (id) object
{
	float						insetWidth_;
	CMXPopUpWindowController	*controller_;
	
	
	controller_ = [self controllerForObject : object];
	if(nil == controller_)
		return NO;
	
	insetWidth_ = [[controller_ class] popUpTrackingInsetWidth];
	if(NO == [controller_ mouseInWindowFrameInset : -insetWidth_]){
		[controller_ performClose];
		return YES;
	}
	return NO;
}


#pragma mark CMRPref Accessors
- (BOOL) popUpUsesSmallScroller
{
	return [CMRPref popUpWindowVerticalScrollerIsSmall];
}
- (BOOL) popUpShouldAntialias
{
	return [CMRPref shouldThreadAntialias];
}
- (BOOL) popUpLinkTextHasUnderline
{
	return [CMRPref hasMessageAnchorUnderline];
}
- (BSThreadViewTheme *)theme
{
	return [CMRPref threadViewTheme];
}
@end
