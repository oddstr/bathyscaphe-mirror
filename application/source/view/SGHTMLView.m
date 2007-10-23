//
//  SGHTMLView.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/08/06.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "SGHTMLView_p.h"
#import "AppDefaults.h"

// for debugging only
#define UTIL_DEBUGGING				0
#import "UTILDebugging.h"

NSString *const SGHTMLViewMouseEnteredNotification = @"SGHTMLViewMouseEnteredNotification";
NSString *const SGHTMLViewMouseExitedNotification = @"SGHTMLViewMouseExitedNotification";

static NSString *const kThreadKeyBindingsFile = @"ThreadKeyBindings.plist";

#define MOUSE_CLICK_TRACKING_TIME	0.18


@implementation SGHTMLView
- (void)dealloc
{
	[self removeTrackingRect:[self visibleRectTag]];
	[self removeAllLinkTrackingRects];
	[_userDataArray release];
	[_trackingRectTags release];

	[super dealloc];
}

#pragma mark Overrides
- (void)resetCursorRects
{
	[self resetCursorRectsImp];
}

/*
2003-11-17 Takanori Ishikawa <takanori@gd5.so-net.ne.jp>
------------------------------------------------------------
- [NSTextView mouseEntered:]
- [NSTextView mouseExited:]
は何故か、- [NSWindow setAcceptsMouseMovedEvents:] を呼ぶ実装になっている。
acceptsMouseMovedEvents == YES だと resetCursorRects が頻繁に呼ばれる
ので、super のメソッドは実行しない。
*/
- (void)mouseEntered:(NSEvent *)theEvent
{
//	[super mouseEntered:theEvent];
	[self responseMouseEvent:theEvent mouseEntered:YES];
}

- (void)mouseExited:(NSEvent *)theEvent
{
//	[super mouseExited:theEvent];
	[self responseMouseEvent:theEvent mouseEntered:NO];
}

/*
2005-09-08 tsawada2 <ben-sawa@td5.so-net.ne.jp>
------------------------------------------------------------
以前は、ここで -[NSTextView linkTextAttributes] をオーバーライドして空の辞書を返していたが、
現在は CMRThreadView の初期化時に -[NSTextView setLinkTextAttributes:] で適切な属性辞書を
セットして活用している。
*/

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	NSPoint			mouseLocation_;
	NSEventType		type_;
	id				link_;
	NSRange			effectiveRange_;
	
	UTILRequireCondition(theEvent != nil, default_menu);
	
	type_ = [theEvent type];
	UTILRequireCondition(
		NSLeftMouseDown == type_ || 
		NSRightMouseDown == type_ || 
		NSOtherMouseDown == type_,
		default_menu);
	
	mouseLocation_ = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	
	// Link Menu:
	// ==========================================
	// リンクをクリックした場合はリンク全体を選択
	// リンク専用のメニューも追加
	link_ = [self attribute:NSLinkAttributeName atPoint:mouseLocation_ effectiveRange:&effectiveRange_];
	UTILRequireCondition([self validateLinkByFiltering:link_], default_menu);
	
	[self setSelectedRange:effectiveRange_];
	return [self linkMenuWithLink:link_ forImageFile:[self validateLinkForImage:link_]];

default_menu:
	return [self menu];
}

#pragma mark Key Binding Support
+ (SGKeyBindingSupport *)keyBindingSupport
{
	static SGKeyBindingSupport *stKeyBindingSupport_;
	
	if (!stKeyBindingSupport_) {
		NSDictionary	*dict;
		
		dict = [NSBundle mergedDictionaryWithName:kThreadKeyBindingsFile];
		UTILAssertKindOfClass(dict, NSDictionary);
		
		stKeyBindingSupport_ = [[SGKeyBindingSupport alloc] initWithDictionary:dict];
	}
	return stKeyBindingSupport_;
}

