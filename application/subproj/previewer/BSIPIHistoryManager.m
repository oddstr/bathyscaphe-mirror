//
//  BSIPIHistoryManager.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/01/12.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSIPIHistoryManager.h"
#import <CocoMonar/CMRSingletonObject.h>

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

- (NSString *) cachedFilePathForURL : (NSURL *) anURL
{
	unsigned	idx;
	NSArray *tmp = [self arrayOfURLs];
	if (tmp == nil) return nil;

	idx = [tmp indexOfObject : anURL];
	if (idx == NSNotFound) return nil;
	
	return [[self arrayOfPaths] objectAtIndex : idx];
}

- (BOOL) addItemOfURL : (NSURL *) anURL andPath : (NSString *) aPath
{
	if (anURL == nil || aPath == nil) return NO;
	
	NSDictionary *tmpDict;
	tmpDict = [NSDictionary dictionaryWithObjectsAndKeys : anURL, kIPIHistoryItemURLKey, aPath, kIPIHistoryItemPathKey, NULL];

	[[self historyBacket] addObject : tmpDict];
	return YES;
}
@end
