#import "BSDatePickerCell.h"


@implementation BSDatePickerCell


// フォーマットは固定です！！！
#define DATE_FORMAT @"%04Y/%m/%d %H:%M"

#define LONG_YEAR_FORMAT_FORMAT @"%04d"
#define MONTH_FORMAT_FORMAT @"%02d"
#define DAY_FORMAT_FORMAT @"%02d"
#define HOUR_FORMAT_FORMAT @"%02d"
#define MINUTE_FORMAT_FORMAT @"%02d"
#define DATE_SEPARATER @"/"
#define DATE_TEIME_SEPARATER @" "
#define TIME_SEPARATER @":"

const float kPadding = 2;
const float kMinTextWidth = 108;

static inline NSPoint stringDrawingPointForFrame(NSRect );

- (id)init
{
	self = [super initTextCell:@""];
	if(self) {
		formatter = [[NSDateFormatter alloc] initWithDateFormat:DATE_FORMAT
												   allowNaturalLanguage:NO];
		
		stepper = [[NSStepperCell alloc] init];
		[stepper setControlSize:NSSmallControlSize];
		
		[self setDate:[NSCalendarDate calendarDate]];
		[self setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
		
		[self setSelectedColumn:BSDateColumnYear];
	}
	
	return self;
}
- (void)dealloc
{
	[stepper release];
	[date release];
	[font release];
	[formatter release];
	
	[super dealloc];
}
- (NSSize)cellSize
{
	NSSize size = [stepper cellSize];
	size.width += kPadding + kMinTextWidth;
	
	return size;
}
- (NSCellType)type
{
	return NSTextCellType;
}

- (float)textFieldWidth
{
	float result;
	
	result = [[self controlView] frame].size.width - [stepper cellSize].width - kPadding;
	
	return (result < kMinTextWidth) ? kMinTextWidth : result;
}
- (NSPoint)stepperOrigin
{
	return NSMakePoint([self textFieldWidth] + kPadding, 0);
}
- (NSRect)stepperFrame
{
	NSRect stepperFrame;
	
	stepperFrame.origin = [self stepperOrigin];
	stepperFrame.size = [stepper cellSize];
	
	return stepperFrame;
}
- (NSRect)textFieldFrame
{
	NSRect textFrame;
	
	textFrame = [[self controlView] frame];
	textFrame.origin = NSZeroPoint;
	textFrame.size.height = 19;
	textFrame.size.width = [self textFieldWidth];
	textFrame.origin.y += ([self stepperFrame].size.height - textFrame.size.height) / 2.0;
	
	return textFrame;
}
- (NSRect)yearRect
{
	NSString *string;
	id attr;
	NSRect r;
	
	attr = [NSDictionary dictionaryWithObjectsAndKeys:
		[self font], NSFontAttributeName,
		nil];
	r.origin = stringDrawingPointForFrame([self textFieldFrame]);
	
	string = [NSString stringWithFormat:LONG_YEAR_FORMAT_FORMAT, [self year]];
	r.size = [string sizeWithAttributes:attr];
	r = NSInsetRect(r,-1,1);
	r = NSOffsetRect(r,0,-0.5);
	
	return r;
}
- (NSRect)monthRect
{
	NSString *string;
	NSString *format;
	id attr;
	NSRect r;
	
	format = [NSString stringWithFormat:@"%@%@", LONG_YEAR_FORMAT_FORMAT, DATE_SEPARATER];
	string = [NSString stringWithFormat:format, [self year]];
	attr = [NSDictionary dictionaryWithObjectsAndKeys:
		[self font], NSFontAttributeName,
		nil];
	r.size = [string sizeWithAttributes:attr];
	r.origin = stringDrawingPointForFrame([self textFieldFrame]);
	r.origin.x += r.size.width;
	
	string = [NSString stringWithFormat:MONTH_FORMAT_FORMAT, [self month]];
	r.size = [string sizeWithAttributes:attr];
	r = NSInsetRect(r,-1,1);
	r = NSOffsetRect(r,0,-0.5);
	
	return r;
}
- (NSRect)dayRect
{
	NSString *string;
	NSString *format;
	id attr;
	NSRect r;
	
	format = [NSString stringWithFormat:@"%@%@%@%@",
		LONG_YEAR_FORMAT_FORMAT, DATE_SEPARATER, MONTH_FORMAT_FORMAT, DATE_SEPARATER];
	string = [NSString stringWithFormat:format,
		[self year], [self month]];
	attr = [NSDictionary dictionaryWithObjectsAndKeys:
		[self font], NSFontAttributeName,
		nil];
	r.size = [string sizeWithAttributes:attr];
	r.origin = stringDrawingPointForFrame([self textFieldFrame]);
	r.origin.x += r.size.width;
	
	string = [NSString stringWithFormat:DAY_FORMAT_FORMAT, [self day]];
	r.size = [string sizeWithAttributes:attr];
	r = NSInsetRect(r,-1,1);
	r = NSOffsetRect(r,0,-0.5);
	
	return r;
}
- (NSRect)hourRect
{
	NSString *string;
	NSString *format;
	id attr;
	NSRect r;
	
	format = [NSString stringWithFormat:@"%@%@%@%@%@%@",
		LONG_YEAR_FORMAT_FORMAT, DATE_SEPARATER, MONTH_FORMAT_FORMAT, DATE_SEPARATER, DAY_FORMAT_FORMAT,
		DATE_TEIME_SEPARATER];
	string = [NSString stringWithFormat:format,
		[self year], [self month], [self day]];
	attr = [NSDictionary dictionaryWithObjectsAndKeys:
		[self font], NSFontAttributeName,
		nil];
	r.size = [string sizeWithAttributes:attr];
	r.origin = stringDrawingPointForFrame([self textFieldFrame]);
	r.origin.x += r.size.width;
	
	string = [NSString stringWithFormat:HOUR_FORMAT_FORMAT, [self hour]];
	r.size = [string sizeWithAttributes:attr];
	r = NSInsetRect(r,-1,1);
	r = NSOffsetRect(r,0,-0.5);
	
	return r;
}
- (NSRect)minuteRect
{
	NSString *string;
	NSString *format;
	id attr;
	NSRect r;
	
	format = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@",
		LONG_YEAR_FORMAT_FORMAT, DATE_SEPARATER, MONTH_FORMAT_FORMAT, DATE_SEPARATER, DAY_FORMAT_FORMAT,
		DATE_TEIME_SEPARATER,
		HOUR_FORMAT_FORMAT, TIME_SEPARATER];
	string = [NSString stringWithFormat:format,
		[self year], [self month], [self day], [self hour]];
	attr = [NSDictionary dictionaryWithObjectsAndKeys:
		[self font], NSFontAttributeName,
		nil];
	r.size = [string sizeWithAttributes:attr];
	r.origin = stringDrawingPointForFrame([self textFieldFrame]);
	r.origin.x += r.size.width;
	
	string = [NSString stringWithFormat:MINUTE_FORMAT_FORMAT, [self minute]];
	r.size = [string sizeWithAttributes:attr];
	r = NSInsetRect(r,-1,1);
	r = NSOffsetRect(r,0,-0.5);
	
	return r;
}
- (NSRect)currentSelectedColumnRect
{
	NSRect result = NSZeroRect;
	
	switch(selectedColumn) {
		case BSDateColumnYear:
			result = [self yearRect];
			break;
		case BSDateColumnMonth:
			result = [self monthRect];
			break;
		case BSDateColumnDay:
			result = [self dayRect];
			break;
		case BSDateColumnHour:
			result = [self hourRect];
			break;
		case BSDateColumnMinute:
			result = [self minuteRect];
			break;
		case BSDateColumnSecond:
			// result = [self secondRect];
			// break;
		default:
			// do nothig.
			break;
	}
	
	return result;
}

