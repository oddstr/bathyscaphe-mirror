//
//  BSThreadInfoPanelController.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/01/20.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//

#import "BSThreadInfoPanelController.h"
#import "CMRThreadViewer.h"
#import <CocoMonar/CocoMonar.h>

@interface BSThreadInfoDateValueTransformer: NSValueTransformer
@end

@implementation BSThreadInfoDateValueTransformer
+ (Class) transformedValueClass
{
    return [NSString class];
}
 
+ (BOOL) allowsReverseTransformation
{
    return NO;
}
 
- (id) transformedValue: (id) beforeObject
{
	static CFDateFormatterRef	l_dateFormatterRef;
    if (beforeObject == nil || NO == [beforeObject isKindOfClass: [NSDate class]]) return nil;
	
	CFStringRef			dayStrRef;
	NSString			*dayStr_ = nil;

	if (l_dateFormatterRef == NULL) {
		CFLocaleRef	localeRef = CFLocaleCopyCurrent();
		l_dateFormatterRef = CFDateFormatterCreate(kCFAllocatorDefault, localeRef, kCFDateFormatterFullStyle, kCFDateFormatterMediumStyle);
		CFRelease(localeRef);
	}

	dayStrRef = CFDateFormatterCreateStringWithDate(kCFAllocatorDefault, l_dateFormatterRef, (CFDateRef)beforeObject);

	if (dayStrRef != NULL) {
		dayStr_ = [NSString stringWithString: (NSString *)dayStrRef];
		CFRelease(dayStrRef);
	}

    return dayStr_;
}
@end

#pragma mark -
@implementation BSThreadInfoPanelController
static BOOL	g_isNonActivatingPanel = NO;

APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(sharedInstance);

+ (BOOL) nonActivatingPanel
{
	return g_isNonActivatingPanel;
}

+ (void) setNonActivatingPanel: (BOOL) nonActivating
{
	g_isNonActivatingPanel = nonActivating;
}

#pragma mark Override
- (id) init
{
	if (self = [super initWithWindowNibName : @"BSThreadInfoPanel"]) {
		id transformer = [[[BSThreadInfoDateValueTransformer alloc] init] autorelease];
		[NSValueTransformer setValueTransformer: transformer forName: @"BSThreadInfoDateValueTransformer"];

		[[NSNotificationCenter defaultCenter]
			 addObserver : self
				selector : @selector(mainWindowChanged:)
					name : NSWindowDidBecomeMainNotification
				  object : nil];
	}
	return self;
}

- (void) awakeFromNib
{
	[[self window] setFrameAutosaveName : @"BathyScaphe:Thread Info Panel Autosave"];
	[(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded: g_isNonActivatingPanel];
}

- (void) showWindow: (id) sender
{
	if ([self isWindowLoaded] && [[self window] isVisible] && [[self window] isKeyWindow]) {
		[[self window] orderOut : sender];
	} else {
		[super showWindow : sender];
		id winController_ = [[NSApp mainWindow] windowController];

		if (winController_ && [winController_ respondsToSelector: @selector(threadAttributes)]) {
			[m_greenCube bind: @"contentObject" toObject: winController_ withKeyPath: @"threadAttributes" options: nil];
		}
	}
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[super dealloc];
}

#pragma mark Delegate and Notification
- (void) mainWindowChanged : (NSNotification *) aNotification
{
	if (NO == [self isWindowLoaded] || NO == [[self window] isVisible]) return;

	id winController_ = [[aNotification object] windowController];

	if ([winController_ respondsToSelector: @selector(threadAttributes)]) {
		[m_greenCube unbind: @"contentObject"];
		[m_greenCube bind: @"contentObject" toObject: winController_ withKeyPath: @"threadAttributes" options: nil];
	}
}

- (void) windowWillClose : (NSNotification *) aNotification
{
	[m_greenCube unbind: @"contentObject"];
}
@end
