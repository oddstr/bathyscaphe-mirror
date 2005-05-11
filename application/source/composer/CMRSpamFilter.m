/**
  * $Id: CMRSpamFilter.m,v 1.1.1.1 2005/05/11 17:51:04 tsawada2 Exp $
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

#define CMRFilterFile		@"SpamFilter.plist"

#define kFilterIdentifierKey	@"FilterIdentifier"
#define CMRSpamFilterIdentifier	@"SpamFilter"
#define kDetectersKey			@"Detecters"
#define kSpamCorpusKey			@"Corpus"



NSString *const CMRSpamFilterDidChangeNotification = @"CMRSpamFilterDidChangeNotification";



@implementation CMRSpamFilter
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(sharedInstance);

+ (NSString *) defaultFilepath
{
	return [[CMRFileManager defaultManager]
				 supportFilepathWithName : CMRFilterFile
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
			
			rep = [NSDictionary dictionaryWithContentsOfFile : 
										[[self class] defaultFilepath]];
			
			v = [[rep arrayForKey : kDetectersKey] head];
			_detecter = [[CMRSamplingDetecter alloc] 
							initWithDictionaryRepresentation : v];
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
	[rep writeToFile : [[self class] defaultFilepath]
		  atomically : YES];
}
- (void) postDidChangeNotification
{
}
- (void) addSample : (CMRThreadMessage   *) aMessage
			  with : (CMRThreadSignature *) aThread
{
	[[self detecter] addSample:aMessage with:aThread];
	[self postDidChangeNotification];
}
- (void) removeSample : (CMRThreadMessage   *) aMessage
			     with : (CMRThreadSignature *) aThread
{
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
