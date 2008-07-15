//
//  BSImagePreviewInspector-Settings.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/11/12.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSImagePreviewInspector.h"
#import <SGFoundation/NSDictionary-SGExtensions.h>
#import <SGFoundation/NSMutableDictionary-SGExtensions.h>
#import <CocoMonar/CocoMonar.h>

static NSString *const kIPIAlwaysKeyWindowKey	= @"jp.tsawada2.BathyScaphe.ImagePreviewer:Always Key Window";
static NSString *const kIPISaveDirectoryKey		= @"jp.tsawada2.BathyScaphe.ImagePreviewer:Save Directory";
static NSString *const kIPIAlphaValueKey		= @"jp.tsawada2.BathyScaphe.ImagePreviewer:Window Alpha Value";
static NSString *const kIPIOpaqueWhenKeyWindowKey = @"jp.tsawada2.BathyScaphe.ImagePreviewer:Opaque When Key Window";
static NSString *const kIPIResetWhenHideWindowKey = @"jp.tsawada2.BathyScaphe.ImagePreviewer:Reset When Hide Window";
static NSString *const kIPIFloatingWindowKey	= @"jp.tsawada2.BathyScaphe.ImagePreviewer:Floating Window";
static NSString *const kIPIPreferredViewTypeKey = @"jp.tsawada2.BathyScaphe.ImagePreviewer:Preferred View";
static NSString *const kIPILastShownViewTagKey	= @"jp.tsawada2.BathyScaphe.ImagePreviewer:Last Shown View";
//static NSString *const kIPIRedirBehaviorKey		= @"jp.tsawada2.BathyScaphe.ImagePreviewer:Redirection Behavior";
static NSString *const kIPILeaveFailedTokenKey	= @"jp.tsawada2.BathyScaphe.ImagePreviewer:Leave Failed Tokens";
static NSString *const kIPIFullScreenWheelAmountKey = @"jp.tsawada2.BathyScaphe.ImagePreviewer:FullScreen Wheel Amount";
static NSString *const kIPIUseIKSlideShowOnLeopardKey = @"jp.tsawada2.BathyScaphe.ImagePreviewer:Use IKSlideShow On Leopard";
static NSString *const kIPIFullScreenBgColorKey = @"jp.tsawada2.BathyScaphe.ImagePreviewer:FullScreen Bg Color";
static NSString *const kIPIAttachFinderCommentKey = @"jp.tsawada2.BathyScaphe.ImagePreviewer:Attach Finder Comment";


@implementation BSImagePreviewInspector(Settings)
- (NSMutableDictionary *)prefsDict
{
	return [[self preferences] imagePreviewerPrefsDict];
}

- (BOOL)alwaysBecomeKey
{
	return [[self prefsDict] boolForKey:kIPIAlwaysKeyWindowKey defaultValue:YES];
}

- (void)setAlwaysBecomeKey:(BOOL)alwaysKey
{
	[[self prefsDict] setBool:alwaysKey forKey:kIPIAlwaysKeyWindowKey];
	[(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded:!alwaysKey];
}

- (NSString *)saveDirectory
{
	return [[self prefsDict] objectForKey:kIPISaveDirectoryKey defaultObject:[[CMRFileManager defaultManager] userDomainDownloadsFolderPath]];
}

- (void)setSaveDirectory:(NSString *)aString
{
	[[self prefsDict] setObject:aString forKey:kIPISaveDirectoryKey];
}

- (float)alphaValue
{
	return [[self prefsDict] floatForKey:kIPIAlphaValueKey defaultValue:1.0];
}

- (void)setAlphaValue:(float)newValue
{
	[[self prefsDict] setFloat:newValue forKey:kIPIAlphaValueKey];
	[[self window] setAlphaValue:newValue];
}

- (BOOL)opaqueWhenKey
{
	return [[self prefsDict] boolForKey:kIPIOpaqueWhenKeyWindowKey defaultValue:NO];
}

- (void)setOpaqueWhenKey:(BOOL)opaqueWhenKey
{
	[[self prefsDict] setBool:opaqueWhenKey forKey:kIPIOpaqueWhenKeyWindowKey];
}

- (BOOL)resetWhenHide
{
	return [[self prefsDict] boolForKey:kIPIResetWhenHideWindowKey defaultValue:NO];
}

- (void)setResetWhenHide:(BOOL)reset
{
	[[self prefsDict] setBool:reset forKey:kIPIResetWhenHideWindowKey];
}

- (BOOL)floating
{
	return [[self prefsDict] boolForKey:kIPIFloatingWindowKey defaultValue:YES];
}

- (void)setFloating:(BOOL)floatOrNot
{
	[[self prefsDict] setBool:floatOrNot forKey:kIPIFloatingWindowKey];
	[(NSPanel *)[self window] setFloatingPanel:floatOrNot];
}

- (int)preferredView
{
	return [[self prefsDict] integerForKey:kIPIPreferredViewTypeKey defaultValue:0];
}

- (void)setPreferredView:(int)aType
{
	[[self prefsDict] setInteger:aType forKey:kIPIPreferredViewTypeKey];
}

- (int)lastShownViewTag
{
	return [[self prefsDict] integerForKey:kIPILastShownViewTagKey defaultValue:0];
}

- (void)setLastShownViewTag:(int)aTag
{
	[[self prefsDict] setInteger:aTag forKey:kIPILastShownViewTagKey];
}
/*
- (BSIPIRedirectionBehavior)redirectionBehavior
{
	return [[self prefsDict] integerForKey:kIPIRedirBehaviorKey defaultValue:BSIPIAlwaysAsk];
}

- (void)setRedirectionBehavior:(BSIPIRedirectionBehavior)aTag
{
	[[self prefsDict] setInteger:aTag forKey:kIPIRedirBehaviorKey];
}*/

- (BOOL)leaveFailedToken
{
	return [[self prefsDict] boolForKey:kIPILeaveFailedTokenKey defaultValue:NO];
}

- (void)setLeaveFailedToken:(BOOL)leave
{
	[[self prefsDict] setBool:leave forKey:kIPILeaveFailedTokenKey];
}

- (float)fullScreenWheelAmount
{
	return [[self prefsDict] floatForKey:kIPIFullScreenWheelAmountKey defaultValue:0.5];
}

- (void)setFullScreenWheelAmount:(float)floatValue
{
	[[self prefsDict] setFloat:floatValue forKey:kIPIFullScreenWheelAmountKey];
}

- (BOOL)useIKSlideShowOnLeopard
{
	if (floor(NSAppKitVersionNumber) <= 824) return NO;
	return [[self prefsDict] boolForKey:kIPIUseIKSlideShowOnLeopardKey defaultValue:NO];
}

- (void)setUseIKSlideShowOnLeopard:(BOOL)flag
{
	[[self prefsDict] setBool:flag forKey:kIPIUseIKSlideShowOnLeopardKey];
}

- (NSData *)fullScreenBgColorData
{
	return [[self prefsDict] objectForKey:kIPIFullScreenBgColorKey defaultObject:[NSArchiver archivedDataWithRootObject:[NSColor blackColor]]];
}

- (void)setFullScreenBgColorData:(NSData *)aColorData
{
	[[self prefsDict] setObject:aColorData forKey:kIPIFullScreenBgColorKey];
}

- (BOOL)attachFinderComment
{
	return [[self prefsDict] boolForKey:kIPIAttachFinderCommentKey defaultValue:NO];
}

- (void)setAttachFinderComment:(BOOL)flag
{
	[[self prefsDict] setBool:flag forKey:kIPIAttachFinderCommentKey];
}
@end