- (void)drawFrame
{
	NSRect frameRect = [self textFieldFrame];
	
	NSDrawWhiteBezel(frameRect, frameRect);
	frameRect = NSInsetRect(frameRect, 1, 1);
	[[NSColor whiteColor] set];
	NSRectFill(frameRect);
}
static inline NSBezierPath *roundSquareFromRect(NSRect rect, float radius)
{
	NSBezierPath *result;
	float height, width;
	
	height = NSHeight(rect);
	width = NSWidth(rect);
	
	if(height / 2 < radius) radius = height / 2;
	if(width / 2 < radius) radius = width / 2;
	
	result = [NSBezierPath bezierPath];
	
	[result moveToPoint:NSMakePoint(NSMaxX(rect) - radius, NSMinY(rect))];
	[result curveToPoint:NSMakePoint(NSMaxX(rect), NSMinY(rect) + radius)
		   controlPoint1:NSMakePoint(NSMaxX(rect) - radius / 2, NSMinY(rect))
		   controlPoint2:NSMakePoint(NSMaxX(rect), NSMinY(rect) + radius / 2)];
	if(height / 2 != radius) {
		[result lineToPoint:NSMakePoint(NSMaxX(rect), NSMaxY(rect) - radius)];
	}
	[result curveToPoint:NSMakePoint(NSMaxX(rect) - radius, NSMaxY(rect))
		   controlPoint1:NSMakePoint(NSMaxX(rect), NSMaxY(rect) - radius / 2)
		   controlPoint2:NSMakePoint(NSMaxX(rect) - radius / 2, NSMaxY(rect))];
	if(width / 2 != radius) {
		[result lineToPoint:NSMakePoint(NSMinX(rect) + radius, NSMaxY(rect))];
	}
	[result curveToPoint:NSMakePoint(NSMinX(rect), NSMaxY(rect) - radius)
		   controlPoint1:NSMakePoint(NSMinX(rect) + radius / 2, NSMaxY(rect))
		   controlPoint2:NSMakePoint(NSMinX(rect), NSMaxY(rect) - radius / 2)];
	if(height / 2 != radius) {
		[result lineToPoint:NSMakePoint(NSMinX(rect), NSMinY(rect) + radius)];
	}
	[result curveToPoint:NSMakePoint(NSMinX(rect) + radius, NSMinY(rect))
		   controlPoint1:NSMakePoint(NSMinX(rect), NSMinY(rect) + radius / 2)
		   controlPoint2:NSMakePoint(NSMinX(rect) + radius / 2, NSMinY(rect))];
	[result closePath];
	
	return result;
}
static inline NSPoint stringDrawingPointForFrame(NSRect frame)
{
	return NSMakePoint(NSMinX(frame) + 3, NSMinY(frame) + 3);
}
- (void)drawField
{	
	[self drawFrame];
	
	if([self showsFirstResponder]) {
		[NSGraphicsContext saveGraphicsState];
		[[NSColor selectedTextBackgroundColor] set];
		[NSBezierPath setDefaultLineCapStyle:NSRoundLineCapStyle];
		
		switch(selectedColumn) {
			case BSDateColumnYear:
				[roundSquareFromRect([self yearRect], 2) fill];
				break;
			case BSDateColumnMonth:
				[roundSquareFromRect([self monthRect], 2) fill];
				break;
			case BSDateColumnDay:
				[roundSquareFromRect([self dayRect], 2) fill];
				break;
			case BSDateColumnHour:
				[roundSquareFromRect([self hourRect], 2) fill];
				break;
			case BSDateColumnMinute:
				[roundSquareFromRect([self minuteRect], 2) fill];
				break;
			case BSDateColumnSecond:
				//
				// break;
			default:
				// do nothig.
				break;
		}
		
		[NSGraphicsContext restoreGraphicsState];
	}
	
	{
		NSString *string = [self stringValue];
		id attr;
		
		attr = [NSDictionary dictionaryWithObjectsAndKeys:
			[self font], NSFontAttributeName,
			nil];
		[string drawAtPoint:stringDrawingPointForFrame([self textFieldFrame]) withAttributes:attr];
	}
}
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[stepper drawWithFrame:[self stepperFrame] inView:controlView];
	
	[self drawField];
	
	if([self showsFirstResponder]) {
		[NSGraphicsContext saveGraphicsState];
		NSSetFocusRingStyle([self focusRingType]);
		NSRectFill([self textFieldFrame]);
		[NSGraphicsContext restoreGraphicsState];
	}
}

