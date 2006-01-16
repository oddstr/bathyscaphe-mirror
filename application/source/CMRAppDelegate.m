/**
 * $Id: CMRAppDelegate.m,v 1.17 2006/01/16 00:20:20 tsawada2 Exp $
 * 
 * CMRAppDelegate.m
 *
 * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
 * See the file LICENSE for copying permission.
 */
#import "CMRAppDelegate_p.h"
#import "CMRTaskManager.h"
#import "CMRMainMenuManager.h"
#import "BSHistoryMenuManager.h"
#import <SGAppKit/NSColor-SGExtensions.h>


@implementation CMRAppDelegate
- (void) awakeFromNib
{
    [self setupMenu];
}

#pragma mark IBAction

- (IBAction) showPreferencesPane : (id) sender
{
    [[CMRPref sharedPreferencesPane] showWindow : sender];
}
- (IBAction) showStandardFindPanel : (id) sender
{
    [[TextFinder standardTextFinder] showWindow : self];
}
- (IBAction) toggleOnlineMode : (id) sender
{    
    [NSApp sendAction : @selector(toggleOnlineMode:)
                   to : CMRPref
                 from : sender];
}
- (IBAction) showTaskInfoPanel : (id) sender
{
    [[CMRTaskManager defaultManager] showWindow : sender];
}
- (IBAction) openURL : (id) sender
{
    NSURL *url;
    
    UTILAssertRespondsTo(sender, @selector(representedObject));
    if (url = [sender representedObject]) {
        UTILAssertKindOfClass(url, NSURL);
        [[NSWorkspace sharedWorkspace] openURL : url];
    }
}

// Application Reset Alert's help button delegate
- (BOOL) alertShowHelp : (NSAlert *) alert
{
	[[NSHelpManager sharedHelpManager] openHelpAnchor : [alert helpAnchor]
											   inBook : [NSBundle applicationHelpBookName]];
	return YES;
}

- (IBAction) resetApplication : (id) sender
{
    CMRApplicationReset(self);
}

- (IBAction) openURLPanel : (id) sender
{
    [[CMROpenURLManager defaultManager] askUserURL];
}

/*- (BOOL) isOnlineMode
{
	return [CMRPref isOnlineMode];
}*/

- (IBAction) clearHistory : (id) sender
{
	[[CMRHistoryManager defaultManager] removeAllItems];
	[[BSHistoryMenuManager defaultManager] updateHistoryMenuWithMenu : [[[CMRMainMenuManager defaultManager] historyMenuItem] submenu]];
}

- (IBAction) showAcknowledgment : (id) sender
{
	NSBundle* mainBundle;
    NSString* fileName;

    mainBundle = [NSBundle mainBundle];
    fileName = [mainBundle pathForResource:@"Acknowledgments" ofType:@"rtf"];
	
    [[NSWorkspace sharedWorkspace] openFile : fileName withApplication : @"TextEdit"];
}


#pragma mark Launch Helper App

- (IBAction)launchCMLF:(id)sender
{
    [[NSWorkspace sharedWorkspace] launchApplication: [CMRPref helperAppPath]];
}

- (BOOL) validateToolbarItem : (NSToolbarItem *) theItem
{
	if ([theItem action] == @selector(launchCMLF:)) {
		NSString	*name_ = [CMRPref helperAppDisplayName];

		if (nil == name_) {
			return NO;
		} else {
			[theItem setLabel : name_];
			[theItem setPaletteLabel : name_];
			return YES;
		}
	}
	return YES;
}

- (BOOL) validateMenuItem : (NSMenuItem *) theItem
{
	if ([theItem action] == @selector(launchCMLF:)) {
		NSString	*name_ = [CMRPref helperAppDisplayName];

		if (nil == name_) {
			[theItem setTitle : [self localizedString : APP_MAINMENU_HELPER_NOTFOUND]];
			return NO;
		} else {
			[theItem setTitle : name_];
			return YES;
		}
	}
	return YES;
}
@end


@implementation CMRAppDelegate(CMRLocalizableStringsOwner)
+ (NSString *) localizableStringsTableName
{
    return APP_MAINMENU_LOCALIZABLE_FILE_NAME;
}
@end



@implementation CMRAppDelegate(NSApplicationNotifications)
- (void) applicationDidFinishLaunching : (NSNotification *) aNotification
{
	CMRMainMenuManager *tmp = [CMRMainMenuManager defaultManager];
    /* Service menu */
    [NSApp setServicesProvider : [CMROpenURLManager defaultManager]];

	/* Remove 'Open Recent' menu */
	int openURLMenuItemIndex = [[tmp fileMenu] indexOfItemWithTarget:self andAction:@selector(openURLPanel:)];

    if (openURLMenuItemIndex>=0 && [[[tmp fileMenu] itemAtIndex:openURLMenuItemIndex+1] hasSubmenu])
    {
            [[tmp fileMenu] removeItemAtIndex:openURLMenuItemIndex+1];
    }
}
@end

