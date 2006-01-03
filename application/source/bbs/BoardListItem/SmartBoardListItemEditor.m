//
//  SmartBoardListItemEditor.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/12/27.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "SmartBoardListItemEditor.h"


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

NSInvocation *checkMethodSignature(id obj, SEL selector)
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
		////
		
		
		/////
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

// windowWillClose: で[self cancel:self]を呼ぶと、[NSWindow close] が呼ばれるため無限ループに陥る。
- (BOOL)windowShouldClose:(id)sender
{
	[self cancel:self];
	return YES;
}

@end