- (void)interpretKeyEvents:(NSArray *)eventArray
{
	id	targets_[] = {
			self,
			[self window],
			NULL
		};
	
	id	*p;

	for (p = targets_; *p != NULL; p++) {
		if ([[[self class] keyBindingSupport] 
				interpretKeyBindings:eventArray target:*p]) {
			return;
		}
	}
	
	[super interpretKeyEvents:eventArray];
}

#pragma mark Mouse Actions
- (BOOL)mouseClicked:(NSEvent *)theEvent atIndex:(unsigned)charIndex
{
	id		delegate_ = [self delegate];
	SEL		selector_ = @selector(HTMLView:mouseClicked:atIndex:);
	
	if (delegate_ && [delegate_ respondsToSelector:selector_]) {
		return [delegate_ HTMLView:self mouseClicked:theEvent atIndex:charIndex];
	}
	return NO;
}

- (BOOL)mouseClicked:(NSEvent *)theEvent
{
	NSPoint		mouseLocation_;
	unsigned	charIndex_;
	
	mouseLocation_ = [theEvent locationInWindow];
	mouseLocation_ = [[self window] convertBaseToScreen:mouseLocation_];

	charIndex_ = [self characterIndexForPoint:mouseLocation_];
	// characterIndexForPoint: は見つからないとき、0 を返す。
	if (charIndex_ != NSNotFound && charIndex_ < [[self string] length])
		return [self mouseClicked:theEvent atIndex:charIndex_];
	
	return NO;
}

- (void)mouseDown:(NSEvent *)theEvent
{
	NSEventType			type;
	unsigned int		modifierFlags_;
	
	NSEvent				*nextEvent_;
	unsigned int		eventMask_;
	
	if (!theEvent) return;
	
	type = [theEvent type];
	modifierFlags_ = [theEvent modifierFlags];
	
	if (NSCommandKeyMask & modifierFlags_) {
		[self commandMouseDown:theEvent];
		return;
	}

	if ([self shouldHandleContinuousMouseDown:theEvent]) {
		NSNumber	*interval_;
		double		doubleInterval;
		
		eventMask_ = (	NSLeftMouseUpMask | 
						NSLeftMouseDraggedMask | 
						NSPeriodicMask);
		
		interval_ = [NSNumber numberWithFloat:[CMRPref mouseDownTrackingTime]];
		UTILAssertKindOfClass(interval_, NSNumber);
		doubleInterval = [interval_ doubleValue];

		[NSEvent startPeriodicEventsAfterDelay:doubleInterval withPeriod:doubleInterval];
		nextEvent_ = [[self window] nextEventMatchingMask:eventMask_
										untilDate:[NSDate distantFuture]
										   inMode:NSEventTrackingRunLoopMode
										  dequeue:NO];
		
		[NSEvent stopPeriodicEvents];
		if (nextEvent_ && NSPeriodic == [nextEvent_ type]) {
			if ([self handleContinuousMouseDown:nextEvent_]) {
				return;
			}
		}
	}
	if (NSLeftMouseDown == type){
		NSEvent		*nextEvent_;
		unsigned	eventMask_;
		
		eventMask_ = (NSLeftMouseUpMask | NSLeftMouseDraggedMask);
		nextEvent_ = [[self window] nextEventMatchingMask:eventMask_
									untilDate:[NSDate dateWithTimeIntervalSinceNow:MOUSE_CLICK_TRACKING_TIME]
									inMode:NSEventTrackingRunLoopMode
									dequeue:NO];
		type = [nextEvent_ type];
		if (NSLeftMouseUp == type) {
			if ([self mouseClicked:nextEvent_])
				return;
		}
	}

	[super mouseDown:theEvent];
}
@end



@implementation SGHTMLView(CMRLocalizableStringsOwner)
+ (NSString *)localizableStringsTableName
{
	return kLocalizableFile;
}
@end



