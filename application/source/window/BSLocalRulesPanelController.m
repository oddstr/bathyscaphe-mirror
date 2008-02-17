//
//  BSLocalRulesPanelController.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/02/11.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSLocalRulesPanelController.h"
#import "BSLocalRulesCollector.h"

@implementation BSLocalRulesPanelController
- (id) init
{
	if (self = [super initWithWindowNibName:@"BSLocalRulesPanel"]) {
		[self setWindowFrameAutosaveName:@"BathyScaphe: Local Rules Panel Autosave"];
	}
	return self;
}

- (void)dealloc
{
	[[self textView] unbind:@"attributedString"];
	[super dealloc];
}

- (NSObjectController *)objectController
{
	return m_objectController;
}

- (NSTextView *)textView
{
	return m_textView;
}

- (void)setObjectControllerContent:(id)contentObject bindToTextView:(BOOL)flag
{
	[[self objectController] setContent:contentObject];
	if ([contentObject isKindOfClass:[BSLocalRulesCollector class]] && flag) {
		NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
														 forKey:@"NSConditionallySetsEditable"/*NSConditionallySetsEditableBindingOption*/];
		[[self textView] bind:@"attributedString" toObject:[self objectController] withKeyPath:@"selection.localRulesAttrString" options:dict];
	}
}

- (IBAction)reload:(id)sender
{
	id collector = [[self objectController] content];
	if ([collector isKindOfClass:[BSLocalRulesCollector class]]) {
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
