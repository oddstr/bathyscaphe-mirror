//:TextFinder-ViewAccessor.m
#import "AppDefaults.h"
#import "TextFinder_p.h"

@implementation TextFinder(ViewAccessor)
/* Accessor for _findTextField */
- (NSTextField *) findTextField
{
	return _findTextField;
}

/* Accessor for _buttonMatrix */
- (NSMatrix *) buttonMatrix
{
	return _buttonMatrix;
}

/* Accessor for _optionMatrix */
- (NSMatrix *) optionMatrix
{
	return _optionMatrix;
}

//////////////////////////////////////////////////////////////////////
//////////////////// [ インスタンスメソッド ] ////////////////////////
//////////////////////////////////////////////////////////////////////
/* Working with pasteboards */
- (NSString *) loadFindStringFromPasteboard
{
	NSPasteboard *pasteboard;

	pasteboard = [NSPasteboard pasteboardWithName : NSFindPboard];
	
	if ([[pasteboard types] containsObject : NSStringPboardType])
		return [pasteboard stringForType : NSStringPboardType];
	
	return nil;
}

- (void) setFindStringToPasteboard
{
	NSPasteboard *pasteboard;
	
	pasteboard = [NSPasteboard pasteboardWithName : NSFindPboard];
	if ([[[self findTextField] stringValue] length] > 0) {
		NSArray *types_;
		
		types_ = [NSArray arrayWithObject : NSStringPboardType];
		
		[pasteboard declareTypes : types_
						   owner : nil];
		[pasteboard setString : [[self findTextField] stringValue] 
					  forType : NSStringPboardType];
	}
}

- (CMRSearchMask) loadSearchOptionFromUserDefaults
{
	return [CMRPref contentsSearchOption];
}

- (void) setupUIComponents
{
	NSString		*s;		// from Pasteboard
	CMRSearchMask	option;
	
	s = [self loadFindStringFromPasteboard];
	if (s != nil) {
		[[self findTextField] setStringValue : s];
	}
	option = [self loadSearchOptionFromUserDefaults];
	[self setSearchOption : option];

	[[self findTextField] setDelegate : self];
    [[self window] setFrameAutosaveName : APP_FIND_PANEL_AUTOSAVE_NAME];
	[self updateComponents : nil];
}

- (void) updateButtonEnabled
{
	NSString	*stringValue_;
	NSCell		*linkOnlyCell_;
	BOOL		isEnabled_;
	
	stringValue_ = [[self findTextField] stringValue];
	linkOnlyCell_ = [[self optionMatrix] cellWithTag : kInLinkOptionBtnTag];
	
	if (NSOnState == [linkOnlyCell_ state])
		isEnabled_ = YES;
	else
		isEnabled_ = ([stringValue_ length] > 0);
	
	[[self buttonMatrix] setEnabled : isEnabled_];
}

//////////////////////////////////////////////////////////////////////
/////////////////// [ 他オブジェクトのDelegate] //////////////////////
//////////////////////////////////////////////////////////////////////

- (void) controlTextDidChange : (NSNotification *) aNotification
{
	NSString *name_;
	
	name_ = [aNotification name];
	
	if ([name_ isEqualToString : NSControlTextDidChangeNotification]) {
		[self updateButtonEnabled];
		// 検索文字列をペーストボードに設定する。
		[self setFindStringToPasteboard];
	}
}

@end