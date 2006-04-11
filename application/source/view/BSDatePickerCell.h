/* BSDatePickerCell */

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