@implementation SGHTMLView(ResponderExtensions)
- (NSArray *)HTMLViewFilteringLinkSchemes:(SGHTMLView *)aView
{
	id	delegate_;
	
	delegate_ = [aView delegate];
	if (!delegate_ || ![delegate_ respondsToSelector:_cmd]) return nil;
	return [delegate_ HTMLViewFilteringLinkSchemes:aView];
}

- (NSMenuItem *)commandItemWithLink:(id)aLink
							command:(Class)aFunctorClass
							  title:(NSString *)aTitle
{
	NSString		*linkstr_;
	NSMenuItem		*menuItem_;
	id				cmd_;
	
	UTILAssertConformsTo(aFunctorClass, @protocol(SGFunctor));

	linkstr_ = [aLink respondsToSelector:@selector(absoluteString)]
				? [aLink absoluteString]
				: [aLink description];
	cmd_ = [aFunctorClass functorWithObject:linkstr_];
	menuItem_ = [[NSMenuItem alloc] 
					initWithTitle:aTitle
						   action:@selector(execute:)
					keyEquivalent:@""];
	[menuItem_ setRepresentedObject:cmd_];
	[menuItem_ setTarget:cmd_];
	[menuItem_ setEnabled:YES];

	return [menuItem_ autorelease];
}

- (NSMenu *)linkMenuWithLink:(id)aLink forImageFile:(BOOL)isImage
{
	NSString		*title_;
	NSMenu			*menu_;
	NSMenuItem		*menuItem_;
	
	title_ = [self localizedString:kLinkStringKey];
	menu_ = [[NSMenu allocWithZone:[NSMenu menuZone]] initWithTitle:title_];

	// リンクをコピー
	title_ = [self localizedString : kCopyLinkStringKey];
	menuItem_ = [self commandItemWithLink : aLink 
								  command : [SGCopyLinkCommand class]
									title : title_];
	[menu_ addItem : menuItem_];
	
	
	// リンクを開く
	title_ = [self localizedString : kOpenLinkStringKey];
	menuItem_ = [self commandItemWithLink : aLink 
								  command : [SGOpenLinkCommand class]
									title : title_];
	[menu_ addItem : menuItem_];
	
	if (isImage) {
		// リンクをプレビュー
		title_ = [self localizedString : kPreviewLinkStringKey];
		menuItem_ = [self commandItemWithLink : aLink 
									  command : [SGPreviewLinkCommand class]
										title : title_];
		[menu_ addItem : menuItem_];
	}

	title_ = [self localizedString:@"Download Link"];
	menuItem_ = [self commandItemWithLink : aLink 
								  command : [SGDownloadLinkCommand class]
									title : title_];
	[menu_ addItem : menuItem_];

	return [menu_ autorelease];
}

- (NSMenu *) linkMenuWithLink:(id)aLink
{
	return [self linkMenuWithLink:aLink forImageFile:NO];
}

- (BOOL)validateLinkByFiltering:(id)aLink
{
	NSArray			*filter_;
	NSString		*scheme_;
	NSURL			*url_;
	
	if (nil == aLink) return NO;
	
	url_ = [NSURL URLWithLink : aLink];
	if (nil == url_) return NO;
	filter_ = [self HTMLViewFilteringLinkSchemes : self];
	if (nil == filter_) return YES;
	
	scheme_ = [url_ scheme];
	return (NO == [filter_ containsObject : scheme_]);
}

- (BOOL)validateLinkForImage:(id)aLink
{
	NSURL	*url_;
	id tmp;
	if (nil == aLink) return NO;

	url_ = [NSURL URLWithLink : aLink];
	if (nil == url_) return NO;

	tmp = [CMRPref sharedImagePreviewer];
	if (!tmp) return NO;
	return [tmp validateLink : url_];
}