#define kRGBColorSpace	@"NSCalibratedRGBColorSpace"
@implementation NSApplication(ScriptingSupport)
- (BOOL) isOnlineMode
{
	return [CMRPref isOnlineMode];
}
- (void) setIsOnlineMode : (BOOL) flag
{
	[CMRPref setIsOnlineMode : flag];
}

- (NSArray *) browserTableViewColor
{
	float red,green,blue;
	
	NSColor *color_ = [CMRPref browserSTableBackgroundColor];
		
	[[color_ colorUsingColorSpaceName : kRGBColorSpace] getRed: &red green: &green blue: &blue alpha: NULL];

	return [NSArray arrayWithObjects : [NSNumber numberWithFloat:red], [NSNumber numberWithFloat:green], [NSNumber numberWithFloat:blue], nil];
}

- (void) setBrowserTableViewColor : (NSArray *) colorValue;
{
	// colorValue 配列の要素数が 0 のときは、デフォルトのカラーに戻す。
	// また、配列の要素数が 0,3 以外のときは何もしない。
	if ([colorValue count] == 0) {
		[CMRPref setBrowserSTableDrawsBackground : NO];
	} else if ([colorValue count] == 3) {
		float red,green,blue;
		red		= [[colorValue objectAtIndex : 0] floatValue];
		green	= [[colorValue objectAtIndex : 1] floatValue];
		blue	= [[colorValue objectAtIndex : 2] floatValue];
	
		if (red == 0 && green == 0 && blue == 0) {
			[CMRPref setBrowserSTableDrawsBackground : NO];
		} else {
			[CMRPref setBrowserSTableBackgroundColor : [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:1.0]];
		}
	}
}
- (NSArray *) boardListColor
{
	float red,green,blue;
	
	NSColor *color_ = [CMRPref boardListBackgroundColor];		
	[[color_ colorUsingColorSpaceName : kRGBColorSpace] getRed: &red green: &green blue: &blue alpha: NULL];

	return [NSArray arrayWithObjects : [NSNumber numberWithFloat:red], [NSNumber numberWithFloat:green], [NSNumber numberWithFloat:blue], nil];
}

- (void) setBoardListColor : (NSArray *) colorValue;
{
	// colorValue 配列の要素数が 0 のときは、デフォルトのカラーに戻す。
	// また、配列の要素数が 0,3 以外のときは何もしない。
	if ([colorValue count] == 0) {
		[CMRPref setBoardListBackgroundColor : nil];
	} else if ([colorValue count] == 3) {
		float red,green,blue;
		red		= [[colorValue objectAtIndex : 0] floatValue];
		green	= [[colorValue objectAtIndex : 1] floatValue];
		blue	= [[colorValue objectAtIndex : 2] floatValue];

		[CMRPref setBoardListBackgroundColor : [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:1.0]];
	}
}

- (NSString *) searchIgnoreChars
{
	return [CMRPref ignoreTitleCharacters];
}
- (void) setSearchIgnoreChars : (NSString *) someString
{
	[CMRPref setIgnoreTitleCharacters : someString];
}

- (BOOL) ignoreSpecificCharsOnSearch
{
	CMRSearchMask tmp_ = [CMRPref threadSearchOption];
	return (tmp_ & CMRSearchOptionIgnoreSpecified);
}

- (void) setIgnoreSpecificCharsOnSearch : (BOOL) flag;
{
	CMRSearchMask		prefOption_;		// 設定済みのオプション
	
	prefOption_ = [CMRPref threadSearchOption];

	if (flag) {
		[CMRPref setThreadSearchOption : 
			prefOption_ | CMRSearchOptionIgnoreSpecified];
	} else {
		[CMRPref setThreadSearchOption : 
			(prefOption_ & ~CMRSearchOptionIgnoreSpecified)];
	}
	
}

- (void) handleOpenURLCommand : (NSScriptCommand *) command
{
	NSURL *url_;
    CMROpenURLManager    *mgr;

	NSString *urlstr_ = nil;
	
	if(!(urlstr_ = [command directParameter]) || [urlstr_ isEqualToString:@""]) {
		return;
	}
	
	url_ = [NSURL URLWithString : urlstr_];
	
    mgr = [CMROpenURLManager defaultManager];
	[mgr openURL : url_];
}
@end