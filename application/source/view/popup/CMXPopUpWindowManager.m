//: CMXPopUpWindowManager.m
/**
  * $Id: CMXPopUpWindowManager.m,v 1.5 2007/02/07 13:26:13 tsawada2 Exp $
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
//	[_controllerArray release];
	[bs_controllersArray release];
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[super dealloc];
}

//- (SGBaseCArrayWrapper *) controllerArray
- (NSMutableArray *) controllerArray
{
/*	if(nil == _controllerArray){
		_controllerArray = [[SGBaseCArrayWrapper alloc] initWithCapacity: kCMXPopUpWindowDefaultCapacity];
	}
	return _controllerArray;*/
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
//	unsigned					i, cnt;
	CMXPopUpWindowController	*controller_ = nil;
//	SGBaseCArrayWrapper			*array_;
	NSMutableArray	*array_= [self controllerArray];
	NSEnumerator *iter_ = [array_ objectEnumerator];
	
//	array_ = [self controllerArray];
/*	cnt = [array_ count];
	for(i = 0; i < cnt; i++){
		controller_ = SGBaseCArrayWrapperObjectAtIndex(array_, i);
		if([controller_ canPopUpWindow]){
			break;
		}
	}*/
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

//		[[self controllerArray] addObject : controller_];
		[array_ addObject: controller_];
//		[controller_ release];		
	}
	return controller_;
}

- (BOOL) isPopUpWindowVisible
{
//	unsigned					i, cnt;
	CMXPopUpWindowController	*controller_ = nil;
//	SGBaseCArrayWrapper			*array_;
	NSMutableArray *array_ = [self controllerArray];
	NSEnumerator *iter_ = [array_ objectEnumerator];
	
///	array_ = [self controllerArray];
/*	cnt = [array_ count];
	for(i = 0; i < cnt; i++){
		controller_ = SGBaseCArrayWrapperObjectAtIndex(array_, i);
		if(NO == [controller_ canPopUpWindow]) {
			return YES;
		}
	}*/
	while (controller_ = [iter_ nextObject]) {
		if (NO == [controller_ canPopUpWindow]) return YES;
	}
	return NO;
}

- (CMXPopUpWindowController *) controllerForObject : (id) object
{
//	unsigned					i, cnt;
	CMXPopUpWindowController	*controller_ = nil;
//	SGBaseCArrayWrapper			*array_;
	NSMutableArray *array_ = [self controllerArray];
	NSEnumerator *iter_ = [array_ objectEnumerator];
	
/*	array_ = [self controllerArray];
	cnt = [array_ count];
	for(i = 0; i < cnt; i++){
		id		obj_;
		
		controller_ = SGBaseCArrayWrapperObjectAtIndex(array_, i);
		obj_ = [controller_ object];
		
		if([obj_ isEqual : object])
			return controller_;
	}*/
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
	[controller_ setBackgroundColor: [self backgroundColor]];
	[controller_ setAlphaValue: [self popUpAlphaValue]];
	[controller_ setUsesAlternateTextColor: [self popUpUsesAlternateTextColor]];
	[controller_ setAlternateTextColor: [self popUpAlternateTextColor]];
	[controller_ setUsesSmallScroller: [self popUpUsesSmallScroller]];	
	[controller_ setShouldAntialias: [self popUpShouldAntialias]];
	[controller_ setLinkTextHasUnderline: [self popUpLinkTextHasUnderline]];

	[controller_ showPopUpWindowWithContext : context
					                  owner : owner
							   locationHint : point];
	return controller_;
}

- (void) closePopUpWindowForOwner : (id) owner;
{
//	unsigned					i, cnt;
	CMXPopUpWindowController	*controller_ = nil;
//	SGBaseCArrayWrapper			*array_;
	NSMutableArray *array_ = [self controllerArray];
	NSEnumerator *iter_ = [array_ objectEnumerator];
	
//	array_ = [self controllerArray];
/*	cnt = [array_ count];
	for(i = 0; i < cnt; i++){
		controller_ = SGBaseCArrayWrapperObjectAtIndex(array_, i);
		if([(id)[controller_ owner] isEqual : owner])
			[controller_ performClose];
	}*/
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
- (NSColor *) backgroundColor
{
	return [CMRPref resPopUpBackgroundColor];
}
- (float) popUpAlphaValue
{
	return [CMRPref resPopUpBgAlphaValue];
}
- (BOOL) popUpUsesSmallScroller
{
	return [CMRPref popUpWindowVerticalScrollerIsSmall];
}
- (BOOL) popUpUsesAlternateTextColor
{
	return [CMRPref isResPopUpTextDefaultColor];
}
- (NSColor *) popUpAlternateTextColor
{
	return [CMRPref resPopUpDefaultTextColor];
}
- (BOOL) popUpShouldAntialias
{
	return [CMRPref shouldThreadAntialias];
}
- (BOOL) popUpLinkTextHasUnderline
{
	return [CMRPref hasMessageAnchorUnderline];
}
@end
