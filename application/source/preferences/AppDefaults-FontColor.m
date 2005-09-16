/**
  * $Id: AppDefaults-FontColor.m,v 1.7 2005/09/16 01:18:29 tsawada2 Exp $
  * 
  * AppDefaults-FontColor.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "AppDefaults_p.h"
#import "CMRThreadsList.h"
#import "CMRMessageAttributesTemplate.h"
#import <AppKit/NSAttributedString.h>

static NSString *const kPrefAppearanceDictKey		= @"Preferences - Fonts And Colors";

static NSString *const kPrefReplyColorKey			= @"Reply Text Color";
static NSString *const kPrefReplyFontKey			= @"Reply Text Font";
static NSString *const kPrefAntialiasKey			= @"Should Thread Antialias";
static NSString *const kPrefThreadsViewFontKey		= @"TextFont";
static NSString *const kPrefThreadsViewColorKey		= @"TextColor";
static NSString *const kPrefTextEnhancedColorKey	= @"Text Emphasis Color";
static NSString *const kPrefResPopUpDefaultTextColorKey = @"Res PopUp Default Text-Color";
static NSString *const kPrefIsResPopUpTextDefaultColorKey = @"Res PopUp uses Default Text-Color";
static NSString *const kPrefMessageHeadIndentKey	= @"Message Head Indent";
static NSString *const kPrefMessageColorKey			= @"Message Contents Color";
static NSString *const kPrefMessageFontKey			= @"Message Contents Font";
static NSString *const kPrefMessageAlternateFontKey	= @"Message Alternate Font";
static NSString *const kPrefMessageTitleColorKey	= @"Message Item Color";
static NSString *const kPrefMessageTitleFontKey		= @"Message Item Font";
static NSString *const kPrefMessageNameColorKey		= @"Message Name Color";
static NSString *const kPrefMessageAnchorColorKey	= @"Message Anchor Color";
static NSString *const kPrefMessageAnchorHasUnderlineKey = @"Message Anchor Underline";
static NSString *const kPrefMessageFilteredColorKey	= @"Message Filtered Color";
static NSString *const kPrefThreadsListRowHeightKey	= @"Row Height";
static NSString *const kPrefThreadsListIntercellSpacingKey = @"Intercell Spacing";
static NSString *const kPrefThreadsListDrawsGridKey = @"Draws Grid";
static NSString *const kPrefThreadsListColorKey		= @"ThreadsListColor";
static NSString *const kPrefThreadsListFontKey		= @"ThreadsListFont";
static NSString *const kPrefNewThreadColorKey		= @"NewThreadColor";
static NSString *const kPrefNewThreadFontKey		= @"NewThreadFont";

static NSString *const kPrefMessageHostColorKey			= @"Message Host Color";
static NSString *const kPrefMessageHostFontKey			= @"Message Host Font";
static NSString *const kPrefMessageBeProfileFontKey		= @"Message BeProfileLink Font";

static NSString *const kPrefPopupAttrKey			= @"Popup scroller is small";

static NSString *const kPrefBoardListRowHeightKey	= @"BoardList Row Height";
static NSString *const kPrefBoardListBgColorKey		= @"BoardList Bg Color";
static NSString *const kPrefBoardListTextColorKey	= @"BoardList Text Color";
static NSString *const kPrefBoardListFontKey		= @"BoardList Font";

static NSString *const kPrefThreadViewerMsgSpacingBeforeKey = @"Message Content Spacing (Top)";
static NSString *const kPrefThreadViewerMsgSpacingAfterKey = @"Message Content Spacing (Bottom)";

//:AppDefaults-FontColor.m
@interface AppDefaults(FontColorPrivate)
- (NSMutableDictionary *) appearances;

- (NSFont *) appearanceFontForKey : (NSString *) key;
- (void) setAppearanceFont : (NSFont   *) aFont
					forKey : (NSString *) key;
- (NSColor *) appearanceColorForKey : (NSString *) key;
- (void) setAppearanceColor : (NSColor  *) color
					 forKey : (NSString *) key;

/* return default aFont if nil. */
- (NSFont *) appearanceFontForKey : (NSString *) key
					  defaultSize : (float     ) fontSize;
