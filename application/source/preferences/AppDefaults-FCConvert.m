//
// AppDefaults-FCConvert.m
// BathyScaphe
//
// Written by Tsutomu Sawada on 04/12/07.
// Copyright 2007 BathyScaphe Project. All rights reserved.
// encoding="UTF-8"
//

#import "AppDefaults_p.h"

static NSString *const kPrefReplyColorKey			= @"Reply Text Color"; // Deprecated in Starlight Breaker.
static NSString *const kPrefReplyFontKey			= @"Reply Text Font"; // Deprecated in Starlight Breaker.
static NSString *const kPrefThreadsViewFontKey		= @"TextFont"; // Deprecated in Starlight Breaker.
static NSString *const kPrefThreadsViewColorKey		= @"TextColor"; // Deprecated in Starlight Breaker.
static NSString *const kPrefResPopUpDefaultTextColorKey		= @"Res PopUp Default Text-Color"; // Deprecated in Starlight Breaker.
static NSString *const kPrefIsResPopUpTextDefaultColorKey	= @"Res PopUp uses Default Text-Color"; // Deprecated in Starlight Breaker.

static NSString *const kPrefMessageColorKey			= @"Message Contents Color"; // Deprecated in Starlight Breaker.
static NSString *const kPrefMessageFontKey			= @"Message Contents Font"; // Deprecated in Starlight Breaker.
static NSString *const kPrefMessageAlternateFontKey	= @"Message Alternate Font"; // Deprecated in Starlight Breaker.
static NSString *const kPrefMessageTitleColorKey	= @"Message Item Color"; // Deprecated in Starlight Breaker.
static NSString *const kPrefMessageTitleFontKey		= @"Message Item Font"; // Deprecated in Starlight Breaker.
static NSString *const kPrefMessageNameColorKey		= @"Message Name Color"; // Deprecated in Starlight Breaker.
static NSString *const kPrefMessageAnchorColorKey	= @"Message Anchor Color"; // Deprecated in Starlight Breaker.

static NSString *const kPrefMessageHostColorKey			= @"Message Host Color"; // Deprecated in Starlight Breaker.
static NSString *const kPrefMessageHostFontKey			= @"Message Host Font"; // Deprecated in Starlight Breaker.
static NSString *const kPrefMessageBeProfileFontKey		= @"Message BeProfileLink Font"; // Deprecated in Starlight Breaker.

static NSString *const kImportedThemeFileNameKey = @"ImportedTheme.plist";

@implementation AppDefaults(ConvertOldSettingsToThemeFile)
- (void) convertFontSettingsToTheme: (BSThreadViewTheme *) theme
{
	NSLog(@"Converting font settings...");
	NSFont *tmpFont;

	tmpFont = [self appearanceFontCleaningForKey: kPrefMessageBeProfileFontKey defaultSize: DEFAULT_BEPROFILELINK_FONTSIZE];
	[theme setBeFont: tmpFont];
	tmpFont = [self appearanceFontCleaningForKey: kPrefMessageHostFontKey defaultSize: DEFAULT_HOST_FONTSIZE];
	[theme setHostFont: tmpFont];
	tmpFont = [self appearanceFontCleaningForKey: kPrefMessageAlternateFontKey defaultSize: DEFAULT_THREADS_VIEW_FONTSIZE];
	[theme setAAFont: tmpFont];
	tmpFont = [self appearanceFontCleaningForKey: kPrefMessageTitleFontKey defaultSize: DEFAULT_THREADS_VIEW_FONTSIZE];
	[theme setTitleFont: tmpFont];
	tmpFont = [self appearanceFontCleaningForKey: kPrefMessageFontKey defaultSize: DEFAULT_THREADS_VIEW_FONTSIZE];
	[theme setMessageFont: tmpFont];
	[theme setBookmarkFont: tmpFont];
	tmpFont = [self appearanceFontCleaningForKey: kPrefThreadsViewFontKey defaultSize: DEFAULT_THREADS_VIEW_FONTSIZE];
	[theme setBaseFont: tmpFont];
	tmpFont = [self appearanceFontCleaningForKey: kPrefReplyFontKey defaultSize: DEFAULT_REPLY_FONTSIZE];
	[theme setReplyFont: tmpFont];
}

- (NSColor *) appearanceColorCleaningIfNeededForKey: (NSString *) key defaultColor: (NSColor *) color
{
	if (!key) return nil;
	NSColor *resultColor = [self appearanceColorForKey: key];
	if (resultColor) {
		[[self appearances] removeObjectForKey: key];
		return resultColor;
	}
	return color;
}

