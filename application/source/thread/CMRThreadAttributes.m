/**
  * $Id: CMRThreadAttributes.m,v 1.1.1.1 2005/05/11 17:51:07 tsawada2 Exp $
  * 
  * CMRThreadAttributes.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRThreadAttributes.h"
#import "CMRBBSSignature.h"
#import "CMRThreadVisibleRange.h"
#import "CMRThreadSignature.h"

#import "CMRDocumentFileManager.h"
#import "BoardManager.h"
#import "CMXPreferences.h"
#import "CMRHostHandler.h"
#import "CMRThreadUserStatus.h"



NSString *const CMRThreadAttributesDidChangeNotification = 
					@"CMRThreadAttributesDidChangeNotification";




@implementation CMRThreadAttributes
- (id) initWithDictionary : (NSDictionary *) info
{
	if (self = [super init]) {
		[self addEntriesFromDictionary : info];
	}
	return self;
}
- (void) dealloc
{
	[_attributes release];
	[super dealloc];
}

- (NSMutableDictionary *) getMutableAttributes
{
	if (nil == _attributes) {
		_attributes = [[NSMutableDictionary alloc] init];
	}
	
	return _attributes;
}
- (NSDictionary *) dictionaryRepresentation
{
	return [self getMutableAttributes];
}

- (void) notifyDidChangeAttributes
{
	[[NSNotificationCenter defaultCenter]
		postNotificationName : CMRThreadAttributesDidChangeNotification
					  object : self
					userInfo : [self getMutableAttributes]];
}
- (void) addEntriesFromDictionary : (NSDictionary *) newAttrs
{
	if (nil == newAttrs || 0 == [newAttrs count])
		return;
	
	[[self getMutableAttributes] addEntriesFromDictionary : newAttrs];
	[self notifyDidChangeAttributes];
}


- (CMRBBSSignature *) BBSSignature
{
	return [CMRBBSSignature BBSSignatureWithName : [self boardName]];
}
- (CMRThreadSignature *) threadSignature
{
	return [CMRThreadSignature 
				threadSignatureWithIdentifier : [self datIdentifier]
								 BBSSignature : [self BBSSignature]];
}
- (NSString *) datIdentifier
{
	return [[self class] identifierFromDictionary : [self getMutableAttributes]];
}


/* ログファイルがないため更新が必要 */
- (BOOL) needsToBeUpdatedFromLoadedContents
{
	return (nil == [self threadTitle]) || (0 == [self numberOfLoadedMessages]);
}
- (BOOL) needsToUpdateLogFile
{
	return _changed;
}
- (void) setNeedsToUpdateLogFile : (BOOL) flag
{
	_changed = flag;
}

- (unsigned) numberOfLoadedMessages
{
	return [[self getMutableAttributes] unsignedIntForKey : CMRThreadLastLoadedNumberKey
								   defaultValue : 0];
}
- (void) setNumberOfLoadedMessages : (unsigned) n
{
	[[self getMutableAttributes] setUnsignedInt:n forKey:CMRThreadLastLoadedNumberKey];
}

- (unsigned) numberOfMessages
{
	return [[self getMutableAttributes] unsignedIntForKey : CMRThreadNumberOfMessagesKey
								   defaultValue : 0];
}
- (NSString *) path
{
	return [[self class] pathFromDictionary : [self getMutableAttributes]];
}

- (NSString *) threadTitle
{
	return [[self class] threadTitleFromDictionary : [self getMutableAttributes]];
}

- (NSString *) boardName
{
	return [[self class] boardNameFromDictionary : [self getMutableAttributes]];
}
- (NSString *) bbsIdentifier
{
	return [[[self boardURL] stringValue] lastPathComponent];
}

- (NSURL *) boardURL
{
	return [[self class] boardURLFromDictionary : [self getMutableAttributes]];
}

- (NSURL *) threadURL
{
	return [[self class] threadURLFromDictionary : [self getMutableAttributes]];
}


- (NSRect) windowFrame
{	
	if (nil == [self getMutableAttributes])
		return NSZeroRect;
	return [[self getMutableAttributes] rectForKey : CMRThreadWindowFrameKey];
}


- (void) setWindowFrame : (NSRect) newFrame
{
	if (NSEqualRects(NSZeroRect, newFrame)) return;
	
	[[self getMutableAttributes] setRect : newFrame
						forKey : CMRThreadWindowFrameKey];
	[self notifyDidChangeAttributes];
	[self setNeedsToUpdateLogFile : YES];
}

