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
#import "BSTsuruPetaPopUpBtnCell.h"
#import "AppDefaults.h"
#import "BSRelativeKeywordsCollector.h"

static NSString *const kFirstVisibleNumbersPlist =	@"firstVisibleNumbers.plist";
static NSString *const kLastVisibleNumbersPlist =	@"lastVisibleNumbers.plist";

static NSString *const APP_TVIEW_FIRST_VISIBLE_LABEL_KEY =	@"First Visibles";
static NSString *const APP_TVIEW_LAST_VISIBLE_LABEL_KEY =	@"Last Visibles";
static NSString *const APP_TVIEW_SHOW_ALL_LABEL_KEY =	@"Show All";
static NSString *const APP_TVIEW_SHOW_NONE_LABEL_KEY =	@"Show None";

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
/*
- (NSPopUpButton *) firstVisibleRangePopUpButton
{
	return m_firstVisibleRangePopUpButton;
}

- (NSPopUpButton *) lastVisibleRangePopUpButton
{
	return m_lastVisibleRangePopUpButton;
}
*/
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
+ (NSString *) visibleNumbersFilepathWithName : (NSString *) filename
{
	NSBundle	*bundles[] = {
			[NSBundle applicationSpecificBundle],
			[NSBundle mainBundle],
			nil};
	NSBundle	**p;
	NSString	*s = nil;
	
	for (p = bundles; *p != nil; p++)
		if ((s = [*p pathForResourceWithName : filename]) != nil)
			break;
	
	return s;
}

+ (NSArray *) visibleNumbersArrayWithName : (NSString *) filename
{
	NSMutableArray		*values;
	int					i;
	
	values = [NSMutableArray arrayWithContentsOfFile : 
				[self visibleNumbersFilepathWithName : filename]];
	if (nil == values) values = [NSMutableArray array];
	
	for (i = [values count] -1; i >= 0; i--) {
		id		v = [values objectAtIndex : i];
		
		if (NO == [v isKindOfClass : [NSNumber class]]) {
			[values removeObjectAtIndex : i];
			continue;
		}
		
		if ([v intValue] < 0) {
			[values replaceObjectAtIndex : i
			  withObject : [NSNumber numberWithUnsignedInt : CMRThreadShowAll]];
		}
	}
	return values;
}

+ (NSArray *) firstVisibleNumbersArray
{
	return [self visibleNumbersArrayWithName : kFirstVisibleNumbersPlist];
}

+ (NSArray *) lastVisibleNumbersArray
{
	return [self visibleNumbersArrayWithName : kLastVisibleNumbersPlist];
}

- (NSString *) localizedVisibleStringWithFormat : (NSString *) format
								  visibleLength : (unsigned  ) visibleLength
{
	if (0 == visibleLength)
		return [self localizedString: APP_TVIEW_SHOW_NONE_LABEL_KEY];
	if (CMRThreadShowAll == visibleLength)
		return [self localizedString: APP_TVIEW_SHOW_ALL_LABEL_KEY];
	
	return [NSString stringWithFormat : 
							format,
							visibleLength];
}

- (NSString *) localizedFirstVisibleStringWithNumber : (NSNumber *) visibleNumber
{
	NSString			*format_;
	
	if (nil == visibleNumber) return nil;
	
	format_ = [self localizedString : APP_TVIEW_FIRST_VISIBLE_LABEL_KEY];
	return [self localizedVisibleStringWithFormat : format_
						visibleLength : [visibleNumber unsignedIntValue]];
}

- (NSString *) localizedLastVisibleStringWithNumber : (NSNumber *) visibleNumber
{
	NSString			*format_;
	
	if (nil == visibleNumber) return nil;
	
	format_ = [self localizedString : APP_TVIEW_LAST_VISIBLE_LABEL_KEY];
	return [self localizedVisibleStringWithFormat : format_
						visibleLength : [visibleNumber unsignedIntValue]];
}

- (BSTsuruPetaPopUpBtnCell *) popUpButtonCellTemplate
{
	BSTsuruPetaPopUpBtnCell	*cell = [[BSTsuruPetaPopUpBtnCell alloc] initTextCell: @"" pullsDown: NO];
	float fontSize = [NSFont systemFontSizeForControlSize: NSSmallControlSize];

	[cell setBordered: NO];
	[cell setControlSize: NSSmallControlSize];
	[cell setFont: [NSFont systemFontOfSize: fontSize]];
	
	return [cell autorelease];
}

