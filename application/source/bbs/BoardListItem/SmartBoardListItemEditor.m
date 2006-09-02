//
//  SmartBoardListItemEditor.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/12/27.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "SmartBoardListItemEditor.h"

#import "BoardManager.h"

@implementation SmartBoardListItemEditor

+ (id) editor
{
	return [[self alloc] init];
}

- (id) init
{
	if(self = [super init]) {
		[NSBundle loadNibNamed : @"SmartBoardItemEditor"
						 owner : self];
	}
	
	return self;
}
- (void) dealloc
{
	[mInvocation release];
	
	[super dealloc];
}

static inline NSInvocation *checkMethodSignature(id obj, SEL selector)
{
	NSInvocation *result = nil;
	NSMethodSignature *sig;
	const char *argType;
	
	if(!obj || !selector) return nil;
	
	sig = [obj methodSignatureForSelector:selector];
	if(!sig) return nil;
	
	if(4 != [sig numberOfArguments]) return nil;
	
	argType = [sig getArgumentTypeAtIndex:2];
	if(argType[0] != '@') return nil;
	
	argType = [sig getArgumentTypeAtIndex:3];
	switch(argType[0]) {
		case '@': // id型
		case '^': // ポインタ型
		case '[': // 配列型
		case ':': // SEL型
		case '#': // Class型
		case '*': // char*型
			break;
		case '?': // 不明な型。関数ポインタの可能性あり。
			break;
		default:
			return nil;
	}
	
	result = [NSInvocation invocationWithMethodSignature:sig];
	if(!result) return nil;
	
	[result setTarget:obj];
	[result setSelector:selector];
	
	return result;
}

- (NSString *)newItemName
{
	NSString *result = NSLocalizedString(@"New SmartBoard", @"New SmartBoard");
	SmartBoardList *bl = [[BoardManager defaultManager] userList];
	id item;
	
	item = [bl itemForName:result];
	if(!item) {
		return result;
	}
	
	unsigned i;
	for(i = 2; i < UINT_MAX; i++) {
		result = [[NSString alloc] initWithFormat:NSLocalizedString(@"New SmartBoard %u", @"New SmartBoard %u"), i];
		if(![bl itemForName:result]) {
			break;
		}
		[result release];
		result = nil;
	}
	
	return result;
}

- (void) cretateFromUIWindow : (NSWindow *)inModalForWindow
					delegate : (id)delegate
			 settingSelector : (SEL)settingSelector
					userInfo : (void *)contextInfo
{
	mInvocation = checkMethodSignature(delegate, settingSelector);
	if(delegate && settingSelector && !mInvocation) {
		NSLog(@"settingSelector misssmatch.");
		return;
	}
	if(mInvocation) {
		[mInvocation setArgument:&contextInfo atIndex:3];
		[mInvocation retain];
	}
	
	[nameField setStringValue:[self newItemName]];
	if(inModalForWindow) {
		[NSApp beginSheet:editorWindow
		   modalForWindow:inModalForWindow
			modalDelegate:self
		   didEndSelector:@selector(endSelector:returnCode:contextInfo:)
			  contextInfo:NULL];
	} else {
		[editorWindow makeKeyAndOrderFront:self];
	}
}
- (void)endSelector:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)context
{
	id newItem = nil;
	
	if(sheet != editorWindow) return;
	
	[editorWindow orderOut:self];
	if(returnCode) {
		newItem = [BoardListItem baordListItemWithName:[nameField stringValue]
											 condition:[helper condition]];
	}
	
	if(mInvocation) {
		[mInvocation setArgument:&newItem atIndex:2];
		[mInvocation invoke];
	}
	
	[editorWindow close];
	[self autorelease];
}

- (void) ok : (id)sender
{
	if([editorWindow isSheet]) {
		[NSApp endSheet : editorWindow returnCode : NSOKButton];
	} else {
		[self endSelector:editorWindow returnCode:NSOKButton contextInfo:NULL];
	}
}
- (void) cancel : (id) sender
{
	if([editorWindow isSheet]) {
		[NSApp endSheet : editorWindow returnCode : NSCancelButton];
	} else {
		[self endSelector:editorWindow returnCode:NSCancelButton contextInfo:NULL];
	}
}

- (void)editWithUIWindow : (NSWindow *)inModalForWindow
		  smartBoardItem : (BoardListItem *)smartBoardItem
{
	[nameField setStringValue:[smartBoardItem name]];
	[helper buildHelperFromCondition:[smartBoardItem condition]];
	if(inModalForWindow) {
		[NSApp beginSheet:editorWindow
		   modalForWindow:inModalForWindow
			modalDelegate:self
		   didEndSelector:@selector(endEditSelector:returnCode:contextInfo:)
			  contextInfo:smartBoardItem];
	} else {
		[editorWindow makeKeyAndOrderFront:self];
	}
	
}

// windowWillClose: で[self cancel:self]を呼ぶと、[NSWindow close] が呼ばれるため無限ループに陥る。
- (BOOL)windowShouldClose:(id)sender
{
	[self cancel:self];
	return YES;
}

@end
