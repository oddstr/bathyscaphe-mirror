//
//  BSBoardListView.m
//  SGAppKit (BathyScaphe)
//
//  Created by Tsutomu Sawada on 05/09/20.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//

#import "BSBoardListView.h"
#import <SGAppKit/NSImage-SGExtensions.h>

#import "NSBezierPath_AMShading.h"

#define useLog 0

@implementation BSBoardListView
static NSArray *activeFirstResponderColors;
static NSArray *activeNo1stResponderColors;
static NSArray *nonActiveColors;

+ (void)initialize
{
	if (self == [BSBoardListView class]) {
		[self resetColors];
		nonActiveColors = [[NSArray alloc] initWithObjects:
							[NSColor colorWithDeviceRed:0.592 green:0.592 blue:0.592 alpha:1.0],
							[NSColor colorWithDeviceRed:0.541 green:0.541 blue:0.541 alpha:1.0],
							[NSColor colorWithDeviceRed:0.71 green:0.71 blue:0.71 alpha:1.0],
							[NSColor colorWithDeviceRed:0.549 green:0.549 blue:0.549 alpha:1.0],
							nil];
	}
}

+ (void)resetColors
{
	if ([NSColor currentControlTint] == NSGraphiteControlTint) {
		activeFirstResponderColors = [[NSArray alloc] initWithObjects:
			[NSColor colorWithDeviceRed:0.408 green:0.471 blue:0.549 alpha:1.0],
			[NSColor colorWithDeviceRed:0.251 green:0.341 blue:0.439 alpha:1.0],
			[NSColor colorWithDeviceRed:0.510 green:0.576 blue:0.651 alpha:1.0],
			[NSColor colorWithDeviceRed:0.267 green:0.357 blue:0.451 alpha:1.0],
			nil];
		activeNo1stResponderColors = [[NSArray alloc] initWithObjects:
			[NSColor colorWithDeviceRed:0.584 green:0.600 blue:0.690 alpha:1.0],
			[NSColor colorWithDeviceRed:0.494 green:0.557 blue:0.627 alpha:1.0],
			[NSColor colorWithDeviceRed:0.667 green:0.718 blue:0.769 alpha:1.0],
			[NSColor colorWithDeviceRed:0.506 green:0.569 blue:0.635 alpha:1.0],
			nil];	
	} else {
		activeFirstResponderColors = [[NSArray alloc] initWithObjects:
			[NSColor colorWithDeviceRed:0.271 green:0.502 blue:0.784 alpha:1.0],
			[NSColor colorWithDeviceRed:0.082 green:0.325 blue:0.667 alpha:1.0],
			[NSColor colorWithDeviceRed:0.361 green:0.576 blue:0.835 alpha:1.0],
			[NSColor colorWithDeviceRed:0.102 green:0.345 blue:0.678 alpha:1.0],
			nil];
		activeNo1stResponderColors = [[NSArray alloc] initWithObjects:
			[NSColor colorWithDeviceRed:0.569 green:0.627 blue:0.753 alpha:1.0],
			[NSColor colorWithDeviceRed:0.435 green:0.51 blue:0.607 alpha:1.0],
			[NSColor colorWithDeviceRed:0.635 green:0.694 blue:0.812 alpha:1.0],
			[NSColor colorWithDeviceRed:0.447 green:0.522 blue:0.675 alpha:1.0],
			nil];
	}
}

- (int)semiSelectedRow
{
	return m_semiSelectedRow;
}

