//
//  $Id: BSBoardListView.m,v 1.5 2007/02/25 11:51:05 tsawada2 Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/09/20.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import "BSBoardListView.h"
#import <SGAppKit/NSImage-SGExtensions.h>

#import "NSBezierPath_AMShading.h"

#define useLog 0

@implementation BSBoardListView
- (int) semiSelectedRow
{
	return _semiSelectedRow;
}

- (NSRect) semiSelectedRowRect
{
	return _semiSelectedRowRect;
}

- (void) awakeFromNib
{
	isInstalledTextInputEvent = NO;
	isFindBegin = NO;
	isUsingInputWindow = NO;
	resetTimer = nil;  

	_semiSelectedRow = -1;
	_semiSelectedRowRect = NSZeroRect;
}

#pragma mark Custom highlight drawing
- (void)highlightSelectionInClipRect:(NSRect)clipRect
{	
	NSColor *topLineColor, *bottomLineColor, *gradientStartColor, *gradientEndColor;
	
	if (([[self window] firstResponder] == self) && [[self window] isKeyWindow]) {
		// Finder Style
/*		topLineColor = [NSColor colorWithCalibratedRed:(61.0/255.0) green:(123.0/255.0) blue:(218.0/255.0) alpha:1.0];
		bottomLineColor = [NSColor colorWithCalibratedRed:(31.0/255.0) green:(92.0/255.0) blue:(207.0/255.0) alpha:1.0];
		gradientStartColor = [NSColor colorWithCalibratedRed:(89.0/255.0) green:(153.0/255.0) blue:(209.0/255.0) alpha:1.0];
		gradientEndColor = [NSColor colorWithCalibratedRed:(33.0/255.0) green:(94.0/255.0) blue:(208.0/255.0) alpha:1.0];*/
		// Tiger Mail Style
		topLineColor = [NSColor colorWithDeviceRed:(112.0/255.0) green:(155.0/255.0) blue:(230.0/255.0) alpha:1.0];
		bottomLineColor = [NSColor colorWithDeviceRed:(89.0/255.0) green:(128.0/255.0) blue:(205.0/255.0) alpha:1.0];
		gradientStartColor = [NSColor colorWithDeviceRed:(103.0/255.0) green:(148.0/255.0) blue:(229.0/255.0) alpha:1.0];
		gradientEndColor = [NSColor colorWithDeviceRed:(84.0/255.0) green:(135.0/255.0) blue:(225.0/255.0) alpha:1.0];
	} else {
		topLineColor = [NSColor colorWithDeviceRed:(173.0/255.0) green:(187.0/255.0) blue:(209.0/255.0) alpha:1.0];
		bottomLineColor = [NSColor colorWithDeviceRed:(150.0/255.0) green:(161.0/255.0) blue:(183.0/255.0) alpha:1.0];
		gradientStartColor = [NSColor colorWithDeviceRed:(168.0/255.0) green:(183.0/255.0) blue:(205.0/255.0) alpha:1.0];
		gradientEndColor = [NSColor colorWithDeviceRed:(157.0/255.0) green:(174.0/255.0) blue:(199.0/255.0) alpha:1.0];
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
- (void) cleanUpSemiHighlightBorder : (NSNotification *) theNotification
{
	// erase the border
	[self setNeedsDisplayInRect: _semiSelectedRowRect];
	[[NSNotificationCenter defaultCenter] removeObserver : self];	
	_semiSelectedRowRect = NSZeroRect;
}

- (NSMenu *) menuForEvent : (NSEvent *) theEvent
{
	int row = [self rowAtPoint : [self convertPoint : [theEvent locationInWindow] fromView : nil]];

	if(![self isRowSelected : row]) {
		_semiSelectedRowRect = [self rectOfRow : row];
		// draw the border
		[self lockFocus];
		NSFrameRectWithWidth(_semiSelectedRowRect, 2.0);
		[self unlockFocus];
		[self displayIfNeededInRect: _semiSelectedRowRect];

		// This Notification is available in Mac OS X 10.3 and later.
 		[[NSNotificationCenter defaultCenter] addObserver : self
												 selector : @selector(cleanUpSemiHighlightBorder:)
													 name : NSMenuDidEndTrackingNotification
												   object : nil];
	}

	if(row >= 0) {
		_semiSelectedRow = row;
		return [self menu];
	} else {
		return nil;
	}
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
	OSStatus err = GetEventParameter(theEvent, kEventParamTextInputSendText, typeUnicodeText, NULL, 0, &dataSize, NULL);
	UniChar *dataPtr = (UniChar *)malloc(dataSize);
	err = GetEventParameter(theEvent, kEventParamTextInputSendText, typeUnicodeText, NULL, dataSize, NULL, dataPtr);
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

	if (delegate_ && [delegate_ respondsToSelector: @selector(outlineView:findForString:)]) {
		indexes = [delegate_ outlineView: self findForString: aString];
	}
	if (indexes != nil) {
		[self selectRowIndexes: indexes byExtendingSelection: NO];
	}
}
@end
