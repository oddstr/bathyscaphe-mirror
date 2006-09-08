//:FCController-ViewAccessor.m
#import "FCController_p.h"


@implementation FCController(ViewAccessor)
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
- (NSButton *) replyFontButton
{
	return m_replyFontButton;
}

- (NSButton *) hostFontButton
{
	return _hostFontButton;
}
- (NSButton *) boardListTextFontButton
{
	return m_BLtextFontButton;
}

- (NSButton *) beProfileFontButton
{
	return _beProfileFontButton;
}

#pragma mark -

- (void) setupUIComponents
{
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
		@"messageAlternateFont",
		@"messageHostFont",
		@"messageBeProfileFont",
		@"boardListFont"
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
		@"alternateFontButton",
		@"hostFontButton",
		@"beProfileFontButton",
		@"boardListTextFontButton"
	};
	int i, cnt = UTILNumberOfCArray(controls);
	for (i = 0; i < cnt; i++) {
		NSButton		*field;
		
		field = [self valueForKey : controls[i]];
		NSFont *font_ = [self getFontOf : i];
		NSFont *font2_ = [NSFont fontWithName : [font_ fontName] size : [[field font] pointSize]];
		[field setFont : font2_];
		[field setTitle : [NSString stringWithFormat : @"%@ %0.0f",[font_ displayName], [font_ pointSize]]];
	}
}

- (void) updateUIComponents
{
	AppDefaults *pref_ = [self preferences];
	
	if (nil == _contentView || nil == pref_) return;
	
	[self updateFontWellComponents];
}
@end