- (BOOL)acceptsFirstResponder
{
	[self setShowsFirstResponder:YES];
	return YES;
}
- (BOOL)refusesFirstResponder
{
	[self setShowsFirstResponder:NO];
	return YES;
}
- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)flag
{
	NSPoint mouse;
	
	mouse = [controlView convertPoint:[theEvent locationInWindow] fromView:nil];
	if(NSMouseInRect(mouse,[self stepperFrame], [controlView isFlipped])) {
		return [stepper trackMouse:theEvent inRect:[self stepperFrame] ofView:controlView untilMouseUp:flag];
	}
	
	return [super trackMouse:theEvent inRect:cellFrame ofView:controlView untilMouseUp:flag];
}
	
- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView
{
	BOOL result = NO;
		
	if(NSMouseInRect(startPoint,[self stepperFrame], [controlView isFlipped])) {
		NSLog(@"Fail tracking Stepper!!");
	} else if(NSMouseInRect(startPoint,[self yearRect], [controlView isFlipped])) {
		[self setSelectedColumn:BSDateColumnYear];
		[controlView displayIfNeeded];
		result = YES;
	} else if(NSMouseInRect(startPoint,[self monthRect], [controlView isFlipped])) {
		[self setSelectedColumn:BSDateColumnMonth];
		[controlView displayIfNeeded];
		result = YES;
	} else if(NSMouseInRect(startPoint,[self dayRect], [controlView isFlipped])) {
		[self setSelectedColumn:BSDateColumnDay];
		[controlView displayIfNeeded];
		result = YES;
	} else if(NSMouseInRect(startPoint,[self hourRect], [controlView isFlipped])) {
		[self setSelectedColumn:BSDateColumnHour];
		[controlView displayIfNeeded];
		result = YES;
	} else if(NSMouseInRect(startPoint,[self minuteRect], [controlView isFlipped])) {
		[self setSelectedColumn:BSDateColumnMinute];
		[controlView displayIfNeeded];
		result = YES;
	} else if(NSMouseInRect(startPoint,[self textFieldFrame], [controlView isFlipped])) {
		result = YES;
	}
	
	return result;
}
- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint inView:(NSView *)controlView
{	
	
	if(NSMouseInRect(currentPoint,[self yearRect], [controlView isFlipped])) {
		[self setSelectedColumn:BSDateColumnYear];
		[controlView displayIfNeeded];
	} else if(NSMouseInRect(currentPoint,[self monthRect], [controlView isFlipped])) {
		[self setSelectedColumn:BSDateColumnMonth];
		[controlView displayIfNeeded];
	} else if(NSMouseInRect(currentPoint,[self dayRect], [controlView isFlipped])) {
		[self setSelectedColumn:BSDateColumnDay];
		[controlView displayIfNeeded];
	} else if(NSMouseInRect(currentPoint,[self hourRect], [controlView isFlipped])) {
		[self setSelectedColumn:BSDateColumnHour];
		[controlView displayIfNeeded];
	} else if(NSMouseInRect(currentPoint,[self minuteRect], [controlView isFlipped])) {
		[self setSelectedColumn:BSDateColumnMinute];
		[controlView displayIfNeeded];
	}
	
	return YES;
}

