#import "FCController_p.h"


#define kLabelKey		@"Appearance Label"
#define kToolTipKey		@"Appearance ToolTip"
#define kImageName		@"AppearancePreferences"

#define PREF			[self preferences]

@implementation FCController
- (NSString *) mainNibName
{
	return @"FontsAndColors";
}
#pragma mark IBActions
- (IBAction) changeTableRowSpace : (id) sender
{
	[[self preferences]	setThreadsListRowHeight : [sender floatValue]];
	[self updateTableRowSettings];
}

- (IBAction) changeBoardListRowHeight : (id) sender
{
	[[self preferences]	setBoardListRowHeight : [sender floatValue]];
	[self updateBoardListRowSettings];
}

- (IBAction) fixRowHeightToFont : (id) sender
{
	[[self preferences] fixRowHeightToFontSize];
	[self updateTableRowSettings];
}

- (IBAction) fixRowHeightToFontOfBoardList : (id) sender
{
	[[self preferences] fixBoardListRowHeightToFontSize];
	[self updateBoardListRowSettings];
}
#pragma mark Font Setting
- (void) changeFontOf : (int) tagNum To: (NSFont *) newFont
{
	SEL		selector_[] = {
				@selector(setThreadsViewFont:),
				@selector(setMessageFont:),
				@selector(setMessageTitleFont:),
				@selector(setThreadsListFont:),
				@selector(setThreadsListNewThreadFont:),
				@selector(setReplyFont:),
				@selector(setMessageAlternateFont:),
				@selector(setMessageHostFont:),
				@selector(setMessageBeProfileFont:),
				@selector(setBoardListFont:)
			};
	
	if (nil == [self preferences]) return;

	if (NO == [[self preferences] respondsToSelector : selector_[tagNum]] || newFont == nil) 
		return;
	
	[[self preferences] performSelector : selector_[tagNum]
							 withObject : newFont];
}

#pragma mark SledgeHammer Additions

- (float) msgContIndentValue
{
	return [[self preferences] messageHeadIndent];
}
- (void) setMsgContIndentValue : (float) aValue
{
	[[self preferences] setMessageHeadIndent : aValue];
}
- (float) msgContSpacingBeforeValue
{
	return [[self preferences] msgIdxSpacingAfter];
}
- (void) setMsgContSpacingBeforeValue : (float) aValue
{
	[[self preferences] setMsgIdxSpacingAfter : aValue];
}
- (float) msgContSpacingAfterValue
{
	return [[self preferences] msgIdxSpacingBefore];
}
- (void) setMsgContSpacingAfterValue : (float) aValue
{
	[[self preferences] setMsgIdxSpacingBefore : aValue];
}


- (float) resPopUpBgAlphaValue
{
	return [[self preferences] resPopUpBgAlphaValue];
}
- (void) setResPopUpBgAlphaValue : (float) aValue
{
	[[self preferences] setResPopUpBgAlphaValue : aValue];
}
- (float) replyBgAlphaValue
{
	return [[self preferences] replyBgAlphaValue];
}
- (void) setReplyBgAlphaValue : (float) aValue
{
	[[self preferences] setReplyBgAlphaValue : aValue];
}

#pragma mark Lemonade New Color Settings

- (NSColor *) threadTextColor
{
	return [PREF threadsViewColor];
}
- (void) setThreadTextColor : (NSColor *) newColor
{
	[PREF setThreadsViewColor : newColor];
}

- (NSColor *) msgTextColor
{
	return [PREF messageColor];
}
- (void) setMsgTextColor : (NSColor *) newColor
{
	[PREF setMessageColor : newColor];
}

- (NSColor *) headerTextColor
{
	return [PREF messageTitleColor];
}
- (void) setHeaderTextColor : (NSColor *) newColor
{
	[PREF setMessageTitleColor : newColor];
}

- (NSColor *) hostTextColor
{
	return [PREF messageHostColor];
}
- (void) setHostTextColor : (NSColor *) newColor
{
	[PREF setMessageHostColor : newColor];
}

- (NSColor *) linkTextColor
{
	return [PREF messageAnchorColor];
}
- (void) setLinkTextColor : (NSColor *) newColor
{
	[PREF setMessageAnchorColor : newColor];
}