- (void)setSemiSelectedRow:(int)rowIndex
{
	m_semiSelectedRow = rowIndex;
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow
{
	if (!newWindow) return;

	isInstalledTextInputEvent = NO;
	isFindBegin = NO;
	isUsingInputWindow = NO;
	resetTimer = nil;
	
	[[NSNotificationCenter defaultCenter]
		addObserver:self selector:@selector(systemColorDidChange:) name:NSSystemColorsDidChangeNotification object:nil];

	[self setSemiSelectedRow:-1];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	if (isInstalledTextInputEvent) {
		OSStatus err = RemoveEventHandler(textInputEventHandler);
		if (err != noErr) {
			NSLog([NSString stringWithFormat:@"Fail to Remove EventHandler with : %d", err]);
		}
	}

	fieldEditor = nil;
	[self stopResetTimer];
	[super dealloc];
}

#pragma mark Custom highlight drawing
- (void)systemColorDidChange:(NSNotification *)aNotification
{
	[[self class] resetColors];
}

- (void)highlightSelectionInClipRect:(NSRect)clipRect
{	
	NSColor *topLineColor, *bottomLineColor, *gradientStartColor, *gradientEndColor;
	
	if ([[self window] isMainWindow]) {
		if ([[self window] firstResponder] == self) {
/*
			// Tiger Finder Style
			topLineColor = [NSColor colorWithCalibratedRed:(61.0/255.0) green:(123.0/255.0) blue:(218.0/255.0) alpha:1.0];
			bottomLineColor = [NSColor colorWithCalibratedRed:(31.0/255.0) green:(92.0/255.0) blue:(207.0/255.0) alpha:1.0];
			gradientStartColor = [NSColor colorWithCalibratedRed:(89.0/255.0) green:(153.0/255.0) blue:(209.0/255.0) alpha:1.0];
			gradientEndColor = [NSColor colorWithCalibratedRed:(33.0/255.0) green:(94.0/255.0) blue:(208.0/255.0) alpha:1.0];
*/
			// Tiger Mail Style
/*			topLineColor = [NSColor colorWithDeviceRed:0.271 green:0.502 blue:0.784 alpha:1.0];
			bottomLineColor = [NSColor colorWithDeviceRed:0.082 green:0.325 blue:0.667 alpha:1.0];
			gradientStartColor = [NSColor colorWithDeviceRed:0.361 green:0.576 blue:0.835 alpha:1.0];
			gradientEndColor = [NSColor colorWithDeviceRed:0.102 green:0.345 blue:0.678 alpha:1.0];*/
			topLineColor = [activeFirstResponderColors objectAtIndex:0];
			bottomLineColor = [activeFirstResponderColors objectAtIndex:1];
			gradientStartColor = [activeFirstResponderColors objectAtIndex:2];
			gradientEndColor = [activeFirstResponderColors objectAtIndex:3];
		} else {
/*			topLineColor = [NSColor colorWithDeviceRed:0.569 green:0.627 blue:0.753 alpha:1.0];
			bottomLineColor = [NSColor colorWithDeviceRed:0.435 green:0.51 blue:0.607 alpha:1.0];
			gradientStartColor = [NSColor colorWithDeviceRed:0.635 green:0.694 blue:0.812 alpha:1.0];
			gradientEndColor = [NSColor colorWithDeviceRed:0.447 green:0.522 blue:0.675 alpha:1.0];*/
			topLineColor = [activeNo1stResponderColors objectAtIndex:0];
			bottomLineColor = [activeNo1stResponderColors objectAtIndex:1];
			gradientStartColor = [activeNo1stResponderColors objectAtIndex:2];
			gradientEndColor = [activeNo1stResponderColors objectAtIndex:3];
		}
	} else {
/*
		topLineColor = [NSColor colorWithDeviceRed:(173.0/255.0) green:(187.0/255.0) blue:(209.0/255.0) alpha:1.0];
		bottomLineColor = [NSColor colorWithDeviceRed:(150.0/255.0) green:(161.0/255.0) blue:(183.0/255.0) alpha:1.0];
		gradientStartColor = [NSColor colorWithDeviceRed:(168.0/255.0) green:(183.0/255.0) blue:(205.0/255.0) alpha:1.0];
		gradientEndColor = [NSColor colorWithDeviceRed:(157.0/255.0) green:(174.0/255.0) blue:(199.0/255.0) alpha:1.0];
*/
/*		topLineColor = [NSColor colorWithDeviceRed:0.592 green:0.592 blue:0.592 alpha:1.0];
		bottomLineColor = [NSColor colorWithDeviceRed:0.541 green:0.541 blue:0.541 alpha:1.0];
		gradientStartColor = [NSColor colorWithDeviceRed:0.71 green:0.71 blue:0.71 alpha:1.0];
		gradientEndColor = [NSColor colorWithDeviceRed:0.549 green:0.549 blue:0.549 alpha:1.0];*/
		topLineColor = [nonActiveColors objectAtIndex:0];
		bottomLineColor = [nonActiveColors objectAtIndex:1];
		gradientStartColor = [nonActiveColors objectAtIndex:2];
		gradientEndColor = [nonActiveColors objectAtIndex:3];
	}
	
	NSIndexSet *selRows = [self selectedRowIndexes];
	int rowIndex = [selRows firstIndex];
	int newRowIndex;
	NSRect highlightRect;
	
	while (rowIndex != NSNotFound)
	{
		newRowIndex = [selRows indexGreaterThanIndex:rowIndex];
		highlightRect = [self rectOfRow:rowIndex];

		highlightRect.size.height -= 1.0;
		
		[topLineColor set];
		NSRectFill(highlightRect);
		
		highlightRect.origin.y += 1.0;
		highlightRect.size.height-=1.0;
		[bottomLineColor set];
		NSRectFill(highlightRect);
		
		highlightRect.size.height -= 1.0;
			
		[[NSBezierPath bezierPathWithRect:highlightRect] linearGradientFillWithStartColor:gradientStartColor
																				 endColor:gradientEndColor];
		
		rowIndex = newRowIndex;
	}
}

#pragma mark Contextual menu handling
- (void)highlightSemiSelectedRow:(int)rowIndex clipRect:(NSRect)clipRect
{
	if (rowIndex == -1) return;
	[[NSColor selectedMenuItemColor] set];
	NSFrameRectWithWidth(clipRect, 2.0);
}

- (void)cleanUpSemiHighlightBorder:(NSNotification *)theNotification
{
	// erase the border
	[self setNeedsDisplayInRect:[self rectOfRow:[self semiSelectedRow]]];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSMenuDidEndTrackingNotification object:nil];	
}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	int row = [self rowAtPoint:[self convertPoint:[theEvent locationInWindow] fromView:nil]];
	[self setSemiSelectedRow:row];

	if (![self isRowSelected:row]) {
		NSRect	semiSelectedRowRect = [self rectOfRow:row];

		// draw the border
		[self lockFocus];
		[self highlightSemiSelectedRow:row clipRect:semiSelectedRowRect];
		[self unlockFocus];
		[self displayIfNeededInRect:semiSelectedRowRect];

		// This Notification is available in Mac OS X 10.3 and later.
 		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(cleanUpSemiHighlightBorder:)
													 name:NSMenuDidEndTrackingNotification
												   object:nil];
	}

	return [self menu];
}
@end

