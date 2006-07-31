//
//  $Id: BSIPIHistoryManager.m,v 1.4.2.1 2006/07/31 12:43:13 tsawada2 Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/01/12.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSIPIHistoryManager.h"
#import "BSIPIFoundationExtensions.h"

NSString *const kIPIHistoryItemURLKey	= @"PassedURL";
NSString *const kIPIHistoryItemPathKey	= @"DownloadedFilePath";

@implementation BSIPIHistoryManager
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(sharedManager)	

- (void) dealloc
{
	[_historyBacket release];
	[super dealloc];
}

- (NSMutableArray *) historyBacket
{
	if(_historyBacket == nil)
		_historyBacket = [[NSMutableArray alloc] init];

	return _historyBacket;
}

- (void) setHistoryBacket : (NSMutableArray *) aMutableArray
{
	id	tmp;
	tmp = _historyBacket;
	_historyBacket = [aMutableArray retain];
	[tmp release];
}

- (NSArray *) arrayOfURLs
{
	NSMutableArray *tmp = [self historyBacket];
	return ([tmp count] > 0) ? [tmp valueForKey : kIPIHistoryItemURLKey] : nil;
}

- (NSArray *) arrayOfPaths
{
	NSMutableArray *tmp = [self historyBacket];
	return ([tmp count] > 0) ? [tmp valueForKey : kIPIHistoryItemPathKey] : nil;
}

- (unsigned) indexOfURL: (NSURL *) anURL
{
	NSArray *tmp = [self arrayOfURLs];
	if (tmp == nil)
		return NSNotFound;

	return [tmp indexOfObject : anURL];
}

- (unsigned) indexOfPath: (NSString *) aPath
{
	NSArray *tmp = [self arrayOfPaths];
	if (tmp == nil)
		return NSNotFound;
	
	return [tmp indexOfObject: aPath];
}

- (NSString *) cachedFilePathForURL : (NSURL *) anURL
{
	unsigned	idx = [self indexOfURL: anURL];
	if (idx == NSNotFound) return nil;
	
	return [[self arrayOfPaths] objectAtIndex : idx];
}

- (NSURL *) cachedURLForFilePath: (NSString *) aPath
{
	unsigned	idx = [self indexOfPath: aPath];
	if (idx == NSNotFound) return nil;
	
	return [[self arrayOfURLs] objectAtIndex: idx];
}

- (NSString *) cachedNextFilePathForURL: (NSURL *) currentURL
{
	unsigned	idx = [self indexOfURL: currentURL];
	if (idx == NSNotFound || idx == [[self arrayOfURLs] count]-1) return nil;

	return [[self arrayOfPaths] objectAtIndex: idx+1];
}

- (NSString *) cachedPrevFilePathForURL: (NSURL *) currentURL
{
	if(!currentURL) return [self cachedLastFilePath];

	unsigned	idx = [self indexOfURL: currentURL];
	if (idx == NSNotFound || idx == 0) return nil;
	
	return [[self arrayOfPaths] objectAtIndex: idx-1];
}

- (NSString *) cachedFirstFilePath
{
	return [[self arrayOfPaths] objectAtIndex: 0];
}

- (NSString *) cachedLastFilePath
{
	return [[self arrayOfPaths] lastObject];
}

- (void) openCachedFileForURLWithPreviewApp: (NSURL *) anURL
{
	NSWorkspace	*ws_ = [NSWorkspace sharedWorkspace];
	NSString *appName_ = [ws_ absolutePathForAppBundleWithIdentifier : @"com.apple.Preview"];
	[ws_ openFile : [self cachedFilePathForURL: anURL] withApplication : appName_];
}

