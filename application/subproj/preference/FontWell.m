#import "FontWell.h"

@implementation FontWell

static NSMutableArray*  _fontWells = nil;

- (void)_updateTitleWithFont : (NSFont *) font_
{
	NSString	*titlestr_;
	
	if (font_ == nil) {
		font_ = [[[self window] delegate] getFontOf : [self tag]];
	}
	
	titlestr_ = [NSString stringWithFormat : @"%@ %0.0f",[font_ displayName],[font_ pointSize]];
	[self setTitle:titlestr_];
}

- (void)dealloc
{
	[super dealloc];
	
	[_fontWells removeObject:self];
}

- (void)awakeFromNib
{
	if (!_fontWells) {
		_fontWells = [[NSMutableArray array] retain];
	}
	if (![_fontWells containsObject:self]) {
		[_fontWells addObject:self];
	}
	
	//[self _updateTitleWithFont : nil];
	
	[self setTarget:self];
	[self setAction:@selector(_pushed:)];
}

- (void)changeFont:(id)sender
{
	NSFont* font;
	font = [self font];
	
	NSFont* convertedFont;
	convertedFont = [sender convertFont:font];
	NSFont* resizedFont;
	resizedFont = [sender fontWithFamily:[convertedFont familyName] 
			traits:[sender traitsOfFont:convertedFont] 
			weight:[sender weightOfFont:convertedFont] 
			size:[font pointSize]];
	[self setFont:resizedFont];
	//[self setFont:convertedFont];
	[[[self window] delegate] changeFontOf : [self tag]
										To : convertedFont];

	
	[self _updateTitleWithFont : convertedFont];
}

- (void)activate
{
	[[NSFontPanel sharedFontPanel] makeKeyAndOrderFront:self];
	[[NSFontPanel sharedFontPanel] setDelegate:self];
	[[NSFontManager sharedFontManager] 
			setSelectedFont:[self font] isMultiple:NO];
	
	NSEnumerator*   enumerator;
	enumerator = [_fontWells objectEnumerator];
	FontWell*   fontWell;
	while (fontWell = [enumerator nextObject]) {
		if (fontWell != self) {
			[fontWell deactivate];
		}
	}
	
	[[self window] makeFirstResponder:self];
}

- (void)deactivate
{
	[self setState:NSOffState];
	[[self window] makeFirstResponder:nil];
}

- (void)_pushed:(id)sender
{
	int state;
	state = [self state];
	if (state == NSOnState) {
		[self activate];
	}
	if (state == NSOffState) {
		[self deactivate];
	}
}
- (void)windowWillClose:(NSNotification *)aNotification
{
	if ([self state] == NSOnState) [self deactivate];
}
@end