//
// Type-To-Select Support
// Available in Starlight Breaker.
//
// From FileTreeView.m (part of StationaryPalette by 栗田哲郎)
// BathyScaphe プロジェクトに対し、栗田氏のご厚意により特別に FileTreeView.m を
// 修正 BSD ライセンスに基づいて使用する許可を得ています。
//
#pragma mark -

@implementation BSBoardListView(TypeToSelect)
static OSStatus inputText(EventHandlerCallRef nextHandler, EventRef theEvent, void* userData)
{
#if useLog    
	NSLog(@"inputText");
#endif
	UInt32 dataSize;
	OSStatus err = GetEventParameter(theEvent, kEventParamTextInputSendText, typeUTF16ExternalRepresentation, NULL, 0, &dataSize, NULL);
	UniChar *dataPtr = (UniChar *)malloc(dataSize);
	err = GetEventParameter(theEvent, kEventParamTextInputSendText, typeUTF16ExternalRepresentation, NULL, dataSize, NULL, dataPtr);
	NSString *aString =[[NSString alloc] initWithBytes:dataPtr length:dataSize encoding:NSUnicodeStringEncoding];
	[(id)userData insertTextInputSendText:aString];
	free(dataPtr);
#if useLog	
	NSLog(@"end inputText");
#endif
	return(CallNextEventHandler(nextHandler, theEvent));
}

