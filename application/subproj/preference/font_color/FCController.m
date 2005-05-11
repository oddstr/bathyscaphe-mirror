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


#define kPrefPopUpScrollerTagBase	10
- (IBAction) changePopUpScrollerSize : (id) sender
{
	BOOL	setOn_;
	int		tag_;
	
	UTILAssertRespondsTo(sender, @selector(tag));
	UTILAssertRespondsTo(sender, @selector(state));
	
	tag_ = [sender tag];
	setOn_ = (NSOnState == [sender state]);
	
	[[self preferences] setValue : [NSNumber numberWithBool:setOn_]
				forKey : @"popUpWindowVerticalScrollerIsSmall"];
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

- (IBAction) fixRowHeightToFont : (id) sender
{
	[[self preferences] fixRowHeightToFontSize];
	[self updateTableRowSettings];
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
				@selector(setThreadsListColor:),				// 6
				@selector(setThreadsListNewThreadColor:),		// 7
				@selector(setResPopUpBackgroundColor:),			// 8
				@selector(setResPopUpDefaultTextColor:),		// 9
				@selector(setReplyTextColor:),					// 10
				@selector(setReplyBackgroundColor:),			// 11
				@selector(setMessageFilteredColor:),			// 12
				@selector(setTextEnhancedColor:)				// 13
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
- (IBAction) chooseProgressStyleRadioBotton : (id) sender
{
	BOOL		usesSpinningStyle_;
	NSCell		*cell_;
	
	if (NO == [sender respondsToSelector : @selector(cellWithTag:)])
		return;
	
	cell_ = [[self progressStyleRadioBotton] selectedCell]; 
	usesSpinningStyle_ = (kSpiningStyleTag == [cell_ tag]);
	[[self preferences] setStatusLineUsesSpinningStyle : usesSpinningStyle_];
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
				@selector(setMessageAlternateFont:)
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