#pragma mark## Private Functions ##
static int sMaxDays[] = {
	31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31,
};

static inline BOOL isLeapYear(int year)
{
	if((!(year % 4) && (year % 100)) || !(year % 400)) {
		return YES;
	}
	return NO;
}

static inline int maxDayFor(int year, int month)
{
	if(month != 2) return sMaxDays[month - 1];
	if(!isLeapYear(year)) return sMaxDays[month - 1];
	
	return 29;
}

static inline int calcDayFor(int newYear, int newMonth, int oldDay)
{
	int newMaxDay;
		
	newMaxDay = sMaxDays[newMonth - 1];
	// 新しい月の最大日数以下
	if(newMaxDay >= oldDay) return oldDay;
	// 2月以外は新しい最大日
	if(newMonth != 2) return newMaxDay;
	// うるう年ではない
	if(!isLeapYear(newYear)) return newMaxDay;
	
	return 29;
}

#pragma mark## Accessor ##
- (void)setTarget:(id)anObject
{
	[stepper setTarget:anObject];
	[super setTarget:anObject];
}
- (void)setAction:(SEL)aSelector
{
	[stepper setAction:aSelector];
	[super setAction:aSelector];
}
- (void)setFont:(NSFont *)newFont
{
	id temp = font;
	font = [newFont retain];
	[temp release];
}
- (NSFont *)font
{
	return font;
}
- (void)setFormatter:(NSFormatter *)newFormatter
{
	// Do not change formatter.
	
}
- (NSFormatter *)formatter
{
	return formatter;
}

