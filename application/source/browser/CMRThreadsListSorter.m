/**
  * $Id: CMRThreadsListSorter.m,v 1.1.1.1 2005/05/11 17:51:04 tsawada2 Exp $
  * 
  * CMRThreadsListSorter.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRThreadsListSorter.h"
#import "CMXPreferences.h"
#import "missing.h"
#import "CMRHistoryManager.h"
#import "CMRSearchOptions.h"
#import <SGAppKit/SGAppKit.h>

#import "CMRBrowserTemplateKeys.h"

#define kDefaultSearchToolbarItemWidth	104.0f
#define kDefaultSearchPopUpFrame		NSMakeRect(-3, 2, 30, 16)

#define kFindOptionsImage				@"FindOptions"
#define kLocalizableTableName			@"ThreadViewer"

#define kSearchHistoryItemAction		@selector(searchHistoryItemAction:)
#define kSearchThreadAction				@selector(searchThread:)

@interface CMRThreadsListSorter(ViewInitializer)
- (void) setupSearchOptionItemsWithPopUpButton : (NSPopUpButton *) popUpBtn
									searchMask : (CMRSearchMask  ) searchMask;
- (void) setupSearchOptionItemsWithPopUpButton : (NSPopUpButton *) popUpBtn;
- (void) resetSearchPopUp;
- (void) setupSearchPopUp;
- (void) setupSearchTextField;
- (void) setupSearchAccessoryView;
- (void) setupUIComponents;
@end



@interface CMRThreadsListSorter(History)<CMRHistoryClient>
- (void) synchronizeHistoryItemsWithManager;
@end



@implementation CMRThreadsListSorter
- (id) init
{
	if (self = [super init]) {
		if (NO == [NSBundle loadNibNamed : @"CMRThreadsListSorter"
								  owner : self]) {
			NSLog(@"Can't load nib<%@>", @"CMRThreadsListSorter");
			
			[self release];
			return nil;
		}
		
		[[CMRHistoryManager defaultManager] addClient : self];
		[[NSNotificationCenter defaultCenter]
			addObserver:self 
			selector:@selector(applicationWillReset:)
			name:CMRApplicationWillResetNotification
			object:nil];
		[[NSNotificationCenter defaultCenter]
			addObserver:self 
			selector:@selector(applicationDidReset:)
			name:CMRApplicationDidResetNotification
			object:nil];

	}
	return self;
}
- (void) awakeFromNib
{
	[self setupUIComponents];
}
- (void) dealloc
{
	[[CMRHistoryManager defaultManager] removeClient : self];
	[_view release];
	[_searchItemController release];
	[super dealloc];
}
@end


static NSMenuItem *kSearchHistoryPopUpItem;

@implementation CMRThreadsListSorter(History)
// アプリケーションのリセット
- (void) applicationWillReset : (NSNotification *) theNotification
{
	[[CMRHistoryManager defaultManager] removeClient : self];
}
- (void) applicationDidReset : (NSNotification *) theNotification
{
	[[CMRHistoryManager defaultManager] addClient : self];
	[self resetSearchPopUp];
}

// タイトルがインデントされたmenuItem
+ (NSMenuItem *) searchPopUpHistoryItemWithTitle : (NSString *) aTitle
{
	NSMenuItem		*item_;
	NSString		*title_;
	
	
	if (nil == kSearchHistoryPopUpItem) {
		NSString	*title_;
		
		title_ = NSLocalizedStringFromTable(
					@"Search PopUp History Indent",
					kLocalizableTableName,
					@"Search PopUp History Indent");
		kSearchHistoryPopUpItem = 
			[[NSMenuItem alloc] initWithTitle : title_
									   action : kSearchHistoryItemAction
								keyEquivalent : @""];
	}

	item_ = [kSearchHistoryPopUpItem copy];
	title_ = [item_ title];
	title_ = [title_ stringByAppendingString : aTitle];
	[item_ setTitle : title_];
	[item_ setAction : kSearchHistoryItemAction];
	[item_ setTag : kSearchPopUpHistoryItemTag];
	
	return [item_ autorelease];
}
+ (NSMenuItem *) searchPopUpSeparatorItem
{
	NSMenuItem	*menuItem_;
	
	menuItem_ = (NSMenuItem*)[NSMenuItem separatorItem];
	[menuItem_ setTag : kSearchPopUpSeparatorTag];
	
	return menuItem_;
}
+ (NSMenuItem *) searchPopUpHistoryHeadertem
{
	static NSMenuItem *kHeaderItem;
	
	if (nil == kHeaderItem) {
		NSString	*title_;
		
		title_ = NSLocalizedStringFromTable(
					@"Search PopUp History Title",
					kLocalizableTableName,
					@"Search PopUp History Title");
		kHeaderItem = [NSMenuItem alloc];
		kHeaderItem = [kHeaderItem initWithTitle : title_
												action : NULL
										 keyEquivalent : @""];
		[kHeaderItem setEnabled : NO];
		[kHeaderItem setTag : kSearchPopUpHistoryHeaderItemTag];
	}
	return [[kHeaderItem copy] autorelease];
}

- (void) removeSearchOptionHistoryItems
{
	NSPopUpButton	*popUp_;
	int				i, cnt;
	int				separatorIndex_;
	
	popUp_ = [self searchPopUp];
	separatorIndex_ = [popUp_ indexOfItemWithTag : kSearchPopUpSeparatorTag];
	if (-1 == separatorIndex_)
		return;
	
	cnt = [popUp_ numberOfItems];
	for (i = cnt; i >= separatorIndex_; i--)
		[popUp_ removeItemAtIndex : i];
}

- (void) synchronizeHistoryItemsWithManager
{
	NSPopUpButton		*popUp_;
	CMRHistoryManager	*hm = [CMRHistoryManager defaultManager];
	NSArray				*itemArray_;
	unsigned			i, cnt;
	
	popUp_ = [self searchPopUp];
	[self removeSearchOptionHistoryItems];
	
	itemArray_ = [hm historyItemArrayForType : 
						CMRHistorySearchListOptionEntryType];
	UTILAssertNotNil(itemArray_);
	
	cnt = [itemArray_ count];
		[[popUp_ menu] addItem : [[self class] searchPopUpSeparatorItem]];
		[[popUp_ menu] addItem : [[self class] searchPopUpHistoryHeadertem]];
	
	for (i = 0; i < cnt; i++) {
		CMRHistoryItem	*item_;
		
		item_ = [itemArray_ objectAtIndex : i];
		[self historyManager : hm
		   insertHistoryItem : item_
					 atIndex : [popUp_ numberOfItems]];
	}
}
- (void) historyManager : (CMRHistoryManager *) aManager
	  insertHistoryItem : (CMRHistoryItem    *) anItem
				atIndex : (unsigned int       ) anIndex
{
	NSPopUpButton		*popUp_;
	NSMenuItem			*menuItem_;
	
	if ([anItem type] != CMRHistorySearchListOptionEntryType)
		return;
	
	popUp_ = [self searchPopUp];
	
	menuItem_ = [[self class] searchPopUpHistoryItemWithTitle : [anItem title]];
	[menuItem_ setTarget : self];
	[menuItem_ setRepresentedObject : anItem];
	
	[[popUp_ menu] addItem : menuItem_];
}

- (void) historyManager : (CMRHistoryManager *) aManager
	  removeHistoryItem : (CMRHistoryItem    *) anItem
				atIndex : (unsigned int       ) anIndex
{
	NSPopUpButton		*popUp_;
	int					index_;
	
	if ([anItem type] != CMRHistorySearchListOptionEntryType)
		return;
	
	popUp_ = [self searchPopUp];
	index_ = [popUp_ indexOfItemWithRepresentedObject : anItem];
	if (-1 == index_) return;
	
	if (index_ == ([popUp_ numberOfItems] -1))
		[self removeSearchOptionHistoryItems];
	else
		[popUp_ removeItemAtIndex : index_];
}

- (void) historyManager : (CMRHistoryManager *) aManager
	  changeHistoryItem : (CMRHistoryItem    *) anItem
				atIndex : (unsigned int       ) anIndex
{
	NSPopUpButton		*popUp_;
	NSMenuItem			*menuItem_;
	SEL					action_;
	int					index_;
	
	if ([anItem type] != CMRHistorySearchListOptionEntryType)
		return;
	
	popUp_ = [self searchPopUp];
	action_ = NULL;
	;
	if (-1 == (index_ = [popUp_ indexOfItemWithRepresentedObject : anItem]))
		return;
	
	menuItem_ = (NSMenuItem*)[popUp_ itemAtIndex : index_];

	[menuItem_ setRepresentedObject : anItem];
}

- (IBAction) searchHistoryItemAction : (id) sender
{
	id					controller_;
	CMRHistoryItem		*item_;
	CMRSearchOptions	*options_;
	
	UTILAssertRespondsTo(sender, @selector(representedObject));
	item_ = [sender representedObject];
	UTILAssertKindOfClass(item_, CMRHistoryItem);
	
	options_ = (CMRSearchOptions*)[item_ representedObject];
	UTILAssertKindOfClass(options_, CMRSearchOptions);
	
	if (nil == [options_ findObject])
		return;
	
	
	if ([[options_ userInfo] respondsToSelector : @selector(unsignedIntValue)]) {
		CMRSearchMask		searchMask_;
		
		searchMask_ = [[options_ userInfo] unsignedIntValue];
		[self setupSearchOptionItemsWithPopUpButton : [self searchPopUp]
										 searchMask : searchMask_];
	}
	
	controller_ = [self searchItemController];
	[controller_ setStringValue : [options_ findObject]];
	[controller_ sendTextFieldAction];
	[controller_ selectAll : nil];
}
@end



@implementation CMRThreadsListSorter(ViewInitializer)
- (void) setupSearchOptionItemsWithPopUpButton : (NSPopUpButton *) popUpBtn
									searchMask : (CMRSearchMask  ) searchMask
{

	CMRSearchMask searchMasks_[] = {
									CMRSearchOptionCaseInsensitive,
									CMRSearchOptionZenHankakuInsensitive,
									CMRSearchOptionIgnoreSpecified
								};
								
	NSString *itemNameKeys_[] = {
									@"Case Insensitive",
									@"Zenkaku/Hankaku Insensitive",
									@"Ignore Specified"
								};
	int				i, cnt;
	
	UTILAssertNotNil(popUpBtn);
	cnt = UTILNumberOfCArray(searchMasks_);
	
	NSAssert2(
		cnt == UTILNumberOfCArray(itemNameKeys_),
		@"searchMasks_[] count expected (%u) but was (%u).",
		UTILNumberOfCArray(itemNameKeys_),
		cnt);
	
	for (i = 0; i < cnt; i++) {
		NSString			*label_;
		NSMenuItem			*item_;
		NSNumber			*rep_;
		NSCellStateValue	state_;
		
		label_ = NSLocalizedStringFromTable(
					itemNameKeys_[i],
					kLocalizableTableName,
					@"search option lable.");
		
		rep_  = [NSNumber numberWithUnsignedInt : searchMasks_[i]];
		item_ = (NSMenuItem*)[popUpBtn itemWithTitle : label_];
		if (nil == item_) {
			[popUpBtn addItemWithTitle : label_];
			item_ = (NSMenuItem*)[popUpBtn lastItem];
			[item_ setTag : kSearchPopUpOptionItemTag];
			[item_ setRepresentedObject : rep_];
			[item_ setAction : @selector(searchToolbarPopupChanged:)];
			[item_ setTarget : nil];
		}
		
		state_ = (searchMasks_[i] & searchMask) ? NSOnState : NSOffState;
		if (CMRSearchOptionCaseInsensitive == searchMasks_[i] || 
		   CMRSearchOptionZenHankakuInsensitive == searchMasks_[i]) {
			// 意味が逆になっている。
			state_ = (state_ == NSOnState) ? NSOffState : NSOnState;
		}
		[item_ setState : state_];
	}
}
- (void) setupSearchOptionItemsWithPopUpButton : (NSPopUpButton *) popUpBtn
{
	[self setupSearchOptionItemsWithPopUpButton:popUpBtn searchMask:[CMRPref threadSearchOption]];
}
- (void) resetSearchPopUp
{
	NSPopUpButton	*pb_	= [self searchPopUp];
	id tmp;

	[pb_ removeAllItems];
	[pb_ addItemWithTitle : @""];
	[self setupSearchOptionItemsWithPopUpButton : pb_];
	
	// Incremental Search の場合は検索語句の履歴メニューを表示しない
    tmp = SGTemplateResource(kBrowserIncrementalSearchKey);
    UTILAssertRespondsTo(tmp, @selector(boolValue));
    if(NO == [tmp boolValue]){
		[self synchronizeHistoryItemsWithManager];
	}
	
	[pb_ setBordered : NO];
	[pb_ setAutoenablesItems : NO];
	
	[[pb_ cell] setArrowPosition : NSPopUpNoArrow];
	[pb_ setImagePosition : NSImageOnly];
	[[pb_ itemAtIndex:0] setImage : [NSImage imageAppNamed : kFindOptionsImage]];
	[pb_ setAutoresizingMask : NSViewMaxXMargin];
}
- (void) setupSearchPopUp
{
	NSPopUpButton	*pb_	= [self searchPopUp];
	
	UTILAssertNotNil(pb_);
	
	[pb_ setFrame : kDefaultSearchPopUpFrame];

	[self resetSearchPopUp];
}

- (void) setupSearchTextField
{
	NSTextField		*field_;
	id				tmp;

	field_ = [self searchTextField];
	[field_ setAction : kSearchThreadAction];
	[field_ setTarget : nil];
	[[field_ cell] setSendsActionOnEndEditing : YES];

	// Incremental Search
	tmp = SGTemplateResource(kBrowserIncrementalSearchKey);
    UTILAssertRespondsTo(tmp, @selector(boolValue));

	[[self searchItemController] setSendsActionOnTextDidChange : [tmp boolValue]];
}

- (void) setupSearchAccessoryView
{
	NSSize		size_;
	NSView		*item_ = [self searchView];
	
	size_ = [item_ bounds].size;
	size_.width = kDefaultSearchToolbarItemWidth;
	[item_ setAutoresizingMask : NSViewWidthSizable];
	[item_ setFrameSize : size_];
	
	[[self searchItemController] setAccessoryView : [self searchPopUp]];
}
- (void) setupUIComponents
{
	[self setupSearchPopUp];
	[self setupSearchTextField];
	[self setupSearchAccessoryView];
}
@end



@implementation CMRThreadsListSorter(ViewAccessor)
- (NSView *) componentView
{
	return [[self searchItemController] componentView];
}
- (NSView *) searchView
{
	return [[self searchItemController] backgroundView];
}
- (NSPopUpButton *) searchPopUp
{
	return _searchPopUp;
}
- (NSTextField *) searchTextField
{
	return [[self searchItemController] textField];
}
- (SGTextAccessoryFieldController *) searchItemController
{
	if (nil == _searchItemController) {
		NSRect		frame_;
		
		frame_.origin = NSZeroPoint;
		frame_.size.width = kDefaultSearchToolbarItemWidth;
		frame_.size.height = [SGTextAccessoryFieldController preferedHeight];
		
		_searchItemController = 
			[[SGTextAccessoryFieldController alloc] 
							initWithViewFrame : frame_];
		[[_searchItemController backgroundView] retain];
	}
	return _searchItemController;
}
@end