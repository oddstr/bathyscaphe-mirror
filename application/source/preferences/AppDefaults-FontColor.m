/**
  * $Id: AppDefaults-FontColor.m,v 1.19 2007/04/12 12:55:12 tsawada2 Exp $
  * BathyScaphe
  *
  * Copyright 2005 BathyScaphe Project. All rights reserved.
  *
  */

#import "AppDefaults_p.h"
#import "CMRThreadsList.h"
#import "CMRMessageAttributesTemplate.h"
#import <AppKit/NSAttributedString.h>

static NSString *const kPrefAppearanceDictKey		= @"Preferences - Fonts And Colors";

static NSString *const kPrefAntialiasKey			= @"Should Thread Antialias";
static NSString *const kPrefTextEnhancedColorKey	= @"Text Emphasis Color";
static NSString *const kPrefMessageHeadIndentKey	= @"Message Head Indent";
static NSString *const kPrefMessageAnchorHasUnderlineKey	= @"Message Anchor Underline";
static NSString *const kPrefMessageFilteredColorKey	= @"Message Filtered Color";

static NSString *const kPrefThreadsListRowHeightKey	= @"Row Height";
static NSString *const kPrefThreadsListDrawsGridKey = @"Draws Grid";
static NSString *const kPrefThreadsListColorKey		= @"ThreadsListColor";
static NSString *const kPrefThreadsListFontKey		= @"ThreadsListFont";
static NSString *const kPrefNewThreadColorKey		= @"NewThreadColor";
static NSString *const kPrefNewThreadFontKey		= @"NewThreadFont";

static NSString *const kPrefPopupAttrKey			= @"Popup scroller is small";

static NSString *const kPrefBoardListRowHeightKey	= @"BoardList Row Height";
static NSString *const kPrefBoardListBgColorKey		= @"BoardList Bg Color";
static NSString *const kPrefBoardListTextColorKey	= @"BoardList Text Color";
static NSString *const kPrefBoardListFontKey		= @"BoardList Font";
static NSString *const kPrefBoardListTextAttrKey	= @"bs_internal:BoardList Text Attributes";

static NSString *const kPrefThreadViewerMsgSpacingBeforeKey = @"Message Content Spacing (Top)";
static NSString *const kPrefThreadViewerMsgSpacingAfterKey	= @"Message Content Spacing (Bottom)";

#define	SHARED_ATTR_TEMPLATE	[CMRMessageAttributesTemplate sharedTemplate]

@implementation AppDefaults(FontColorPrivate)
- (NSMutableDictionary *) appearances
{
	if (nil == _dictAppearance) {
		NSDictionary	*dict_ = [[self defaults] dictionaryForKey : kPrefAppearanceDictKey];

		if (nil == dict_) {
			_dictAppearance = [[NSMutableDictionary alloc] init];
		} else {
			_dictAppearance = [dict_ mutableCopy];
		}
	}

	return _dictAppearance;
}

/*** Font ***/
- (NSFont *) appearanceFontForKey : (NSString *) key
{
	NSMutableDictionary		*mdict_;
	NSFont					*font_;
	
	mdict_ = [self appearances];
	font_ = [mdict_ objectForKey : key];

	if (nil == font_)
		return nil;

	if (NO == [font_ isKindOfClass : [NSFont class]]) {
		/* convert */
		font_ = [mdict_ fontForKey : key];
		[mdict_ setNoneNil : font_ forKey : key];
	}

	return font_;
}

- (NSFont *) appearanceFontForKey : (NSString *) key
					  defaultSize : (float     ) fontSize
{
	NSFont		*font_;
	font_ = [self appearanceFontForKey : key];
	return (font_) ? font_ : [NSFont controlContentFontOfSize : fontSize];
}

- (NSFont *) appearanceFontCleaningForKey : (NSString *) key
					  defaultSize : (float     ) fontSize
{
	NSFont		*font_;
	font_ = [self appearanceFontForKey : key];
	if (font_) {
		[[self appearances] removeObjectForKey: key];
		return font_;
	} else {
		return [NSFont controlContentFontOfSize : fontSize];
	}
}

- (void) setAppearanceFont : (NSFont   *) aFont
					forKey : (NSString *) key;
{
	if (nil == key) 
		return;
	if (nil == aFont)
		[[self appearances] removeObjectForKey : key];
	else
		[[self appearances] setObject : aFont forKey : key];
}

/*** Color ***/
- (NSColor *) appearanceColorForKey : (NSString *) key
{
	NSMutableDictionary		*mdict_;
	NSColor					*color_;
	
	mdict_ = [self appearances];
	color_ = [mdict_ objectForKey : key];
	if (nil == color_)
		return nil;
	
	if (NO == [color_ isKindOfClass : [NSColor class]]) {
		/* convert */
		color_ = [mdict_ colorForKey : key];
		[mdict_ setNoneNil : color_ forKey : key];
	}

	return color_;
}

