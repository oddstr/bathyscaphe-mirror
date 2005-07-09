//
//  CMRNSSearchField.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/04/30.
//

#import "CMRNSSearchField.h"
#import "AppDefaults.h"
#import "CMRSearchOptions.h"

#define kSearchFieldNibName				@"PantherSearchField"
#define kLocalizableTableName			@"ThreadViewer"

/*
	pantherSearchField のターゲットとアクションは
	CMRBrowser 側で初期化する際に設定する。CMRBrowser-ViewAccessor.m を参照のこと。
*/

# pragma mark -

@implementation CMRNSSearchField
- (id) init
{
	if(self = [super init]){
		if(NO == [NSBundle loadNibNamed : kSearchFieldNibName owner : self]){
			NSLog(@"can't load Nib file - PantherSearchField.nib");
			[self autorelease];
			return nil;
		}
	}
	return self;
}
- (void) awakeFromNib
{
	[self setupUIComponents];
}


- (NSSearchField *) pantherSearchField
{
	return searchField;
}

- (void) setupUIComponents
{
	NSMenuItem		*hItem1, *hItem2, *hItem3, *hItem5;
	id				hItem4;
	
	BOOL	isIncremental;

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
	
	NSMenu	*cellMenu	= [[[NSMenu alloc] initWithTitle : @"Search Menu"] autorelease];
    id		searchCell	= [[self pantherSearchField] cell];

	isIncremental = [CMRPref useIncrementalSearch];
	[searchCell setSendsWholeSearchString : (NO == isIncremental)];
	
	if (!isIncremental) {
		int maxValu = [CMRPref maxCountForSearchHistory];
		[searchCell setMaximumRecents : maxValu];
	}

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
		
		label_ = NSLocalizedStringFromTable(itemNameKeys_[i], kLocalizableTableName, nil);
		
		rep_  = [NSNumber numberWithUnsignedInt : searchMasks_[i]];
		item_ = [[NSMenuItem alloc] initWithTitle : label_
										   action : @selector(searchToolbarPopupChanged:)
									keyEquivalent : @""];

		[item_ setTag : kSearchPopUpOptionItemTag];
		[item_ setRepresentedObject : rep_];
		
		state_ = (searchMasks_[i] & [CMRPref threadSearchOption]) ? NSOnState : NSOffState;

		if (CMRSearchOptionCaseInsensitive == searchMasks_[i] || 
		   CMRSearchOptionZenHankakuInsensitive == searchMasks_[i]) {
			// 意味が逆になっている。
			state_ = (state_ == NSOnState) ? NSOffState : NSOnState;
		}
		[item_ setState : state_];
		[cellMenu insertItem:item_ atIndex:i];
		[item_ release];
	}

	if (!isIncremental) {
		[cellMenu insertItem : [NSMenuItem separatorItem] atIndex : cnt];

		hItem1 = [[NSMenuItem alloc] initWithTitle : NSLocalizedStringFromTable(@"Search PopUp History Title",
														kLocalizableTableName, nil)
											action : NULL
									 keyEquivalent : @""];
		[hItem1 setTag : NSSearchFieldRecentsTitleMenuItemTag];
		[cellMenu insertItem : hItem1 atIndex : (cnt+1)];
		[hItem1 release];

		hItem2 = [[NSMenuItem alloc] initWithTitle : NSLocalizedStringFromTable(@"Search PopUp NoHistory Title",
														kLocalizableTableName, nil)
											action : NULL
									 keyEquivalent : @""];
		[hItem2 setTag : NSSearchFieldNoRecentsMenuItemTag];
		[cellMenu insertItem : hItem2 atIndex : (cnt+2)];
		[hItem2 release];

		hItem3 = [[NSMenuItem alloc] initWithTitle : NSLocalizedStringFromTable(@"Search PopUp History Title",
														kLocalizableTableName, nil)
											action : NULL
									 keyEquivalent : @""];
		[hItem3 setTag : NSSearchFieldRecentsMenuItemTag];
		[cellMenu insertItem : hItem3 atIndex : (cnt+3)];
		[hItem3 release];

		hItem4 = [NSMenuItem separatorItem];
		[hItem4 setTag : NSSearchFieldClearRecentsMenuItemTag];
		[cellMenu insertItem : hItem4 atIndex : (cnt+4)];

		hItem5 = [[NSMenuItem alloc] initWithTitle : NSLocalizedStringFromTable(@"Search Popup History Clear",
														kLocalizableTableName, nil)
											action : NULL
									 keyEquivalent : @""];
		[hItem5 setTag : NSSearchFieldClearRecentsMenuItemTag];
		[cellMenu insertItem : hItem5 atIndex : (cnt+5)];
		[hItem5 release];
	}
	
    [searchCell setSearchMenuTemplate : cellMenu];
}
@end