- (void) convertColorSettingsToTheme: (BSThreadViewTheme *) theme
{
	NSLog(@"Converting color settings...");
	NSColor *tmpColor;

	tmpColor = [self textAppearanceColorCleaningForKey : kPrefThreadsViewColorKey];
	[theme setBaseColor: tmpColor];
	tmpColor = [self textAppearanceColorCleaningForKey : kPrefMessageColorKey];
	[theme setMessageColor: tmpColor];
	[theme setBookmarkColor: tmpColor];

	tmpColor = [self appearanceColorCleaningIfNeededForKey: kPrefMessageNameColorKey defaultColor: OLD_DEFAULT_MESSAGE_NAME_COLOR];
	[theme setNameColor: tmpColor];

	tmpColor = [self appearanceColorCleaningIfNeededForKey: kPrefMessageTitleColorKey defaultColor: OLD_DEFAULT_MESSAGE_TITLE_COLOR];
	[theme setTitleColor: tmpColor];

	tmpColor = [self appearanceColorCleaningIfNeededForKey: kPrefMessageAnchorColorKey defaultColor: [NSColor blueColor]];
	[theme setLinkColor: tmpColor];

	tmpColor = [self appearanceColorCleaningIfNeededForKey: kPrefMessageHostColorKey defaultColor: [NSColor lightGrayColor]];
	[theme setHostColor: tmpColor];

	tmpColor = [self appearanceColorCleaningIfNeededForKey: kPrefReplyColorKey defaultColor: [NSColor blackColor]];
	[theme setReplyColor: tmpColor];

	tmpColor = [self appearanceColorCleaningIfNeededForKey: kPrefResPopUpDefaultTextColorKey defaultColor: [NSColor blackColor]];
	[theme setPopupAlternateTextColor: tmpColor];
}

- (void) convertBgColorSettingsToTheme: (BSThreadViewTheme *) theme
{
	NSLog(@"Converting bg color");
	NSDictionary	*dict2_ = [[self defaults] dictionaryForKey: AppDefaultsBackgroundsKey];
	if (!dict2_) {
		[theme setBackgroundColor: [NSColor whiteColor]];
		[theme setReplyBackgroundColorIgnoringAlpha: [NSColor whiteColor]];
		[theme setReplyBackgroundAlphaValue: DEFAULT_REPLY_BG_ALPHA];
		[theme setPopupBackgroundColorIgnoringAlpha: DEFAULT_POPUP_BG_COLOR];
		[theme setPopupBackgroundAlphaValue: DEFAULT_POPUP_BG_ALPHA];
		[theme setPopupUsesAlternateTextColor: DEFAULT_IS_RESPOPUP_TEXT_COLOR];
		return;
	}
	NSMutableDictionary *dict3_ = [dict2_ mutableCopy];

	NSColor *tmpColor;
	float tmpFloat;

	tmpColor = [dict2_ colorForKey: @"Thread Viewer BackgroundColor"];
	if (!tmpColor) {
		tmpColor = [NSColor whiteColor];
	} else {
		[dict3_ removeObjectForKey: @"Thread Viewer BackgroundColor"];
	}
	[theme setBackgroundColor: tmpColor];

	tmpColor = [dict2_ colorForKey: @"Reply Window BackgroundColor"];
	if (!tmpColor) {
		tmpColor = [NSColor whiteColor];
	} else {
		[dict3_ removeObjectForKey: @"Reply Window BackgroundColor"];
	}
	[theme setReplyBackgroundColorIgnoringAlpha: tmpColor];

	tmpColor = [dict2_ colorForKey: @"Res PopUp Background"];
	if (!tmpColor) {
		tmpColor = DEFAULT_POPUP_BG_COLOR;
	} else {
		[dict3_ removeObjectForKey: @"Res PopUp Background"];
	}
	[theme setPopupBackgroundColorIgnoringAlpha: tmpColor];

	tmpFloat = [dict2_ floatForKey: @"Res PopUp Bg Alpha Value"];
	if (tmpFloat <= 0) {
		tmpFloat = DEFAULT_POPUP_BG_ALPHA;
	} else {
		[dict3_ removeObjectForKey: @"Res PopUp Bg Alpha Value"];
	}
	[theme setPopupBackgroundAlphaValue: tmpFloat];
	
	tmpFloat = [dict2_ floatForKey: @"Reply Window Bg Alpha Value"];
	if (tmpFloat <= 0) {
		tmpFloat = DEFAULT_REPLY_BG_ALPHA;
	} else {
		[dict3_ removeObjectForKey: @"Reply Window Bg Alpha Value"];
	}
	[theme setReplyBackgroundAlphaValue: tmpFloat];
	
	[[self defaults] setObject: dict3_ forKey: AppDefaultsBackgroundsKey];
	[dict3_ release];
}

- (void) convertOldFCToThemeFile
{
	NSDictionary	*dict_ = [[self defaults] dictionaryForKey : @"Preferences - Fonts And Colors"];
	if (!dict_) {
		[[self defaults] setBool: YES forKey: AppDefaultsOldFontsAndColorsConvertedKey];
		return;
	}

	BSThreadViewTheme *tmp = [[BSThreadViewTheme alloc] initWithIdentifier: NSLocalizedString(@"Imported From Old Ver.", @"")];

	[self convertFontSettingsToTheme: tmp];
	[self convertColorSettingsToTheme: tmp];
	[self convertBgColorSettingsToTheme: tmp];
	[tmp setPopupUsesAlternateTextColor: [dict_ boolForKey: kPrefIsResPopUpTextDefaultColorKey]];

	[tmp writeToFile: [self createFullPathFromThemeFileName: kImportedThemeFileNameKey] atomically: YES];
	[tmp release];
	[[self defaults] setBool: YES forKey: AppDefaultsOldFontsAndColorsConvertedKey];
	[[self defaults] setObject: kImportedThemeFileNameKey forKey: @"ThreadViewTheme FileName"];

	NSLog(@"Convert finished");
}
@end