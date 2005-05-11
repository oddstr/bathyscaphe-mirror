//:FCController-ViewAccessor.m
#import "FCController_p.h"


@implementation FCController(ViewAccessor)
- (NSColorWell *) threadViewBGColorWell
{
	return _threadViewBGColorWell;
}

- (NSColorWell *) threadViewColorWell
{
	return _threadViewColorWell;
}

- (NSColorWell *) messageColorWell
{
	return _messageColorWell;
}

- (NSColorWell *) messageNameColorWell
{
	return _messageNameColorWell;
}

- (NSColorWell *) messageTitleColorWell
{
	return _messageTitleColorWell;
}

- (NSColorWell *) messageAnchorColorWell
{
	return _messageAnchorColorWell;
}
- (NSColorWell *) messageFilteredColorWell
{
	return _messageFilteredColorWell;
}
- (NSColorWell *) messageTextEnhancedColorWell
{
	return _messageTextEnhancedColorWell;
}

- (NSButton *) hasAnchorULButton
{
	return _hasAnchorULButton;
}
- (NSColorWell *) newThreadColorWell
{
	return _newThreadColorWell;
}
- (NSColorWell *) threadsListColorWell
{
	return _threadsListColorWell;
}
- (NSButton *) threadViewFontButton
{
	return _threadViewFontButton;
}

- (NSButton *) messageFontButton
{
	return _messageFontButton;
}

- (NSButton *) alternateFontButton
{
	return _alternateFontButton;
}

- (NSButton *) itemTitleFontButton
{
	return _itemTitleFontButton;
}

- (NSButton *) threadsListFontButton
{
	return _threadsListFontButton;
}

- (NSButton *) newThreadFontButton
{
	return _newThreadFontButton;
}

- (NSColorWell *) resPopUpBGColorWell
{
	return _resPopUpBGColorWell;
}

- (NSColorWell *) resPopUpTextColorWell
{
	return _resPopUpTextColorWell;
}

- (NSButton *) resPopUpUsesTCButton
{
	return _resPopUpUsesTCButton;
}
- (NSButton *) resPopUpIsSeeThroughButton
{
	return _resPopUpIsSeeThroughButton;
}

- (NSButton *) shouldAntialiasButton
{
	return m_shouldAntialiasButton;
}
- (NSTextField *) rowHeightField
{
	return m_rowHeightField;
}
- (NSTextField *) spaceWidthField
{
	return m_spaceWidthField;
}
- (NSTextField *) spaceHeightField
{
	return m_spaceHeightField;
}
- (NSButton *) drawsGridCheckBox
{
	return m_drawsGridCheckBox;
}
- (NSButton *) drawStripedCheckBox
{
	return m_drawStripedCheckBox;
}
- (NSStepper *) rowHeightStepper
{
	return m_rowHeightStepper;
}
- (NSStepper *) spaceWidthStepper
{
	return m_spaceWidthStepper;
}
- (NSStepper *) spaceHeightStepper
{
	return m_spaceHeightStepper;
}
- (NSButton *) replyFontButton
{
	return m_replyFontButton;
}

- (NSColorWell *) replyTextColorWell
{
	return m_replyTextColorWell;
}

- (NSColorWell *) replyBackgroundColorWell
{
	return m_replyBackgroundColorWell;
}
- (NSMatrix *) progressStyleRadioBotton
{
	return _progressStyleRadioBotton;
}
- (NSButton *) resPopUpScrollerIsSmall
{
	return _resPopUpScrollerIsSmall;
}

#pragma mark -

