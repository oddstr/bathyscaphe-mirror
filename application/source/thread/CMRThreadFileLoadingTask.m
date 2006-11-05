/**
  * $Id: CMRThreadFileLoadingTask.m,v 1.2 2006/11/05 12:53:48 tsawada2 Exp $
  * 
  * CMRThreadFileLoadingTask.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRThreadFileLoadingTask.h"
#import "CMRThreadComposingTask_p.h"
#import "CMRThreadLayout.h"
#import "CMRThreadDictReader.h"

NSString *const CMRThreadFileLoadingTaskDidLoadAttributesNotification = @"CMRThreadFileLoadingTaskDidLoadAttributesNotification";



@implementation CMRThreadFileLoadingTask
+ (id) taskWithFilepath : (NSString *) filepath
{
	return [[[self alloc] initWithFilepath : filepath] autorelease];
}
- (id) initWithFilepath : (NSString *) filepath
{
	if (self = [super init]) {
		[self setFilepath : filepath];
	}
	return self;
}
- (void) dealloc
{
	[_filepath release];
	[super dealloc];
}
- (NSString *) filepath
{
	return _filepath;
}
- (void) setFilepath : (NSString *) aFilepath
{
	id		tmp;
	
	tmp = _filepath;
	_filepath = [aFilepath retain];
	[tmp release];
}

// CMRThreadLayoutTask:
- (void) doExecuteWithLayout : (CMRThreadLayout *) layout
{
	CMRThreadDictReader		*reader_;
	NSNotification			*notification_;
	NSDictionary			*dict_;
	
	reader_ = [CMRThreadDictReader readerWithContentsOfFile : [self filepath]];
	[reader_ setNextMessageIndex : 0];
	[self checkIsInterrupted];
	
	// ここで「最後に読んだレス」などの属性を設定するので、
	// 同期メッセージングが必要
	dict_ = [[reader_ threadAttributes] retain];
	notification_ = [NSNotification notificationWithName : 
						CMRThreadFileLoadingTaskDidLoadAttributesNotification
									  object : self
									userInfo : dict_];
	[CMRMainMessenger postNotification:notification_ synchronized:YES];
	[dict_ release];
	
	// --------- Start Composing ---------
	[super setReader : reader_];
	[super doExecuteWithLayout : layout];
}

- (NSString *) threadTitle
{
	return [super threadTitle]
		? [super threadTitle]
		: [[self filepath] lastPathComponent];
}
- (NSString *) titleFormat
{
	return [self localizedString : @"%@ Loading..."];
}
- (NSString *) messageFormat;
{
	return [self localizedString : @"Now Loading..."];
}
- (NSString *) messageInProgress;
{
	return [self messageFormat] 
		? [NSString stringWithFormat : [self messageFormat], [[self filepath] lastPathComponent]]
		: [self filepath];
}
@end
