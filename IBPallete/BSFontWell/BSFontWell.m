/* encoding="UTF-8"
 *
 * BSFontWell.m
 * BathyScaphe
 *
 * Copyright 2005-2007 BathyScaphe Project. All rights reserved.
 * Last Update: 2007-01-14
 */

#import "BSFontWell.h"

NSString *const BSFontValueDidChangeNotification = @"BSFontValueDidChangeNotification";

@implementation BSFontWell
static NSMutableArray	*bs_fontWells = nil;

static void	*bs_fontValueContext = @"Akazukin";

+ (void) initialize
{
    if (self == [BSFontWell class]) {
		CFArrayCallBacks arrayCallBacks = kCFTypeArrayCallBacks;
		arrayCallBacks.retain = NULL;
		arrayCallBacks.release = NULL;
		bs_fontWells = (NSMutableArray *)CFArrayCreateMutable(NULL, 0, &arrayCallBacks);

        [self exposeBinding: @"fontValue"];
    }
}

- (id) initWithCoder: (NSCoder *) coder
{
    if (self = [super initWithCoder: coder]) {
        [self setFontValue: [coder decodeObject]];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *) coder
{
    [super encodeWithCoder: coder];
    [coder encodeObject: [self fontValue]];
}

- (void) awakeFromNib
{
	if (NSNotFound == [bs_fontWells indexOfObjectIdenticalTo: self]) {
		[bs_fontWells addObject: self];
	}

	[self setTarget: self];
	[self setAction: @selector(bsFontWellPushed:)];
}
 
- (void) dealloc
{
	[bs_fontWells removeObjectIdenticalTo: self];
	[self setDelegate: nil];
    [m_actualFont release];
    [super dealloc];
}

#pragma mark -
- (void) bsFontWellPushed : (id) sender
{
	int		state = [self state];

	if (state == NSOnState) {
		[self activate];
	}
	if (state == NSOffState) {
		[self deactivate];
	}
}

- (void) updateTitle
{
    NSFont      *font_ = [self fontValue];
    NSFont      *displayFont_;
    NSFontManager   *fm_ = [NSFontManager sharedFontManager];
	NSString	*titlestr_;
	titlestr_ = [NSString stringWithFormat: @"%@ %.0f", [font_ displayName], [font_ pointSize]];

	displayFont_ = [fm_ fontWithFamily: [font_ familyName] 
								traits: [fm_ traitsOfFont: font_] 
								weight: [fm_ weightOfFont: font_]
								  size: 12.0];//[[self font] pointSize]]; // 応急処置

	[self setTitle: titlestr_];
	[self setFont: displayFont_];
}

- (id) cachedControllerObject
{
	return m_controller;
}

- (void) setCachedControllerObject: (id) aController
{
	[aController retain];
	[m_controller release];
	m_controller = aController;
}

- (NSString *) cachedKeyPath
{
	return m_keyPath;
}

- (void) setCachedKeyPath: (NSString *) aString
{
	[aString retain];
	[m_keyPath release];
	m_keyPath = aString;
}

- (NSFont *) fontValue
{
    return m_actualFont;
}

- (void) setFontValue: (NSFont *) aFont
{
    [aFont retain];
    [m_actualFont release];
    m_actualFont = aFont;
    [self updateTitle];
}

- (id) delegate
{
	return m_delegate;
}

- (void) setDelegate: (id) anObject
{
	m_delegate = anObject;
}

- (void) activate
{
	NSFontManager	*fm_ = 	[NSFontManager sharedFontManager];

	[fm_ setSelectedFont: [self fontValue] isMultiple: NO];

	[fm_ setAction: @selector(changeFont:)];
    [fm_ orderFrontFontPanel: self];

	[[NSFontPanel sharedFontPanel] setDelegate: self];

	NSEnumerator	*enumerator_ = [bs_fontWells objectEnumerator];
	BSFontWell		*fontWell_;
	while (fontWell_ = [enumerator_ nextObject]) {
		if (fontWell_ != self) {
			[fontWell_ deactivate];
		}
	}
	[[self window] makeFirstResponder: self];
}

- (void) deactivate
{
	[self setState: NSOffState];
	[[self window] makeFirstResponder: nil];
}


#pragma mark -
- (void) changeFont: (id) sender
{
	NSFont* font_ = [self fontValue];
	NSFont* convertedFont_ = [sender convertFont: font_];
	[self setFontValue: convertedFont_];

	NSNotification	*notification_ = [NSNotification notificationWithName: BSFontValueDidChangeNotification object: self];
	[[NSNotificationCenter defaultCenter] postNotification: notification_];

	id	delegate_ = [self delegate];
	if (delegate_ != nil && [delegate_ respondsToSelector: @selector(fontValueDidChange:)]) {
		[delegate_ fontValueDidChange: notification_];
	}
}

- (void) windowWillClose: (NSNotification *) aNotification
{
	if ([self state] == NSOnState)
	   [self deactivate];
}

#pragma mark -
- (void) bind: (NSString *) binding toObject: (id) observableController withKeyPath: (NSString *) keyPath options: (NSDictionary *) options
{
	if ([binding isEqualToString: @"fontValue"]) {
		[self addObserver: self
			   forKeyPath: @"fontValue"
				  options: NSKeyValueObservingOptionNew //(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
				  context: bs_fontValueContext];

		[self setCachedControllerObject: observableController];
		[self setCachedKeyPath: keyPath];
	}

	[super bind: binding toObject: observableController withKeyPath: keyPath options: options];
}

- (void) observeValueForKeyPath: (NSString *) keyPath ofObject: (id) object change: (NSDictionary *) change context: (void *) context
{
	if (context == bs_fontValueContext) {
/*		id objNew = [change objectForKey: NSKeyValueChangeNewKey];
		if (objNew == [change objectForKey: NSKeyValueChangeOldKey]) {
			NSLog(@"No Need to call setValue:");
			return;
		}*/
		[[self cachedControllerObject] setValue: [change objectForKey: NSKeyValueChangeNewKey] forKeyPath: [self cachedKeyPath]];
	} else {
		[super observeValueForKeyPath: keyPath ofObject: object change: change context: context];
	}
}

- (void) unbind: (NSString *) binding
{
	if ([binding isEqualToString: @"fontValue"]) {
		[self removeObserver: self forKeyPath: @"fontValue"];
		[self setCachedKeyPath: nil];
		[self setCachedControllerObject: nil];
	}
	[super unbind: binding];
}
@end
