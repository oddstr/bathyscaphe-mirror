/**
  * $Id: CMRNoNameManager.m,v 1.1.1.1 2005/05/11 17:51:05 tsawada2 Exp $
  * 
  * CMRNoNameManager.m
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
#import "CMRNoNameManager.h"
#import "CocoMonar_Prefix.h"
#import "CMRBBSSignature.h"
#import "AppDefaults.h"
#import <Cocoa/Cocoa.h>

/* .nib file name */
#define kNoNameInputControllerNib	@"CMRNoNameInput"

/* constants */
// NND means 'NoNameDict'.
static NSString *const NNDNoNameKey = @"NoName";
static NSString *const NNDSortColumnKey = @"SortColumn";
static NSString *const NNDIsAscendingKey = @"IsAscending";

#pragma mark -

/* Input Panel */
@interface NoNameInputController : NSWindowController
{
	IBOutlet NSTextField	*_messageField;
	IBOutlet NSTextField	*_textField;
}
- (NSString *) askUserAboutDefaultNoNameForBoard : (CMRBBSSignature *) aBoard
									 presetValue : (NSString        *) aValue;
- (IBAction) ok : (id) sender;
- (IBAction) cancel : (id) sender;
@end


@implementation NoNameInputController
- (id) init
{
	return [self initWithWindowNibName : kNoNameInputControllerNib];
}
- (IBAction) ok : (id) sender { [NSApp stopModalWithCode : NSOKButton]; }
- (IBAction) cancel : (id) sender { [NSApp stopModalWithCode : NSCancelButton]; }

- (NSString *) askUserAboutDefaultNoNameForBoard : (CMRBBSSignature *) aBoard
									 presetValue : (NSString        *) aValue
{
	NSString		*s = nil;
	int				code;
	
	[self window];
	
	UTILAssertNotNil([aBoard name]);
	
	s = [_messageField stringValue];
	s = [NSString stringWithFormat : s, [aBoard name]];
	[_messageField setStringValue : s];
	
	[_textField setStringValue : aValue ? aValue : @""];
	
	code = [NSApp runModalForWindow : [self window]];
	
	[[self window] close];
	return (NSOKButton == code)
			? [[[_textField stringValue] copy] autorelease]
			: nil;
}
@end

#pragma mark -

@implementation CMRNoNameManager
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(defaultManager);

+ (NSString *) defaultFilepath
{
	return [[CMRFileManager defaultManager]
				 supportFilepathWithName : CMRNoNamesFile
						resolvingFileRef : NULL];
}

- (id) init
{
	if (self = [super init]) {
		[[NSNotificationCenter defaultCenter]
				 addObserver : self
					selector : @selector(applicationWillTerminate:)
					    name : NSApplicationWillTerminateNotification
					  object : NSApp];
	}
	return self;
}
- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver : self];
	[_noNameDict release];
	[super dealloc];
}

- (NSDictionary *) noNameDict
{
	if (nil == _noNameDict) {
		_noNameDict = [[NSDictionary alloc] initWithContentsOfFile : 
										[[self class] defaultFilepath]];
	}
	if (nil == _noNameDict) {
		_noNameDict = [[NSDictionary empty] copy];
	}
	
	return _noNameDict;
}
- (void) setNoNameDict : (NSDictionary *) aNoNameDict
{
	id		tmp;
	
	tmp = _noNameDict;
	_noNameDict = [aNoNameDict copyWithZone : [self zone]];
	[tmp release];
}

#pragma mark -

- (id) entryForBoardName : (CMRBBSSignature *) aBoard
{
	return [[self noNameDict] objectForKey : [aBoard name]];
}

/* –¼–³‚µ‚³‚ñ‚Ì–¼‘O */
- (NSString *) defauoltNoNameForBoard : (CMRBBSSignature *) aBoard
{
	id entry_;
	
	entry_ = [self entryForBoardName : aBoard];

	if ([entry_ isKindOfClass : [NSString class]]) {
		return [[self noNameDict] stringForKey : [aBoard name]];
	} else if ([entry_ isKindOfClass : [NSDictionary class]]) {
		return [entry_ stringForKey : NNDNoNameKey];
	} else {
		return nil;
	}
}
- (void) setDefaultNoName : (NSString        *) aName
			 	 forBoard : (CMRBBSSignature *) aBoard
{
	NSMutableDictionary		*mdict_;
	id entry_;
	
	UTILAssertNotNil(aName);
	UTILAssertNotNil(aBoard);
	
	entry_ = [self entryForBoardName : aBoard];
	
	mdict_ = [[self noNameDict] mutableCopyWithZone : [self zone]];
	if(entry_ == nil || [entry_ isKindOfClass : [NSString class]]) {
		[mdict_ setObject : [NSDictionary dictionaryWithObject : aName forKey : NNDNoNameKey]
				   forKey : [aBoard name]];
	} else {
		NSMutableDictionary		*mutableEntry_;
		
		mutableEntry_ = [entry_ mutableCopy];
		[mutableEntry_ setObject : aName forKey : NNDNoNameKey];
		
		[mdict_ setObject : mutableEntry_ forKey : [aBoard name]];
		[mutableEntry_ release];
	}
	[self setNoNameDict : mdict_];
	[mdict_ release];
}

