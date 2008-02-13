//
//  BSLocalRulesPanelController.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/02/11.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSLocalRulesPanelController.h"


@implementation BSLocalRulesPanelController
- (id) init
{
	if (self = [super initWithWindowNibName:@"BSLocalRulesPanel"]) {
		[self setWindowFrameAutosaveName:@"BathyScaphe: Local Rules Panel Autosave"];
	}
	return self;
}

- (NSObjectController *)objectController
{
	return m_objectController;
}

- (IBAction)reload:(id)sender
{
	id collector = [[self objectController] content];
	if ([collector respondsToSelector:@selector(reload)]) {
		[collector reload];
	}
}

- (IBAction)showWindow:(id)sender
{
	NSWindow *window = [self window];
	if ([window isVisible] && [window isKeyWindow]) {
		[window orderOut:sender];
	} else {
		[window makeKeyAndOrderFront:sender];
	}
}
@end
