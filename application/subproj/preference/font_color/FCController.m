#import "FCController_p.h"


#define kLabelKey		@"Appearance Label"
#define kToolTipKey		@"Appearance ToolTip"
#define kImageName		@"AppearancePreferences"


@implementation FCController
- (NSString *) mainNibName
{
	return @"FontsAndColors";
}

#pragma mark -

- (IBAction) changeHasAnchorUnderline : (id) sender
{
	UTILAssertKindOfClass(sender, NSButton);
	[[self preferences] setHasMessageAnchorUnderline : 
						([sender state] == NSOnState)];
}
- (IBAction) changeResPopUpUsesTextColor : (id) sender
{
	BOOL usesDefaultColor_;
	
	UTILAssertRespondsTo(sender, @selector(state));
	usesDefaultColor_ = ([sender state] == NSOnState);
	[[self preferences] setIsResPopUpTextDefaultColor : usesDefaultColor_];
	[[self resPopUpTextColorWell] setEnabled : usesDefaultColor_];
}
- (IBAction) changeResPopUpSeeThrough : (id) sender
{
	UTILAssertRespondsTo(sender, @selector(state));
	[[self preferences] setIsResPopUpSeeThrough : 
						([sender state] == NSOnState)];
}


- (IBAction) changePopUpScrollerSize : (id) sender
{
	[[self preferences] setPopUpWindowVerticalScrollerIsSmall : ([sender state] == NSOnState)];
}


- (IBAction) changeShouldThreadAntialias : (id) sender
{
	UTILAssertKindOfClass(sender, NSButton);
	[[self preferences] setShouldThreadAntialias : 
						([sender state] == NSOnState)];
}
- (IBAction) changeDrawsGrid : (id) sender
{
	BOOL	drawsGrid_;
	
	UTILAssertKindOfClass(sender, NSButton);
	drawsGrid_ = ([sender state] == NSOnState);
	[[self preferences] setThreadsListDrawsGrid : drawsGrid_];
}
- (IBAction) changeDrawStriped : (id) sender
{
	BOOL	drawStriped_;
	
	UTILAssertKindOfClass(sender, NSButton);
	drawStriped_ = ([sender state] == NSOnState);
	[[self preferences] setBrowserSTableDrawsStriped : drawStriped_];
}
- (IBAction) changeTableRowSpace : (id) sender
{
	int			index_;
	NSNumber	*number_;
	SEL			selector_[] = {
					@selector(setThreadsListRowHeightNum:),
					@selector(setThreadsListIntercellSpacingHeight:),
					@selector(setThreadsListIntercellSpacingWidth:),
			};
	
	UTILAssertKindOfClass(sender, NSControl);
	
	index_ = [sender tag];
	NSAssert2(
		(index_ < UTILNumberOfCArray(selector_)),
		@"Access over index(%d) length = %d",
		index_,
		UTILNumberOfCArray(selector_));
	
	
	if (NO == [[self preferences] respondsToSelector : selector_[index_]]) 
		return;
	
	number_ = [NSNumber numberWithFloat : [sender floatValue]];
	[[self preferences] performSelector : selector_[index_]
							 withObject : number_];
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

- (IBAction) changeColor : (id) sender
{
	int		index_;
	SEL		selector_[] = {
				@selector(setThreadViewerBackgroundColor:),		// 0
				@selector(setThreadsViewColor:),				// 1
				@selector(setMessageColor:),					// 2
				@selector(setMessageNameColor:),				// 3
				@selector(setMessageTitleColor:),				// 4
				@selector(setMessageAnchorColor:),				// 5
				@selector(setMessageFilteredColor:),			// 6
				@selector(setTextEnhancedColor:),				// 7
				@selector(setThreadsListNewThreadColor:),		// 8
				@selector(setThreadsListColor:),				// 9
				@selector(setReplyTextColor:),					// 10
				@selector(setReplyBackgroundColor:),			// 11
				@selector(setResPopUpBackgroundColor:),			// 12
				@selector(setResPopUpDefaultTextColor:),		// 13
				@selector(setMessageHostColor:),				// 14
				@selector(setBoardListTextColor:)				// 15
	};
	
	if (NO == [sender respondsToSelector : @selector(tag)]) return;
	if (NO == [sender respondsToSelector : @selector(color)]) return;
	
	index_ = [sender tag];
	NSAssert2(
		(index_ < UTILNumberOfCArray(selector_)),
		@"Access over index(%d) length = %d",
		index_,
		UTILNumberOfCArray(selector_));
	
	if (NO == [[self preferences] respondsToSelector : selector_[index_]]) 
		return;
	
	[[self preferences] performSelector : selector_[index_]
							 withObject : [sender color]];
}

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
@end



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