- (NSTimeInterval)findTimeoutInterval
{
    // from Dan Wood's 'Table Techniques Taught Tastefully', as pointed out by someone
    // on cocoadev.com
    
    // Timeout is two times the key repeat rate "InitialKeyRepeat" user default.
    // (converted from sixtieths of a second to seconds), but no more than two seconds.
    // This behavior is determined based on Inside Macintosh documentation on the List Manager.
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int keyThreshTicks = [defaults integerForKey:@"InitialKeyRepeat"]; // undocumented key.  Still valid in 10.3. 
    if (0 == keyThreshTicks)	// missing value in defaults?  Means user has never changed the default.
    {
        keyThreshTicks = 35;	// apparent default value. translates to 1.17 sec timeout.
    }
    
    return MIN(2.0/60.0*keyThreshTicks, 2.0);
}


BOOL isReturnOrEnterKeyEvent(NSEvent *keyEvent) {
	unsigned short key_code = [keyEvent keyCode];
	return ((key_code == 36) || (key_code == 76));
}


BOOL isEscapeKeyEvent(NSEvent *keyEvent) {
	unsigned short key_code = [keyEvent keyCode];
	return (key_code == 53);
}

BOOL shouldBeginFindForKeyEvent(NSEvent *keyEvent)
{
    if (([keyEvent modifierFlags] & (NSCommandKeyMask | NSControlKeyMask | NSFunctionKeyMask)) != 0) {
        return NO;
    }
    
	unsigned short key_code = [keyEvent keyCode];
	// if true, arrow key's event.
	if ((123 <= key_code) && (key_code <= 126)) {
		return NO;
	}
	
	//escape key
	if (isEscapeKeyEvent(keyEvent)) return NO;
	
	if (isReturnOrEnterKeyEvent(keyEvent)) return NO;
	
	//space and tab and newlines are ignored
	unichar character = [[keyEvent characters] characterAtIndex:0];
	if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:character]){
		return NO;
	}
    return YES;    
}

- (BOOL)canChangeSelection
{
    id delegate = [self delegate];
    
    if (   [self isKindOfClass:[NSOutlineView class]] 
           && [delegate respondsToSelector:@selector(selectionShouldChangeInOutlineView:)])
    {
        return [delegate selectionShouldChangeInOutlineView:(NSOutlineView *)self];
    }
    else if ([delegate respondsToSelector:@selector(selectionShouldChangeInTableView:)])
    {
        return [delegate selectionShouldChangeInTableView:self];
    }
    else
    {
        return YES;
    }    
}

- (void)resetFind:(NSTimer *)aTimer
{
#if useLog
	NSLog(@"start restFind");
#endif	
	if (!isUsingInputWindow) {
		isFindBegin = NO;
		// it seems that RemoveEventHandler is not required -- 2007-01-10
		/* 
		OSStatus err = RemoveEventHandler(textInputEventHandler);
		if (err != noErr) {
			NSLog([NSString stringWithFormat:@"Fail to Remove EventHandler with : %d", err]);
		}
		*/
		isUsingInputWindow = NO;
		[self stopResetTimer];
	}
}

- (void)stopResetTimer
{
#if useLog
	NSLog(@"stop startResetTimer");
#endif	
	if (resetTimer != nil) {
		[resetTimer invalidate];
		[resetTimer release];
		resetTimer = nil;
	}
}

- (void)startResetTimer
{
#if useLog
	NSLog(@"start startResetTimer");
#endif	
	if (resetTimer != nil) {
		[resetTimer release];
	}
	
	resetTimer = [NSTimer scheduledTimerWithTimeInterval:[self findTimeoutInterval]
							target:self selector:@selector(resetFind:)
							userInfo:nil repeats:YES];
	[resetTimer retain];
}