- (void) setupUIComponents
{
	SEL		respondsSELs[] = {
		@selector(threadsViewFont),
		@selector(messageFont),
		
		@selector(messageTitleFont),
		@selector(threadsListFont),
		@selector(threadsListNewThreadFont),
		
		@selector(threadViewerBackgroundColor),
		@selector(threadsViewColor),
		@selector(messageColor),
		@selector(messageNameColor),
		@selector(messageTitleColor),
		
		@selector(messageAnchorColor),
		@selector(threadsListNewThreadColor),
		@selector(threadsListColor),
		
		@selector(threadsListDrawsGrid),
		@selector(browserSTableDrawsStriped),
		@selector(threadsListRowHeight),
		@selector(threadsListIntercellSpacing),
		@selector(threadsListIntercellSpacing),
		
		@selector(shouldThreadAntialias),
		@selector(resPopUpBackgroundColor),
		@selector(isResPopUpTextDefaultColor),
		@selector(resPopUpDefaultTextColor),
		@selector(isResPopUpSeeThrough),
		
		@selector(canUseSpinningStyle),
		@selector(messageFilteredColor),
		@selector(messageAlternateFont),

		@selector(popUpWindowVerticalScrollerIsSmall),
		@selector(textEnhancedColor)
	};
	
	NSString	*keys[] = {
		@"threadViewFontButton",
		@"messageFontButton",
		
		@"itemTitleFontButton",
		@"threadsListFontButton",
		@"newThreadFontButton",
		
		@"threadViewBGColorWell",
		@"threadViewColorWell",
		@"messageColorWell",
		@"messageNameColorWell",
		@"messageTitleColorWell",
		
		@"messageAnchorColorWell",
		@"newThreadColorWell",
		@"threadsListColorWell",
		
		@"drawsGridCheckBox",
		@"drawStripedCheckBox",
		@"rowHeightField",
		@"spaceHeightField",
		@"spaceWidthField",
		
		@"shouldAntialiasButton",
		@"resPopUpBGColorWell",
		@"resPopUpUsesTCButton",
		@"resPopUpTextColorWell",
		@"resPopUpIsSeeThroughButton",
		
		@"progressStyleRadioBotton",
		@"messageFilteredColorWell",
		@"alternateFontButton",
		
		@"resPopUpScrollerIsSmall",
		@"messageTextEnhancedColorWell"
	};
	
	int	i, cnt = UTILNumberOfCArray(keys);
	
	NSAssert(
		UTILNumberOfCArray(keys) == UTILNumberOfCArray(respondsSELs),
		@"Array keys and respondsSELs must have same amount of members.");
	
	
	if (nil == _contentView) return;
	
	for (i = 0; i < cnt; i++) {
		id		control;
		
		control = [self valueForKey : keys[i]];
		UTILAssertNotNil(control);
		[self preferencesRespondsTo : respondsSELs[i]
						  ofControl : control];
	}
	// チェックボックスが選択されていない場合は非表示
	if ([[self resPopUpTextColorWell] isEnabled])
		[[self resPopUpTextColorWell] setEnabled : 
			(NSOnState == [[self resPopUpUsesTCButton] state])];
}

- (void) updateColorWellComponents
{
	NSString *getColorKeys[] = {
		@"threadViewerBackgroundColor",
		@"threadsViewColor",
		@"messageColor",
		@"messageNameColor",
		@"messageTitleColor",
		@"messageAnchorColor",
		@"messageFilteredColor",
		@"textEnhancedColor",
		@"threadsListNewThreadColor",
		@"threadsListColor",
		@"replyTextColor",
		@"replyBackgroundColor",
		@"resPopUpBackgroundColor",
		@"resPopUpDefaultTextColor"};
	
	NSString *colorWells[] = {
		@"threadViewBGColorWell",
		@"threadViewColorWell",
		@"messageColorWell",
		@"messageNameColorWell",
		@"messageTitleColorWell",
		@"messageAnchorColorWell",
		@"messageFilteredColorWell",
		@"messageTextEnhancedColorWell",
		@"newThreadColorWell",
		@"threadsListColorWell",
		@"replyTextColorWell",
		@"replyBackgroundColorWell",
		@"resPopUpBGColorWell",
		@"resPopUpTextColorWell"};
		
	[[NSColorPanel sharedColorPanel] setShowsAlpha: YES];
	
	AppDefaults *pref_ = [self preferences];
	int	i, cnt = UTILNumberOfCArray(colorWells);
	
	NSAssert(
		UTILNumberOfCArray(colorWells) == UTILNumberOfCArray(getColorKeys),
		@"Array colorWells and getColorKeys must have same amount of members.");
	for (i = 0; i < cnt; i++) {
		NSColorWell		*colorWell;
		NSColor			*c;
		
		colorWell = [self valueForKey : colorWells[i]];
		c = [pref_ valueForKey : getColorKeys[i]];
		
		UTILAssertKindOfClass(colorWell, NSColorWell);
		UTILAssertKindOfClass(c, NSColor);
		//カラーウェルの状態に関わらずカラーを設定してしまう。
		//if ([colorWell isEnabled]) {
			// プロキシである可能性があるのでコピー
			c = [c copyWithZone : nil];
			[colorWell setColor : c];
			[c release];
		//}
	}
}
- (void) updateCheckboxComponents
{
	NSString *checkBoxes[] = {
		@"drawsGridCheckBox",
		@"drawStripedCheckBox",
		@"resPopUpUsesTCButton",
		@"resPopUpIsSeeThroughButton",
		@"hasAnchorULButton",
		@"shouldAntialiasButton",

		@"resPopUpScrollerIsSmall"
		};
		
	
	SEL getSELs[] = {
		@selector(threadsListDrawsGrid),
		@selector(browserSTableDrawsStriped),
		@selector(isResPopUpTextDefaultColor),
		@selector(isResPopUpSeeThrough),
		@selector(hasMessageAnchorUnderline),
		@selector(shouldThreadAntialias),

		@selector(popUpWindowVerticalScrollerIsSmall)
		};
	
	int		i, cnt = UTILNumberOfCArray(getSELs);
	
	NSAssert(
		UTILNumberOfCArray(checkBoxes) == UTILNumberOfCArray(getSELs),
		@"Array getSELs and checkBoxes must have same amount of members.");
	for (i = 0; i < cnt; i++) {
		NSButton	*chexbox;
		
		chexbox = [self valueForKey : checkBoxes[i]];
		UTILAssertKindOfClass(chexbox, NSButton);
		[self syncButtonState : chexbox
						 with : getSELs[i]];
	}
}

