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

#define kFirstVisibleNumbersPlist	@"firstVisibleNumbers.plist"
#define kLastVisibleNumbersPlist	@"lastVisibleNumbers.plist"

#define APP_TVIEW_FIRST_VISIBLE_LABEL_KEY	@"First Visibles"
#define APP_TVIEW_LAST_VISIBLE_LABEL_KEY	@"Last Visibles"
#define APP_TVIEW_SHOW_ALL_LABEL_KEY		@"Show All"
#define APP_TVIEW_SHOW_NONE_LABEL_KEY		@"Show None"

#pragma mark -

@implementation BSIndexingPopupper
- (id) init
{
	if (self = [super init]) {
		if (NO == [NSBundle loadNibNamed: @"BSIndexingPopupper"
								   owner: self]) {
			[self release];
			return nil;
		}
	}
	return self;
}

- (void) awakeFromNib
{
	[self setupVisibleRangePopUp];
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

- (NSPopUpButton *) firstVisibleRangePopUpButton
{
	return m_firstVisibleRangePopUpButton;
}

- (NSPopUpButton *) lastVisibleRangePopUpButton
{
	return m_lastVisibleRangePopUpButton;
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

#pragma mark Setup
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

- (void) setupVisibleRangePopUpButtonCell : (NSPopUpButtonCell *) aCell
{
	// Reserved...
}

- (void) setupVisibleRangePopUpButton : (NSPopUpButton *) popUpBtn
{
	BSTsuruPetaPopUpBtnCell *tmp_;

	[popUpBtn setFrameSize: NSMakeSize(106,27)];
	[popUpBtn setTarget : nil];
	[popUpBtn setAction : NULL];

	tmp_ = [[BSTsuruPetaPopUpBtnCell alloc] initTextCell: @"" pullsDown: NO];
	[tmp_ setAttributesFromCell: [popUpBtn cell]];
	[popUpBtn setCell: tmp_];
	[tmp_ release];

	[self setupVisibleRangePopUpButtonCell : [popUpBtn cell]];
}

- (NSMenuItem *) addItemWithVisibleRangePopUpButton: (NSPopUpButton *) popUpBtn
									isFirstVisibles: (BOOL           ) isFirst
								   representedIndex: (NSNumber      *) aNum
{
    NSString   *title;
    NSMenuItem *item;
    
    if (isFirst)
      title = [self localizedFirstVisibleStringWithNumber : aNum];
    else
      title = [self localizedLastVisibleStringWithNumber : aNum];
    
    [popUpBtn addItemWithTitle : title];
    
    item = (NSMenuItem *)[popUpBtn lastItem];
    [item setRepresentedObject : aNum];
    [item setTarget : self];
    [item setAction : isFirst 	? 
        @selector(selectFirstVisibleRange:)
        : @selector(selectLastVisibleRange:)];
    return item;
}

- (void) setupVisibleRangePopUpButtonAttributes : (NSPopUpButton *) popUpBtn
								isFirstVisibles : (BOOL           ) isFirst
{
	NSArray			*visibleNumbers_;
	NSEnumerator	*iter_;
	NSNumber		*number_;
	
	[popUpBtn removeAllItems];
	visibleNumbers_ = isFirst 	? [[self class] firstVisibleNumbersArray]
								: [[self class] lastVisibleNumbersArray];
	iter_ = [visibleNumbers_ objectEnumerator];
	while (number_ = [iter_ nextObject]) {
        [self addItemWithVisibleRangePopUpButton : popUpBtn
            isFirstVisibles : isFirst
            representedIndex : number_];
    }
}

- (void) setupVisibleRangePopUp
{
	[self setupVisibleRangePopUpButton : [self firstVisibleRangePopUpButton]];
	[self setupVisibleRangePopUpButton : [self lastVisibleRangePopUpButton]];
	[self setupVisibleRangePopUpButtonAttributes : [self firstVisibleRangePopUpButton]
								 isFirstVisibles : YES];
	[self setupVisibleRangePopUpButtonAttributes : [self lastVisibleRangePopUpButton]
								 isFirstVisibles : NO];
}

#pragma mark Actions
- (void) updateVisibleRange
{
	CMRThreadVisibleRange	*visibleRange_;
	NSNumber				*number_;
	unsigned				firstLength_, lastLength_;
	
	number_ = [[[self firstVisibleRangePopUpButton] selectedItem] representedObject];
	UTILAssertKindOfClass(number_, NSNumber);
	firstLength_ = [number_ unsignedIntValue];
	
	number_ = [[[self lastVisibleRangePopUpButton] selectedItem] representedObject];
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

#pragma mark Utilities
- (void) syncButtonsWithCurrentRangeAtFirst: (BOOL) isFirst
{
    NSPopUpButton	*popUp;
    unsigned		length;
    id				num;
    int				idx = -1;

	CMRThreadVisibleRange *visibleRange = [self visibleRange];
    
    if (nil == visibleRange)
        return;
    
    popUp = isFirst ? [self firstVisibleRangePopUpButton]
                    : [self lastVisibleRangePopUpButton];
    
    length = isFirst ? [visibleRange firstVisibleLength]
                     : [visibleRange lastVisibleLength];
    
    num = [NSNumber numberWithUnsignedInt : length];
    idx = [popUp indexOfItemWithRepresentedObject : num];
    if (-1 == idx) {
        NSMenuItem *item;
        
        item = [self addItemWithVisibleRangePopUpButton: popUp isFirstVisibles: isFirst representedIndex: num];
        idx = [popUp indexOfItem : item];
    }
    [popUp selectItemAtIndex : idx];
}

- (void) syncButtonsWithCurrentRange
{
	[self syncButtonsWithCurrentRangeAtFirst: YES];
	[self syncButtonsWithCurrentRangeAtFirst: NO];
}

+ (NSString *) localizableStringsTableName
{
	return @"ThreadViewer";
}
@end
