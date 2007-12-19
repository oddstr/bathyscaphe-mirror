//
//  NSApplication+BSScriptingSupport.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/12/15.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//

#import "NSApplication+BSScriptingSupport.h"
#import "AppDefaults.h"
#import "CMRPreferencesDefautValues.h"

#import "CMROpenURLManager.h"
#import "CMRTrashBox.h"

static NSString *const kRGBColorSpace = @"NSCalibratedRGBColorSpace";

@implementation NSApplication(BSScriptingSupport)
- (BOOL)isOnlineMode
{
	return [CMRPref isOnlineMode];
}

- (void)setIsOnlineMode:(BOOL)flag
{
	[CMRPref setIsOnlineMode:flag];
}

static inline NSArray *RGBArrayForColor(NSColor *color)
{
	float red,green,blue;

	if (!color) {
		red = 0.0;
		green = 0.0;
		blue = 0.0;
	} else {
		[[color colorUsingColorSpaceName:kRGBColorSpace] getRed:&red green:&green blue:&blue alpha:NULL];
	}
	return [NSArray arrayWithObjects:[NSNumber numberWithFloat:red], [NSNumber numberWithFloat:green], [NSNumber numberWithFloat:blue], nil];
}

static inline NSColor *colorFromRGBArray(NSArray *array, NSColor *defaultColor)
{
	// 配列の要素数が 0 のときは、デフォルトのカラーに戻す。
	// また、配列の要素数が 0,3 以外のときは何もしない。
	if (!array || [array count] == 0) {
		return defaultColor;
	} else if ([array count] == 3) {
		float red,green,blue;
		red		= [[array objectAtIndex:0] floatValue];
		green	= [[array objectAtIndex:1] floatValue];
		blue	= [[array objectAtIndex:2] floatValue];
	
		return [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:1.0];
	}
	return nil;
}

- (NSArray *)browserTableViewColor
{
	return RGBArrayForColor([CMRPref threadsListBackgroundColor]);
}

- (void)setBrowserTableViewColor:(NSArray *)array
{
	NSColor *color = colorFromRGBArray(array, [NSColor whiteColor]);
	if (color) {
		[CMRPref setThreadsListBackgroundColor:color];
	}
}

- (NSArray *)boardListColor
{
	return RGBArrayForColor([CMRPref boardListBackgroundColor]);		
}

- (void)setBoardListColor:(NSArray *)array
{
	NSColor *color = colorFromRGBArray(array, DEFAULT_BOARD_LIST_BG_COLOR);
	if (color) {
		[CMRPref setBoardListBackgroundColor:color];
	}
}

- (NSArray *)boardListNonActiveColor
{
	return RGBArrayForColor([CMRPref boardListNonActiveBgColor]);		
}

- (void)setBoardListNonActiveColor:(NSArray *)array
{
	NSColor *color = colorFromRGBArray(array, DEFAULT_BOARD_LIST_NONACTIVE_BG_COLOR);
	if (color) {
		[CMRPref setBoardListNonActiveBgColor:color];
	}
}

#pragma mark NSScriptCommand
- (void)handleOpenURLCommand:(NSScriptCommand *)command
{
	NSURL		*url_;
	NSString	*urlstr_ = [command directParameter];
	
	if (!urlstr_ || [urlstr_ isEqualToString:@""]) return;
	
	url_ = [NSURL URLWithString:urlstr_];	
	[[CMROpenURLManager defaultManager] openLocation:url_];
}

- (void)handleRemoveFromDBCommand:(NSScriptCommand *)command
{
	NSString *filePath_ = [command directParameter];
	if (!filePath_ || [filePath_ isEqualToString:@""]) return;

	NSNumber *number = [NSNumber numberWithInt:noErr];
	NSNotification *notification = [NSNotification notificationWithName:CMRTrashboxDidPerformNotification
																 object:[CMRTrashbox trash]
															   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:number, kAppTrashUserInfoStatusKey,
																							[NSArray arrayWithObject:filePath_], kAppTrashUserInfoFilesKey,
																							[NSNumber numberWithBool:YES], kAppTrashUserInfoAfterFetchKey,
																							NULL]];
	if (notification) [[NSNotificationCenter defaultCenter] postNotification:notification];
}
@end