- (unsigned) lastIndex
{
	return [[self getMutableAttributes] unsignedIntForKey : CMRThreadLastReadedIndexKey
								   defaultValue : NSNotFound];
}
- (void) setLastIndex : (unsigned) anIndex
{
	NSMutableDictionary	*mdict_ = [self getMutableAttributes];
	id					v;
	
	v = [mdict_ objectForKey : CMRThreadLastReadedIndexKey];
	[[v retain] autorelease];
	if (v && NO == [v respondsToSelector : @selector(unsignedIntValue)]) {
		[mdict_ removeObjectForKey:CMRThreadLastReadedIndexKey];
		v = nil;
	}
	if (NSNotFound == anIndex) {
		if (nil == v) return;
		[mdict_ removeObjectForKey:CMRThreadLastReadedIndexKey];
	} else {
		if ([v unsignedIntValue] == anIndex) return;
		[mdict_ setUnsignedInt:anIndex forKey:CMRThreadLastReadedIndexKey];
	}
	[self setNeedsToUpdateLogFile : YES];
}

- (CMRThreadVisibleRange *) visibleRange
{
	id							rep_;
	CMRThreadVisibleRange		*range_;
	
	UTILRequireCondition([self getMutableAttributes], not_found_entry);
	
	rep_ = [[self getMutableAttributes] objectForKey : CMRThreadVisibleRangeKey];
	UTILRequireCondition(rep_, not_found_entry);
	range_ = [CMRThreadVisibleRange objectWithPropertyListRepresentation : rep_];
	UTILRequireCondition(range_, not_found_entry);
	
	return range_;
	
	not_found_entry:{
		return [CMRThreadVisibleRange defaultVisibleRange];
	}
}
- (void) setVisibleRange : (CMRThreadVisibleRange *) newRange
{
	NSMutableDictionary	*mdict_ = [self getMutableAttributes];
	id					v;
	
	v = [mdict_ objectForKey : CMRThreadVisibleRangeKey];
	[[v retain] autorelease];
	
	if (nil == newRange) {
		if (nil == v) return;
		[mdict_ removeObjectForKey : CMRThreadVisibleRangeKey];
	} else {
		id		newRep = [newRange propertyListRepresentation];
		
		if ([newRep isEqual : v]) return;
		[mdict_ setObject:newRep forKey:CMRThreadVisibleRangeKey];
	}
	[self notifyDidChangeAttributes];
	[self setNeedsToUpdateLogFile : YES];
}

- (void) writeAttributes : (NSMutableDictionary *) aDictionary;
{
	id			v;
	
	v = [[self getMutableAttributes] objectForKey : CMRThreadWindowFrameKey];
	[aDictionary setNoneNil:v forKey:CMRThreadWindowFrameKey];
	v = [[self getMutableAttributes] objectForKey : CMRThreadVisibleRangeKey];
	[aDictionary setNoneNil:v forKey:CMRThreadVisibleRangeKey];
	v = [[self getMutableAttributes] objectForKey : CMRThreadLastReadedIndexKey];
	[aDictionary setNoneNil:v forKey:CMRThreadLastReadedIndexKey];
	/* CMRThreadUserStatus */
	v = [[self getMutableAttributes] objectForKey : CMRThreadUserStatusKey];
	[aDictionary setNoneNil:v forKey:CMRThreadUserStatusKey];
	
}

/* working with CMRThreadUserStatus */
- (CMRThreadUserStatus *) userStatus
{
	id					rep_;
	CMRThreadUserStatus	*s;
	
	rep_ = [[self dictionaryRepresentation]
				objectForKey : CMRThreadUserStatusKey];
	s = [CMRThreadUserStatus objectWithPropertyListRepresentation : rep_];
	if (nil == s) {
		s = [CMRThreadUserStatus statusWithUInt32Value : 0];
	}
	return s;
}

- (BOOL) isAAThread
{
	return [[self userStatus] isAAThread];
}
- (void) setAAThread : (BOOL) flag
{
	CMRThreadUserStatus	*s = [self userStatus];
	
	UTILAssertNotNil(s);
	if ([s isAAThread] == flag)
		return;
	
	[s setAAThread : flag];
	[[self getMutableAttributes]
					   setObject : [s propertyListRepresentation]
						  forKey : CMRThreadUserStatusKey];
	[self setNeedsToUpdateLogFile : YES];
}
@end

