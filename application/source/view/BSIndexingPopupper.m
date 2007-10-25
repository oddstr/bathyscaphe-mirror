//
//  BSIndexingPopupper.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/06/21.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSIndexingPopupper.h"
#import "CMRThreadVisibleRange.h"
#import <SGAppKit/SGAppKit.h>
#import "BSVisibleRangePopUpBtnCell.h"
#import "AppDefaults.h"
#import "BSRelativeKeywordsCollector.h"

static NSString *const kIndexingPopupperNibFileKey =	@"BSIndexingPopupper";
static NSString *const kIndexingPopupperStringsKey =	@"IndexingPopupper";

static NSString *const kKeywordsMenuTitleDefaultKey =	@"Menu Keywords";
static NSString *const kKeywordsMenuTitleOfflineKey =	@"Menu Offline";
static NSString *const kKeywordsMenuTitkeFailedKey =	@"Menu No Keywords";

static NSString *const kAboutKeywordsAlertTitleKey =	@"About Keywords Title";
static NSString *const kAboutKeywordsAlertMsgBaseKey =	@"About Keywords Msg";
static NSString *const kAboutKeywordsAlertOKBtnKey =	@"About Keywords OK Button";

static NSString *const kKeywordsButtonImage = @"Keywords";
static NSString *const kKeywordsButtonPressedImage = @"Keywords_Pressed";

@implementation BSIndexingPopupper
#pragma mark Overrides
- (id) init
{
	if (self = [super init]) {
		if (NO == [NSBundle loadNibNamed: kIndexingPopupperNibFileKey owner: self]) {
			[self release];
			return nil;
		}
	}
	return self;
}

- (void) awakeFromNib
{
	[self setupVisibleRangePopUp];
	[self setupKeywordsButton];
}

- (void) dealloc
{
	[self setDelegate: nil];
	[m_frameView removeFromSuperviewWithoutNeedingDisplay];
	[m_frameView release];
	[m_visibleRange release];
	[super dealloc];
}

#pragma mark Accessors
- (id) delegate
{
	return m_delegate;
}

- (void) setDelegate : (id) aDelegate
{
	m_delegate = aDelegate;
}

- (NSView *) frameView
{
	return m_frameView;
}

- (NSView *) contentView
{
	return [self frameView];
}

- (NSMatrix *) visibleRangeMatrix
{
	return m_visibleRangeMatrix;
}

- (NSPopUpButton *) keywordsButton
{
	return m_keywordsButton;
}

- (NSMenu *) keywordsMenu
{
	return m_keywordsMenuBase;
}

- (CMRThreadVisibleRange *) visibleRange
{
	return m_visibleRange;
}

- (void) setVisibleRange: (CMRThreadVisibleRange *) aVisibleRange
{
	[aVisibleRange retain];
	[m_visibleRange release];
	m_visibleRange = aVisibleRange;

	[self syncButtonsWithCurrentRange];
}

#pragma mark UI Setup
- (id) popUpButtonCellOfClass: (Class) cellClass
{
	id	cell = [[cellClass alloc] initTextCell: @"" pullsDown: NO];
	[cell setTarget: self];
	[cell setAction: @selector(selectVisibleRange:)];
	[cell setupPopUpMenuBase];
	return [cell autorelease];
}

- (void) setupVisibleRangePopUp
{
	NSMatrix	*matrix_ = [self visibleRangeMatrix];

	[matrix_ putCell: [self popUpButtonCellOfClass: [BSFirstRangePopUpBtnCell class]] atRow: 0 column: 0];
	[matrix_ putCell: [self popUpButtonCellOfClass: [BSLastRangePopUpBtnCell class]] atRow: 0 column: 1];
}

- (void) setupKeywordsButton
{
	CMRPullDownIconBtn	*cell_;
	NSPopUpButtonCell	*btnCell_;

	cell_ = [[CMRPullDownIconBtn alloc] initTextCell : @"" pullsDown:YES];
	[cell_ setBtnImg: [NSImage imageNamed: kKeywordsButtonImage]];
	[cell_ setBtnImgPressed: [NSImage imageNamed: kKeywordsButtonPressedImage]];
	btnCell_ = [[self keywordsButton] cell];
    [cell_ setAttributesFromCell : btnCell_];
    [[self keywordsButton] setCell : cell_];
    [cell_ release];

	btnCell_ = [[self keywordsButton] cell];
	[btnCell_ setArrowPosition: NSPopUpNoArrow];
	[btnCell_ setControlSize: NSSmallControlSize];
	[btnCell_ setFont: [NSFont systemFontOfSize: [NSFont systemFontSizeForControlSize: NSSmallControlSize]]];
	[btnCell_ setMenu: [self keywordsMenu]];
	[[[btnCell_ menu] itemAtIndex: 1] setEnabled: NO];
}

