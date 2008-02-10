//
//  CMRReplyControllerTbDelegate.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/08/05.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRReplyControllerTbDelegate.h"
#import "CMRToolbarDelegateImp_p.h"
#import "CMRReplyController.h"


static NSString *const kReplyWindowToolbarIdentifier = @"Reply Window Toolbar";
static NSString *const kNewThreadWindowToolbarIdentifier = @"New Thread Window Toolbar";

static NSString *const kSendMessageIdentifier	= @"sendMessage";
static NSString *const kSendMessageLabelKey		= @"sendMessage Label";
static NSString *const kSendMessagePaletteLabelKey	= @"sendMessage Palette Label";
static NSString *const kSendMessageToolTipKey		= @"sendMessage ToolTip";
static NSString *const kSendMessageImageName		= @"SendMessage";

static NSString *const kSaveAsDraftIdentifier	= @"saveAsDraft";
static NSString *const kSaveAsDraftLabelKey		= @"saveAsDraft Label";
static NSString *const kSaveAsDraftPaletteLabelKey	= @"saveAsDraft Palette Label";
static NSString *const kSaveAsDraftToolTipKey		= @"saveAsDraft ToolTip";
static NSString *const kSaveAsDraftimageName		= @"SaveAsDraft";

static NSString *const kBeLoginIdentifier	= @"beLogin";
static NSString *const kBeLoginLabelKey		= @"beLogin Label";
static NSString *const kBeLoginPaletteLabelKey	= @"beLogin Palette Label";
static NSString *const kBeLoginToolTipKey		= @"beLogin ToolTip";
static NSString *const kBeLoginImageName		= @"beEnabled";

static NSString *const kInsertTemplateIdentifier = @"InsertTemplate";
static NSString *const kInsertTemplateLabelKey = @"InsertTemplate Label";
static NSString *const kInsertTemplateToolTipKey = @"InsertTemplate ToolTip";

static NSString *const kShowLocalRulesIdentifier = @"ShowLocalRules";
static NSString *const kShowLocalRulesLabelKey = @"ShowLocalRules Label";
static NSString *const kShowLocalRulesPaletteLabelKey = @"ShowLocalRules Palette Label";
static NSString *const kShowLocalRulesToolTipKey = @"ShowLocalRules ToolTip";
static NSString *const kShowLocalRulesImageName = @"Emoticon";


@implementation CMRReplyControllerTbDelegate
- (NSString *)identifier
{
	return kReplyWindowToolbarIdentifier;
}
@end

@implementation CMRReplyControllerTbDelegate(Protected)
- (void)setupInsertTemplateItem:(NSToolbarItem *)anItem itemView:(NSPopUpButton *)aView
{
	NSMenuItem *menuItem_ = [[NSMenuItem alloc] initWithTitle:[self localizedString:kInsertTemplateLabelKey] action:NULL keyEquivalent:@""];
	NSSize size_;
	
	[aView retain];

	[aView removeFromSuperviewWithoutNeedingDisplay];
	[anItem setView:aView];
	size_ = [aView frame].size;
	[anItem setMinSize:size_];
	[anItem setMaxSize:size_];

	[aView release];
	
	[menuItem_ setSubmenu:[aView menu]];
	[anItem setMenuFormRepresentation:menuItem_];
	[menuItem_ release];
}