- (NSColor *) textAppearanceColorForKey : (NSString *) key
{
	NSColor		*color_;
	color_ = [self appearanceColorForKey : key];
	return (color_) ? color_ : [NSColor blackColor];
}

- (NSColor *) textAppearanceColorCleaningForKey : (NSString *) key
{
	NSColor		*color_;
	color_ = [self appearanceColorForKey : key];
	if (color_) {
		[[self appearances] removeObjectForKey: key];
		return color_;
	} else {
		return [NSColor blackColor];
	}
}

- (void) setAppearanceColor : (NSColor  *) color
					 forKey : (NSString *) key
{
	if (nil == key)
		return;
	if (nil == color)
		[[self appearances] removeObjectForKey : key];
	else
		[[self appearances] setObject : color forKey : key];
}
@end

#pragma mark -

static float getDefaultLineHeightForFont(NSFont *font_, float minValue_)
{
	/*
	2005-09-18 tsawada2 <ben-sawa@td5.so-net.ne.jp>
	NSFont の defaultLineHeightForFont: は、Mac OS X 10.4 で deprecated になったらしい。
	今のところまだ問題は出ていないが、替わりに NSLayoutManager の defaultLineHeightForFont: を
	使うべしとドキュメントにある。NSLayoutManager の defaultLineHeightForFont: は、
	Mac OS X 10.2 以降で使えるので、互換性の問題はない。よって、そちらに切り替えることにする。
	*/
	static NSLayoutManager *calculator = nil;
	float			value_;

	if (calculator == nil) {
		calculator = [[NSLayoutManager alloc] init];
	}
	value_ = [calculator defaultLineHeightForFont: font_];

	if (minValue_ != 0 && value_ < minValue_) value_ = minValue_;
	
	return value_;
}

@implementation AppDefaults(FontAndColor)
- (BOOL) shouldThreadAntialias
{
	return (PFlags.enableAntialias != 0);
}
- (void) setShouldThreadAntialias : (BOOL) flag
{
	[[self appearances] setBool : flag
						 forKey : kPrefAntialiasKey];
	PFlags.enableAntialias = flag ? 1 : 0;
	[self postLayoutSettingsUpdateNotification];
}

- (BOOL) hasMessageAnchorUnderline
{
	return [[self appearances] boolForKey : kPrefMessageAnchorHasUnderlineKey
							 defaultValue : DEFAULT_MESSAGE_ANCHOR_HAS_UNDERLINE];
}
- (void) setHasMessageAnchorUnderline : (BOOL) flag
{
	[[self appearances] setBool : flag
						 forKey : kPrefMessageAnchorHasUnderlineKey];
	[SHARED_ATTR_TEMPLATE setHasAnchorUnderline : flag];
	[self postLayoutSettingsUpdateNotification];
}

- (float) messageHeadIndent
{
	return [[self appearances] floatForKey : kPrefMessageHeadIndentKey
							  defaultValue : DEFAULT_PARAGRAPH_INDENT];
}
- (void) setMessageHeadIndent : (float) anIndent
{
	[[self appearances] setFloat : anIndent
						  forKey : kPrefMessageHeadIndentKey];
	[SHARED_ATTR_TEMPLATE setMessageHeadIndent : anIndent];
}

#pragma mark Popup
- (BOOL) popUpWindowVerticalScrollerIsSmall
{
	return [[self appearances] boolForKey : kPrefPopupAttrKey
							 defaultValue : DEFAULT_POPUP_SCROLLER_SMALL];
}
- (void) setPopUpWindowVerticalScrollerIsSmall : (BOOL) flag
{
	[[self appearances] setBool : flag
						 forKey : kPrefPopupAttrKey];
}

#pragma mark ThreadViewTheme
- (NSColor *) replyTextColor
{
	return [[self threadViewTheme] replyColor];
}

- (NSFont *) replyFont
{
	return [[self threadViewTheme] replyFont];
}

- (BOOL) isResPopUpTextDefaultColor
{
	return [[self threadViewTheme] popupUsesAlternateTextColor];
}

- (NSColor *) resPopUpDefaultTextColor
{
	return [[self threadViewTheme] popupAlternateTextColor];
}

- (NSFont *) threadsViewFont
{
	return [[self threadViewTheme] baseFont];
}

- (NSFont *) messageFont
{
	return [[self threadViewTheme] messageFont];
}

- (NSFont *) messageTitleFont
{
	return [[self threadViewTheme] titleFont];
}

- (NSColor *) threadsViewColor
{
	return [[self threadViewTheme] baseColor];
}

