//
//  CMRSpamFilter.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/08/10.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRSpamFilter.h"
#import "CMRMessageFilter.h"
#import "CMRThreadMessageBuffer.h"
#import "CMRThreadMessage.h"
#import "CMRThreadSignature.h"
#import "AppDefaults.h"
#import "BoardManager.h"

#import "BSNGExpression.h"

//#define CMRFilterFile		@"SpamFilter.plist"
#define BSFilterFile		@"BSSpamFilter.plist"

#define kFilterIdentifierKey	@"FilterIdentifier"
#define CMRSpamFilterIdentifier	@"SpamFilter"
#define kDetectersKey			@"Detecters"
//#define kSpamCorpusKey			@"Corpus"



NSString *const CMRSpamFilterDidChangeNotification = @"CMRSpamFilterDidChangeNotification";

static NSString *const BSNGExpressionsFile = @"NGExpressions.plist";


@implementation CMRSpamFilter
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(sharedInstance);
/*+ (NSString *) oldDefaultFilepath
{
	return [[CMRFileManager defaultManager]
				 supportFilepathWithName : CMRFilterFile
						resolvingFileRef : NULL];
}
*/

+ (NSString *)defaultFilepath
{
	return [[CMRFileManager defaultManager] supportFilepathWithName:BSFilterFile resolvingFileRef:NULL];
}

+ (NSString *)expressionsFilepath
{
	return [[CMRFileManager defaultManager] supportFilepathWithName:BSNGExpressionsFile resolvingFileRef:NULL];
}

- (NSMutableArray *)restoreFromPlistToCorpus:(id)rep
{
	UTILAssertKindOfClass(rep, NSArray);
	NSMutableArray	*theArray = [NSMutableArray array];
	NSEnumerator	*iter = [rep objectEnumerator];
	NSDictionary	*item;

	while (item = [iter nextObject]) {
		[theArray addObject:[BSNGExpression objectWithPropertyListRepresentation:item]];
	}
	return theArray;
}

- (id)readFromContentsOfPropertyListFile:(NSString *)plistPath
{
	NSData *data;
	id		rep;
	NSString *err = [NSString string];

	data = [NSData dataWithContentsOfFile:plistPath];

	if (!data) {
		rep = [NSDictionary dictionaryWithContentsOfFile:plistPath];
		return rep;
	}

	rep = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:&err];

	if (!rep) {
		NSLog(@"Failed to read %@ with NSPropertyListSerialization. reason:%@", plistPath, err);
	}

	return rep;
}

