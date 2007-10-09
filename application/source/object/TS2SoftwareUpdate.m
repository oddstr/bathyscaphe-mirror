//
//  TS2SoftwareUpdate.m
//  JellyBeans
//
//  Created by Tsutomu Sawada on 07/03/03.
//  Copyright 2007 Tsutomu Sawada. All rights reserved.
//  encoding="UTF-8"
//

#import "TS2SoftwareUpdate.h"

NSString *const TS2SoftwareUpdateCheckKey = @"TS2SoftwareUpdateCheck";
NSString *const TS2SoftwareUpdateCheckIntervalKey = @"TS2SoftwareUpdateCheckInterval";
NSString *const TS2SoftwareUpdateNotifyOnNextLaunchKey = @"TS2SoftwareUpdateNotifyOnNextLaunch";
static NSString *const TS2SoftwareUpdateLastCheckedDateKey = @"TS2SoftwareUpdateLastCheckedDate";

@implementation TS2SoftwareUpdate
static id sharedTS2SUInstance = nil;
static BOOL g_showsLog = NO;

#pragma mark Overrides 
+ (id) allocWithZone: (NSZone *) zone
{
    @synchronized(self) {
        if (sharedTS2SUInstance == nil) {
            sharedTS2SUInstance = [super allocWithZone: zone];
            return sharedTS2SUInstance;
        }
    }
    return nil;
}

- (id) copyWithZone: (NSZone *)zone
{
    return self;
}

- (id) retain
{
    return self;
}

- (unsigned) retainCount
{
    return UINT_MAX;
}

- (void) release
{
    //do nothing
}

- (id) autorelease
{
    return self;
}

- (void) dealloc
{
	[ts2su_connection release];
	[ts2su_receivedData release];
	[ts2su_infoURL release];
	[super dealloc];
}

+ (int) version
{
	return 3;
}

#pragma mark Accessors
- (NSURLConnection *) connection
{
	return ts2su_connection;
}

- (void) setConnection: (NSURLConnection *) aConnection
{
	[aConnection retain];
	[ts2su_connection release];
	ts2su_connection = aConnection;
}

- (SEL) openPrefsSelector
{
	return ts2su_openPrefsSelector;
}

- (void) setOpenPrefsSelector: (SEL) selector
{
	ts2su_openPrefsSelector = selector;
}

- (SEL) updateNowSelector
{
	return ts2su_updateNowSelector;
}

- (void) setUpdateNowSelector: (SEL) selector
{
	ts2su_updateNowSelector = selector;
}

+ (BOOL) showsDebugLog
{
	return g_showsLog;
}

+ (void) setShowsDebugLog: (BOOL) showsLog
{
	g_showsLog = showsLog;
}

- (NSMutableData *) receivedData
{
	if (ts2su_receivedData == nil) {
		ts2su_receivedData = [[NSMutableData alloc] init];
	}
	return ts2su_receivedData;
}

- (NSURL *) updateInfoURL
{
	return ts2su_infoURL;
}

- (void) setUpdateInfoURL: (NSURL *) anURL
{
	[anURL retain];
	[ts2su_infoURL release];
	ts2su_infoURL = anURL;
}

- (BOOL) isChecking
{
	return ts2su_isChecking;
}

- (void) setIsChecking: (BOOL) boolValue
{
	ts2su_isChecking = boolValue;
}

#pragma mark Private Methods
- (NSString *) applicationName
{
	return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleName"];
}

- (NSString *) userAgentString
{
	NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleVersion"];
	return [NSString stringWithFormat: @"TS2SoftwareUpdate/%i %@/%@", [[self class] version], [self applicationName], appVersion];
}

