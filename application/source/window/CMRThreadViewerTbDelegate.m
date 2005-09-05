//:CMRThreadViewerTbDelegate.m
/**
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (02/11/09  9:11:09 PM)
  *
  */
#import "CMRThreadViewerTbDelegate_p.h"
#import "AppDefaults.h"
#import "BSSegmentedControlTbItem.h"

//////////////////////////////////////////////////////////////////////
////////////////////// [ 定数やマクロ置換 ] //////////////////////////
//////////////////////////////////////////////////////////////////////

// スレッドの更新
static NSString *const st_reloadItem_Identifier				= @"Reload Thread";
static NSString *const st_reloadItem_LabelKey				= @"Reload Thread Label";
static NSString *const st_reloadItem_PaletteLabelKey		= @"Reload Thread Palette Label";
static NSString *const st_reloadItem_ToolTipKey				= @"Reload Thread ToolTip";
static NSString *const st_reloadThread_imageName			= @"ReloadThread";

// レス
static NSString *const st_ReplyItem_Identifier			= @"Reply";
static NSString *const st_ReplyItem_LabelKey			= @"Reply Label";
static NSString *const st_ReplyItem_PaletteLabelKey		= @"Reply Palette Label";
static NSString *const st_ReplyItem_ToolTipKey			= @"Reply ToolTip";
static NSString *const st_ReplyItem_imageName			= @"ResToThread";

//「お気に入りに追加」
static NSString *const st_favoritesIdentifier			= @"AddFavorites";
static NSString *const st_favoritesLabelKey				= @"AddFavorites Label";
static NSString *const st_favoritesPaletteLabelKey		= @"AddFavorites Palette Label";
static NSString *const st_favoritesToolTipKey			= @"AddFavorites ToolTip";
static NSString *const st_favorites_imageName			= @"AddFavorites";

// 削除
static NSString *const st_deleteItemItemIdentifier			= @"Delete";
static NSString *const st_deleteItemItemLabelKey			= @"Delete Label";
static NSString *const st_deleteItemItemPaletteLabelKey		= @"Delete Palette Label";
static NSString *const st_deleteItemItemToolTipKey			= @"Delete ToolTip";
static NSString *const st_deleteItem_ImageName				= @"Delete";

// オンライン
static NSString *const st_onlineModeIdentifier			= @"OnlineMode";
static NSString *const st_onlineModeLabelKey			= @"OnlineMode Label";
static NSString *const st_onlineModePaletteLabelKey		= @"OnlineMode Palette Label";
static NSString *const st_onlineModeToolTipKey			= @"OnlineMode ToolTip";
static NSString *const st_onlineMode_ImageName			= @"online";

// Launch CMLogFinder
static NSString *const st_launchCMLFIdentifier			= @"Launch CMLF";
static NSString *const st_launchCMLFLabelKey			= @"Launch CMLF Label";
static NSString *const st_launchCMLFPaletteLabelKey		= @"Launch CMLF Palette Label";
static NSString *const st_launchCMLFToolTipKey			= @"Launch CMLF ToolTip";
static NSString *const st_launchCMLF_ImageName			= @"cmlf_icon";

// 停止
static NSString *const st_stopTaskIdentifier			= @"stopTask";
static NSString *const st_stopTaskLabelKey			= @"stopTask Label";
static NSString *const st_stopTaskPaletteLabelKey		= @"stopTask Palette Label";
static NSString *const st_stopTaskToolTipKey			= @"stopTask ToolTip";
static NSString *const st_stopTask_ImageName			= @"stopSign";

// 戻る／進む
static NSString *const st_historySegmentedControlIdentifier			= @"historySC";	
static NSString *const st_historySegmentedControlLabelKey			= @"historySC Label";
static NSString *const st_historySegmentedControlPaletteLabelKey	= @"historySC Palette Label";


static NSString *const st_localizableStringsTableName	= @"ThreadViewerTbItems";
static NSString *const st_toolbar_identifier			= @"Thread Window Toolbar";


@implementation CMRThreadViewerTbDelegate
- (NSString *) identifier
{
	return st_toolbar_identifier;
}
- (void) dealloc
{
	[super dealloc];
}
@end



@implementation CMRThreadViewerTbDelegate(Private)
- (NSString *) reloadThreadItemIdentifier
{
	return st_reloadItem_Identifier;
}
- (NSString *) replyItemIdentifier
{
	return st_ReplyItem_Identifier;
}
- (NSString *) addFavoritesItemIdentifier
{
	return st_favoritesIdentifier;
}
- (NSString *) deleteItemIdentifier
{
	return st_deleteItemItemIdentifier;
}
- (NSString *) toggleOnlineModeIdentifier
{
	return st_onlineModeIdentifier;
}
- (NSString *) launchCMLFIdentifier
{
	return st_launchCMLFIdentifier;
}
- (NSString *) stopTaskIdentifier
{
	return st_stopTaskIdentifier;
}
- (NSString *) historySegmentedControlIdentifier
{
	return st_historySegmentedControlIdentifier;
}
@end



