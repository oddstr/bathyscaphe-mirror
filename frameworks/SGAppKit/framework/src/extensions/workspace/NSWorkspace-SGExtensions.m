//: NSWorkspace-SGExtensions.m
/**
  * $Id: NSWorkspace-SGExtensions.m,v 1.4 2007/05/29 21:40:09 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "NSWorkspace-SGExtensions_p.h"

#define FINDER_IDENTIFIER	@"com.apple.finder"

@implementation NSWorkspace(SGExtensionsFileOperation)
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
		if (success_ == false) continue;
		
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

- (BOOL) moveFilesToTrash : (NSArray *) filePaths
{
	OSErr			err;
	AppleEvent		event, reply;
	AEDesc			finderAddress;
	AEDescList		targetListDesc;
	const char		*finderId = [FINDER_IDENTIFIER UTF8String];
	
	if(nil == filePaths || 0 == [filePaths count])
		return NO;
	
	// Set up locals
	AECreateDesc(typeNull, NULL, 0, &event);
	AECreateDesc(typeNull, NULL, 0, &finderAddress);
	AECreateDesc(typeNull, NULL, 0, &reply);
	AECreateDesc(typeNull, NULL, 0, &targetListDesc);
	
	// Create an event targeting the Finder
	err = AECreateDesc(typeApplicationBundleID, finderId, strlen(finderId), &finderAddress);
	UTILRequireCondition(noErr == err, bail);
	
	err = AECreateAppleEvent(
			kAECoreSuite,
			kAEDelete,
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
		[[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier: FINDER_IDENTIFIER
															 options: NSWorkspaceLaunchWithoutActivation
									  additionalEventParamDescriptor: nil
													launchIdentifier: nil];
		
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

- (BOOL) _openURLsInBackGround : (NSArray *) URLsArray
{
	OSStatus			err;
	LSLaunchURLSpec inLaunchSpec;
	
	if(nil == URLsArray || 0 == [URLsArray count])
		return NO;
	
	inLaunchSpec.appURL = NULL;
	inLaunchSpec.itemURLs = (CFArrayRef )URLsArray; //NSArray, it's CFArrayRef
	inLaunchSpec.passThruParams = nil;
	inLaunchSpec.launchFlags = kLSLaunchDontSwitch; //アプリケーションを前面に持ってこない
	inLaunchSpec.asyncRefCon = nil;

	err = LSOpenFromURLSpec( &inLaunchSpec, NULL );

	return (err == noErr);
}

- (BOOL) openURL : (NSURL *) url_ inBackGround : (BOOL) inBG
{
	if(url_ == nil) return NO;
	if(inBG) {
		return [self _openURLsInBackGround: [NSArray arrayWithObject: url_]];
	} else {
		return [self openURL: url_];
	}
	return NO;
}
@end

@implementation NSWorkspace(BSIconServicesUtil)
- (NSImage *) systemIconForType: (OSType) iconType
{
    IconRef             iconRef;
    IconFamilyHandle    iconFamily;
    OSErr	result;

    result = GetIconRef(kOnSystemDisk, kSystemIconsCreator, iconType, &iconRef);

    if (result != noErr) {
        return nil;
    }

    result = IconRefToIconFamily(iconRef, kSelectorAllAvailableData, &iconFamily);

    if (result != noErr || !iconFamily)
    {
        return nil;
    }

    ReleaseIconRef(iconRef);
    
    NSData  *iconData;
    NSImage *iconImage = nil;

    iconData = [NSData dataWithBytes: *iconFamily length: GetHandleSize((Handle)iconFamily)];
    iconImage = [[[NSImage alloc] initWithData: iconData] autorelease];
	
	DisposeHandle((Handle)iconFamily);
    
    return iconImage;
}
@end

@implementation NSWorkspace(BSDefaultWebBrowserUtils)
- (NSString *) absolutePathForDefaultWebBrowser
{
	NSURL	*dummyURL = [NSURL URLWithString : @"http://www.apple.com/"];
	OSStatus	err;
	FSRef	outAppRef;
	CFURLRef	outAppURL;
	CFStringRef	appPath;
	NSString	*result_ = nil;

	err = LSGetApplicationForURL((CFURLRef )dummyURL, kLSRolesAll, &outAppRef, &outAppURL);
	if (err == noErr && outAppURL) {
		appPath = CFURLCopyFileSystemPath(outAppURL, kCFURLPOSIXPathStyle);
		result_ = [NSString stringWithString: (NSString *)appPath];
		CFRelease(appPath);
	}

	return result_;
}

- (NSImage *) iconForDefaultWebBrowser
{
	return [self iconForFile: [self absolutePathForDefaultWebBrowser]];
}

- (NSString *) bundleIdentifierForDefaultWebBrowser;
{
	NSBundle *bundle = [NSBundle bundleWithPath: [self absolutePathForDefaultWebBrowser]];
	
	return [bundle bundleIdentifier];
}
@end
