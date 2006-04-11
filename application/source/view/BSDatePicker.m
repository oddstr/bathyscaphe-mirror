#import "BSDatePicker.h"

@implementation BSDatePicker
+ (Class)cellClass
{
	return [BSDatePickerCell class];
}
- (void)drawRect:(NSRect)rect
{
	[[self cell] drawWithFrame:[self frame] inView:self];
}
- (void)mouseDown:(NSEvent *)theEvent
{
	[[self window] makeFirstResponder:self];
	
	[[self cell] trackMouse:theEvent inRect:[self frame] ofView:self untilMouseUp:YES];
}
#define BSDatePickerBuffSize 6
- (void)keyDown:(NSEvent *)theEvent
{
	NSString *s = [theEvent characters];
	BSDateColumn column;
	int value;
	char hoge[BSDatePickerBuffSize];
	char *fuge;
	
	if([s length] != 1) {
		goto fail;
	}
	if(![[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[s characterAtIndex:0]]) {
		goto fail;
	}
	if((column = [[self cell] selectedColumn]) == BSDateColumnNon) {
		goto fail;
	}
	
	switch(column) {
		case BSDateColumnYear:
			value = [[self cell] year];
			snprintf( hoge, BSDatePickerBuffSize, "%04d%d", value, [s intValue]);
			value = strtol(&hoge[1], &fuge, 10);
			if(*fuge) goto fail;
			[[self cell] setYear:value];
			break;
		case BSDateColumnMonth:
			value = [[self cell] month];
			snprintf( hoge, BSDatePickerBuffSize, "%02d%d", value, [s intValue]);
			value = strtol(&hoge[1], &fuge, 10);
			if(*fuge) goto fail;
			if([[self cell] minMonth] > value || [[self cell] maxMonth] < value) {
				value = [s intValue];
			}
			[[self cell] setMonth:value];
			break;
		case BSDateColumnDay:
			value = [[self cell] day];
			snprintf( hoge, BSDatePickerBuffSize, "%02d%d", value, [s intValue]);
			value = strtol(&hoge[1], &fuge, 10);
			if(*fuge) goto fail;
			if([[self cell] minDay] > value || [[self cell] maxDay] < value) {
				value = [s intValue];
			}
			[self setDay:value];
			break;
		case BSDateColumnHour:
			value = [[self cell] hour];
			snprintf( hoge, BSDatePickerBuffSize, "%02d%d", value, [s intValue]);
			value = strtol(&hoge[1], &fuge, 10);
			if(*fuge) goto fail;
			if([[self cell] minHour] > value || [[self cell] maxHour] < value) {
				value = [s intValue];
			}
			[[self cell] setHour:value];
			break;
		case BSDateColumnMinute:
			value = [[self cell] minute];
			snprintf( hoge, BSDatePickerBuffSize, "%02d%d", value, [s intValue]);
			value = strtol(&hoge[1], &fuge, 10);
			if(*fuge) goto fail;
			if([[self cell] minMinute] > value || [[self cell] maxMinute] < value) {
				value = [s intValue];
			}
			[[self cell] setMinute:value];
			break;
		case BSDateColumnSecond:
//			value = [[self cell] second];
//			snprintf( hoge, BSDatePickerBuffSize, "%02d%d", value, [s intValue]);
//			value = strtol(&hoge[1], &fuge, 10);
//			if(*fuge) goto fail;
//			if([[self cell] minSecond] > value || [[self cell] maxSecond] < value) {
//				value = [s intValue];
//			}
//			[[self cell] setSecond:value];
			// break;
		default:
			// do nothig.
			break;
	}
	
	[NSApp sendAction:[self action] to:[self target] from:self];
return;

fail:
NSBeep();
}
	
- (BOOL)acceptsFirstResponder
{
	return YES;
}
- (BOOL)becomeFirstResponder
{
	[[self cell] setShowsFirstResponder:YES];
	[self setNeedsDisplay:YES];
	
	return YES;
}
- (BOOL)resignFirstResponder
{
	[[self cell] setShowsFirstResponder:NO];
	[[self superview] setNeedsDisplayInRect:NSInsetRect([self frame],-3,-3)];
	
	return YES;
}
- (void)removeFromSuperview
{
	[[self cell] setShowsFirstResponder:NO];
	[[self superview] setNeedsDisplayInRect:NSInsetRect([self frame],-3,-3)];
	
	[super removeFromSuperview];
}

#pragma mark## delegate to cell##
- (void)setDate:(NSCalendarDate *)date
{
	[[self cell] setDate:date];
}
- (NSCalendarDate *)date
{
	return [[self cell] date];
}
- (NSString *)stringValue
{
	return [[self cell] stringValue];
}
- (NSTimeInterval)epoch
{
	return [[self cell] epoch];
}

- (void)setYear:(int)year
{
	[[self cell] setYear:year];
}
- (int)year
{
	return [[self cell] year];
}
- (void)setMonth:(int)month
{
	[[self cell] setMonth:month];
}
- (int)month
{
	return [[self cell] month];
}
- (void)setDay:(int)day
{
	[[self cell] setDay:day];
}
- (int)day
{
	return [[self cell] day];
}
- (void)setHour:(int)hour
{
	[[self cell] setHour:hour];
}
- (int)hour
{
	return [[self cell] hour];
}
- (void)setMinute:(int)minute
{
	[[self cell] setMinute:minute];
}
- (int)minute
{
	return [[self cell] minute];
}
- (void)setSecond:(int)second
{
	[[self cell] setSecond:second];
}
- (int)second
{
	return [[self cell] second];
}

- (int)minYear
{
	return [[self cell] minYear];
}
- (int)maxYear
{
	return [[self cell] maxYear];
}
- (int)minMonth
{
	return [[self cell] minMonth];
}
- (int)maxMonth
{
	return [[self cell] maxMonth];
}
- (int)minDay
{
	return [[self cell] minDay];
}
- (int)maxDay
{
	return [[self cell] maxDay];
}
- (int)minHour
{
	return [[self cell] minHour];
}
- (int)maxHour
{
	return [[self cell] maxHour];
}
- (int)minMinute
{
	return [[self cell] minMinute];
}
- (int)maxMinute
{
	return [[self cell] maxMinute];
}
- (int)minSecond
{
	return [[self cell] minSecond];
}
- (int)maxSecond
{
	return [[self cell] maxSecond];
}

- (void)setSelectedColumn:(BSDateColumn)column
{
	[[self cell] setSelectedColumn:column];
}
- (BSDateColumn)selectedColumn
{
	return [[self cell] selectedColumn];
}
@end