@implementation CMRThreadViewerTbDelegate (Protected)
- (NSString *) labelForCMLF
{
	NSString *tmp_ = [CMRPref helperAppDisplayName];
	if (tmp_) {
		return tmp_;
	} else {
		return st_launchCMLFLabelKey;
	}
}
- (void) initializeToolbarItems : (NSWindow *) aWindow
{
	NSToolbarItem			*item_;
	NSWindowController		*wcontroller_;
	
	wcontroller_ = [aWindow windowController];
	UTILAssertNotNil(wcontroller_);

	item_ = [self appendToolbarItemWithItemIdentifier : [self reloadThreadItemIdentifier]
									localizedLabelKey : st_reloadItem_LabelKey
							 localizedPaletteLabelKey : st_reloadItem_PaletteLabelKey
								  localizedToolTipKey : st_reloadItem_ToolTipKey
											   action : @selector(reloadThread:)
											   target : nil];
	[item_ setImage : [NSImage imageAppNamed : st_reloadThread_imageName]];

	item_ = [self appendToolbarItemWithItemIdentifier : [self replyItemIdentifier]
									localizedLabelKey : st_ReplyItem_LabelKey
							 localizedPaletteLabelKey : st_ReplyItem_PaletteLabelKey
								  localizedToolTipKey : st_ReplyItem_ToolTipKey
											   action : @selector(reply:)
											   target : nil];
	[item_ setImage : [NSImage imageAppNamed : st_ReplyItem_imageName]];

	item_ = [self appendToolbarItemWithItemIdentifier : st_favoritesIdentifier
									localizedLabelKey : st_favoritesLabelKey
							 localizedPaletteLabelKey : st_favoritesPaletteLabelKey
								  localizedToolTipKey : st_favoritesToolTipKey
											   action : @selector(addFavorites:)
											   target : nil];
	[item_ setImage : [NSImage imageAppNamed : st_favorites_imageName]];

	item_ = [self appendToolbarItemWithItemIdentifier : [self deleteItemIdentifier]
									localizedLabelKey : st_deleteItemItemLabelKey
							 localizedPaletteLabelKey : st_deleteItemItemPaletteLabelKey
								  localizedToolTipKey : st_deleteItemItemToolTipKey
											   action : @selector(deleteThread:)
											   target : nil];
	[item_ setImage : [NSImage imageAppNamed : st_deleteItem_ImageName]];

	item_ = [self appendToolbarItemWithItemIdentifier : [self toggleOnlineModeIdentifier]
									localizedLabelKey : st_onlineModeLabelKey
							 localizedPaletteLabelKey : st_onlineModePaletteLabelKey
								  localizedToolTipKey : st_onlineModeToolTipKey
											   action : @selector(toggleOnlineMode:)
											   target : nil];
	[item_ setImage : [NSImage imageAppNamed : st_onlineMode_ImageName]];
	
	item_ = [self appendToolbarItemWithItemIdentifier : [self launchCMLFIdentifier]
									localizedLabelKey : [self labelForCMLF]
							 localizedPaletteLabelKey : [self labelForCMLF]
								  localizedToolTipKey : st_launchCMLFToolTipKey
											   action : @selector(launchCMLF:)
											   target : nil];
	[item_ setImage : [NSImage imageAppNamed : st_launchCMLF_ImageName]];
	
	item_ = [self appendToolbarItemWithItemIdentifier : [self stopTaskIdentifier]
									localizedLabelKey : st_stopTaskLabelKey
							 localizedPaletteLabelKey : st_stopTaskPaletteLabelKey
								  localizedToolTipKey : st_stopTaskToolTipKey
											   action : @selector(cancellCurrentTask:)
											   target : nil];
	[item_ setImage : [NSImage imageAppNamed : st_stopTask_ImageName]];
	
	item_ = [self appendToolbarItemWithClass : [BSSegmentedControlTbItem class]
								itemIdentifier : [self historySegmentedControlIdentifier]
							 localizedLabelKey : st_historySegmentedControlLabelKey
					  localizedPaletteLabelKey : st_historySegmentedControlPaletteLabelKey
						   localizedToolTipKey : nil
										action : NULL
										target : wcontroller_];

	[(BSSegmentedControlTbItem *)item_ setupItemViewWithTarget : wcontroller_];
	
}

- (void) configureToolbar : (NSToolbar *) aToolbar
{
	[aToolbar setAllowsUserCustomization : YES];
	[aToolbar setAutosavesConfiguration : YES];
}
@end



@implementation CMRThreadViewerTbDelegate (NSToolbarDelegate)
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
				[self reloadThreadItemIdentifier],
				NSToolbarSeparatorItemIdentifier,
				[self addFavoritesItemIdentifier],
				[self deleteItemIdentifier],
				NSToolbarFlexibleSpaceItemIdentifier,
				[self replyItemIdentifier],
				nil];
}
- (NSArray *) toolbarAllowedItemIdentifiers : (NSToolbar *) toolbar
{
	return [NSArray arrayWithObjects :
				[self reloadThreadItemIdentifier],
				[self stopTaskIdentifier],
				[self addFavoritesItemIdentifier],
				[self deleteItemIdentifier],
				[self replyItemIdentifier],
				[self toggleOnlineModeIdentifier],
				[self launchCMLFIdentifier],
				[self historySegmentedControlIdentifier],
				NSToolbarSeparatorItemIdentifier,
				NSToolbarFlexibleSpaceItemIdentifier,
				NSToolbarSpaceItemIdentifier,
				nil];
}
@end



@implementation CMRThreadViewerTbDelegate(CMRLocalizableStringsOwner)
+ (NSString *) localizableStringsTableName
{
	return st_localizableStringsTableName;
}
@end