- (void) setupVisibleRangeMatrix;
{
	NSMatrix	*matrix_ = [self visibleRangeMatrix];

	[matrix_ putCell: [self popUpButtonCellTemplate] atRow: 0 column: 0];
	[matrix_ putCell: [self popUpButtonCellTemplate] atRow: 0 column: 1];
}

- (NSMenuItem *) addItemWithRepresentedIndex: (NSNumber *) aNum toPopUpBtnCell: (NSPopUpButtonCell *) cell isFirst: (BOOL) isFirst
{
    NSString	*title;
    NSMenuItem	*item;
	SEL			action_;

	if (isFirst) {
		title = [self localizedFirstVisibleStringWithNumber : aNum];
		action_ = @selector(selectFirstVisibleRange:);
	} else {
		title = [self localizedLastVisibleStringWithNumber : aNum];
		action_ = @selector(selectLastVisibleRange:);
	}
    
	[cell addItemWithTitle: title];

	item = (NSMenuItem *)[cell lastItem];
    [item setRepresentedObject: aNum];
    [item setTarget: self];
    [item setAction: action_];
    return item;
}

- (void) setupVisibleRangePopUpBtnCellAttributes: (NSPopUpButtonCell *) cell isFirst: (BOOL) isFirst
{
	NSArray			*visibleNumbers_;
	NSEnumerator	*iter_;
	NSNumber		*number_;

	[cell removeAllItems];

	if (isFirst) {
		visibleNumbers_ = [[self class] firstVisibleNumbersArray];
	} else {
		visibleNumbers_ = [[self class] lastVisibleNumbersArray];
	}

	iter_ = [visibleNumbers_ objectEnumerator];
	while (number_ = [iter_ nextObject]) {
		[self addItemWithRepresentedIndex: number_ toPopUpBtnCell: cell isFirst: isFirst];
    }
}

- (void) setupVisibleRangePopUp
{
	[self setupVisibleRangeMatrix];

	NSMatrix	*matrix_ = [self visibleRangeMatrix];

	[self setupVisibleRangePopUpBtnCellAttributes: [matrix_ cellAtRow: 0 column: 0] isFirst: YES];
	[self setupVisibleRangePopUpBtnCellAttributes: [matrix_ cellAtRow: 0 column: 1] isFirst: NO];
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
- (void) updateVisibleRange
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

- (IBAction) selectFirstVisibleRange : (id) sender
{
	[self updateVisibleRange];
}

- (IBAction) selectLastVisibleRange : (id) sender
{
	[self updateVisibleRange];
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
        [[NSWorkspace sharedWorkspace] openURL : [NSURL URLWithString: strValue_] inBackGround: [CMRPref openInBg]];
    }
}

#pragma mark Utilities
- (void) syncPopUpBtnCellWithCurRange: (NSPopUpButtonCell *) cell isFirst: (BOOL) isFirst
{
    unsigned		length;
    id				num;
    int				idx = -1;

	CMRThreadVisibleRange *visibleRange = [self visibleRange];
    
    if (nil == visibleRange)
        return;

	if (isFirst) {
		length = [visibleRange firstVisibleLength];
	} else {
		length = [visibleRange lastVisibleLength];
    }

    num = [NSNumber numberWithUnsignedInt : length];
    idx = [cell indexOfItemWithRepresentedObject : num];
    if (-1 == idx) {
        NSMenuItem *item;
        item = [self addItemWithRepresentedIndex: num toPopUpBtnCell: cell isFirst: isFirst];
        idx = [cell indexOfItem : item];
    }

    [cell selectItemAtIndex : idx];
}

- (void) syncButtonsWithCurrentRange
{
	NSMatrix	*matrix_ = [self visibleRangeMatrix];

	[self syncPopUpBtnCellWithCurRange: [matrix_ cellAtRow: 0 column: 0] isFirst: YES];
	[self syncPopUpBtnCellWithCurRange: [matrix_ cellAtRow: 0 column: 1] isFirst: NO];
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