- (void)insertTextInputSendText:(NSString *)aString
{
	if (isUsingInputWindow) {
		[fieldEditor insertText:aString];
		[self findForString:[fieldEditor string] ];
	}
}

- (void)keyDown:(NSEvent *)keyEvent
{
#if useLog	
	NSLog([NSString stringWithFormat:@"start KeyDown with event : %@", [keyEvent description]]);
#endif	
	BOOL eatEvent = NO;
//	if (searchColumnIdentifier == nil) goto bail;
 	if (![self canChangeSelection]) goto bail;
	
	BOOL shouldFindFlag = shouldBeginFindForKeyEvent(keyEvent);
	
	if (isFindBegin) {
		if (isUsingInputWindow) {
			if (! isEscapeKeyEvent(keyEvent)) eatEvent = YES;
		}
		else if (shouldFindFlag) {
			eatEvent = YES;
		}
	}
	else if (shouldFindFlag) {
		eatEvent = YES;
	}
	
bail:
	if (eatEvent) {
		#if useLog
		NSLog(@"eat key event");
		#endif
		[self stopResetTimer];
		fieldEditor = [[self window] fieldEditor:YES forObject:self];
		
		if (!isFindBegin) {
			[fieldEditor setString:@""];
			isFindBegin = YES;
		}

		if (!isInstalledTextInputEvent) {
			EventTypeSpec spec = { kEventClassTextInput, kEventTextInputUnicodeForKeyEvent };
			EventHandlerUPP handlerUPP = NewEventHandlerUPP(inputText);
			OSStatus err = InstallApplicationEventHandler(handlerUPP, 1, &spec, (void*)self, &textInputEventHandler);
			DisposeEventHandlerUPP(handlerUPP);
			NSAssert1(err == noErr, @"Fail to install TextInputEvent with error :%d", err);
			isInstalledTextInputEvent = YES;
		}
		
		NSString *before_string = [NSString stringWithString:[fieldEditor string]];
	#if useLog
		NSLog([NSString stringWithFormat:@"before String : %@", before_string]);
	#endif
		[fieldEditor interpretKeyEvents:[NSArray arrayWithObject:keyEvent]];
		NSString *after_string = [fieldEditor string];
		
	#if useLog
		NSLog([NSString stringWithFormat:@"after String : %@", after_string]);
	#endif
	
		isUsingInputWindow = [before_string isEqualToString:after_string];
	#if useLog
		printf("isUsingInputWindow : %d\n", isUsingInputWindow);
	#endif
		if (!isUsingInputWindow) {
			[self findForString:after_string ];
		}
		[self startResetTimer];
	}
	else {
		if (isFindBegin) {
			[self stopResetTimer];
			isFindBegin = NO;
		}
		[super keyDown:keyEvent];	
	}
}

- (void)findForString:(NSString *)aString {
#if useLog
	NSLog([NSString stringWithFormat:@"start findForString:%@", aString]);
#endif
	
/*	NSTableColumn *column = [self tableColumnWithIdentifier:searchColumnIdentifier];
	int nrows = [self numberOfRows];
	id dataSource = [self dataSource];
	for (int i = 0; i< nrows; i++) {
		id item = [self itemAtRow:i];
		id display_name = [dataSource outlineView:self objectValueForTableColumn:column byItem:item];
		if (NSOrderedSame == [display_name compare:aString options:NSCaseInsensitiveSearch range:NSMakeRange(0, [aString length])]) {
			[self selectRowIndexes:[NSIndexSet indexSetWithIndex:i] byExtendingSelection:NO];
			break;
		}
		
	}*/
	id			delegate_ = [self delegate];
	NSIndexSet	*indexes = nil;

	if (delegate_ && [delegate_ respondsToSelector:@selector(outlineView:findForString:)]) {
		indexes = [delegate_ outlineView:self findForString:aString];
	}
	if (indexes) {
		[self selectRowIndexes:indexes byExtendingSelection:NO];
	}
}
@end