- (void)setDate:(NSCalendarDate *)newDate
{
	id temp = date;
	date = [newDate retain];
	[temp release];
	
	[[self controlView] setNeedsDisplayInRect:[self yearRect]];
	[[self controlView] setNeedsDisplayInRect:[self monthRect]];
	[[self controlView] setNeedsDisplayInRect:[self dayRect]];
	[[self controlView] setNeedsDisplayInRect:[self hourRect]];
	[[self controlView] setNeedsDisplayInRect:[self minuteRect]];
//	[[self controlView] setNeedsDisplayInRect:[self secondRect]];
	[[self controlView] displayIfNeeded];
}
- (NSCalendarDate *)date
{
	return date;
}

- (int)minYear {return -999;}
- (int)maxYear {return 9999;}
- (int)year
{
	return [date yearOfCommonEra];
}
- (void)setYear:(int)year
{
	NSCalendarDate *newDate;
	
	newDate = [NSCalendarDate dateWithYear:year
									 month:[self month]
									   day:calcDayFor(year,[self month],[self day])
									  hour:[self hour]
									minute:[self minute]
									second:[self second]
								  timeZone:[date timeZone]];
	[self setDate:newDate];
}

- (int)minMonth {return 1;}
- (int)maxMonth {return 12;}
- (int)month
{
	return [date monthOfYear];
}
- (void)setMonth:(int)month
{
	NSCalendarDate *newDate;
	
	if([self minMonth] > month || month > [self maxMonth]) {
		NSBeep();
		return;
	}
	
	newDate = [NSCalendarDate dateWithYear:[self year]
									 month:month
									   day:calcDayFor([self year],month,[self day])
									  hour:[self hour]
									minute:[self minute]
									second:[self second]
								  timeZone:[date timeZone]];
	[self setDate:newDate];
}

- (int)minDay {return 1;}
- (int)maxDay
{
	return maxDayFor([self year], [self month]);
}
- (int)day
{
	return [date dayOfMonth];
}
- (void)setDay:(int)day
{
	NSCalendarDate *newDate;
	
	if([self minDay] > day || day > [self maxDay]) {
		NSBeep();
		return;
	}
	
	newDate = [NSCalendarDate dateWithYear:[self year]
									 month:[self month]
									   day:day
									  hour:[self hour]
									minute:[self minute]
									second:[self second]
								  timeZone:[date timeZone]];
	[self setDate:newDate];
}

- (int)minHour {return 0;}
- (int)maxHour {return 23;}
- (int)hour
{
	return [date hourOfDay];
}
- (void)setHour:(int)hour
{
	NSCalendarDate *newDate;
	
	if([self minHour] > hour || hour > [self maxHour]) {
		NSBeep();
		return;
	}
	
	newDate = [NSCalendarDate dateWithYear:[self year]
									 month:[self month]
									   day:[self day]
									  hour:hour
									minute:[self minute]
									second:[self second]
								  timeZone:[date timeZone]];
	[self setDate:newDate];
}

- (int)minMinute {return 0;}
- (int)maxMinute {return 59;}
- (int)minute
{
	return [date minuteOfHour];
}
- (void)setMinute:(int)minute
{
	NSCalendarDate *newDate;
	
	if([self minMinute] > minute || minute > [self maxMinute]) {
		NSBeep();
		return;
	}
	
	newDate = [NSCalendarDate dateWithYear:[self year]
									 month:[self month]
									   day:[self day]
									  hour:[self hour]
									minute:minute
									second:[self second]
								  timeZone:[date timeZone]];
	[self setDate:newDate];
}

- (int)minSecond {return 0;}
- (int)maxSecond {return 59;} // うるう秒って何よ？
- (int)second
{
	return [date secondOfMinute];
}
- (void)setSecond:(int)second
{
	NSCalendarDate *newDate;
	
	if([self minSecond] > second || second > [self maxSecond]) {
		NSBeep();
		return;
	}
	
	newDate = [NSCalendarDate dateWithYear:[self year]
									 month:[self month]
									   day:[self day]
									  hour:[self hour]
									minute:[self minute]
									second:second
								  timeZone:[date timeZone]];
	[self setDate:newDate];
}