- (NSColor *) messageColor
{
	return [[self threadViewTheme] messageColor];
}

- (NSColor *) messageTitleColor
{
	return [[self threadViewTheme] titleColor];
}

- (NSColor *) messageNameColor
{
	return [[self threadViewTheme] nameColor];
}

- (NSColor *) messageAnchorColor
{
	return [[self threadViewTheme] linkColor];
}

- (NSFont *) messageAlternateFont
{
	return [[self threadViewTheme] AAFont];
}

- (NSFont *) messageHostFont
{
	return [[self threadViewTheme] hostFont];
}

- (NSColor *) messageHostColor
{
	return [[self threadViewTheme] hostColor];
}

- (NSFont *) messageBeProfileFont
{
	return [[self threadViewTheme] beFont];
}

- (NSFont *) messageBookmarkFont{return [[self threadViewTheme] bookmarkFont];}
- (NSColor *) messageBookmarkColor{return [[self threadViewTheme] bookmarkColor];}

#pragma mark Spam, Hilite
- (NSColor *) getMessageFilteredColor : (id) anUserData
{
	NSColor		*color_;
	
	color_ = [self appearanceColorForKey : kPrefMessageFilteredColorKey];
	if (nil == color_) {
		color_ = [NSColor brownColor];
	}
	return color_;
}
- (NSColor *) messageFilteredColor
{
	return [self getMessageFilteredColor: nil];
}
- (void) setMessageFilteredColor : (NSColor *) color
{
	[self setAppearanceColor : color forKey : kPrefMessageFilteredColorKey] ;
	[self postLayoutSettingsUpdateNotification];
}

- (NSColor *) textEnhancedColor
{
	NSColor		*color_;
	
	color_ = [self appearanceColorForKey : kPrefTextEnhancedColorKey];
	return (color_) ? color_ : [NSColor lightGrayColor];
}
- (void) setTextEnhancedColor : (NSColor *) color
{
	[self setAppearanceColor : color forKey : kPrefTextEnhancedColorKey];
	[self postLayoutSettingsUpdateNotification];
}

#pragma mark SledgeHammer Additions
- (float) msgIdxSpacingBefore
{
	// インデックスの上部余白
	return [[self appearances] floatForKey : kPrefThreadViewerMsgSpacingBeforeKey
							  defaultValue : DEFAULT_TV_IDX_SPACING_BEFORE];
}
- (void) setMsgIdxSpacingBefore : (float) aValue
{
	[[self appearances] setFloat : aValue forKey : kPrefThreadViewerMsgSpacingBeforeKey];
	[SHARED_ATTR_TEMPLATE setMessageIdxSpacingBefore : aValue
									 andSpacingAfter : [self msgIdxSpacingAfter]];
}

- (float) msgIdxSpacingAfter
{
	// インデックスの下部余白
	return [[self appearances] floatForKey : kPrefThreadViewerMsgSpacingAfterKey
							  defaultValue : DEFAULT_TV_IDX_SPACING_AFTER];
}
- (void) setMsgIdxSpacingAfter : (float) aValue
{
	[[self appearances] setFloat : aValue forKey : kPrefThreadViewerMsgSpacingAfterKey];
	[SHARED_ATTR_TEMPLATE setMessageIdxSpacingBefore : [self msgIdxSpacingBefore]
									 andSpacingAfter : aValue];
}

#pragma mark Threads List
- (float) threadsListRowHeight
{
	return [[self appearances] floatForKey : kPrefThreadsListRowHeightKey
							  defaultValue : DEFAULT_THREAD_LIST_ROW_HEIGHT];
}
- (void) setThreadsListRowHeight : (float) rowHeight
{
	[[self appearances] setFloat : rowHeight
						  forKey : kPrefThreadsListRowHeightKey];
	[self postLayoutSettingsUpdateNotification];
}

- (void) fixRowHeightToFontSize
{
	[self setThreadsListRowHeight : getDefaultLineHeightForFont([self threadsListFont], 16.0)];
}

- (BOOL) threadsListDrawsGrid
{
	return [[self appearances] boolForKey : kPrefThreadsListDrawsGridKey
							 defaultValue : DEFAULT_THREAD_LIST_DRAWSGRID];
}
- (void) setThreadsListDrawsGrid : (BOOL) flag
{
	[[self appearances]	setBool : flag
						 forKey : kPrefThreadsListDrawsGridKey];
	[self postLayoutSettingsUpdateNotification];
}

- (NSColor *) threadsListColor
{
	return [self textAppearanceColorForKey : kPrefThreadsListColorKey];
}
- (void) setThreadsListColor : (NSColor *) color
{
	[self setAppearanceColor : color forKey : kPrefThreadsListColorKey];
	[self postLayoutSettingsUpdateNotification];
}