- (id) init
{
	if (self = [super init]) {
		[[NSNotificationCenter defaultCenter]
				 addObserver : self
					selector : @selector(applicationWillTerminate:)
					    name : NSApplicationWillTerminateNotification
					  object : NSApp];
		if (!_detecter) {
			NSDictionary *dicRep = [self readFromContentsOfPropertyListFile:[[self class] defaultFilepath]];

			_detecter = [[CMRSamplingDetecter alloc] initWithDictionaryRepresentation:[[dicRep arrayForKey:kDetectersKey] head]];

			NSArray *arrayRep = [self readFromContentsOfPropertyListFile:[[self class] expressionsFilepath]];
			if (!arrayRep) arrayRep = [NSArray array];
			[self setSpamCorpus:[self restoreFromPlistToCorpus:arrayRep]];
		}
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[_detecter release];
	_detecter = nil;
	[self setSpamCorpus:nil];

	[super dealloc];
}

- (void)resetSpamFilter
{
	[[self detecter] clear];
}

#pragma mark Accessors
- (CMRSamplingDetecter *)detecter
{
	if (!_detecter) {
		_detecter = [[CMRSamplingDetecter alloc] init];
	}
	return _detecter;
}

- (NSMutableArray *)spamCorpus
{
	if (!_spamCorpus) {
		_spamCorpus = [[NSMutableArray alloc] init];
	}
	return _spamCorpus;
}

- (void)setSpamCorpus:(NSMutableArray *)aSpamCorpus
{
	[aSpamCorpus retain];
	[_spamCorpus release];
	_spamCorpus = aSpamCorpus;
}

#pragma mark Writing to file
- (NSArray *)arrayRepresentation
{
	NSMutableArray *theArray = [NSMutableArray array];
	NSEnumerator *iter = [[self spamCorpus] objectEnumerator];
	BSNGExpression *expression;
	while (expression = [iter nextObject]) {
		[theArray addObject:[expression propertyListRepresentation]];
	}
    return theArray;
}

- (BOOL)saveRepresentation:(id)rep toFile:(NSString *)filepath
{
	NSString *errorStr = [NSString string];
	NSData *binaryData_ = [NSPropertyListSerialization dataFromPropertyList:rep
																	 format:NSPropertyListBinaryFormat_v1_0
														   errorDescription:&errorStr];

	if (!binaryData_) {
		NSLog(@"Failed to serialize with NSPropertyListSerialization. reason:%@", errorStr);
		return [rep writeToFile:filepath atomically:YES];
	}

	return [binaryData_ writeToFile:filepath atomically:YES];
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
	[rep setObject:CMRSpamFilterIdentifier forKey:kFilterIdentifierKey];
	
	v = [[self detecter] dictionaryRepresentation];
	if (v) {
		[rep setObject:[NSArray arrayWithObject:v] forKey:kDetectersKey];
	}

	[self saveRepresentation:rep toFile:[[self class] defaultFilepath]];

	[self saveRepresentation:[self arrayRepresentation] toFile:[[self class] expressionsFilepath]];
}

#pragma mark Work with detecter
- (void)setNoNameArrayAtBoardOfThread:(CMRThreadSignature *)aThread forDetecter:(CMRSamplingDetecter *)detecter
{
	BoardManager *bM_ = [BoardManager defaultManager];
	NSString *boardName_ = [aThread BBSName];

	[detecter setNoNameArrayAtWorkingBoard:[bM_ defaultNoNameArrayForBoard:boardName_]];
	[detecter setNanashiAllowedAtWorkingBoard:[bM_ allowsNanashiAtBoard:boardName_]];
}

- (void)addSample:(CMRThreadMessage *)aMessage with:(CMRThreadSignature *)aThread
{
	[self setNoNameArrayAtBoardOfThread:aThread forDetecter:[self detecter]];
	[[self detecter] addSample:aMessage with:aThread];
}

- (void)removeSample:(CMRThreadMessage *)aMessage with:(CMRThreadSignature *)aThread
{
	[self setNoNameArrayAtBoardOfThread:aThread forDetecter:[self detecter]];
	[[self detecter] removeSample:aMessage with:aThread];
}

- (void)runFilterWithMessages:(CMRThreadMessageBuffer *)aBuffer with:(CMRThreadSignature *)aThread
{
	[self runFilterWithMessages:aBuffer with:aThread byDetecter:[self detecter]];
}
						  
- (void)runFilterWithMessages:(CMRThreadMessageBuffer *)aBuffer
						 with:(CMRThreadSignature *)aThread
				   byDetecter:(CMRSamplingDetecter *)detecter
{
	NSAutoreleasePool		*pool_ = [[NSAutoreleasePool alloc] init];
	NSEnumerator			*iter_;
	CMRThreadMessage		*m;

	if (!detecter || !aBuffer || [aBuffer count] == 0)
		return;

	if ([CMRPref usesSpamMessageCorpus]) {
		[detecter setCorpus:[self spamCorpus]];
	} else {
		[detecter setCorpus:nil];
	}

	[self setNoNameArrayAtBoardOfThread:aThread forDetecter:detecter];
	
	iter_ = [[aBuffer messages] objectEnumerator];
	while (m = [iter_ nextObject]) {
		if ([m isSpam]) continue;

		if ([detecter detectMessage:m with:aThread]) {
			[m setSpam:YES];
		}
	}
	[detecter setCorpus:nil];
	[pool_ release];
}
@end
