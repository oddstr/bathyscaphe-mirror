//
//  CMRNSSearchField.m
//  CocoMonar
//
//  Created by Tsutomu Sawada on 05/04/30.
//

#import "CMRNSSearchField.h"
#import "CMRBrowser.h"
#import "CMXPreferences.h"
//#import "CMRThreadsListSorter.h"
#import "CMRSearchOptions.h"
#import "CMRBrowserTemplateKeys.h"

#define kSearchFieldNibName				@"PantherSearchField"
#define kLocalizableTableName			@"ThreadViewer"
#define kHistorySearchListLimitKey    @"History - Limit(SearchList)"

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

# pragma mark -

- (NSSearchField *) pantherSearchField
{
	return searchField;
}

#pragma mark -

- (IBAction) searchString : (id) sender
{
	[CMRMainBrowser searchThreadWithString : [sender stringValue]];
}

- (void) setupUIComponents
{
	NSMenuItem		*hItem1, *hItem2, *hItem3, *hItem4;
	id				hItem5;
	
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
	id		tmp			= SGTemplateResource(kBrowserIncrementalSearchKey);
	
    UTILAssertRespondsTo(tmp, @selector(boolValue));
	isIncremental = (NO == [tmp boolValue]);
	[searchCell setSendsWholeSearchString : isIncremental];
	
	if (isIncremental) {
		id maxValu = SGTemplateResource(kHistorySearchListLimitKey);
		[searchCell setMaximumRecents : [maxValu unsignedIntValue]];
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
		
		label_ = NSLocalizedStringFromTable(
					itemNameKeys_[i],
					kLocalizableTableName,
					@"search option lable.");
		
		rep_  = [NSNumber numberWithUnsignedInt : searchMasks_[i]];
		item_ = [[NSMenuItem alloc] initWithTitle:label_
                                         action:@selector(searchToolbarPopupChanged:)
                                         keyEquivalent:@""];
		[item_ setTag : kSearchPopUpOptionItemTag];
		[item_ setRepresentedObject : rep_];
		//[item_ setTarget : nil];
		
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

	if (isIncremental) {
		[cellMenu insertItem : [NSMenuItem separatorItem] atIndex : cnt];

		hItem1 = [[NSMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(
					@"Search PopUp History Title", kLocalizableTableName, @"search option lable.")
											action:NULL keyEquivalent:@""];
		[hItem1 setTag:NSSearchFieldRecentsTitleMenuItemTag];
		[cellMenu insertItem:hItem1 atIndex: (cnt+1)];
		[hItem1 release];

		hItem4 = [[NSMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(
					@"Search PopUp NoHistory Title", kLocalizableTableName, @"search option lable.")
											action:NULL keyEquivalent:@""];
		[hItem4 setTag:NSSearchFieldNoRecentsMenuItemTag];
		[cellMenu insertItem:hItem4 atIndex: (cnt+2)];
		[hItem4 release];

		hItem2 = [[NSMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(
					@"Search PopUp History Title", kLocalizableTableName, @"search option lable.")
											action:NULL keyEquivalent:@""];
		[hItem2 setTag:NSSearchFieldRecentsMenuItemTag];
		[cellMenu insertItem:hItem2 atIndex:(cnt+3)];
		[hItem2 release];

		hItem5 = [NSMenuItem separatorItem];
		[hItem5 setTag:NSSearchFieldClearRecentsMenuItemTag];
		[cellMenu insertItem:hItem5 atIndex:(cnt+4)];

		hItem3 = [[NSMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(
					@"Search Popup History Clear", kLocalizableTableName, @"search option lable.")
											action:NULL keyEquivalent:@""];
		[hItem3 setTag:NSSearchFieldClearRecentsMenuItemTag];
		[cellMenu insertItem:hItem3 atIndex:(cnt+5)];
		[hItem3 release];
	}
	
    [searchCell setSearchMenuTemplate:cellMenu];
}
@end
