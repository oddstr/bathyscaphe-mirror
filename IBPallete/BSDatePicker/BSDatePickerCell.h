//
//  BSDatePickerCell.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 06/01/09.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum BSDateColumn {
	BSDateColumnNon = 0,
	BSDateColumnYear,
	BSDateColumnMonth,
	BSDateColumnDay,
	BSDateColumnHour,
	BSDateColumnMinute,
	BSDateColumnSecond,
} BSDateColumn;

@interface BSDatePickerCell : NSActionCell
{
	NSStepperCell *stepper;
	
	NSCalendarDate *date;
	
	NSFont *font;
	NSFormatter *formatter;
	
	BSDateColumn selectedColumn;
	
	NSRect frame;
}

- (void)setDate:(NSCalendarDate *)date;
- (NSCalendarDate *)date;
- (NSString *)stringValue;
- (NSTimeInterval)epoch;

- (void)setYear:(int)year;
- (int)year;
- (void)setMonth:(int)month;
- (int)month;
- (void)setDay:(int)day;
- (int)day;
- (void)setHour:(int)hour;
- (int)hour;
- (void)setMinute:(int)minute;
- (int)minute;
- (void)setSecond:(int)second;
- (int)second;

- (int)minYear;
- (int)maxYear;
- (int)minMonth;
- (int)maxMonth;
- (int)minDay;
- (int)maxDay;
- (int)minHour;
- (int)maxHour;
- (int)minMinute;
- (int)maxMinute;
- (int)minSecond;
- (int)maxSecond;

- (void)setSelectedColumn:(BSDateColumn)column;
- (BSDateColumn)selectedColumn;
@end
