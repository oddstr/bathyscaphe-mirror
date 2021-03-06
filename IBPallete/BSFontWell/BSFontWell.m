//
//  BSFontWell.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/11/02.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSFontWell.h"

NSString *const BSFontValueDidChangeNotification = @"jp.tsawada2.BathyScaphe.BSFontValueDidChangeNotification";

@implementation BSFontWell
static NSMutableArray	*bs_fontWells = nil;

static void	*bs_fontValueContext = @"Akazukin";

+ (void)initialize
{
    if (self == [BSFontWell class]) {
		CFArrayCallBacks arrayCallBacks = kCFTypeArrayCallBacks;
		arrayCallBacks.retain = NULL;
		arrayCallBacks.release = NULL;
		bs_fontWells = (NSMutableArray *)CFArrayCreateMutable(NULL, 0, &arrayCallBacks);

        [self exposeBinding:@"fontValue"];
    }
}

- (id) initWithCoder: (NSCoder *) coder
{
    if (self = [super initWithCoder: coder]) {
        [self setFontValue: [coder decodeObjectForKey:@"bsFontWell_fontValue"]];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *) coder
{
    [super encodeWithCoder: coder];
    [coder encodeObject: [self fontValue] forKey:@"bsFontWell_fontValue"];
}

- (void)awakeFromNib
{
	if (NSNotFound == [bs_fontWells indexOfObjectIdenticalTo:self]) {
		[bs_fontWells addObject:self];
	}

	[self setTarget:self];
	[self setAction:@selector(bsFontWellPushed:)];
}

- (void)dealloc
{
	[self setDelegate:nil];
	[bs_fontWells removeObjectIdenticalTo:self];
    [m_actualFont release];
	m_actualFont = nil;
    [super dealloc];
}

#pragma mark -
- (void)bsFontWellPushed:(id)sender
{
	int		state = [self state];

	if (state == NSOnState) {
		[self activate];
	}
	if (state == NSOffState) {
		[self deactivate];
	}
}

- (void)updateTitle
{
    NSFont      *font_ = [self fontValue];
    NSFont      *displayFont_;
    NSFontManager   *fm_ = [NSFontManager sharedFontManager];
	NSString	*titlestr_;
	titlestr_ = [NSString stringWithFormat:@"%@ %.0f", [font_ displayName], [font_ pointSize]];

	displayFont_ = [fm_ fontWithFamily:[font_ familyName] 
								traits:[fm_ traitsOfFont:font_] 
								weight:[fm_ weightOfFont:font_]
								  size:12.0];//[[self font] pointSize]]; // 応急処置

	[self setTitle:titlestr_];
	[self setFont:displayFont_];
}

- (id)cachedControllerObject
{
	return m_controller;
}

- (void)setCachedControllerObject:(id)aController
{
	[aController retain];
	[m_controller release];
	m_controller = aController;
}

- (NSString *)cachedKeyPath
{
	return m_keyPath;
}

- (void)setCachedKeyPath:(NSString *)aString
{
	[aString retain];
	[m_keyPath release];
	m_keyPath = aString;
}

- (NSFont *)fontValue
{
    return m_actualFont;
}

- (void)setFontValue:(NSFont *)aFont
{
    [aFont retain];
    [m_actualFont release];
    m_actualFont = aFont;
    [self updateTitle];
}

- (id)delegate
{
	return m_delegate;
}

- (void)setDelegate:(id)anObject
{
	m_delegate = anObject;
}

- (void)activate
{
	NSFontManager	*fm_ = 	[NSFontManager sharedFontManager];

	[fm_ setSelectedFont:[self fontValue] isMultiple:NO];

	[fm_ setAction:@selector(changeFont:)];
    [fm_ orderFrontFontPanel:self];

//	[[NSFontPanel sharedFontPanel] setDelegate:self];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bs_windowWillClose:) name:NSWindowWillCloseNotification object:[NSFontPanel sharedFontPanel]];

	NSEnumerator	*enumerator_ = [bs_fontWells objectEnumerator];
	BSFontWell		*fontWell_;
	while (fontWell_ = [enumerator_ nextObject]) {
		if (fontWell_ != self) {
			[fontWell_ deactivate];
		}
	}
	[[self window] makeFirstResponder:self];
}

- (void)deactivate
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillCloseNotification object:[NSFontPanel sharedFontPanel]];
	[self setState:NSOffState];
	[[self window] makeFirstResponder:nil];
}


#pragma mark -
- (void)changeFont:(id)sender
{
	NSFont* font_ = [self fontValue];
	NSFont* convertedFont_ = [sender convertFont:font_];
	[self setFontValue:convertedFont_];

	NSNotification	*notification_ = [NSNotification notificationWithName:BSFontValueDidChangeNotification object:self];
	[[NSNotificationCenter defaultCenter] postNotification:notification_];

	id	delegate_ = [self delegate];
	if (delegate_ && [delegate_ respondsToSelector:@selector(fontValueDidChange:)]) {
		[delegate_ fontValueDidChange:notification_];
	}
}

- (void)bs_windowWillClose:(NSNotification *)aNotification
{
	if ([self state] == NSOnState) {
	   [self deactivate];
	}
}

#pragma mark -
- (void)bind:(NSString *)binding toObject:(id)observableController withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
	if ([binding isEqualToString:@"fontValue"]) {
		if (![[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.InterfaceBuilder3"]) {
		[self addObserver:self
			   forKeyPath:@"fontValue"
				  options:NSKeyValueObservingOptionNew
				  context:bs_fontValueContext];

		[self setCachedControllerObject:observableController];
		[self setCachedKeyPath:keyPath];
		}
	}

	[super bind:binding toObject:observableController withKeyPath:keyPath options:options];
}

- (void)observeValueForKeyPath:(NSString *) keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == bs_fontValueContext) {
		[[self cachedControllerObject] setValue:[change objectForKey:NSKeyValueChangeNewKey] forKeyPath:[self cachedKeyPath]];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)unbind:(NSString *)binding
{
	if ([binding isEqualToString:@"fontValue"]) {
		[self removeObserver:self forKeyPath:@"fontValue"];
		[self setCachedKeyPath:nil];
		[self setCachedControllerObject:nil];
	}
	[super unbind: binding];
}
@end