- (NSArray *)linksArrayForRange:(NSRange)range_
{
	NSTextStorage	*storage_ = [self textStorage];	

	if (NSNotFound == range_.location || NSMaxRange(range_) > [storage_ length]) {
		return nil;
	}

	NSMutableArray *array = [[NSMutableArray alloc] init];
	unsigned		charIndex_;
	id				v;
	NSRange			effectiveRange_;

	charIndex_ = range_.location;
	while (charIndex_ < NSMaxRange(range_)) {
		v = [storage_ attribute:NSLinkAttributeName
						atIndex:charIndex_
		  longestEffectiveRange:&effectiveRange_
						inRange:range_];
		if (v && [self validateLinkByFiltering:v]) {
			[array addObject:[NSURL URLWithLink:v]];
		}
		charIndex_ = NSMaxRange(effectiveRange_);
	}

	if ([array count] == 0) {
		[array release];
		return nil;
	} else {
		return [array autorelease];
	}
}

- (NSArray *)previewlinksArrayForRange:(NSRange)range_
{
	NSTextStorage	*storage_ = [self textStorage];	

	if (NSNotFound == range_.location || NSMaxRange(range_) > [storage_ length]) {
		return nil;
	}

	NSMutableArray *array = [[NSMutableArray alloc] init];
	unsigned		charIndex_;
	id				v;
	NSRange			effectiveRange_;

	charIndex_ = range_.location;
	while (charIndex_ < NSMaxRange(range_)) {
		v = [storage_ attribute:NSLinkAttributeName
						atIndex:charIndex_
		  longestEffectiveRange:&effectiveRange_
						inRange:range_];
		if (v && [self validateLinkForImage:v]) {
			[array addObject:[NSURL URLWithLink:v]];
		}
		charIndex_ = NSMaxRange(effectiveRange_);
	}

	if ([array count] == 0) {
		[array release];
		return nil;
	} else {
		return [array autorelease];
	}
}

#pragma mark Command-Dragging Support
- (void)pushCloseHandCursorIfNeeded
{
	NSCursor	*cursor_;
	
	cursor_ = [NSCursor currentCursor];
	if (cursor_ == [NSCursor openHandCursor]) {
		[cursor_ pop];
		[[NSCursor closedHandCursor] push];
	}
}

- (void)commandMouseDragged:(NSEvent *)theEvent
{
	NSPoint		newOrigin_;
	NSRect		bounds_;
	float		deltaY_;

	[self pushCloseHandCursorIfNeeded];
	
	deltaY_ = [theEvent deltaY];
	bounds_ = [self visibleRect];
	newOrigin_ = bounds_.origin;
	
	if (deltaY_ > newOrigin_.y) return;
	newOrigin_.y -= deltaY_;
	
	[self scrollPoint:newOrigin_];
}

- (void)commandMouseUp:(NSEvent *)theEvent
{
	NSCursor	*cursor_;	
	
	cursor_ = [NSCursor currentCursor];
	if (cursor_ != [NSCursor closedHandCursor] && cursor_ != [NSCursor openHandCursor]) {
		return;
	}

	[cursor_ pop];
}

- (void)commandMouseDown:(NSEvent *)theEvent
{
	BOOL	keepOn_		= YES;
	BOOL	isInside_	= YES;
	NSPoint	mouseLocation_;
	
	[[NSCursor openHandCursor] push];
	
	while (keepOn_) {
		theEvent = [[self window] nextEventMatchingMask:(NSLeftMouseUpMask | NSLeftMouseDraggedMask)];
		mouseLocation_ = [self convertPoint:[theEvent locationInWindow] fromView:nil];
		isInside_ = [self mouse:mouseLocation_ inRect:[self bounds]];

		switch([theEvent type]) {
			case NSLeftMouseDragged:
				[self commandMouseDragged:theEvent];
				break;
			case NSLeftMouseUp:
				if (isInside_) [self commandMouseUp:theEvent];
				keepOn_ = NO;
				break;
			default:
				/* Ignore any other kind of event. */
				break;
		}
	};

	return;
}
@end