- (void) syncColorWellComponents
{
	[[self resPopUpTextColorWell] setEnabled : (NSOnState == [[self resPopUpUsesTCButton]  state])];
}

- (NSFont *) getFontOf : (int) btnTag
{
	NSString *fonts[] = {
		@"threadsViewFont",
		@"messageFont",
		@"messageTitleFont",
		@"threadsListFont",
		@"threadsListNewThreadFont",
		@"replyFont",
		@"messageAlternateFont"
	};

	AppDefaults *pref_ = [self preferences];
	NSFont *f = [pref_ valueForKey : fonts[btnTag]];
	return f;
}
- (void) updateFontWellComponents
{
	NSString *controls[] = {
		@"threadViewFontButton",
		@"messageFontButton",
		@"itemTitleFontButton",
		@"threadsListFontButton",
		@"newThreadFontButton",
		@"replyFontButton",
		@"alternateFontButton"
	};
	int i, cnt = UTILNumberOfCArray(controls);
	for (i = 0; i < cnt; i++) {
		NSButton		*field;
		
		field = [self valueForKey : controls[i]];
		NSFont *font_ = [self getFontOf : i];
		NSFont *font2_ = [NSFont fontWithName : [font_ fontName] size : [[field font] pointSize]];
		[field setFont : font2_];
		[field setTitle : [NSString stringWithFormat : @"%@ - %0.1f",[font_ displayName], [font_ pointSize]]];
	}
}

- (void) updateUIComponents
{
	AppDefaults *pref_ = [self preferences];
	
	if (nil == _contentView || nil == pref_) return;
	
	[self updateTableRowSettings];
	[self updateFontWellComponents];
	[self updateColorWellComponents];
	[self updateCheckboxComponents];
	[self syncColorWellComponents];
	
	// ステータス行
	if ([[self preferences] canUseSpinningStyle]) {
		[[self progressStyleRadioBotton] selectCellWithTag : 
			([[self preferences] statusLineUsesSpinningStyle]
				? kSpiningStyleTag : kBarStyleTag)];
	}
}



- (void) updateTableRowSettings
{
	AppDefaults		*pref_;
	
	pref_ = [self preferences];
	if ([[self rowHeightField] isEnabled]) {
		[[self rowHeightField] setFloatValue :
			[pref_ threadsListRowHeight]];
		[[self rowHeightStepper] setFloatValue :
			[pref_ threadsListRowHeight]];
	}
	if ([[self spaceWidthField] isEnabled]) {
		[[self spaceWidthField] setFloatValue :
			[pref_ threadsListIntercellSpacing].width];
		[[self spaceWidthStepper] setFloatValue :
			[pref_ threadsListIntercellSpacing].width];
	}
	if ([[self spaceHeightField] isEnabled]) {
		[[self spaceHeightField] setFloatValue :
			[pref_ threadsListIntercellSpacing].height];
		[[self spaceHeightStepper] setFloatValue :
			[pref_ threadsListIntercellSpacing].height];
	}
}
@end