- (void) copyCachedFileForURL: (NSURL *) anURL intoFolder: (NSString *) folderPath
{
	NSFileManager	*fm_ = [NSFileManager defaultManager];
	NSString		*fPath_ = [self cachedFilePathForURL: anURL];
	NSString		*dest_ = [folderPath stringByAppendingPathComponent : [fPath_ lastPathComponent]];

	if (![fm_ fileExistsAtPath : dest_]) {
		[fm_ copyPath : fPath_ toPath : dest_ handler : nil];
	} else {
		NSBeep();
		NSLog(@"Could not save the file %@ because same file already exists.", [fPath_ lastPathComponent]);
	}
}

- (NSImage *) makeThumbnailWithPath: (NSString *) aPath
{
	//NSImage *image_ = [[NSImage alloc] initWithContentsOfFile: aPath];
	//if (!image_)
	//	return [[NSWorkspace sharedWorkspace] iconForFile: aPath];

	NSImageRep	*imageRep_;
	float initX, initY, thumbX;
	//imageRep_ = [image_ bestRepresentationForDevice: nil];
	imageRep_ = [NSImageRep imageRepWithContentsOfFile: aPath];
	initX = [imageRep_ pixelsWide];
	initY = [imageRep_ pixelsHigh];

	thumbX = 32.0 * initX / initY;
	[imageRep_ setSize: NSMakeSize(thumbX, 32.0)];
	
	NSImage *image_ = [[NSImage alloc] initWithSize: NSMakeSize(thumbX, 32.0)];
	[image_ addRepresentation: imageRep_];
	[image_ setDataRetained: NO];
	
	return [image_ autorelease];
}

- (BOOL) addItemOfURL : (NSURL *) anURL andPath : (NSString *) aPath
{
	if (anURL == nil || aPath == nil) return NO;
	
	NSDictionary *tmpDict;
	NSImage *image_ = [self makeThumbnailWithPath: aPath];
	tmpDict = [NSDictionary dictionaryWithObjectsAndKeys : anURL, kIPIHistoryItemURLKey, aPath, kIPIHistoryItemPathKey, image_, @"imageRef",NULL];
	[[self historyBacket] addObject : tmpDict];
	//[image_ release];
	return YES;
}

- (BOOL) removeItemOfURL: (NSURL *) anURL
{
	if (anURL == nil) return NO;
	unsigned idx_ = [self indexOfURL: anURL];
	
	if (idx_ == NSNotFound) return NO;

	NSString *fPath_ = [self cachedFilePathForURL: anURL];
	if (NO == [[NSFileManager defaultManager] removeFileAtPath: fPath_ handler: nil]) return NO;

	[[self historyBacket] removeObjectAtIndex: idx_];
	return YES;
}

#pragma mark NSTableDataSource
- (BOOL) appendDataForURL: (NSURL *) source toPasteboard: (NSPasteboard *) pboard withFilenamesPboardType: (BOOL) filenamesType
{
	if (!source) return NO;
	
	NSString *fPath_ = [self cachedFilePathForURL: source];
	if(!fPath_ && filenamesType) return NO;
	
	if (filenamesType) {
		[pboard declareTypes: [NSArray arrayWithObjects: NSFilenamesPboardType, NSURLPboardType, nil] owner: nil];
		[pboard setPropertyList: [NSArray arrayWithObject: fPath_] forType: NSFilenamesPboardType];
	} else {
		[pboard declareTypes: [NSArray arrayWithObjects: NSURLPboardType, NSStringPboardType, nil] owner: nil];
		[pboard setString: [source absoluteString] forType: NSStringPboardType];
	}
	
	[source writeToPasteboard: pboard];
	return YES;
}

- (BOOL) tableView: (NSTableView *) aTableView writeRowsWithIndexes: (NSIndexSet *) rowIndexes toPasteboard: (NSPasteboard*) pboard
{
	// とりあえず一つだけ
	unsigned int rowIndex = [rowIndexes firstIndex];
	NSURL		*fileURL_ = [[self arrayOfURLs] objectAtIndex: rowIndex];

	return [self appendDataForURL: fileURL_ toPasteboard: pboard withFilenamesPboardType: YES];
}
@end
