/**
 * $Id: CMRAppDelegate.m,v 1.14.2.4 2006/09/01 13:46:54 masakih Exp $
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
#import <SGAppKit/NSImage-SGExtensions.h>

#define kOnlineItemKey				@"On Line"
#define kOfflineItemKey				@"Off Line"
#define kOnlineItemImageName		@"online"
#define kOfflineItemImageName		@"offline"

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

- (IBAction) togglePreviewPanel : (id) sender
{
	BOOL	result_;
	result_ = [NSApp sendAction : @selector(togglePreviewPanel:)
							 to : [CMRPref sharedImagePreviewer]
						   from : sender];

	if(NO == result_) NSLog(@"togglePreviewPanel: fail to send action.");
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

- (IBAction) clearHistory : (id) sender
{
	[[CMRHistoryManager defaultManager] removeAllItems];
	[[BSHistoryMenuManager defaultManager] updateHistoryMenuWithMenu : [[[CMRMainMenuManager defaultManager] historyMenuItem] submenu]];
}

- (IBAction) showAcknowledgment : (id) sender
{
	NSBundle	*mainBundle;
    NSString	*fileName;
	NSString	*appName;
	NSWorkspace	*ws = [NSWorkspace sharedWorkspace];

    mainBundle = [NSBundle mainBundle];
    fileName = [mainBundle pathForResource : @"Acknowledgments" ofType : @"rtf"];
	appName = [ws absolutePathForAppBundleWithIdentifier : @"com.apple.TextEdit"];
	
    [ws openFile : fileName withApplication : appName];
}

- (IBAction) closeAll : (id) sender
{
	//この方法では「BathyScaphe について」パネルなどが閉じられない（Safari では閉じてくれる！）
	//NSArray	*array_ = [NSApp orderedWindows];
	//if (array_ == nil || [array_ count] == 0) return;
	
	//[array_ makeObjectsPerformSelector : @selector(performClose:)
	//						withObject : sender];
	
	//この方法だと概ね良い感じだが、makeWindowsPerform:inOrder: を使って発信するセレクタは "Can’t take any arguments"
	//であり、performClose: を使って良いのかどうかやや不安。（close を呼ぶ手もあるが、それもまたちょっと…）
	[NSApp makeWindowsPerform : @selector(performClose:) inOrder : YES];
}

- (IBAction) miniaturizeAll : (id) sender
{
	[NSApp miniaturizeAll : sender];
}

- (IBAction) launchCMLF : (id) sender
{
    [[NSWorkspace sharedWorkspace] launchApplication: [CMRPref helperAppPath]];
}

- (IBAction) runBoardWarrior: (id) sender
{
	NSBundle* mainBundle;
    NSString* fileName;

    mainBundle = [NSBundle mainBundle];
    fileName = [mainBundle pathForResource:@"BWAgent" ofType:@"app"];
	
    [[NSWorkspace sharedWorkspace] launchApplication:fileName];
}

#pragma mark validation
- (BOOL) validateToolbarItem : (NSToolbarItem *) theItem
{
	SEL action_ = [theItem action];
	if (action_ == @selector(launchCMLF:)) {
		NSString	*name_ = [CMRPref helperAppDisplayName];

		if (nil == name_) {
			return NO;
		} else {
			[theItem setLabel : name_];
			[theItem setPaletteLabel : name_];
			return YES;
		}
	}

	if (action_ == @selector(toggleOnlineMode:)) {
		NSString		*title_;
		NSImage			*image_;
		
		title_ = [CMRPref isOnlineMode]
					? [self localizedString : kOnlineItemKey]
					: [self localizedString : kOfflineItemKey];

		image_ = [CMRPref isOnlineMode]
					? [NSImage imageAppNamed : kOnlineItemImageName]
					: [NSImage imageAppNamed : kOfflineItemImageName];
		
		[theItem setImage : image_];
		[theItem setLabel : title_];
		return YES;
	}

	return YES;
}

- (BOOL) validateMenuItem : (NSMenuItem *) theItem
{
	SEL action_ = [theItem action];

	if (action_ == @selector(launchCMLF:)) {
		NSString	*name_ = [CMRPref helperAppDisplayName];

		if (nil == name_) {
			[theItem setTitle : [self localizedString : APP_MAINMENU_HELPER_NOTFOUND]];
			return NO;
		} else {
			[theItem setTitle : name_];
			return YES;
		}
	} else if (action_ == @selector(closeAll:)) {
		return ([NSApp makeWindowsPerform : @selector(isVisible) inOrder : YES] != nil);
	} else if (action_ == @selector(miniaturizeAll:)) {
		return ([NSApp makeWindowsPerform : @selector(isNotMiniaturizedButCanMinimize) inOrder : YES] != nil);
	} else if (action_ == @selector(togglePreviewPanel:)) {
		id tmp_ = [CMRPref sharedImagePreviewer]; // WARNING が出るだろうけど気にせず…
		return [tmp_ respondsToSelector : @selector(togglePreviewPanel:)];
	}
	return YES;
}

#pragma mark AppleEvent Support
// Available in BathyScaphe 1.2 and later.
- (void) handleGetURLEvent : (NSAppleEventDescriptor *) event withReplyEvent : (NSAppleEventDescriptor *) replyEvent
{
    NSString	*urlStr_;
    NSURL		*url_;

    urlStr_ = [[event paramDescriptorForKeyword : keyDirectObject] stringValue];
	url_ = [NSURL URLWithString : urlStr_];

	// scheme の違い（bathyscaphe: or http:）は CMROpenURLManager が吸収する
    [[CMROpenURLManager defaultManager] openLocation : url_];
}

#pragma mark NSApplication Delegates
- (void) applicationWillFinishLaunching : (NSNotification *) aNotification
// available in BathyScaphe 1.2 and later.
{
	NSAppleEventManager	*aeMgr = [NSAppleEventManager sharedAppleEventManager];
	
	[aeMgr setEventHandler : self
			   andSelector : @selector(handleGetURLEvent:withReplyEvent:)
			 forEventClass : 'GURL'
				andEventID : 'GURL']; // 'GURL' is different from 'gurl'
}

- (void) applicationDidFinishLaunching : (NSNotification *) aNotification
{
	CMRMainMenuManager *tmp = [CMRMainMenuManager defaultManager];
    /* Service menu */
    [NSApp setServicesProvider : [CMROpenURLManager defaultManager]];

	/* Remove 'Open Recent' menu */
	int openURLMenuItemIndex = [[tmp fileMenu] indexOfItemWithTarget : self andAction : @selector(openURLPanel:)];

    if (openURLMenuItemIndex >= 0 && [[[tmp fileMenu] itemAtIndex : openURLMenuItemIndex+1] hasSubmenu])
    {
            [[tmp fileMenu] removeItemAtIndex : openURLMenuItemIndex+1];
    }
}
@end


@implementation CMRAppDelegate(CMRLocalizableStringsOwner)
+ (NSString *) localizableStringsTableName
{
    return APP_MAINMENU_LOCALIZABLE_FILE_NAME;
}
@end

#pragma mark -

@implementation NSWindow(BSAddition)
- (BOOL) isNotMiniaturizedButCanMinimize
{
	// 最小化されていない、かつ、最小化可能であるウインドウである場合に YES を返す。
	// 最小化不可能なウインドウでは常に NO を返す。
	if (NO == ([self styleMask] & NSMiniaturizableWindowMask)) return NO;
	return (NO == [self isMiniaturized]);
}
@end

#pragma mark -

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

- (void) handleOpenURLCommand : (NSScriptCommand *) command
{
	NSURL		*url_;
	NSString	*urlstr_ = [command directParameter];
	
	if(!urlstr_ || [urlstr_ isEqualToString : @""])
		return;
	
	url_ = [NSURL URLWithString : urlstr_];	
	[[CMROpenURLManager defaultManager] openLocation : url_];
}
@end
