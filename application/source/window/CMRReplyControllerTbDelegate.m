#import "CMRReplyControllerTbDelegate.h"
#import "CMRToolbarDelegateImp_p.h"


//////////////////////////////////////////////////////////////////////
///////////////////// [ COnstants, Defined ] /////////////////////////
//////////////////////////////////////////////////////////////////////
// Identifier
#define kReplyWindowToolbarIdentifier		@"Reply Window Toolbar"
// Items
#define kSendMessageIdentifier		@"sendMessage"
#define kSendMessageLabelKey		@"sendMessage Label"
#define kSendMessagePaletteLabelKey	@"sendMessage Palette Label"
#define kSendMessageToolTipKey		@"sendMessage ToolTip"
#define kSendMessageImageName		@"SendMessage"

#define kSaveAsDraftIdentifier		@"saveAsDraft"
#define kSaveAsDraftLabelKey		@"saveAsDraft Label"
#define kSaveAsDraftPaletteLabelKey	@"saveAsDraft Palette Label"
#define kSaveAsDraftToolTipKey		@"saveAsDraft ToolTip"
#define kSaveAsDraftimageName		@"SaveAsDraft"

#define kBeLoginIdentifier		@"beLogin"
#define kBeLoginLabelKey		@"beLogin Label"
#define kBeLoginPaletteLabelKey	@"beLogin Palette Label"
#define kBeLoginToolTipKey		@"beLogin ToolTip"
#define kBeLoginImageName		@"beEnabled"


@implementation CMRReplyControllerTbDelegate
- (NSString *) identifier
{
	return kReplyWindowToolbarIdentifier;
}
@end

@implementation CMRReplyControllerTbDelegate (Protected)
- (void) initializeToolbarItems : (NSWindow *) aWindow
{
	NSToolbarItem			*item_;
	NSWindowController		*wcontroller_;
	
	
	wcontroller_ = [aWindow windowController];
	UTILAssertNotNil(wcontroller_);

	item_ = [self appendToolbarItemWithItemIdentifier : kSendMessageIdentifier
									localizedLabelKey : kSendMessageLabelKey
							 localizedPaletteLabelKey : kSendMessagePaletteLabelKey
								  localizedToolTipKey : kSendMessageToolTipKey
											   action : @selector(sendMessage:)
											   target : nil];
	[item_ setImage : [NSImage imageAppNamed : kSendMessageImageName]];

	item_ = [self appendToolbarItemWithItemIdentifier : kSaveAsDraftIdentifier
									localizedLabelKey : kSaveAsDraftLabelKey
							 localizedPaletteLabelKey : kSaveAsDraftPaletteLabelKey
								  localizedToolTipKey : kSaveAsDraftToolTipKey
											   action : @selector(saveDocument:)
											   target : nil];
	[item_ setImage : [NSImage imageAppNamed : kSaveAsDraftimageName]];

	item_ = [self appendToolbarItemWithItemIdentifier : kBeLoginIdentifier
									localizedLabelKey : kBeLoginLabelKey
							 localizedPaletteLabelKey : kBeLoginPaletteLabelKey
								  localizedToolTipKey : kBeLoginToolTipKey
											   action : @selector(toggleBeLogin:)
											   target : nil];
	[item_ setImage : [NSImage imageAppNamed : kBeLoginImageName]];
}

- (void) configureToolbar : (NSToolbar *) aToolbar
{
	[aToolbar setAllowsUserCustomization : YES];
	[aToolbar setAutosavesConfiguration : YES];
}
@end



@implementation CMRReplyControllerTbDelegate (NSToolbarDelegate)
- (NSToolbarItem *) toolbar : (NSToolbar *) toolbar
      itemForItemIdentifier : (NSString  *) itemIdentifier
  willBeInsertedIntoToolbar : (BOOL       ) willBeInsertedIntoToolbar
{
	NSToolbarItem		*item_;
	
	UTILAssertNotNilArgument(toolbar, @"Toolbar");
	UTILAssertNotNilArgument(itemIdentifier, @"itemIdentifier");
	
	if(NO == [[self identifier] isEqualToString : [toolbar identifier]])
		return nil;
	
	item_ = [self itemForItemIdentifier : itemIdentifier];
	
	return item_;
}

- (NSArray *) toolbarDefaultItemIdentifiers : (NSToolbar *) toolbar
{
	return [NSArray arrayWithObjects :
				kSendMessageIdentifier,
				NSToolbarSeparatorItemIdentifier,
				kSaveAsDraftIdentifier,
				NSToolbarFlexibleSpaceItemIdentifier,
				kBeLoginIdentifier,
				//NSToolbarShowFontsItemIdentifier,
				nil];
}
- (NSArray *) toolbarAllowedItemIdentifiers : (NSToolbar *) toolbar
{
	return [NSArray arrayWithObjects :
				kSendMessageIdentifier,
				kSaveAsDraftIdentifier,
				kBeLoginIdentifier,
				//NSToolbarShowFontsItemIdentifier,
				//NSToolbarShowColorsItemIdentifier,
				NSToolbarSeparatorItemIdentifier,
				NSToolbarFlexibleSpaceItemIdentifier,
				NSToolbarSpaceItemIdentifier,
				nil];
}
@end



@implementation CMRReplyControllerTbDelegate(CMRLocalizableStringsOwner)
+ (NSString *) localizableStringsTableName
{
	return @"ReplyWindowToolbarItems";
}
@end
