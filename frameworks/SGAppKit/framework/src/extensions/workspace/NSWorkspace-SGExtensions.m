//
//  NSWorkspace-SGExtensions.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/10/25.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "NSWorkspace-SGExtensions.h"
#import <SGAppKit/NSAppleScript-SGExtensions.h>
#import "UTILKit.h"

static NSString *const kAppleScriptFile = @"attachFinderComment";

#define FINDER_IDENTIFIER	@"com.apple.finder"
#define ATTACH_COMMENT_HANDLER_NAME	@"attachComment"

@implementation NSWorkspace(BSExtensions)
#pragma mark Move To Trash
OSErr createFilesDesc(AEDescList *targetListDescPtr, NSArray *pathsArray)
{
	OSErr			err;
	FSRef			fsRef;
	AliasHandle		aliasHandle;
	NSEnumerator	*iter_;
	NSString		*filepath_;
	
	iter_ = [pathsArray objectEnumerator];
	while (filepath_ = [iter_ nextObject]) {
		Boolean		success_;
		CFURLRef	fileURL_;
		
		fileURL_ = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)filepath_, kCFURLPOSIXPathStyle, false);
		success_ = CFURLGetFSRef(fileURL_, &fsRef);
		CFRelease(fileURL_);
		if (!success_) continue;
		
		// Create the descriptor of the file to delete
		err = FSNewAliasMinimal(&fsRef, &aliasHandle);
		if (noErr != err) return err;
		
		// Then add the alias to the descriptor list
		HLock((Handle)aliasHandle);
		err = AEPutPtr(
				targetListDescPtr,
				0,
				typeAlias,
				*aliasHandle,
				GetHandleSize((Handle)aliasHandle));
		HUnlock((Handle)aliasHandle);
		
		DisposeHandle((Handle)aliasHandle);
		if (noErr != err) return err;
	}
	return noErr;
}

- (BOOL)sendAppleEventOfClass:(AEEventClass)theAEEventClass eventID:(AEEventID)theAEEventID withFiles:(NSArray *)filePaths
{
	OSErr			err;
	AppleEvent		event, reply;
	AEDesc			finderAddress;
	AEDescList		targetListDesc;
	const char		*finderId = [FINDER_IDENTIFIER UTF8String];
	
	if (!filePaths || [filePaths count] == 0) {
		return NO;
	}

	// Set up locals
	AECreateDesc(typeNull, NULL, 0, &event);
	AECreateDesc(typeNull, NULL, 0, &finderAddress);
	AECreateDesc(typeNull, NULL, 0, &reply);
	AECreateDesc(typeNull, NULL, 0, &targetListDesc);
	
	// Create an event targeting the Finder
	err = AECreateDesc(typeApplicationBundleID, finderId, strlen(finderId), &finderAddress);
	UTILRequireCondition(noErr == err, bail);
	
	err = AECreateAppleEvent(
			theAEEventClass,
			theAEEventID,
			&finderAddress,
			kAutoGenerateReturnID,
			kAnyTransactionID,
			&event);
	UTILRequireCondition(noErr == err, bail);
	
	err = AECreateList(
				NULL,
				0,
				false,
				&targetListDesc);
	UTILRequireCondition(noErr == err, bail);

	// Add the file descriptor list to the apple event
	err = createFilesDesc(&targetListDesc, filePaths);
	UTILRequireCondition(noErr == err, bail);	
	
	err = AEPutParamDesc(&event, keyDirectObject, &targetListDesc);
	UTILRequireCondition(noErr == err, bail);
	
	// Send the event to the Finder
	err = AESendMessage(&event, &reply, kAEWaitReply, kAEDefaultTimeout); // wait until event is done

	if (err == procNotFound || err == connectionInvalid) { // Finder is not running
		[self launchAppWithBundleIdentifier:FINDER_IDENTIFIER
									options:NSWorkspaceLaunchWithoutActivation
			 additionalEventParamDescriptor:nil
						   launchIdentifier:nil];

		err = AESendMessage(&event, &reply, kAEWaitReply, kAEDefaultTimeout); // Retry
	}	
	// Clean up and leave
bail:
	AEDisposeDesc(&targetListDesc);
	AEDisposeDesc(&event);
	AEDisposeDesc(&finderAddress);
	AEDisposeDesc(&reply);
	
	return (err == noErr);
}

- (BOOL)moveFilesToTrash:(NSArray *)filePaths
{
	return [self sendAppleEventOfClass:kAECoreSuite eventID:kAEDelete withFiles:filePaths];
}

- (BOOL)revealFilesInFinder:(NSArray *)filePaths
{
	if (![self sendAppleEventOfClass:kAEMiscStandards eventID:kAEMakeObjectsVisible withFiles:filePaths]) {
		return NO;
	}
	return [self activateAppWithBundleIdentifier:FINDER_IDENTIFIER];
}