- (NSColor *) nameTextColor
{
	return [PREF messageNameColor];
}
- (void) setNameTextColor : (NSColor *) newColor
{
	[PREF setMessageNameColor : newColor];
}
- (NSColor *) threadBgColor
{
	return [PREF threadViewerBackgroundColor];
}
- (void) setThreadBgColor : (NSColor *) newColor
{
	[PREF setThreadViewerBackgroundColor : newColor];
}

- (NSColor *) thListDefaultColor
{
	return [PREF threadsListColor];
}
- (void) setThListDefaultColor : (NSColor *) newColor
{
	[PREF setThreadsListColor : newColor];
}
- (NSColor *) thListNewColor
{
	return [PREF threadsListNewThreadColor];
}
- (void) setThListNewColor : (NSColor *) newColor
{
	[PREF setThreadsListNewThreadColor : newColor];
}

- (NSColor *) popupBgColor
{
	return [PREF resPopUpBackgroundColor];
}
- (void) setPopupBgColor : (NSColor *) newColor
{
	[PREF setResPopUpBackgroundColor : newColor];
}

- (NSColor *) popupTextColor
{
	return [PREF resPopUpDefaultTextColor];
}
- (void) setPopupTextColor : (NSColor *) newColor
{
	[PREF setResPopUpDefaultTextColor : newColor];
}
- (NSColor *) replyTextColor
{
	return [PREF replyTextColor];
}
- (void) setReplyTextColor : (NSColor *) newColor
{
	[PREF setReplyTextColor : newColor];
}
- (NSColor *) replyBgColor
{
	return [PREF replyBackgroundColor];
}
- (void) setReplyBgColor : (NSColor *) newColor
{
	[PREF setReplyBackgroundColor : newColor];
}
- (NSColor *) boardListTextColor
{
	return [PREF boardListTextColor];
}
- (void) setBoardListTextColor : (NSColor *) newColor
{
	[PREF setBoardListTextColor : newColor];
}

#pragma mark Lemonade New CheckBox Setings
- (BOOL) hasAnchorUL
{
	return [PREF hasMessageAnchorUnderline];
}
- (void) setHasAnchorUL : (BOOL) boxState
{
	[PREF setHasMessageAnchorUnderline : boxState];
}
- (BOOL) shouldAntiAlias
{
	return [PREF shouldThreadAntialias];
}
- (void) setShouldAntiAlias : (BOOL) boxState
{
	[PREF setShouldThreadAntialias : boxState];
}
- (BOOL) drawsGrid
{
	return [PREF threadsListDrawsGrid];
}
- (void) setDrawsGrid : (BOOL) boxState
{
	[PREF setThreadsListDrawsGrid : boxState];
}
- (BOOL) drawsStriped
{
	return [PREF browserSTableDrawsStriped];
}
- (void) setDrawsStriped : (BOOL) boxState
{
	[PREF setBrowserSTableDrawsStriped : boxState];
}
- (BOOL) popupUsesCustomTextColor
{
	return [PREF isResPopUpTextDefaultColor];
}
- (void) setPopupUsesCustomTextColor : (BOOL) boxState
{
	[PREF setIsResPopUpTextDefaultColor : boxState];
}
- (BOOL) popupUsesSmallScroller
{
	return [PREF popUpWindowVerticalScrollerIsSmall];
}
- (void) setPopupUsesSmallScroller : (BOOL) boxState
{
	[PREF setPopUpWindowVerticalScrollerIsSmall : boxState];
}

#pragma mark LittleWish Addition
- (NSColor *) hiliteColor
{
	return [PREF textEnhancedColor];
}
- (void) setHiliteColor : (NSColor *) newColor
{
	[PREF setTextEnhancedColor : newColor];
}

#pragma mark NSFontPanelValidation

- (unsigned int) validModesForFontPanel : (NSFontPanel *) fontPanel
{
	return (NSFontPanelFaceModeMask|NSFontPanelSizeModeMask|NSFontPanelCollectionModeMask);
}
@end

#pragma mark -

@implementation FCController(Toolbar)
- (NSString *) identifier
{
	return PPFontsAndColorsIdentifier;
}
- (NSString *) helpKeyword
{
	return PPLocalizedString(@"Help_View");
}
- (NSString *) label
{
	return PPLocalizedString(kLabelKey);
}
- (NSString *) paletteLabel
{
	return PPLocalizedString(kLabelKey);
}
- (NSString *) toolTip
{
	return PPLocalizedString(kToolTipKey);
}
- (NSString *) imageName
{
	return kImageName;
}
@end
