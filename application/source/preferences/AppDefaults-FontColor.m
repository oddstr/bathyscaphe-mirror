/**
  * $Id: AppDefaults-FontColor.m,v 1.1.1.1 2005/05/11 17:51:06 tsawada2 Exp $
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
// PopUp Window attributes
#import "CMXPopUpWindowAttributes.h"



#define kPrefAppearanceDictKey				@"Preferences - Fonts And Colors"

#define kPrefReplyColorKey					@"Reply Text Color"
#define kPrefReplyBackgroundColorKey		@"Reply Background Color"
#define kPrefReplyFontKey					@"Reply Text Font"
#define kPrefCaretUsesTextColorKey			@"Caret Uses Text Color"
#define kPrefAntialiasKey					@"Should Thread Antialias"
#define kPrefThreadsViewFontKey				@"TextFont"
#define kPrefThreadsViewColorKey			@"TextColor"
#define kPrefTextEnhancedColorKey			@"Text Emphasis Color"
#define kPrefResPopUpDefaultTextColorKey	@"Res PopUp Default Text-Color"
#define kPrefIsResPopUpTextDefaultColorKey	@"Res PopUp uses Default Text-Color"
#define kPrefPopUpWindowAttributesKey		@"PopUpWindow Attributes"
#define kPrefMessageHeadIndentKey			@"Message Head Indent"
#define kPrefMessageColorKey				@"Message Contents Color"
#define kPrefMessageFontKey					@"Message Contents Font"
#define kPrefMessageAlternateFontKey		@"Message Alternate Font"
#define kPrefMessageTitleColorKey			@"Message Item Color"
#define kPrefMessageTitleFontKey			@"Message Item Font"
#define kPrefMessageNameColorKey			@"Message Name Color"
#define kPrefMessageAnchorColorKey			@"Message Anchor Color"
#define kPrefMessageAnchorHasUnderlineKey	@"Message Anchor Underline"
#define kPrefMessageFilteredColorKey		@"Message Filtered Color"
#define kPrefThreadsListRowHeightKey		@"Row Height"
#define kPrefThreadsListIntercellSpacingKey	@"Intercell Spacing"
#define kPrefThreadsListDrawsGridKey		@"Draws Grid"
#define kPrefThreadsListGridColorKey		@"Grid Color"
#define kPrefThreadsListColorKey			@"ThreadsListColor"
#define kPrefThreadsListFontKey				@"ThreadsListFont"
#define kPrefNewThreadColorKey				@"NewThreadColor"
#define kPrefNewThreadFontKey				@"NewThreadFont"



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


- (NSColor *) replyTextColor
{
	return [self textAppearanceColorForKey : kPrefReplyColorKey];
}
- (void) setReplyTextColor : (NSColor *) aColor
{
	[self setAppearanceColor:aColor forKey:kPrefReplyColorKey] ;
	[self postLayoutSettingsUpdateNotification];
}
- (NSColor *) replyBackgroundColor
{
	NSColor *color_ = [self appearanceColorForKey:kPrefReplyBackgroundColorKey];
	return (nil == color_) ? [NSColor whiteColor] : color_;
}
- (void) setReplyBackgroundColor : (NSColor *) aColor
{
	[self setAppearanceColor:aColor forKey:kPrefReplyBackgroundColorKey] ;
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
- (BOOL) caretUsesTextColor
{
	return NO;
}
- (void) setCaretUsesTextColor : (BOOL) flag
{
	NSLog(@"Deprecated");
}
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

- (NSColor *) threadsListGridColor
{
	NSLog(@"Deprecated");
}

- (void) setThreadsListGridColor : (NSColor *) color
{
	NSLog(@"Deprecated");
}


/*** ポップアップ ***/
// デフォルトの色
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

// @see CMXPopUpWindowAttributes.h
- (UInt32) popUpWindowAttributes
{
	return [[self appearances] 
		 unsignedIntForKey : kPrefPopUpWindowAttributesKey
			  defaultValue : CMRPopUpDefaultAttributes];
}
- (void) setPopUpWindowAttributes:(UInt32) v setOn:(BOOL) setOn
{
	UInt32		flags_ = [self popUpWindowAttributes];
	
	v &= CMRPopUpUsedMask;
	flags_ = (setOn) ? (flags_|v) : (flags_&~v);
	
	[[self appearances] setUnsignedInt : flags_
			forKey : kPrefPopUpWindowAttributesKey];
}
- (BOOL) popUpWindowHasVerticalScroller
{
	return YES;//(([self popUpWindowAttributes] & CMRPopUpScrollerVertical) > 0);
}
- (BOOL) popUpWindowAutohidesScrollers
{
	return YES;//(([self popUpWindowAttributes] & CMRPopUpScrollerAutoHides) > 0);
}
- (BOOL) popUpWindowVerticalScrollerIsSmall
{
	return (([self popUpWindowAttributes] & CMRPopUpScrollerSmall) > 0);
}

- (void) setPopUpWindowHasVerticalScroller : (BOOL) flag
{
	NSLog(@"Deprecated.");//[self setPopUpWindowAttributes:CMRPopUpScrollerVertical setOn:flag];
}
- (void) setPopUpWindowAutohidesScrollers : (BOOL) flag
{
	NSLog(@"Deprecated.");//[self setPopUpWindowAttributes:CMRPopUpScrollerAutoHides setOn:flag];
}
- (void) setPopUpWindowVerticalScrollerIsSmall : (BOOL) flag
{
	[self setPopUpWindowAttributes:CMRPopUpScrollerSmall setOn:flag];
}




/* 本文：インデント */
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

/*** スレッド一覧 ***/
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
