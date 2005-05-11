//:CMRIndexingStepper.m
#import "CMRIndexingStepper_p.h"


@implementation CMRIndexingStepper
- (id) init
{
	if(self = [super init]){
		if(NO == [NSBundle loadNibNamed : APP_INDEXINGSTEPPER_LOADNIB_NAME
								  owner : self]){
			[self release];
			return nil;
		}
	}
	return self;
}
- (void) awakeFromNib
{
	[self setupUIComponents];
}
- (void) dealloc
{
	[self setDelegate : nil];
	[m_frameView removeFromSuperviewWithoutNeedingDisplay];
	[m_frameView release];
	[m_format release];
	[super dealloc];
}
@end



@implementation CMRIndexingStepper(Private)
- (void) invokeDelegateMethodWithSelector : (SEL) aSelector
{
	if(nil == [self delegate]) return;
	if(NO == [[self delegate] respondsToSelector : aSelector]) return;
	
	[[self delegate] performSelector : aSelector
						  withObject : self];
}
- (BOOL) canScrollToLastUpdatedMessage
{
	if ( nil == [self delegate] ) {
		return NO;
	}
	if ( NO == [[self delegate] respondsToSelector:@selector(canScrollToLastUpdatedMessage)] ) {
		return NO;
	} else {
		int returnId = 0;
		
		returnId = (int)[[self delegate] performSelector:@selector(canScrollToLastUpdatedMessage)];
		return (BOOL)returnId;
	}
}
- (void) controlTextDidEndEditing : (NSNotification *) aNotification
{
	unsigned	moveIndex_;
	NSRange		scanedRange_;
	
	UTILAssertNotificationName(
		aNotification,
		NSControlTextDidEndEditingNotification);
	UTILAssertNotificationObject(
		aNotification,
		[self textField]);
	
	moveIndex_ = [self unsignedIntAfterPrefix : [self prefixToBeSkiped]
									    field : &scanedRange_];

	if((moveIndex_ == NSNotFound) ||
		moveIndex_ > [self maxValue] ||
		moveIndex_ < [self minValue]){
		
		NSBeep();
		[self updateUIComponents];
		return;
	}
	[self setIntValue : moveIndex_];
	[self invokeDelegateMethodWithSelector : @selector(indexingStepperDidEndEditing:)];
}
@end



@implementation CMRIndexingStepper(DelegateExtension)
- (NSRange) selectRangeWithTextField : (NSTextField *) textField
{
	return [self editableRange : NULL];
}
@end



@implementation CMRIndexingStepper(Scan)
- (unsigned) nthfield : (unsigned ) anIndex
                field : (NSRange *) aRange
{
	NSScanner			*scanner_;
	NSCharacterSet		*decimalSet_;
	unsigned			curIndex_;
	unsigned			startIndex_;
	int					value_;
	
	curIndex_ = 0;
	scanner_ = [NSScanner scannerWithString : [self stringValue]];
	
	decimalSet_ = [NSCharacterSet decimalDigitCharacterSet];
	do{
		[scanner_ scanUpToCharactersFromSet : decimalSet_
								 intoString : NULL];
		startIndex_ = [scanner_ scanLocation];
		[scanner_ scanInt : &value_];
		
		curIndex_++;
	}while(curIndex_ <= anIndex);
	
	if(aRange != NULL){
		aRange->location = startIndex_;
		aRange->length = ([scanner_ scanLocation] - startIndex_);
	}
	return value_;
}


- (unsigned) unsignedIntAfterPrefix : (NSString *) prefix
                              field : (NSRange  *) aRange
{
	NSScanner		*scanner_;
	unsigned		startIndex_;
	int				value_;
	BOOL			isScaned_;
		
	scanner_ = [NSScanner scannerWithString : [self stringValue]];
	isScaned_ = YES;

	if(prefix != nil && [prefix length] > 0){
		isScaned_ = [scanner_ scanString : prefix intoString : NULL];
	}

	startIndex_ = [scanner_ scanLocation];
	isScaned_ = (isScaned_ && [scanner_ scanInt : &value_]);
	

	if(NO == isScaned_){
		return NSNotFound;
	}
	if(aRange != NULL){
		aRange->location = startIndex_;
		aRange->length = ([scanner_ scanLocation] - startIndex_);
	}
	return value_;
}



- (void) selectEditableRange : (NSText *) fieldEditor
{
	NSRange editableRange_;
	
	editableRange_ = [self editableRange : NULL];
	[fieldEditor setSelectedRange : editableRange_];
}

- (NSRange) editableRange : (unsigned *) value
{
	NSRange		edRange_;
	unsigned	nthfield_;
	
	nthfield_ = [self nthfield : 0 field : &edRange_];
	if(value != NULL) *value = nthfield_;
	
	return edRange_;
}

- (NSString *) prefixToBeSkiped
{
	return nil;
}
@end



@implementation CMRIndexingStepper(Attributes)
/* Accessor for m_delegate */
- (id) delegate
{
	return m_delegate;
}
- (void) setDelegate : (id) aDelegate
{
	m_delegate = aDelegate;
}
- (NSString *) format
{
	if(nil == m_format)
		m_format = [[NSString alloc] initWithString : APP_INDEXINGSTEPPER_FORMAT];
	return m_format;
}
- (void) setFormat : (NSString *) aFormat
{
	id tmp;
	
	tmp = m_format;
	m_format = [aFormat retain];
	[tmp release];
	
	[self updateUIComponents];
}
- (NSView *) contentView
{
	return [self frameView];
}
- (NSTextField *) textField
{
	return [self indexField];
}
- (NSString *) stringValue
{
	return [[self textField] stringValue];
}
/* Accessor for m_maxValue */
- (int) maxValue
{
	return m_maxValue;
}
- (void) setMaxValue : (int) aMaxValue
{
	m_maxValue = aMaxValue;
	[self updateUIComponents];
}
/* Accessor for m_minValue */
- (int) minValue
{
	return m_minValue;
}
- (void) setMinValue : (int) aMinValue
{
	m_minValue = aMinValue;
	[self updateUIComponents];
}
/* Accessor for m_intValue */
- (int) intValue
{
	return m_intValue;
}
- (void) setIntValue : (int) anIntValue
{
	if(anIntValue < [self minValue]) return;
	if(anIntValue > [self maxValue]) return;
	
	m_intValue = anIntValue;
	[self updateUIComponents];
}
@end



@implementation CMRIndexingStepper(Action)
- (IBAction) increment : (id) sender
{
	[self setIntValue : ([self intValue] +1)];
	[self invokeDelegateMethodWithSelector : @selector(indexingStepperDidIncrement:)];
}
- (IBAction) decrement : (id) sender
{
	[self setIntValue : ([self intValue] -1)];
	[self invokeDelegateMethodWithSelector : @selector(indexingStepperDidDecrement:)];
}
- (IBAction) max : (id) sender
{
	[self setIntValue : [self maxValue]];
	[self invokeDelegateMethodWithSelector : @selector(indexingStepperDidBecomeMax:)];
}
- (IBAction) min : (id) sender
{
	[self setIntValue : [self minValue]];
	[self invokeDelegateMethodWithSelector : @selector(indexingStepperDidBecomeMin:)];
}
- (IBAction) updated : (id) sender
{
	[self invokeDelegateMethodWithSelector : @selector(indexingStepperDidBecomeUpdated:)];
}
@end