- (NSString *) sortColumnForBoard : (CMRBBSSignature *) aBoard
{
	id entry_;
	NSString	*str_;
	
	entry_ = [self entryForBoardName : aBoard];

	if ([entry_ isKindOfClass : [NSDictionary class]]) {
		str_ = [entry_ stringForKey : NNDSortColumnKey];
	} else {
		str_ = nil;
	}
	
	if (str_ == nil) str_ = [CMRPref browserSortColumnIdentifier];
	return str_;
}

- (void) setSortColumn : (NSString        *) anIdentifier
			  forBoard : (CMRBBSSignature *) aBoard
{
	NSMutableDictionary		*mdict_;
	id entry_;
	
	UTILAssertNotNil(anIdentifier);
	UTILAssertNotNil(aBoard);
	
	entry_ = [self entryForBoardName : aBoard];
	
	mdict_ = [[self noNameDict] mutableCopyWithZone : [self zone]];
	if(entry_ == nil || [entry_ isKindOfClass : [NSString class]]) {
		NSArray	*tempObjects, *tempKeys;
		
		if (entry_ != nil) {
			tempObjects = [NSArray arrayWithObjects : entry_, anIdentifier, nil];
			tempKeys	= [NSArray arrayWithObjects : NNDNoNameKey, NNDSortColumnKey, nil];
		} else {
			tempObjects = [NSArray arrayWithObjects : anIdentifier, nil];
			tempKeys	= [NSArray arrayWithObjects : NNDSortColumnKey, nil];
		}
		[mdict_ setObject : [NSDictionary dictionaryWithObjects : tempObjects forKeys : tempKeys]
				   forKey : [aBoard name]];
	} else {
		NSMutableDictionary		*mutableEntry_;
		mutableEntry_ = [entry_ mutableCopy];
		[mutableEntry_ setObject : anIdentifier forKey : NNDSortColumnKey];
		
		[mdict_ setObject : mutableEntry_ forKey : [aBoard name]];
		[mutableEntry_ release];
	}
	[self setNoNameDict : mdict_];
	[mdict_ release];
}


- (BOOL)  sortColumnIsAscendingAtBoard : (CMRBBSSignature *) aBoard
{
	id entry_;
	
	entry_ = [self entryForBoardName : aBoard];

	if ([entry_ isKindOfClass : [NSString class]]) {
		return [CMRPref browserSortAscending];
	} else if ([entry_ isKindOfClass : [NSDictionary class]]) {
		if ([[entry_ allKeys] containsObject : NNDIsAscendingKey]) {
			return [entry_ boolForKey : NNDIsAscendingKey];
		} else {
			return [CMRPref browserSortAscending];
		}
	} else {
		return [CMRPref browserSortAscending];
	}
}

- (void) setSortColumnIsAscending : (BOOL			  ) TorF
						  atBoard : (CMRBBSSignature *) aBoard;
{
	NSMutableDictionary		*mdict_;
	id entry_;
	
	UTILAssertNotNil(aBoard);
	
	entry_ = [self entryForBoardName : aBoard];
	
	mdict_ = [[self noNameDict] mutableCopyWithZone : [self zone]];
	if(entry_ == nil || [entry_ isKindOfClass : [NSString class]]) {
		NSArray	*tempObjects, *tempKeys;
		
		if (entry_ != nil) {
			tempObjects = [NSArray arrayWithObjects : entry_, [NSNumber numberWithBool : TorF], nil];
			tempKeys	= [NSArray arrayWithObjects : NNDNoNameKey, NNDIsAscendingKey, nil];
		} else {
			tempObjects = [NSArray arrayWithObjects : [NSNumber numberWithBool : TorF], nil];
			tempKeys	= [NSArray arrayWithObjects : NNDIsAscendingKey, nil];
		}
		[mdict_ setObject : [NSDictionary dictionaryWithObjects : tempObjects forKeys : tempKeys]
				   forKey : [aBoard name]];
	} else {
		NSMutableDictionary		*mutableEntry_;
		mutableEntry_ = [entry_ mutableCopy];
		[mutableEntry_ setBool : TorF forKey : NNDIsAscendingKey];
		
		[mdict_ setObject : mutableEntry_ forKey : [aBoard name]];
		[mutableEntry_ release];
	}
	[self setNoNameDict : mdict_];
	[mdict_ release];
}

#pragma mark -

- (void) applicationWillTerminate : (NSNotification *) notification
{	
	UTILAssertNotificationName(
		notification,
		NSApplicationWillTerminateNotification);
	UTILAssertNotificationObject(
		notification,
		NSApp);
	
	
	[[self noNameDict] writeToFile : [[self class] defaultFilepath]
						atomically : YES];
}
- (NSString *) askUserAboutDefaultNoNameForBoard : (CMRBBSSignature *) aBoard
									 presetValue : (NSString        *) aValue
{
	NoNameInputController	*controller_;
	NSString				*v;
	
	controller_ = [[NoNameInputController alloc] init];
	v = [controller_ askUserAboutDefaultNoNameForBoard:aBoard presetValue:aValue];
	
	if (v != nil) {
		[self setDefaultNoName:v forBoard:aBoard];
	}
	[controller_ release];
	
	return v;
}
@end
