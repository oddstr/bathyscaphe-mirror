//
//  BSVisibleRangePopUpBtnCell.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/03/07.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSVisibleRangePopUpBtnCell.h"
#import "CMRThreadVisibleRange.h"
#import <SGAppKit/SGAppKit.h>

static NSString *const kFirstVisibleNumbersPlist =	@"firstVisibleNumbers.plist";
static NSString *const kLastVisibleNumbersPlist =	@"lastVisibleNumbers.plist";

static NSString *const APP_TVIEW_FIRST_VISIBLE_LABEL_KEY =	@"First Visibles";
static NSString *const APP_TVIEW_LAST_VISIBLE_LABEL_KEY =	@"Last Visibles";
static NSString *const APP_TVIEW_SHOW_ALL_LABEL_KEY =	@"Show All";
static NSString *const APP_TVIEW_SHOW_NONE_LABEL_KEY =	@"Show None";

@implementation BSFirstRangePopUpBtnCell
- (id)initTextCell:(NSString *)stringValue pullsDown:(BOOL)pullDown
{
    if (self = [super initTextCell: stringValue pullsDown: pullDown]) {
        float fontSize = [NSFont systemFontSizeForControlSize: NSSmallControlSize];

        [self setBordered: NO];
        [self setControlSize: NSSmallControlSize];
        [self setFont: [NSFont systemFontOfSize: fontSize]];
    }
    return self;
}

+ (NSString *) numberPlistFileName
{
    return kFirstVisibleNumbersPlist;
}

+ (NSString *) visibleNumbersFilepath
{
	NSBundle	*bundles[] = {
			[NSBundle applicationSpecificBundle],
			[NSBundle mainBundle],
			nil};
	NSBundle	**p;
	NSString	*s = nil;
	
	for (p = bundles; *p != nil; p++)
		if ((s = [*p pathForResourceWithName: [self numberPlistFileName]]) != nil)
			break;
	
	return s;
}

+ (NSArray *) visibleNumbersArray
{
	NSMutableArray		*values;
	int					i;
	
	values = [NSMutableArray arrayWithContentsOfFile: [self visibleNumbersFilepath]];
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

- (NSString *) localizedMenuItemTitleTemplate
{
	static NSString *template = nil;
	if (template == nil) {
		template = [[self localizedString: APP_TVIEW_FIRST_VISIBLE_LABEL_KEY] retain];
	}
    return template;
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

- (NSString *) localizedMenuItemTitleWithNumber: (NSNumber *) visibleNumber
{
	NSString			*format_;
	
	if (nil == visibleNumber) return nil;
	
	format_ = [self localizedMenuItemTitleTemplate];
	return [self localizedVisibleStringWithFormat: format_
	                                visibleLength: [visibleNumber unsignedIntValue]];
}

- (NSMenuItem *) addItemWithRepresentedIndex: (NSNumber *) aNum
{
    NSString	*title;
    NSMenuItem	*item;

	title = [self localizedMenuItemTitleWithNumber : aNum];
    
	[self addItemWithTitle: title];

	item = (NSMenuItem *)[self lastItem];
    [item setRepresentedObject: aNum];
    [item setTarget: [self target]];
    [item setAction: [self action]];
    return item;
}

- (void) setupPopUpMenuBase
{
	NSArray			*visibleNumbers_;
	NSEnumerator	*iter_;
	NSNumber		*number_;

	[self removeAllItems];

	visibleNumbers_ = [[self class] visibleNumbersArray];
	iter_ = [visibleNumbers_ objectEnumerator];

	while (number_ = [iter_ nextObject]) {
		[self addItemWithRepresentedIndex: number_];
    }
}

- (unsigned) eitherOfLength: (CMRThreadVisibleRange *) range
{
    return [range firstVisibleLength];
}

- (void) syncWithCurrentRange: (CMRThreadVisibleRange *) visibleRange
{
    unsigned		length;
    id				num;
    int				idx = -1;
    
    if (nil == visibleRange)
        return;

	length = [self eitherOfLength: visibleRange];

    num = [NSNumber numberWithUnsignedInt : length];
    idx = [self indexOfItemWithRepresentedObject : num];

    if (-1 == idx) {
        NSMenuItem *item;
        item = [self addItemWithRepresentedIndex: num];
        idx = [self indexOfItem : item];
    }

    [self selectItemAtIndex: idx];
}

+ (NSString *) localizableStringsTableName
{
	return @"IndexingPopupper";
}
@end

@implementation BSLastRangePopUpBtnCell
+ (NSString *) numberPlistFileName
{
    return kLastVisibleNumbersPlist;
}

- (NSString *) localizedMenuItemTitleTemplate
{
	static NSString *template = nil;
	if (template == nil) {
		template = [[self localizedString: APP_TVIEW_LAST_VISIBLE_LABEL_KEY] retain];
	}
    return template;
}

- (unsigned) eitherOfLength: (CMRThreadVisibleRange *) range
{
    return [range lastVisibleLength];
}
@end
