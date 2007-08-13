//
//  BSDatePickerPalette.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 06/01/09.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//


#import "BSDatePickerPalette.h"

#import "BSDatePicker.h"
#import "BSDatePickerCell.h"

@implementation BSDatePickerPalette
- (void)finishInstantiate {
	
	datePickerCellObject = [[BSDatePickerCell alloc] init];
	
	[self associateObject:datePickerCellObject
				   ofType:IBTableColumnPboardType
				 withView:datePickerCellView];
	
}
@end

@implementation BSDatePicker(BSDatePickerPalette)
- (NSString *)inspectorClassName
{
	return @"BSDatePickerInspector";
}


- (NSSize)minimumFrameSizeFromKnobPosition:(IBKnobPosition)position
{
	return [[self cell] cellSize];
}
- (NSSize)maximumFrameSizeFromKnobPosition:(IBKnobPosition)knobPosition
{
	NSSize size = [[self cell] cellSize];
	size.width = UINT_MAX;
	return size;
}
- (BOOL)ibHasAlternateMinimumWidth
{
	return YES;
}
- (BOOL)ibHasAlternateMinimumHeight
{
	return YES;
}
- (float)ibAlternateMinimumWidth
{
	return [[self cell] cellSize].width;
}
- (float)ibAlternateMinimumHeight
{
	return [[self cell] cellSize].height;
}
- (int)ibNumberOfBaseLine
{
	return 1;
}
- (float)ibBaseLineAtIndex:(int)index
{
	return [[self cell] ibBaseLineForCellSize:[self frame].size];
}

- (BOOL)allowsAltDragging
{
	return YES;
}

@end

@implementation BSDatePickerCell(BSDatePickerPalette)

- (NSString *)inspectorClassName
{
	return @"BSDatePickerInspector";
}

- (BOOL)ibHasBaseLine
{
	return YES;
}
- (float)ibBaseLineForCellSize:(NSSize)cellSize
{
	return 7.0;
}

@end