- (NSFont *) threadsListFont
{
	return [self appearanceFontForKey : kPrefThreadsListFontKey
						  defaultSize : DEFAULT_THREADS_LIST_FONTSIZE];
}
- (void) setThreadsListFont : (NSFont *) aFont
{
	[self setAppearanceFont : aFont forKey : kPrefThreadsListFontKey];
	[self postLayoutSettingsUpdateNotification];
}

- (NSColor *) threadsListNewThreadColor
{
	NSColor		*c;
	
	c = [self appearanceColorForKey : kPrefNewThreadColorKey];
	return (nil == c) ? [NSColor redColor] : c;
}
- (void) setThreadsListNewThreadColor : (NSColor *) color
{
	[self setAppearanceColor : color forKey : kPrefNewThreadColorKey];
	[self postLayoutSettingsUpdateNotification];
}

- (NSFont *) threadsListNewThreadFont
{
	return [self appearanceFontForKey : kPrefNewThreadFontKey
					      defaultSize : DEFAULT_THREADS_LIST_FONTSIZE];
}
- (void) setThreadsListNewThreadFont : (NSFont *) aFont
{
	[self setAppearanceFont : aFont forKey : kPrefNewThreadFontKey];
	[self postLayoutSettingsUpdateNotification];
}

#pragma mark BoardList
- (NSDictionary *) boardListTextAttributes // Available in Starlight Breaker.
{
	id	obj = [[self appearances] objectForKey: kPrefBoardListTextAttrKey];
	if (obj == nil) {
		NSDictionary *attrDict;
		attrDict = [NSDictionary dictionaryWithObjectsAndKeys: [CMRPref boardListFont], NSFontAttributeName,
															   [CMRPref boardListTextColor], NSForegroundColorAttributeName,
															   NULL];
		[[self appearances] setObject: attrDict forKey: kPrefBoardListTextAttrKey];
		return attrDict;
	} else {
		return obj;
	}
}

- (void) resetBoardListTextAttributes
{
	[[self appearances] removeObjectForKey: kPrefBoardListTextAttrKey];
}

- (float) boardListRowHeight
{
	return [[self appearances] floatForKey : kPrefBoardListRowHeightKey
							  defaultValue : DEFAULT_BOARD_LIST_ROW_HEIGHT];
}
- (void) setBoardListRowHeight : (float) rowHeight
{
	[[self appearances] setFloat : rowHeight
						  forKey : kPrefBoardListRowHeightKey];

	[self postLayoutSettingsUpdateNotification];
}

- (void) fixBoardListRowHeightToFontSize
{
	[self setBoardListRowHeight : getDefaultLineHeightForFont([self boardListFont], 18.0)];
}

- (NSFont *) boardListFont
{
	return [self appearanceFontForKey : kPrefBoardListFontKey
						  defaultSize : DEFAULT_BOARD_LIST_FONTSIZE];
}
- (void) setBoardListFont : (NSFont *) font
{
	[self setAppearanceFont : font forKey : kPrefBoardListFontKey];
	[self resetBoardListTextAttributes];
	[self postLayoutSettingsUpdateNotification];
}

- (NSColor *) boardListTextColor
{
	NSColor		*c;
	
	c = [self appearanceColorForKey : kPrefBoardListTextColorKey];
	return (nil == c) ? [NSColor blackColor] : c;
}
- (void) setBoardListTextColor : (NSColor *) color
{
	[self setAppearanceColor : color forKey : kPrefBoardListTextColorKey];
	[self resetBoardListTextAttributes];
	[self postLayoutSettingsUpdateNotification];
}

#pragma mark -
- (void) _loadFontAndColor
{
	[self setShouldThreadAntialias : [[self appearances] boolForKey : kPrefAntialiasKey
													   defaultValue : DEFAULT_SHOULD_THREAD_ANTIALIAS]];
}
- (BOOL) _saveFontAndColor
{
	NSMutableDictionary	*mdict;
	NSMutableDictionary	*mResult;
	NSEnumerator		*keyEnum;
	id					key;
	
	mdict = [self appearances];
	[mdict removeObjectForKey: kPrefBoardListTextAttrKey];
	mResult = [mdict mutableCopy];
	UTILAssertNotNil(mdict);
	
	/* Font, Color をプロパティリスト形式に変換 */
	keyEnum = [mdict keyEnumerator];
	while (key = [keyEnum nextObject]) {
		id		v = [mdict objectForKey : key];
		
		if ([v isKindOfClass : [NSFont class]])
			[mResult setFont : v forKey : key];
		else if ([v isKindOfClass : [NSColor class]])
			[mResult setColor : v forKey : key];
	}
	
	[[self defaults] setObject : mResult
						forKey : kPrefAppearanceDictKey];
	[mResult release];
	return YES;
}
@end
