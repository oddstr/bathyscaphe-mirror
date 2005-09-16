#import "FontWell.h"

@implementation FontWell
static NSMutableArray*  _fontWells = nil;

- (void) _updateTitleWithFont : (NSFont *) font_
{
	NSString	*titlestr_;
	
	if (font_ == nil) {
		font_ = [[[self window] delegate] getFontOf : [self tag]];
	}
	
	titlestr_ = [NSString stringWithFormat : @"%@ %0.0f", [font_ displayName], [font_ pointSize]];
	[self setTitle : titlestr_];
}

- (void) _pushed : (id) sender
{
	int		state = [self state];

	if (state == NSOnState) {
		[self activate];
	}
	if (state == NSOffState) {
		[self deactivate];
	}
}

- (void) awakeFromNib
{
	if (!_fontWells) {
		_fontWells = [[NSMutableArray array] retain];
	}
	if (![_fontWells containsObject : self]) {
		[_fontWells addObject : self];
	}

	[self setTarget : self];
	[self setAction : @selector(_pushed:)];
}

- (void) dealloc
{
	[super dealloc];
	[_fontWells removeObject : self];
}

- (void) activate
{
	NSFontManager	*fm_ = 	[NSFontManager sharedFontManager];

	[fm_ setSelectedFont : [[[self window] delegate] getFontOf : [self tag]] isMultiple : NO];
	[fm_ setDelegate : self];
    [fm_ orderFrontFontPanel : self];

	[[NSFontPanel sharedFontPanel] setDelegate : self];	// in order to catch the notification of closing font panel.

	NSEnumerator	*enumerator = [_fontWells objectEnumerator];
	FontWell		*fontWell;
	while (fontWell = [enumerator nextObject]) {
		if (fontWell != self) {
			[fontWell deactivate];
		}
	}
	
	[[self window] makeFirstResponder : self];	// in order to response changeFont: message by own.
}

- (void) deactivate
{
	[self setState : NSOffState];
	[[self window] makeFirstResponder : nil];
}

#pragma mark NSFontManager Delegate

- (void) changeFont : (id) sender
{
	NSFont* font = [self font];
	NSFont* convertedFont = [sender convertFont : font];

	NSFont* resizedFont = [sender fontWithFamily : [convertedFont familyName] 
										  traits : [sender traitsOfFont : convertedFont] 
										  weight : [sender weightOfFont : convertedFont]
											size : [font pointSize]];

	[[[self window] delegate] changeFontOf : [self tag]
										To : convertedFont];

	[self setFont : resizedFont];
	[self _updateTitleWithFont : convertedFont];
}

#pragma mark NSFontPanel (NSWindow) Delegate

- (void) windowWillClose : (NSNotification *) aNotification
{
	if ([self state] == NSOnState) [self deactivate];
}
@end