- (NSString *)stringValue
{
	return [[self formatter] stringForObjectValue:[self date]];
}
- (void)setStringValue:(NSString *)string
{
	NSCalendarDate *newDate;
	id temp;
	
	newDate = [NSCalendarDate dateWithString:string calendarFormat:DATE_FORMAT];
	if(newDate) {
		temp = date;
		date = [newDate retain];
		[temp release];
	}
}
- (float)floatValue
{
	return (float)[[self date] timeIntervalSince1970];
}
- (void)setFloatValue:(float)value
{
	NSCalendarDate *newDate;
	id temp;
	
	newDate = [NSCalendarDate dateWithTimeIntervalSince1970:value];
	if(newDate) {
		temp = date;
		date = [newDate retain];
		[temp release];
	}
}
- (double)doubleValue
{
	return [[self date] timeIntervalSince1970];
}
-(void)setDoubleValue:(double)value
{
	NSCalendarDate *newDate;
	id temp;
	
	newDate = [NSCalendarDate dateWithTimeIntervalSince1970:value];
	if(newDate) {
		temp = date;
		date = [newDate retain];
		[temp release];
	}
}
- (NSTimeInterval)epoch
{
	return [[self date] timeIntervalSince1970];
}
- (void)setSelectedColumn:(BSDateColumn)column
{
	NSString *keyPath;
	NSString *minKeyPath;
	NSString *maxKeyPath;
	
	[[self controlView] setNeedsDisplayInRect:[self currentSelectedColumnRect]];
	
	switch(column) {
		case BSDateColumnYear:
			keyPath = @"year";
			minKeyPath = @"minYear";
			maxKeyPath = @"maxYear";
			break;
		case BSDateColumnMonth:
			keyPath = @"month";
			minKeyPath = @"minMonth";
			maxKeyPath = @"maxMonth";
			break;
		case BSDateColumnDay:
			keyPath = @"day";
			minKeyPath = @"minDay";
			maxKeyPath = @"maxDay";
			break;
		case BSDateColumnHour:
			keyPath = @"hour";
			minKeyPath = @"minHour";
			maxKeyPath = @"maxHour";
			break;
		case BSDateColumnMinute:
			keyPath = @"minute";
			minKeyPath = @"minMinute";
			maxKeyPath = @"maxMinute";
			break;
		case BSDateColumnSecond:
			keyPath = @"second";
			minKeyPath = @"minSecond";
			maxKeyPath = @"maxSecond";
			break;
		default:
			// do nothig.
			return;
	}
	selectedColumn = column;
	
	[stepper bind:@"value"
		 toObject:self
	  withKeyPath:keyPath
		  options:nil];
	[stepper bind:@"minValue"
		 toObject:self
	  withKeyPath:minKeyPath
		  options:nil];
	[stepper bind:@"maxValue"
		 toObject:self
	  withKeyPath:maxKeyPath
		  options:nil];
	
	[[self controlView] setNeedsDisplayInRect:[self currentSelectedColumnRect]];
}
- (BSDateColumn)selectedColumn
{
	return selectedColumn;
}

@end

static NSString *StepperCodingKey = @"StepperCodingKey";
static NSString *FormatterCodingKey = @"FormatterCodingKey";
static NSString *FontCodingKey = @"FontCodingKey";
static NSString *DateCodingKey = @"DateCodingKey";

@implementation BSDatePickerCell(BSDatePickerCell_NSCoder)
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:stepper forKey:StepperCodingKey];
	[aCoder encodeObject:formatter forKey:FormatterCodingKey];
	[aCoder encodeObject:font forKey:FontCodingKey];
	[aCoder encodeObject:date forKey:DateCodingKey];
	
	[super encodeWithCoder:aCoder];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
	if( self = [super initWithCoder:aDecoder]) {
		stepper = [[aDecoder decodeObjectForKey:StepperCodingKey] retain];
		formatter = [[aDecoder decodeObjectForKey:FormatterCodingKey] retain];
		[self setFont:[aDecoder decodeObjectForKey:FontCodingKey]];
		[self setDate:[aDecoder decodeObjectForKey:DateCodingKey]];
		
		[self setSelectedColumn:BSDateColumnYear];
	}
	
	return self;
}
@end