- (NSColor *) textAppearanceColorForKey : (NSString *) key;
@end

@implementation AppDefaults(FontColorPrivate)
- (NSMutableDictionary *) appearances
{
	if (nil == _dictAppearance) {
		NSDictionary	*dict_;
		
		dict_ = [[self defaults] dictionaryForKey : kPrefAppearanceDictKey];
		_dictAppearance = [dict_ mutableCopy];
		if (nil == _dictAppearance)
			_dictAppearance = [[NSMutableDictionary alloc] init];
	}
	
	return _dictAppearance;
}

/*** Font ***/
- (NSFont *) appearanceFontForKey : (NSString *) key
{
	NSMutableDictionary		*mdict_;
	NSFont					*font_;
	
	mdict_ = [self appearances];
	if (nil == (font_ = [mdict_ objectForKey : key]))
		return nil;
	
	if (NO == [font_ isKindOfClass : [NSFont class]]) {
		/* convert */
		font_ = [mdict_ fontForKey : key];
		[mdict_ setNoneNil:font_ forKey:key];
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
- (void) setAppearanceFont : (NSFont   *) aFont
					forKey : (NSString *) key;
{
	if (nil == key) 
		return;
	if (nil == aFont)
		[[self appearances] removeObjectForKey : key];
	else
		[[self appearances] setObject:aFont forKey:key];
}

/*** Color ***/
- (NSColor *) appearanceColorForKey : (NSString *) key
{
	NSMutableDictionary		*mdict_;
	NSColor					*color_;
	
	mdict_ = [self appearances];
	if (nil == (color_ = [mdict_ objectForKey : key]))
		return nil;
	
	if (NO == [color_ isKindOfClass : [NSColor class]]) {
		/* convert */
		color_ = [mdict_ colorForKey : key];
		[mdict_ setNoneNil:color_ forKey:key];
	}
	return color_;
}
- (NSColor *) textAppearanceColorForKey : (NSString *) key
{
	NSColor		*color_;
	
	color_ = [self appearanceColorForKey : key];
	return (color_) ? color_ : [NSColor blackColor];
}
- (void) setAppearanceColor : (NSColor  *) color
					 forKey : (NSString *) key
{
	if (nil == key) return;
	
	if (nil == color)
		[[self appearances] removeObjectForKey:key];
	else
		[[self appearances] setObject:color forKey:key];
}
@end

#pragma mark -

@implementation AppDefaults(FontAndColor)
- (CMRMessageAttributesTemplate *) _template
{
	return [CMRMessageAttributesTemplate sharedTemplate];
}

- (BOOL) shouldThreadAntialias
{
	return (PFlags.enableAntialias != 0);
}
- (void) setShouldThreadAntialias : (BOOL) flag
{
	[[self appearances]
			   setBool : flag
				forKey : kPrefAntialiasKey];
	PFlags.enableAntialias = flag ? 1 : 0;
}
- (BOOL) hasMessageAnchorUnderline
{
	return [[self appearances]
				boolForKey : kPrefMessageAnchorHasUnderlineKey
			  defaultValue : DEFAULT_MESSAGE_ANCHOR_HAS_UNDERLINE];
}
- (void) setHasMessageAnchorUnderline : (BOOL) flag
{
	[[self appearances] setBool:flag forKey:kPrefMessageAnchorHasUnderlineKey];
	[[self _template] setHasAnchorUnderline : flag];
}
- (float) messageHeadIndent
{
	return [[self appearances] 
					 floatForKey : kPrefMessageHeadIndentKey
					defaultValue : DEFAULT_PARAGRAPH_INDENT];
}
- (void) setMessageHeadIndent : (float) anIndent
{
	[[self appearances] 
				setFloat : anIndent
				  forKey : kPrefMessageHeadIndentKey];
	[[self _template] setMessageHeadIndent : anIndent];
}

#pragma mark Reply
- (NSColor *) replyTextColor
{
	return [self textAppearanceColorForKey : kPrefReplyColorKey];
}
- (void) setReplyTextColor : (NSColor *) aColor
{
	[self setAppearanceColor:aColor forKey:kPrefReplyColorKey] ;
	[self postLayoutSettingsUpdateNotification];
}
- (NSFont *) replyFont
{
	return [self appearanceFontForKey : kPrefReplyFontKey
						  defaultSize : DEFAULT_THREADS_VIEW_FONTSIZE];
}
- (void) setReplyFont : (NSFont *) aFont
{
	[self setAppearanceFont:aFont forKey:kPrefReplyFontKey];
	[self postLayoutSettingsUpdateNotification];
}

#pragma mark Popup
- (BOOL) isResPopUpTextDefaultColor
{
	return [[self appearances] 
				boolForKey : kPrefIsResPopUpTextDefaultColorKey
			  defaultValue : DEFAULT_IS_RESPOPUP_TEXT_COLOR];
}
- (void) setIsResPopUpTextDefaultColor : (BOOL) flag
{
	[[self appearances]
				setBool : flag
				 forKey : kPrefIsResPopUpTextDefaultColorKey];
}

- (NSColor *) resPopUpDefaultTextColor
{
	return [self textAppearanceColorForKey : 
					kPrefResPopUpDefaultTextColorKey];
}
- (void) setResPopUpDefaultTextColor : (NSColor *) color
{
	[self setAppearanceColor : color
						forKey : kPrefResPopUpDefaultTextColorKey] ;
}

- (BOOL) popUpWindowVerticalScrollerIsSmall
{
	return [[self appearances] boolForKey : kPrefPopupAttrKey defaultValue : YES];
}

- (void) setPopUpWindowVerticalScrollerIsSmall : (BOOL) flag
{
	[[self appearances] setBool : flag forKey : kPrefPopupAttrKey];
}

#pragma mark Thread viewer
/* 標準：色 */
- (NSColor *) getThreadsViewColor : (id) anUserData
{
	return [self textAppearanceColorForKey : 
					kPrefThreadsViewColorKey];
}
- (NSColor *) threadsViewColor
{
	return [self valueProxyForSelector:@selector(getThreadsViewColor:) key:kPrefThreadsViewColorKey];
}
- (void) setThreadsViewColor : (NSColor *) color
{
	[self setAppearanceColor:color forKey:kPrefThreadsViewColorKey] ;
	[self postLayoutSettingsUpdateNotification];
}
/* 本文：色 */
- (NSColor *) getMessageColor : (id) anUserData
{
	return [self textAppearanceColorForKey : kPrefMessageColorKey];
}
- (NSColor *) messageColor
{
	return [self valueProxyForSelector:@selector(getMessageColor:) key:kPrefMessageColorKey];
}
- (void) setMessageColor : (NSColor *) color
{
	[self setAppearanceColor:color forKey:kPrefMessageColorKey] ;
	[self postLayoutSettingsUpdateNotification];
}

/* 標準：フォント */
- (NSFont *) getThreadsViewFont : (id) anUserData
{
	return [self appearanceFontForKey : kPrefThreadsViewFontKey
					      defaultSize : DEFAULT_THREADS_VIEW_FONTSIZE];
}
- (NSFont *) threadsViewFont
{
	// return [self valueProxyForSelector:@selector(getThreadsViewFont:) key:kPrefThreadsViewFontKey];
	return [self getThreadsViewFont : kPrefThreadsViewFontKey];
}
- (void) setThreadsViewFont : (NSFont *) aFont
{
	[self setAppearanceFont:aFont forKey:kPrefThreadsViewFontKey];
	[self postLayoutSettingsUpdateNotification];
	
	[[CMRMessageAttributesTemplate sharedTemplate]
		setAttributeForText:NSFontAttributeName value:aFont];
}

/* 本文：フォント */
- (NSFont *) getMessageFont : (id) anUserData
{
	return [self appearanceFontForKey : kPrefMessageFontKey
						  defaultSize : DEFAULT_THREADS_VIEW_FONTSIZE];
}
- (NSFont *) messageFont
{
	// return [self valueProxyForSelector:@selector(getMessageFont:) key:kPrefMessageFontKey];
	return [self getMessageFont : nil];
}
- (void) setMessageFont : (NSFont *) aFont
{
	[self setAppearanceFont:aFont forKey:kPrefMessageFontKey];
	[self postLayoutSettingsUpdateNotification];
	
	[[CMRMessageAttributesTemplate sharedTemplate]
		setAttributeForMessage:NSFontAttributeName value:aFont];
}

/* 項目：フォント */
- (NSFont *) getMessageTitleFont : (id) anUserData
{
	return [self appearanceFontForKey : kPrefMessageTitleFontKey
						  defaultSize : DEFAULT_THREADS_VIEW_FONTSIZE];
}
- (NSFont *) messageTitleFont
{
	// return [self valueProxyForSelector:@selector(getMessageTitleFont:) key:kPrefMessageTitleFontKey];
	return [self getMessageTitleFont : nil];
}
- (void) setMessageTitleFont : (NSFont *) aFont
{
	[self setAppearanceFont:aFont forKey:kPrefMessageTitleFontKey];
	[self postLayoutSettingsUpdateNotification];
	[[CMRMessageAttributesTemplate sharedTemplate]
		setAttributeForTitle:NSFontAttributeName value:aFont];
}

/* 項目：色 */
- (NSColor *) getMessageTitleColor : (id) anUserData
{
	NSColor		*color_;
	
	color_ = [self appearanceColorForKey:kPrefMessageTitleColorKey];
	if (nil == color_) {
		color_ = [NSColor colorWithCalibratedRed  : 0.56f
											green : 0.0f
											blue  : 0.0f
											alpha : 1.0f];
	}
	return color_;
}
- (NSColor *) messageTitleColor
{
	return [self valueProxyForSelector:@selector(getMessageTitleColor:) key:kPrefMessageTitleColorKey];
}
- (void) setMessageTitleColor : (NSColor *) color
{
	[self setAppearanceColor:color forKey:kPrefMessageTitleColorKey] ;
	[self postLayoutSettingsUpdateNotification];
}

/* 名前：色 */
- (NSColor *) getMessageNameColor : (id) anUserData
{
	NSColor		*color_;
	
	color_ = [self appearanceColorForKey:anUserData];
	if (nil == color_) {
		color_ = [NSColor colorWithCalibratedRed  : 0.0f
											green : 0.56f
											blue  : 0.0f
											alpha : 1.0f];
	}
	return color_;
}
- (NSColor *) messageNameColor
{
	return [self valueProxyForSelector:@selector(getMessageNameColor:) key:kPrefMessageNameColorKey];
}
- (void) setMessageNameColor : (NSColor *) color
{
	[self setAppearanceColor:color forKey:kPrefMessageNameColorKey] ;
	[self postLayoutSettingsUpdateNotification];
}

/* ＡＡ：フォント */
- (NSFont *) getMessageAlternateFont : (id) anUserData
{
	return [self appearanceFontForKey : kPrefMessageAlternateFontKey
						  defaultSize : DEFAULT_THREADS_VIEW_FONTSIZE];
}
- (NSFont *) messageAlternateFont
{
	// return [self valueProxyForSelector:@selector(getMessageTitleFont:) key:kPrefMessageTitleFontKey];
	return [self getMessageAlternateFont : nil];
}
- (void) setMessageAlternateFont : (NSFont *) aFont
{
	[self setAppearanceFont:aFont forKey:kPrefMessageAlternateFontKey];
	[self postLayoutSettingsUpdateNotification];
}



/* アンカー：色 */
- (NSColor *) getMessageAnchorColor : (id) anUserData
{
	NSColor		*color_;
	
	color_ = [self appearanceColorForKey:kPrefMessageAnchorColorKey];
	if (nil == color_) {
		color_ = [NSColor blueColor];
	}
	return color_;
}
- (NSColor *) messageAnchorColor
{
	return [self valueProxyForSelector:@selector(getMessageAnchorColor:) key:kPrefMessageAnchorColorKey];
}
- (void) setMessageAnchorColor : (NSColor *) color
{
	[self setAppearanceColor:color forKey:kPrefMessageAnchorColorKey] ;
	[self postLayoutSettingsUpdateNotification];
}


/* フィルタされたレスの色 */
- (NSColor *) getMessageFilteredColor : (id) anUserData
{
	NSColor		*color_;
	
	color_ = [self appearanceColorForKey:kPrefMessageFilteredColorKey];
	if (nil == color_) {
		color_ = [NSColor brownColor];
	}
	return color_;
}
- (NSColor *) messageFilteredColor
{
	return [self valueProxyForSelector:@selector(getMessageFilteredColor:) key:kPrefMessageFilteredColorKey];
}
- (void) setMessageFilteredColor : (NSColor *) color
{
	[self setAppearanceColor:color forKey:kPrefMessageFilteredColorKey] ;
	[self postLayoutSettingsUpdateNotification];
}



// テキストの強調色
- (NSColor *) textEnhancedColor
{
	NSColor		*color_;
	
	color_ = [self appearanceColorForKey : kPrefTextEnhancedColorKey];
	return (color_) ? color_ : [NSColor lightGrayColor];
}
- (void) setTextEnhancedColor : (NSColor *) color
{
	[self setAppearanceColor:color forKey:kPrefTextEnhancedColorKey];
	// [self postLayoutSettingsUpdateNotification];
}

#pragma mark BathyScaphe 1.0.1 additions
- (NSFont *) getMessageHostFont : (id) anUserData
{
	return [self appearanceFontForKey : kPrefMessageHostFontKey
						  defaultSize : DEFAULT_HOST_FONTSIZE];
}
- (NSFont *) messageHostFont
{
	// return [self valueProxyForSelector:@selector(getMessageFont:) key:kPrefMessageFontKey];
	return [self getMessageHostFont : nil];
}
- (void) setMessageHostFont : (NSFont *) aFont
{
	[self setAppearanceFont:aFont forKey:kPrefMessageHostFontKey];
	//[self postLayoutSettingsUpdateNotification];
	
	[[CMRMessageAttributesTemplate sharedTemplate]
		setAttributeForHost:NSFontAttributeName value:aFont];
}
- (NSColor *) getMessageHostColor : (id) anUserData
{
	NSColor		*color_;
	
	color_ = [self appearanceColorForKey:anUserData];
	if (nil == color_) {
		color_ = [NSColor lightGrayColor];
	}
	return color_;
}
- (NSColor *) messageHostColor
{
	return [self valueProxyForSelector:@selector(getMessageHostColor:) key:kPrefMessageHostColorKey];
}
- (void) setMessageHostColor : (NSColor *) color
{
	[self setAppearanceColor:color forKey:kPrefMessageHostColorKey] ;
	//[self postLayoutSettingsUpdateNotification];
}
- (NSFont *) getMessageBeProfileFont : (id) anUserData
{
	return [self appearanceFontForKey : kPrefMessageBeProfileFontKey
						  defaultSize : DEFAULT_BEPROFILELINK_FONTSIZE];
}
- (NSFont *) messageBeProfileFont
{
	// return [self valueProxyForSelector:@selector(getMessageFont:) key:kPrefMessageFontKey];
	return [self getMessageBeProfileFont : nil];
}
- (void) setMessageBeProfileFont : (NSFont *) aFont
{
	[self setAppearanceFont:aFont forKey:kPrefMessageBeProfileFontKey];
	//[self postLayoutSettingsUpdateNotification];
	
	[[CMRMessageAttributesTemplate sharedTemplate]
		setAttributeForBeProfileLink:NSFontAttributeName value:aFont];
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
	[self postLayoutSettingsUpdateNotification];
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
	[self postLayoutSettingsUpdateNotification];
}

/*** スレッド一覧 ***/
#pragma mark Threads List
- (float) threadsListRowHeight
{
	return [[self appearances] 
					floatForKey : kPrefThreadsListRowHeightKey
				   defaultValue : DEFAULT_THREAD_LIST_ROW_HEIGHT];
}
- (void) setThreadsListRowHeight : (float) rowHeight
{
	[[self appearances] setFloat:rowHeight forKey:kPrefThreadsListRowHeightKey];
	[self postLayoutSettingsUpdateNotification];
}
- (void) fixRowHeightToFontSize
{
	NSFont	*listFont_;
	
	listFont_ = [self threadsListFont];
	[self setThreadsListRowHeight : [listFont_ defaultLineHeightForFont]];
}


- (NSSize) threadsListIntercellSpacing
{
	NSString		*s;
	
	s = [[self appearances] stringForKey : kPrefThreadsListIntercellSpacingKey];
	if (nil == s)
		return DEFAULT_THREAD_LIST_INTERCELL_SPACING;
	
	return NSSizeFromString(s);
}
- (void) setThreadsListIntercellSpacing : (NSSize) space
{
	[[self appearances]
			setSize : space
			 forKey : kPrefThreadsListIntercellSpacingKey];
	[self postLayoutSettingsUpdateNotification];
}
- (void) setThreadsListRowHeightNum : (NSNumber *) rowHeight
{
	UTILAssertNotNilArgument(rowHeight, @"rowHeight");
	[self setThreadsListRowHeight : [rowHeight floatValue]];
}
- (void) setThreadsListIntercellSpacingHeight : (NSNumber *) height
{
	float		height_;
	NSSize		newSize_;
	
	UTILAssertNotNilArgument(height, @"height");
	
	height_ = [height floatValue];
	newSize_ = [self threadsListIntercellSpacing];
	newSize_.height = height_;
	
	[self setThreadsListIntercellSpacing : newSize_];
}
- (void) setThreadsListIntercellSpacingWidth : (NSNumber *) width
{
	float		width_;
	NSSize		newSize_;
	
	UTILAssertNotNilArgument(width, @"width");
	
	width_ = [width floatValue];
	newSize_ = [self threadsListIntercellSpacing];
	newSize_.width = width_;
	
	[self setThreadsListIntercellSpacing : newSize_];
}


- (BOOL) threadsListDrawsGrid
{
	return [[self appearances] 
				boolForKey : kPrefThreadsListDrawsGridKey
			  defaultValue : DEFAULT_THREAD_LIST_DRAWSGRID];
}
- (void) setThreadsListDrawsGrid : (BOOL) flag
{
	[[self appearances]
				setBool : flag
				 forKey : kPrefThreadsListDrawsGridKey];
	[self postLayoutSettingsUpdateNotification];
}

- (NSColor *) threadsListColor
{
	return [self textAppearanceColorForKey:kPrefThreadsListColorKey];
}
- (void) setThreadsListColor : (NSColor *) color
{
	[self setAppearanceColor:color forKey:kPrefThreadsListColorKey];
	[self postLayoutSettingsUpdateNotification];
}
- (NSFont *) threadsListFont
{
	return [self appearanceFontForKey : kPrefThreadsListFontKey
					   defaultSize : DEFAULT_THREADS_LIST_FONTSIZE];
}
- (void) setThreadsListFont : (NSFont *) aFont
{
	[self setAppearanceFont:aFont forKey:kPrefThreadsListFontKey];
	[self postLayoutSettingsUpdateNotification];
}
- (NSColor *) threadsListNewThreadColor
{
	NSColor		*c;
	
	c = [self appearanceColorForKey:kPrefNewThreadColorKey];
	return (nil == c) ? [NSColor redColor] : c;
}
- (void) setThreadsListNewThreadColor : (NSColor *) color
{
	[self setAppearanceColor:color forKey:kPrefNewThreadColorKey];
	[self postLayoutSettingsUpdateNotification];
}
- (NSFont *) threadsListNewThreadFont
{
	return [self appearanceFontForKey : kPrefNewThreadFontKey
					      defaultSize : DEFAULT_THREADS_LIST_FONTSIZE];
}
- (void) setThreadsListNewThreadFont : (NSFont *) aFont
{
	[self setAppearanceFont : aFont
				   forKey : kPrefNewThreadFontKey];
	[self postLayoutSettingsUpdateNotification];
}

#pragma mark BoardList
- (float) boardListRowHeight
{
	return [[self appearances] 
					floatForKey : kPrefBoardListRowHeightKey
				   defaultValue : DEFAULT_BOARD_LIST_ROW_HEIGHT];
}
- (void) setBoardListRowHeight : (float) rowHeight
{
	[[self appearances] setFloat:rowHeight forKey:kPrefBoardListRowHeightKey];
	[self postLayoutSettingsUpdateNotification];
}
- (void) fixBoardListRowHeightToFontSize
{
	NSFont	*listFont_;
	
	listFont_ = [self boardListFont];
	[self setBoardListRowHeight : [listFont_ defaultLineHeightForFont]];
}
- (NSFont *) boardListFont
{
	return [self appearanceFontForKey : kPrefBoardListFontKey
					   defaultSize : DEFAULT_BOARD_LIST_FONTSIZE];
}
- (void) setBoardListFont : (NSFont *) font
{
	[self setAppearanceFont:font forKey:kPrefBoardListFontKey];
	[self postLayoutSettingsUpdateNotification];
}
- (NSColor *) boardListTextColor
{
	NSColor		*c;
	
	c = [self appearanceColorForKey:kPrefBoardListTextColorKey];
	return (nil == c) ? [NSColor blackColor] : c;
}
- (void) setBoardListTextColor : (NSColor *) color
{
	[self setAppearanceColor:color forKey:kPrefBoardListTextColorKey];
	[self postLayoutSettingsUpdateNotification];
}

#pragma mark -
- (void) _loadFontAndColor
{
	[self setShouldThreadAntialias : 
		[[self appearances] boolForKey:kPrefAntialiasKey defaultValue:DEFAULT_SHOULD_THREAD_ANTIALIAS]];

}
- (BOOL) _saveFontAndColor
{
	NSMutableDictionary	*mdict;
	NSMutableDictionary	*mResult;
	NSEnumerator		*keyEnum;
	id					key;
	
	mdict = [self appearances];
	mResult = [mdict mutableCopy];
	UTILAssertNotNil(mdict);
	
	/* Font, Color をプロパティリスト形式に変換 */
	keyEnum = [mdict keyEnumerator];
	while (key = [keyEnum nextObject]) {
		id		v = [mdict objectForKey : key];
		
		if ([v isKindOfClass : [NSFont class]])
			[mResult setFont:v forKey:key];
		else if ([v isKindOfClass : [NSColor class]])
			[mResult setColor:v forKey:key];
	}
	
	[[self defaults] setObject : mResult
						forKey : kPrefAppearanceDictKey];
	[mResult release];
	
	return YES;
}
@end