- (BOOL)activateAppWithBundleIdentifier:(NSString *)bundleIdentifier
{
	if (!bundleIdentifier) return NO;
	const char		*bundleIdentifierStr = [bundleIdentifier UTF8String];
	NSAppleEventDescriptor *targetDesc;
	NSAppleEventDescriptor *appleEvent;
	OSStatus err;

	bundleIdentifierStr = [bundleIdentifier UTF8String];
	targetDesc = [NSAppleEventDescriptor descriptorWithDescriptorType:typeApplicationBundleID
																bytes:bundleIdentifierStr
															   length:strlen(bundleIdentifierStr)];
	if(!targetDesc) return NO;

	appleEvent = [NSAppleEventDescriptor appleEventWithEventClass:kAEMiscStandards
														  eventID:kAEActivate
												 targetDescriptor:targetDesc
														 returnID:kAutoGenerateReturnID
													transactionID:kAnyTransactionID];
	if(!appleEvent) return NO;

	err = AESendMessage([appleEvent aeDesc], NULL, kAECanInteract, kAEDefaultTimeout);

	return (err == noErr);
}

- (BOOL)attachComment:(NSString *)comment toFile:(NSString *)filePath
{
	NSString		*hfsPath;
	NSAppleScript	*script;

	CFURLRef fileURL = CFURLCreateWithFileSystemPath(NULL, (CFStringRef)filePath, kCFURLPOSIXPathStyle, false);
	hfsPath = (NSString *)CFURLCopyFileSystemPath(fileURL, kCFURLHFSPathStyle);
	CFRelease(fileURL);

	NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.steam_gadget.SGAppKit"];
	NSString *scriptPath = [bundle pathForResource:kAppleScriptFile ofType:@"scpt"];

	script = [[[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:scriptPath] error:NULL] autorelease];

	return [script doHandler:ATTACH_COMMENT_HANDLER_NAME withParameters:[NSArray arrayWithObjects:hfsPath, comment, nil] error:NULL];
}

#pragma mark Opening URL(s)
- (BOOL)openURLs:(NSArray *)urls inBackground:(BOOL)flag;
{
	if (!urls || [urls count] == 0) return NO;

	NSString	*identifier = [self bundleIdentifierForDefaultWebBrowser];
	NSWorkspaceLaunchOptions	options = NSWorkspaceLaunchDefault;

	if (flag) {
		options |= NSWorkspaceLaunchWithoutActivation;
	}

	return [self openURLs:urls withAppBundleIdentifier:identifier options:options additionalEventParamDescriptor:nil launchIdentifiers:nil];
}

- (BOOL)openURL:(NSURL *)url inBackground:(BOOL)flag
{
	return [self openURLs:[NSArray arrayWithObject:url] inBackground:flag];
}

- (BOOL)openURL:(NSURL *)url_ inBackGround:(BOOL)inBG
{
	return [self openURL:url_ inBackground:inBG];
}

#pragma mark Icon Services Wrapper
- (NSImage *)systemIconForType:(OSType)iconType
{
    IconRef             iconRef;
    IconFamilyHandle    iconFamily;
    OSErr	result;

    result = GetIconRef(kOnSystemDisk, kSystemIconsCreator, iconType, &iconRef);

    if (result != noErr) {
        return nil;
    }

    result = IconRefToIconFamily(iconRef, kSelectorAllAvailableData, &iconFamily);

    if (result != noErr || !iconFamily) {
        return nil;
    }

    ReleaseIconRef(iconRef);
    
    NSData  *iconData;
    NSImage *iconImage = nil;

    iconData = [NSData dataWithBytes:*iconFamily length:GetHandleSize((Handle)iconFamily)];
    iconImage = [[[NSImage alloc] initWithData:iconData] autorelease];
	
	DisposeHandle((Handle)iconFamily);
    
    return iconImage;
}

#pragma mark Default Web Browser Utilities
- (NSString *)absolutePathForDefaultWebBrowser
{
	NSURL	*dummyURL = [NSURL URLWithString:@"http://www.apple.com/"];
	OSStatus	err;
	FSRef	outAppRef;
	CFURLRef	outAppURL;
	CFStringRef	appPath;
	NSString	*result_ = nil;

	err = LSGetApplicationForURL((CFURLRef )dummyURL, kLSRolesAll, &outAppRef, &outAppURL);
	if (err == noErr && outAppURL) {
		appPath = CFURLCopyFileSystemPath(outAppURL, kCFURLPOSIXPathStyle);
		result_ = [NSString stringWithString:(NSString *)appPath];
		CFRelease(appPath);
	}

	return result_;
}

- (NSImage *)iconForDefaultWebBrowser
{
	return [self iconForFile:[self absolutePathForDefaultWebBrowser]];
}

- (NSString *)bundleIdentifierForDefaultWebBrowser;
{
	NSBundle *bundle = [NSBundle bundleWithPath:[self absolutePathForDefaultWebBrowser]];

	return [bundle bundleIdentifier];
}
@end
