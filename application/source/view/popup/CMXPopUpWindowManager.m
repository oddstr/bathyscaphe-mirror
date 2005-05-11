//: CMXPopUpWindowManager.m
/**
  * $Id: CMXPopUpWindowManager.m,v 1.1 2005/05/11 17:51:09 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "CMXPopUpWindowManager.h"
#import "CocoMonar_Prefix.h"
#import "CMXPopUpWindowController.h"
#import "CMXPreferences.h"
#import "CMRPopUpTemplateKeys.h"



@implementation CMXPopUpWindowManager
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(defaultManager);

- (void) dealloc
{
	[_controllerArray release];
	[super dealloc];
}
- (SGBaseCArrayWrapper *) controllerArray
{
	if(nil == _controllerArray){
		_controllerArray = 
			[[SGBaseCArrayWrapper alloc] 
				initWithCapacity : kCMXPopUpWindowDefaultCapacity];
	}
	return _controllerArray;
}
- (CMXPopUpWindowController *) availableController
{
	unsigned					i, cnt;
	CMXPopUpWindowController	*controller_ = nil;
	SGBaseCArrayWrapper			*array_;
	
	array_ = [self controllerArray];
	cnt = [array_ count];
	for(i = 0; i < cnt; i++){
		controller_ = SGBaseCArrayWrapperObjectAtIndex(array_, i);
		if([controller_ canPopUpWindow]){
			break;
		}
	}
	
	if(nil == controller_ || (NO == [controller_ canPopUpWindow])){
		// 
		// ‚·‚×‚ÄŽg—p’†
		// 
		controller_ = [[CMXPopUpWindowController alloc] init];
		[controller_ window];
		[controller_ setBackgroundColor : [self backgroundColor]];
		[controller_ setIsSeeThrough : [self isSeeThrough]];
		[[self controllerArray] addObject : controller_];
		[controller_ release];
		
	}
	return controller_;
}


- (BOOL) isPopUpWindowVisible
{
	unsigned					i, cnt;
	CMXPopUpWindowController	*controller_ = nil;
	SGBaseCArrayWrapper			*array_;
	
	array_ = [self controllerArray];
	cnt = [array_ count];
	for(i = 0; i < cnt; i++){
		controller_ = SGBaseCArrayWrapperObjectAtIndex(array_, i);
		if(NO == [controller_ canPopUpWindow]){
			return YES;
		}
	}
	return NO;
}


- (CMXPopUpWindowController *) controllerForObject : (id) object
{
	unsigned					i, cnt;
	CMXPopUpWindowController	*controller_ = nil;
	SGBaseCArrayWrapper			*array_;
	
	array_ = [self controllerArray];
	cnt = [array_ count];
	for(i = 0; i < cnt; i++){
		id		obj_;
		
		controller_ = SGBaseCArrayWrapperObjectAtIndex(array_, i);
		obj_ = [controller_ object];
		
		if([obj_ isEqual : object])
			return controller_;
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

- (id) showPopUpWindowWithContext : (NSAttributedString *) context
                        forObject : (id                  ) object
                            owner : (id                  ) owner
                     locationHint : (NSPoint             ) point
{
	CMXPopUpWindowController	*controller_;
	
	UTILAssertNotNilArgument(context, @"context");
	controller_ = [self availableController];
	[controller_ setObject : object];
	[controller_ setBackgroundColor : [self backgroundColor]];
	[controller_ setIsSeeThrough : [self isSeeThrough]];
	
	[controller_ showPopUpWindowWithContext : context
					                  owner : owner
							   locationHint : point];
	return controller_;
}

- (void) closePopUpWindowForOwner : (id) owner;
{
	unsigned					i, cnt;
	CMXPopUpWindowController	*controller_ = nil;
	SGBaseCArrayWrapper			*array_;
	
	array_ = [self controllerArray];
	cnt = [array_ count];
	for(i = 0; i < cnt; i++){
		controller_ = SGBaseCArrayWrapperObjectAtIndex(array_, i);
		if([(id)[controller_ owner] isEqual : owner])
			[controller_ performClose];
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



- (NSColor *) backgroundColor
{
	return [CMRPref resPopUpBackgroundColor];
}
- (BOOL) isSeeThrough
{
	return [CMRPref isResPopUpSeeThrough];
}
@end
