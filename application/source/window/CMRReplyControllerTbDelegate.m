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


static NSString *const kReplyWindowToolbarIdentifier = @"Reply Window Toolbar";

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


@implementation CMRReplyControllerTbDelegate
- (NSString *) identifier
{
	return kReplyWindowToolbarIdentifier;
}
@end

@implementation CMRReplyControllerTbDelegate(Protected)
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
}
/*
- (void)configureToolbar:(NSToolbar *)aToolbar
{
	[aToolbar setAllowsUserCustomization:YES];
	[aToolbar setAutosavesConfiguration:YES];
}*/
@end



@implementation CMRReplyControllerTbDelegate(NSToolbarDelegate)
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
	return [NSArray arrayWithObjects:
				kSendMessageIdentifier,
				NSToolbarSeparatorItemIdentifier,
				kSaveAsDraftIdentifier,
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
				NSToolbarSeparatorItemIdentifier,
				NSToolbarFlexibleSpaceItemIdentifier,
				NSToolbarSpaceItemIdentifier,
				nil];
}
@end
