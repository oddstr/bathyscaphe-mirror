/**
  * $Id: CMRSpamFilter.m,v 1.1.1.1.8.1 2006/08/31 10:18:40 tsawada2 Exp $
  * 
  * CMRSpamFilter.m
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
#import "CMRSpamFilter.h"
#import "CocoMonar_Prefix.h"
#import "CMRMessageFilter.h"
#import "CMRThreadMessageBuffer.h"
#import "CMRThreadMessage.h"
#import "CMRThreadSignature.h"
#import "AppDefaults.h"
#import "BoardManager.h"

#define CMRFilterFile		@"SpamFilter.plist"
#define BSFilterFile		@"BSSpamFilter.plist"

#define kFilterIdentifierKey	@"FilterIdentifier"
#define CMRSpamFilterIdentifier	@"SpamFilter"
#define kDetectersKey			@"Detecters"
#define kSpamCorpusKey			@"Corpus"



NSString *const CMRSpamFilterDidChangeNotification = @"CMRSpamFilterDidChangeNotification";



@implementation CMRSpamFilter
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(sharedInstance);
+ (NSString *) oldDefaultFilepath
{
	return [[CMRFileManager defaultManager]
				 supportFilepathWithName : CMRFilterFile
						resolvingFileRef : NULL];
}


+ (NSString *) defaultFilepath
{
	return [[CMRFileManager defaultManager]
				 supportFilepathWithName : BSFilterFile
						resolvingFileRef : NULL];
}

- (id) init
{
	if (self = [super init]) {
		[[NSNotificationCenter defaultCenter]
				 addObserver : self
					selector : @selector(applicationWillTerminate:)
					    name : NSApplicationWillTerminateNotification
					  object : NSApp];
		if (nil == _detecter) {
			NSDictionary	*rep;
			id				v;
			
			NSString *errorStr;

			rep = [NSPropertyListSerialization propertyListFromData: [NSMutableData dataWithContentsOfFile: [[self class] defaultFilepath]]
															mutabilityOption: NSPropertyListImmutable
																	  format: NULL
															errorDescription: &errorStr];
			if (errorStr != nil) {
				NSLog(@"CMRSpamFilter failed to read BSSpamFilter.plist. NSPropertyListSerialization said %@", errorStr);
				[errorStr release];
			}
			
			if (!rep) {
				rep = [NSDictionary dictionaryWithContentsOfFile : [[self class] defaultFilepath]];
			}
			
			if (!rep) {
				rep = [NSDictionary dictionaryWithContentsOfFile : [[self class] oldDefaultFilepath]];
			}			

			v = [[rep arrayForKey : kDetectersKey] head];
			_detecter = [[CMRSamplingDetecter alloc] initWithDictionaryRepresentation : v];
			v = [rep arrayForKey : kSpamCorpusKey];
			[self setSpamCorpus : v];
		}
	}
	return self;
}
- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver : self];
	
	[_detecter release];
	_detecter = nil;
	[_spamCorpus release];
	_spamCorpus = nil;
	
	[super dealloc];
}

- (void) resetSpamFilter
{
	[[self detecter] clear];
}


- (CMRSamplingDetecter *) detecter
{
	if (nil == _detecter) {
		_detecter = [[CMRSamplingDetecter alloc] init];
	}
	return _detecter;
}

- (NSArray *) spamCorpus
{
	if (nil == _spamCorpus)
		_spamCorpus = [[NSArray empty] copy];
	
	return _spamCorpus;
}
- (void) setSpamCorpus : (NSArray *) aSpamCorpus
{
	id		tmp;
	
	tmp = _spamCorpus;
	_spamCorpus = [aSpamCorpus retain];
	[tmp release];
}

- (BOOL) saveRepresentation: (id) rep
{
	NSString *errorStr = nil;
	NSData *binaryData_ = [NSPropertyListSerialization dataFromPropertyList: rep
																	 format: NSPropertyListBinaryFormat_v1_0
														   errorDescription: &errorStr];

	if (errorStr) {
		NSLog(@"BoardManager failed to serialize noNameDict. NSPropertyListSerialization said: %@", errorStr);
		[errorStr release];
		return [rep writeToFile: [[self class] defaultFilepath] atomically: YES];
	}
	
	return [binaryData_ writeToFile: [[self class] defaultFilepath] atomically: YES];
}

- (void) applicationWillTerminate : (NSNotification *) notification
{
	id		rep;
	id		v;
	
	UTILAssertNotificationName(
		notification,
		NSApplicationWillTerminateNotification);
	UTILAssertNotificationObject(
		notification,
		NSApp);
	
	rep = [NSMutableDictionary dictionary];
	[rep setObject : CMRSpamFilterIdentifier
			forKey : kFilterIdentifierKey];
	[rep setObject : [self spamCorpus]
			forKey : kSpamCorpusKey];
	
	v = [[self detecter] dictionaryRepresentation];
	if (v != nil) {
		[rep setObject : [NSArray arrayWithObject : v]
				forKey : kDetectersKey];
	}
	//[rep writeToFile : [[self class] defaultFilepath]
	//	  atomically : YES];
	[self saveRepresentation: rep];
}
- (void) postDidChangeNotification
{
}

- (void) setNoNameSetAtBoardOfThread: (CMRThreadSignature *) aThread forDetecter: (CMRSamplingDetecter *) detecter
{
	NSString *boardName_ = [aThread BBSName];
	[detecter setNoNameSetAtWorkingBoard: [[BoardManager defaultManager] defaultNoNameSetForBoard: boardName_]];
}

- (void) addSample : (CMRThreadMessage   *) aMessage
			  with : (CMRThreadSignature *) aThread
{
	[self setNoNameSetAtBoardOfThread: aThread forDetecter: [self detecter]];
	[[self detecter] addSample:aMessage with:aThread];
	[self postDidChangeNotification];
}
- (void) removeSample : (CMRThreadMessage   *) aMessage
			     with : (CMRThreadSignature *) aThread
{
	[self setNoNameSetAtBoardOfThread: aThread forDetecter: [self detecter]];
	[[self detecter] removeSample:aMessage with:aThread];
	[self postDidChangeNotification];
}

- (void) runFilterWithMessages : (CMRThreadMessageBuffer *) aBuffer
						  with : (CMRThreadSignature     *) aThread
{
	[self runFilterWithMessages:aBuffer with:aThread byDetecter:[self detecter]];
}
						  
- (void) runFilterWithMessages : (CMRThreadMessageBuffer *) aBuffer
						  with : (CMRThreadSignature     *) aThread
					byDetecter : (CMRSamplingDetecter    *) detecter
{

	NSEnumerator			*iter_;
	CMRThreadMessage		*m;
	
	if (nil == detecter || nil == aBuffer || 0 == [aBuffer count])
		return;
	
	if ([CMRPref usesSpamMessageCorpus])
		[detecter setCorpus : [self spamCorpus]];
	else
		[detecter setCorpus : nil];

	[self setNoNameSetAtBoardOfThread: aThread forDetecter: detecter];
	
	iter_ = [[aBuffer messages] objectEnumerator];
	while (m = [iter_ nextObject]) {
		if ([m isSpam]) continue;
		
		if ([detecter detectMessage:m with:aThread]) {
			[m setSpam : YES];
		}
	}
	[detecter setCorpus : nil];
}
@end
