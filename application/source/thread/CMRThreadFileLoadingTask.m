//
//  CMRThreadFileLoadingTask.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/02/18.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRThreadFileLoadingTask.h"
#import "CMRThreadComposingTask_p.h"
#import "CMRThreadLayout.h"
#import "CMRThreadDictReader.h"

//NSString *const CMRThreadFileLoadingTaskDidLoadAttributesNotification = @"CMRThreadFileLoadingTaskDidLoadAttributesNotification";

@implementation CMRThreadFileLoadingTask
+ (id)taskWithFilepath:(NSString *)filepath
{
	return [[[self alloc] initWithFilepath:filepath] autorelease];
}

- (id)initWithFilepath:(NSString *)filepath
{
	if (self = [super init]) {
		[self setFilepath:filepath];
	}
	return self;
}

- (void)dealloc
{
	[_filepath release];
	[super dealloc];
}

- (NSString *)filepath
{
	return _filepath;
}

- (void)setFilepath:(NSString *)aFilepath
{
	id		tmp;
	
	tmp = _filepath;
	_filepath = [aFilepath retain];
	[tmp release];
}

- (BOOL)delegateWillCompleteMessages:(CMRThreadMessageBuffer *)aMessageBuffer
{
	return YES;
}

- (void)doExecuteWithLayout:(CMRThreadLayout *)layout
{
	CMRThreadDictReader		*reader_;
//	NSNotification			*notification_;
	NSDictionary			*dict_;
	
	reader_ = [CMRThreadDictReader readerWithContentsOfFile:[self filepath]];
	[reader_ setNextMessageIndex:0];
	[self checkIsInterrupted];
	
	// ここで「最後に読んだレス」などの属性を設定するので、
	// 同期メッセージングが必要
	dict_ = [[reader_ threadAttributes] retain];
/*	notification_ = [NSNotification notificationWithName : 
						CMRThreadFileLoadingTaskDidLoadAttributesNotification
									  object : self
									userInfo : dict_];
	[CMRMainMessenger postNotification:notification_ synchronized:YES];
	// 2008-02-18 */
	unsigned int foo = [dict_ unsignedIntForKey:CMRThreadLastReadedIndexKey defaultValue:NSNotFound];
	[[self delegate] performSelectorOnMainThread:@selector(threadFileLoadingTaskDidLoadFile:) withObject:dict_ waitUntilDone:YES];
	[dict_ release];
	
	// --------- Start Composing ---------
	[self setCallbackIndex:foo]; // 2008-02-18
	[self setReader:reader_];
	[super doExecuteWithLayout:layout];
}

- (NSString *)threadTitle
{
	return [[self filepath] lastPathComponent];
}

- (NSString *)titleFormat
{
	return [self localizedString:@"%@ Loading..."];
}

- (NSString *)messageFormat
{
	return [self localizedString:@"Now Loading..."];
}

- (NSString *)messageInProgress
{
	return [NSString stringWithFormat:[self messageFormat], [self threadTitle]];
}
@end