#pragma mark Actions
- (IBAction) selectVisibleRange: (id) sender
{
	CMRThreadVisibleRange	*visibleRange_;
	NSNumber				*number_;
	unsigned				firstLength_, lastLength_;
	NSMatrix				*matrix_ = [self visibleRangeMatrix];
	
	number_ = [[[matrix_ cellAtRow: 0 column: 0] selectedItem] representedObject];
	UTILAssertKindOfClass(number_, NSNumber);
	firstLength_ = [number_ unsignedIntValue];
	
	number_ = [[[matrix_ cellAtRow: 0 column: 1] selectedItem] representedObject];
	UTILAssertKindOfClass(number_, NSNumber);
	lastLength_ = [number_ unsignedIntValue];
	
	visibleRange_ = [CMRThreadVisibleRange visibleRangeWithFirstVisibleLength: firstLength_ lastVisibleLength: lastLength_];
	
	[self setVisibleRange: visibleRange_];

	if ([[self delegate] respondsToSelector: @selector(indexingPopupper:didChangeVisibleRange:)]) {
		[[self delegate] indexingPopupper: self didChangeVisibleRange: visibleRange_];
	}
}

- (IBAction) aboutKeywords: (id) sender
{
	NSString *informativeText_ = [NSString stringWithFormat: [self localizedString: kAboutKeywordsAlertMsgBaseKey], [NSBundle applicationName]];
	NSAlert *alert_ = [[[NSAlert alloc] init] autorelease];
	[alert_ setAlertStyle: NSInformationalAlertStyle];
	[alert_ setInformativeText: informativeText_];
	[alert_ setMessageText: [self localizedString: kAboutKeywordsAlertTitleKey]];
	[alert_ addButtonWithTitle: [self localizedString: kAboutKeywordsAlertOKBtnKey]];
	[alert_ runModal];
}

- (IBAction) selectKeyword: (id) sender
{
	NSString *strValue_;
    
    UTILAssertRespondsTo(sender, @selector(representedObject));
    if (strValue_ = [sender representedObject]) {
        UTILAssertKindOfClass(strValue_, NSString);
        [[NSWorkspace sharedWorkspace] openURL : [NSURL URLWithString: strValue_] inBackground: [CMRPref openInBg]];
    }
}

#pragma mark Utilities
- (void) syncButtonsWithCurrentRange
{
	NSMatrix	*matrix_ = [self visibleRangeMatrix];
	CMRThreadVisibleRange *visibleRange = [self visibleRange];

	[[matrix_ cellAtRow: 0 column: 0] syncWithCurrentRange: visibleRange];
	[[matrix_ cellAtRow: 0 column: 1] syncWithCurrentRange: visibleRange];
}

- (void) cleanupMenu: (NSMenu *) menu
{
	if ([menu numberOfItems] > 4) {
		int i;
		for (i = [menu numberOfItems] - 3; i > 1; i--) {
			[menu removeItemAtIndex: i];
		}
	}
}

- (void) updateKeywordsMenuForOfflineMode
{
	NSMenu	*menu = [self keywordsMenu];
	[self cleanupMenu: menu];
	[[menu itemAtIndex: 1] setTitle: [self localizedString: kKeywordsMenuTitleOfflineKey]];
}

- (void) updateKeywordsMenu
{
	NSMenu	*menu = [self keywordsMenu];
	id		delegate_ = [self delegate];
	NSArray	*array = nil;

	[self cleanupMenu: menu];

	if (delegate_ && [delegate_ respondsToSelector: @selector(cachedKeywords)]) {
		array = [delegate_ cachedKeywords];
	}

	if (!array || [array count] == 0) {
		[[menu itemAtIndex: 1] setTitle: [self localizedString: kKeywordsMenuTitkeFailedKey]];
	} else {
		NSEnumerator *iter = [array reverseObjectEnumerator];
		NSDictionary *eachItem;
		NSMenuItem *menuItem;
		NSString *title_;

		while (eachItem = [iter nextObject]) {
			title_ = [NSString stringWithFormat: @"  %@", [eachItem objectForKey: BSRelativeKeywordsCollectionKeywordStringKey]];

			menuItem = [[NSMenuItem alloc] initWithTitle: title_ action: @selector(selectKeyword:) keyEquivalent: @""];

			[menuItem setTarget: self];
			[menuItem setRepresentedObject: [eachItem objectForKey: BSRelativeKeywordsCollectionKeywordURLKey]];

			[menu insertItem: menuItem atIndex: 2];
			[menuItem release];
		}

		[[menu itemAtIndex: 1] setTitle: [self localizedString: kKeywordsMenuTitleDefaultKey]];
	}
	[menu update];
}

+ (NSString *) localizableStringsTableName
{
	return kIndexingPopupperStringsKey;
}
@end