- (void)initializeToolbarItems:(NSWindow *)aWindow
{
	NSToolbarItem			*item_;
	NSWindowController		*wcontroller_;
	
	wcontroller_ = [aWindow windowController];
	UTILAssertNotNil(wcontroller_);

	item_ = [self appendToolbarItemWithItemIdentifier:kSendMessageIdentifier
									localizedLabelKey:kSendMessageLabelKey
							 localizedPaletteLabelKey:kSendMessagePaletteLabelKey
								  localizedToolTipKey:kSendMessageToolTipKey
											   action:@selector(sendMessage:)
											   target:nil];
	[item_ setImage:[NSImage imageAppNamed:kSendMessageImageName]];

	item_ = [self appendToolbarItemWithItemIdentifier:kSaveAsDraftIdentifier
									localizedLabelKey:kSaveAsDraftLabelKey
							 localizedPaletteLabelKey:kSaveAsDraftPaletteLabelKey
								  localizedToolTipKey:kSaveAsDraftToolTipKey
											   action:@selector(saveDocument:)
											   target:nil];
	[item_ setImage:[NSImage imageAppNamed:kSaveAsDraftimageName]];

	item_ = [self appendToolbarItemWithItemIdentifier:kBeLoginIdentifier
									localizedLabelKey:kBeLoginLabelKey
							 localizedPaletteLabelKey:kBeLoginPaletteLabelKey
								  localizedToolTipKey:kBeLoginToolTipKey
											   action:@selector(toggleBeLogin:)
											   target:nil];
	[item_ setImage:[NSImage imageAppNamed:kBeLoginImageName]];

	item_ = [self appendToolbarItemWithItemIdentifier:kShowLocalRulesIdentifier
									localizedLabelKey:kShowLocalRulesLabelKey
							 localizedPaletteLabelKey:kShowLocalRulesPaletteLabelKey
								  localizedToolTipKey:kShowLocalRulesToolTipKey
											   action:@selector(showLocalRules:)
											   target:nil];
	[item_ setImage:[NSImage imageAppNamed:kShowLocalRulesImageName]];

	item_ = [self appendToolbarItemWithItemIdentifier:kInsertTemplateIdentifier
									localizedLabelKey:kInsertTemplateLabelKey
							 localizedPaletteLabelKey:kInsertTemplateLabelKey
								  localizedToolTipKey:kInsertTemplateToolTipKey
											   action:NULL
											   target:wcontroller_];
	[self setupInsertTemplateItem:item_ itemView:[(CMRReplyController *)wcontroller_ templateInsertionButton]];
}
@end



@implementation CMRReplyControllerTbDelegate(NSToolbarDelegate)
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
	return [NSArray arrayWithObjects:
				kSendMessageIdentifier,
				NSToolbarSeparatorItemIdentifier,
				kSaveAsDraftIdentifier,
				kInsertTemplateIdentifier,
				NSToolbarFlexibleSpaceItemIdentifier,
				kBeLoginIdentifier,
				nil];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
	return [NSArray arrayWithObjects:
				kSendMessageIdentifier,
				kSaveAsDraftIdentifier,
				kBeLoginIdentifier,
				kShowLocalRulesIdentifier,
				kInsertTemplateIdentifier,
				NSToolbarShowFontsItemIdentifier,
				NSToolbarSeparatorItemIdentifier,
				NSToolbarFlexibleSpaceItemIdentifier,
				NSToolbarSpaceItemIdentifier,
				nil];
}
@end


@implementation BSNewThreadControllerTbDelegate
- (NSString *)identifier
{
	return kNewThreadWindowToolbarIdentifier;
}
@end


@implementation BSNewThreadControllerTbDelegate(NSToolbarDelegate)
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
	return [NSArray arrayWithObjects:
				kSendMessageIdentifier,
				NSToolbarSeparatorItemIdentifier,
				kInsertTemplateIdentifier,
				NSToolbarFlexibleSpaceItemIdentifier,
				kShowLocalRulesIdentifier,
				kBeLoginIdentifier,
				nil];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
	return [NSArray arrayWithObjects:
				kSendMessageIdentifier,
				kBeLoginIdentifier,
				kShowLocalRulesIdentifier,
				kInsertTemplateIdentifier,
				NSToolbarShowFontsItemIdentifier,
				NSToolbarSeparatorItemIdentifier,
				NSToolbarFlexibleSpaceItemIdentifier,
				NSToolbarSpaceItemIdentifier,
				nil];
}
@end
