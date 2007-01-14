//
//  BSFontWellInspector.m
//  BSFontWell
//
//  Created by Tsutomu Sawada on 06/12/12.
//  Copyright BathyScaphe Project 2006 . All rights reserved.
//

#import "BSFontWellInspector.h"
#import "BSFontWell.h"

@implementation BSFontWellInspector

- (id)init
{
    self = [super init];
    [NSBundle loadNibNamed:@"BSFontWellInspector" owner:self];
	[m_fontWell setDelegate: self];

	NSNotificationCenter *nc_ = [NSNotificationCenter defaultCenter];
	[nc_ addObserver: self
			selector: @selector(paneChanged:)
				name: IBWillInspectWithModeNotification
			  object: nil];
	[nc_ addObserver: self
			selector: @selector(objectChanged:)
				name: IBWillInspectObjectNotification
			  object: nil];

    return self;
}

- (void) paneChanged: (NSNotification *) aNotification
{
	if (NO == [[aNotification object] isEqualToString: IBInspectAttributesMode]) {
		[m_fontWell deactivate];
	}
}

- (void) objectChanged: (NSNotification *) aNotification
{
	if ([aNotification object] != [self object]) {
		[m_fontWell deactivate];
		[[NSFontManager sharedFontManager] setAction: @selector(changeIBFont:)];
	}
}

- (void)ok:(id)sender
{
	/* Your code Here */
	BSFontWell	*selectedView = [self object];
	[selectedView setFontValue: [m_fontWell fontValue]];
    [super ok:sender];
}

- (void)revert:(id)sender
{
	/* Your code Here */
	BSFontWell	*selectedView = [self object];
	[m_fontWell setFontValue: [selectedView fontValue]];
    [super revert:sender];
}

- (void) fontValueDidChange: (NSNotification *) aNotification
{
	[self ok: [aNotification object]];
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[super dealloc];
}
@end