- (void) showUpdateIsAvailableAlert
{
	NSString *appName = [self applicationName];
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert setAlertStyle: NSCriticalAlertStyle];

	NSString *msg = [NSString stringWithFormat: NSLocalizedStringFromTable(@"NewVerIsAvailableAlertMsg", @"SoftwareUpdate", @""),
												appName];
	NSString *info = [NSString stringWithFormat: NSLocalizedStringFromTable(@"NewVerIsAvailableAlertInfo", @"SoftwareUpdate", @""),
												 appName, appName];
	[alert setMessageText: msg];
	[alert setInformativeText: info];
	NSButton *btn1 = [alert addButtonWithTitle: NSLocalizedStringFromTable(@"Update Now", @"SoftwareUpdate", @"")];
	[btn1 setKeyEquivalent: @""];
	NSButton *btn2 = [alert addButtonWithTitle: NSLocalizedStringFromTable(@"Ask Again Later", @"SoftwareUpdate", @"")];
	[btn2 setKeyEquivalent: @"\E"];
	NSButton *btn3 = [alert addButtonWithTitle: NSLocalizedStringFromTable(@"Change Preferences...", @"SoftwareUpdate", @"")];
	[btn3 setKeyEquivalent: @"\r"];

	int returnCode = [alert runModal];
	
	if (returnCode == NSAlertFirstButtonReturn) {
		[[NSUserDefaults standardUserDefaults] removeObjectForKey: TS2SoftwareUpdateNotifyOnNextLaunchKey];
		[NSApp sendAction: [self updateNowSelector] to: nil from: self];
	} else if (returnCode == NSAlertThirdButtonReturn) {
		[NSApp sendAction: [self openPrefsSelector] to: nil from: self];
	}
}

- (void) showErrorAlert
{
	NSAlert *alert_ = [[[NSAlert alloc] init] autorelease];
	[alert_ setAlertStyle: NSWarningAlertStyle];
	[alert_ setMessageText: NSLocalizedStringFromTable(@"FailedToCheckAlertMsg", @"SoftwareUpdate", @"")];
	[alert_ setInformativeText: NSLocalizedStringFromTable(@"FailedToCheckAlertInfo", @"SoftwareUpdate", @"")];
	[alert_ addButtonWithTitle: NSLocalizedStringFromTable(@"OK", @"SoftwareUpdate", @"")];
	[alert_ runModal];
}

- (void) showThisIsUpToDateAlert
{
	NSAlert *alert_ = [[[NSAlert alloc] init] autorelease];
	[alert_ setAlertStyle: NSInformationalAlertStyle];
	[alert_ setMessageText: [NSString stringWithFormat: NSLocalizedStringFromTable(@"UpToDateAlertMsg", @"SoftwareUpdate", @""),
														[self applicationName]]];
	[alert_ addButtonWithTitle: NSLocalizedStringFromTable(@"OK", @"SoftwareUpdate", @"")];
	[alert_ runModal];
}

- (BOOL) shouldCheck: (id) sender
{
	if ([self isChecking]) return NO;

	NSUserDefaults *defaults_ = [NSUserDefaults standardUserDefaults];
	NSNumber *readyNum = [defaults_ objectForKey: TS2SoftwareUpdateNotifyOnNextLaunchKey];
	if (readyNum && [readyNum boolValue]) {
		[self showUpdateIsAvailableAlert];
		return NO;
	}
	
	if (sender != nil) return YES; // 自動チェックの場合は設定による（以下で判定）が、手動チェックはいつでも出来る

	NSNumber *autoCheckNum = [defaults_ objectForKey: TS2SoftwareUpdateCheckKey];
	if (!autoCheckNum || NO == [autoCheckNum boolValue]) {
		return NO;
	}
	
	NSNumber *intervalNum = [defaults_ objectForKey: TS2SoftwareUpdateCheckIntervalKey];
	int interval = [intervalNum intValue];
	NSDate *lastDate = [defaults_ objectForKey: TS2SoftwareUpdateLastCheckedDateKey];
	if (!lastDate) {
		return YES;
	} else {
		NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate: lastDate];
		NSTimeInterval value_;
		switch(interval) {
		case TS2SUCheckDaily:
			value_ = 60*60*24;
			break;
		case TS2SUCheckWeekly:
			value_ = 60*60*24*7;
			break;
		case TS2SUCheckMonthly:
			value_ = 60*60*24*30;
			break;
		default:
			value_ = 60*60*24*7;
			break;
		}
		return (timeInterval > value_);
	}
	return NO;
}

#pragma mark Public Methods
+ (id) sharedInstance
{
    @synchronized(self) {
        if (sharedTS2SUInstance == nil) {
            [[self alloc] init];
        }
    }
    return sharedTS2SUInstance;
}

