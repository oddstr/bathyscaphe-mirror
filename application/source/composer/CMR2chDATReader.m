/**
  * $Id: CMR2chDATReader.m,v 1.1.1.1 2005/05/11 17:51:04 tsawada2 Exp $
  * 
  * CMR2chDATReader.m
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
#import "CMR2chDATReader.h"
#import "AppDefaults.h"
#import "CMXTextParser.h"
#import "CMRThreadMessage.h"
#import "CocoMonar_Prefix.h"
#import "CMRMessageComposer.h"
#import "CMRThreadVisibleRange.h"



@interface CMR2chDATReader(Private)
- (NSArray *) lineArray;
- (void) setupLineArrayWithContents : (NSString *) datContents;
- (NSEnumerator *) lineEnumerator;
- (void) setLineEnumerator : (NSEnumerator *) aLineEnumerator;

/* utility */
- (NSDate *) firstLineDateWithEnumerator : (NSEnumerator *) iter;
@end



@implementation CMR2chDATReader
- (id) initWithContents : (id) fileContents
{
	if (self = [super initWithContents : fileContents]) {
		[self setupLineArrayWithContents : fileContents];
	}
	return self;
}

- (void) dealloc
{
	[_lineArray release];
	[_title release];
	[_lineEnumerator release];
	[super dealloc];
}

- (unsigned int) numberOfLines
{
	return [[self lineArray] count];
}
- (NSString *) threadTitle
{
	NSEnumerator		*iter_;
	NSString			*line_;
	
	if (_title != nil) 
		return _title;
	
	iter_ = [[self lineArray] objectEnumerator];
	while (line_ = [iter_ nextObject]) {
		NSArray		*components_;
		
		components_ = [CMXTextParser separatedLine : line_];
		/* skips empty/blank lines */
		if (nil == components_)
			continue;
		
		if ((k2chDATTitleIndex +1) == [components_ count]) {
			_title = [components_ objectAtIndex : k2chDATTitleIndex];
			_title = [_title stringByReplaceEntityReference];
			_title = [_title copyWithZone : [self zone]];
		}
		break;
	}
	return _title;
}

- (NSDate *) firstMessageDate
{
	NSEnumerator		*iter_;
	
	iter_ = [[self lineArray] objectEnumerator];
	return [self firstLineDateWithEnumerator : iter_];
}

- (NSDate *) lastMessageDate
{
	NSEnumerator		*iter_;
	
	iter_ = [[self lineArray] reverseObjectEnumerator];
	return [self firstLineDateWithEnumerator : iter_];
}


// override
- (CMRThreadVisibleRange *) visibleRange;
{
	return [CMRPref showsAllMessagesWhenDownloaded] ? nil : [CMRThreadVisibleRange defaultVisibleRange];
}
- (unsigned int) numberOfMessages
{
	return [[self lineArray] count];
}
- (NSDictionary *) threadAttributes
{
	NSMutableDictionary		*dict;
	
	dict = [[NSMutableDictionary alloc] initWithCapacity : 4];
	
	[dict setNoneNil:[self threadTitle] forKey:CMRThreadTitleKey];
	[dict setNoneNil:[self firstMessageDate] forKey:CMRThreadCreatedDateKey];
	[dict setNoneNil:[self lastMessageDate] forKey:CMRThreadModifiedDateKey];
	
	return [dict autorelease];
}
- (BOOL) composeNextMessageWithComposer : (id<CMRMessageComposer>) composer
{
	NSString			*line_;
	CMRThreadMessage	*message_;
	
	if (nil == (line_ = [[self lineEnumerator] nextObject]))
		return NO;
	
	message_ = [CMXTextParser messageWithDATLine : line_];
	if (nil == message_) {
		if (line_ != nil && [line_ length] > 0) {
			
			NSLog (
	@"=======================================================\n"
	@"   WARNING:\n"
	@"   Maybe line was not in form of 2ch dat text.\n"
	@"   \n"
	@"   LINE: %u\n"
	@"   TEXT: \"%@\"\n"
	@"   \n"
	@"   If TEXT was html, it's InternalError.\n"
	@"=======================================================",
			[self nextMessageIndex], line_);
			
			// 自動変換
			message_ = [CMXTextParser messageWithInvalidDATLineDetected : line_];
		}
		
		if (nil == message_) {
			// 解析に失敗した場合でも、空行が挟まれているだけかも
			// しれないので試しに次の行も解析してみる。
			return [self composeNextMessageWithComposer:composer];
		}
	}
	UTILAssertNotNil(message_);
	[message_ setIndex : [self nextMessageIndex]];
	
	[composer composeThreadMessage : message_];
	[self incrementNextMessageIndex];
	return YES;
}
@end



@implementation CMR2chDATReader(Private)
- (NSArray *) lineArray
{
	if (nil == _lineArray)
		return [NSArray empty];
	
	return _lineArray;
}
- (void) setupLineArrayWithContents : (NSString *) datContents;
{
	id			tmp = _lineArray;
	
	_lineArray = [[datContents componentsSeparatedByNewline] retain];
	[tmp release];
	
	[self setLineEnumerator : [_lineArray objectEnumerator]];
	
	[_title release];
	_title = nil;
}
/* Accessor for _lineEnumerator */
- (NSEnumerator *) lineEnumerator
{
	return _lineEnumerator;
}
- (void) setLineEnumerator : (NSEnumerator *) aLineEnumerator
{
	id tmp;
	
	tmp = _lineEnumerator;
	_lineEnumerator = [aLineEnumerator retain];
	[tmp release];
}

- (NSDate *) firstLineDateWithEnumerator : (NSEnumerator *) iter
{
	NSString			*line_;
	
	while (line_ = [iter nextObject]) {
		CMRThreadMessage	*message_;
		
		message_ = [CMXTextParser messageWithDATLine : line_];
		if (nil == message_ || [message_ isAboned])
			continue;
		
		return [message_ date];
	}
	return nil;
}
@end