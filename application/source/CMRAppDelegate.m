/**
 * $Id: CMRAppDelegate.m,v 1.7 2005/06/26 13:07:30 tsawada2 Exp $
 * 
 * CMRAppDelegate.m
 *
 * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
 * See the file LICENSE for copying permission.
 */
#import "CMRAppDelegate_p.h"
#import "AboutPanelController.h"
#import "CMRTaskManager.h"
#import <SGAppKit/NSColor-SGExtensions.h>



//:CMRAppDelegate+Menu.m
@interface CMRAppDelegate(MenuSetup)
- (void) setupMenu;
@end


@implementation CMRAppDelegate
- (void) awakeFromNib
{
    [self setupMenu];
}
- (IBAction) showBoardListEditor : (id) sender
{
    [[CMRPref sharedBoardListEditor] showWindow : sender];
}
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

- (IBAction) resetApplication : (id) sender
{
    CMRApplicationReset();
}

- (IBAction) openURLPanel : (id) sender
{
    CMROpenURLManager    *mgr;
    
    mgr = [CMROpenURLManager defaultManager];
    [mgr askUserURL];
}

- (IBAction) orderFrontCustomAboutPanel: (id) sender
{
	    [[AboutPanelController sharedInstance] showPanel];
}

- (IBAction)launchCMLF:(id)sender
{
    [[NSWorkspace sharedWorkspace] launchApplication: [CMRPref helperAppPath]];
}

- (BOOL) validateToolbarItem : (NSToolbarItem *) theItem
{
	if ([theItem action] == @selector(launchCMLF:)) {
		NSString	*name_ = [CMRPref helperAppPath];

		if (nil == name_) {
			return NO;
		} else {
			[theItem setLabel : [[name_ stringByDeletingPathExtension] lastPathComponent]];
			return YES;
		}
	}

	return YES;
}

- (BOOL) isOnlineMode
{
	return [CMRPref isOnlineMode];
}
@end



@implementation CMRAppDelegate(CMRLocalizableStringsOwner)
+ (NSString *) localizableStringsTableName
{
    return APP_MAINMENU_LOCALIZABLE_FILE_NAME;
}
@end



@implementation CMRAppDelegate(NSApplicationNotifications)
//- (void) applicationWillFinishLaunching : (NSNotification *)notification
//{
//}
- (void) applicationDidFinishLaunching : (NSNotification *) aNotification
{
    /* Service menu */
    [NSApp setServicesProvider : [CMROpenURLManager defaultManager]];

	/* Remove 'Open Recent' menu */
	int openURLMenuItemIndex = [fileMenu indexOfItemWithTarget:self andAction:@selector(openURLPanel:)];

    if (openURLMenuItemIndex>=0 && [[fileMenu itemAtIndex:openURLMenuItemIndex+1] hasSubmenu])
    {
            [fileMenu removeItemAtIndex:openURLMenuItemIndex+1];
    }
}
@end

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
	//NSString *colorName_ = [color_ colorSpaceName];
		
	[[color_ colorUsingColorSpaceName : @"NSCalibratedRGBColorSpace"] getRed: &red green: &green blue: &blue alpha: NULL];

	return [NSArray arrayWithObjects : [NSNumber numberWithFloat:red], [NSNumber numberWithFloat:green], [NSNumber numberWithFloat:blue], nil];
}

- (void) setBrowserTableViewColor : (NSArray *) colorValue;
{
	float red,green,blue;
	red = [[colorValue objectAtIndex : 0] floatValue];
	green = [[colorValue objectAtIndex : 1] floatValue];
	blue = [[colorValue objectAtIndex : 2] floatValue];
	
	if (red == 0 && green == 0 && blue == 0) {
		[CMRPref setBrowserSTableDrawsBackground : NO];
	} else {
		[CMRPref setBrowserSTableBackgroundColor : [NSColor colorWithCalibratedRed:red
															 green:green
															  blue:blue
															 alpha:1.0]];
	}
}
- (NSArray *) boardListColor
{
	float red,green,blue;
	
	NSColor *color_ = [CMRPref boardListBgColor];
		
	[[color_ colorUsingColorSpaceName : @"NSCalibratedRGBColorSpace"] getRed: &red green: &green blue: &blue alpha: NULL];

	return [NSArray arrayWithObjects : [NSNumber numberWithFloat:red], [NSNumber numberWithFloat:green], [NSNumber numberWithFloat:blue], nil];
}

- (void) setBoardListColor : (NSArray *) colorValue;
{
	float red,green,blue;
	red = [[colorValue objectAtIndex : 0] floatValue];
	green = [[colorValue objectAtIndex : 1] floatValue];
	blue = [[colorValue objectAtIndex : 2] floatValue];
	
	[CMRPref setBoardListBgColor : [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:1.0]];
}

- (void) handleOpenURLCommand : (NSScriptCommand *) command
{
	NSURL *url_;
    CMROpenURLManager    *mgr;

	NSString *urlstr_ = nil;
	
	if(!(urlstr_ = [command directParameter]) || [urlstr_ isEqualToString:@""]) {
		return;
	}
	//NSLog(@"%@", urlstr_);
	
	url_ = [NSURL URLWithString : urlstr_];
	
    mgr = [CMROpenURLManager defaultManager];
	[mgr openURL : url_];
}
@end