- (void) startUpdateCheck: (id) sender
{
	if (NO == [self shouldCheck: sender]) return;
    NSMutableURLRequest	*req;
    NSURLConnection		*tmpConnection;
	NSString			*uaStr;

    req = [NSMutableURLRequest requestWithURL: [self updateInfoURL]
                                  cachePolicy: NSURLRequestReloadIgnoringCacheData
                              timeoutInterval: 30.0];
    uaStr = [self userAgentString];
	[req setValue: uaStr forHTTPHeaderField: @"User-Agent"];
	if (g_showsLog) NSLog(@"(TS2SoftwareUpdate) User-Agent: %@", uaStr);

    tmpConnection = [[NSURLConnection alloc] initWithRequest: req delegate: self];
	[self setConnection: tmpConnection];
	[tmpConnection release];
	[self setIsChecking: YES];
	shouldShowsResult = (sender != nil);
}

- (void) abortChecking
{
	if (NO == [self isChecking]) return;
	
	if ([self connection]) {
		[[self connection] cancel];
		[self setConnection: nil];
	}

	[ts2su_receivedData release];
	ts2su_receivedData = nil;

	[self setIsChecking: NO];
	NSBeep();
}

#pragma mark NSURLConnection Delegates
- (void) connection: (NSURLConnection *) connection didReceiveResponse: (NSURLResponse *) resp
{
    NSHTTPURLResponse *http = (NSHTTPURLResponse *)resp;
	int status = [http statusCode];
	if (g_showsLog) {
		NSLog(@"(TS2SoftwareUpdate) HTTP Status: %i", status);
	}

    switch (status) {
    case 200:
        break;
    default:
		[connection cancel];
		[self setConnection: nil];
		[self setIsChecking: NO];

		[self showErrorAlert];
        break;
    }
}

- (void) connection: (NSURLConnection *) connection didReceiveData: (NSData *) data
{
    [[self receivedData] appendData: data];
}

- (void) connection: (NSURLConnection *) connection didFailWithError: (NSError *) error
{
	[ts2su_receivedData release];
	ts2su_receivedData = nil;

    [self setConnection: nil];
	[self setIsChecking: NO];

	if (!shouldShowsResult && [[error domain] isEqualToString:NSURLErrorDomain] && ([error code] == NSURLErrorNotConnectedToInternet)) {
		if (g_showsLog) NSLog(@"(TS2SoftwareUpdate) %@", [error localizedDescription]);
	} else {
		[self showErrorAlert];
	}
}

- (void) connectionDidFinishLoading: (NSURLConnection *) connection
{
	NSString *errorStr = nil;
	id plist_ = [NSPropertyListSerialization propertyListFromData: [self receivedData]
												 mutabilityOption: NSPropertyListImmutable
														   format: NULL
												 errorDescription: &errorStr];
	if (plist_ == nil) { // Error
		if (g_showsLog) NSLog(@"(TS2SoftWareUpdate) Error: Failed to convert received data to property list.");
		[self showErrorAlert];
	} else {
		if (g_showsLog) NSLog(@"(TS2SoftWareUpdate) ConnectionDidFinishLoading: Successfully Converted To Plist Object.");
		NSUserDefaults *defaults_ = [NSUserDefaults standardUserDefaults];
		NSString *identifier_ = [plist_ objectForKey: @"BundleIdentifier"];
		NSDate	 *releasedDate_ = [plist_ objectForKey: @"ReleasedDate"];

		NSBundle *myself = [NSBundle mainBundle];
		NSDictionary *fileAttr = [[NSFileManager defaultManager] fileAttributesAtPath: [myself executablePath] traverseLink: YES];
		NSDate *createdDate = [fileAttr objectForKey: @"NSFileCreationDate"];

		if ([identifier_ isEqualToString: [myself bundleIdentifier]]) {
			if ([releasedDate_ compare: createdDate] == NSOrderedDescending) {
				[defaults_ setObject: [NSNumber numberWithBool: YES] forKey: TS2SoftwareUpdateNotifyOnNextLaunchKey];
				if (shouldShowsResult) {
					[self showUpdateIsAvailableAlert];
				}
			} else {
				[defaults_ removeObjectForKey: TS2SoftwareUpdateNotifyOnNextLaunchKey];
				if (shouldShowsResult) {
					[self showThisIsUpToDateAlert];
				}
			}
		} else {
			[self showErrorAlert];
		}
		[defaults_ setObject: [NSDate date] forKey: TS2SoftwareUpdateLastCheckedDateKey];
	}

    [self setConnection: nil];

	[ts2su_receivedData release];
	ts2su_receivedData = nil;

	[self setIsChecking: NO];
}
@end
