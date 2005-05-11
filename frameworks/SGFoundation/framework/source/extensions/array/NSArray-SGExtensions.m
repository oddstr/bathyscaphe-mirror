//: NSArray-SGExtensions.m
/**
  * $Id: NSArray-SGExtensions.m,v 1.1.1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "NSArray-SGExtensions.h"
#import "PrivateDefines.h"



@implementation NSArray(SGExtensions)
+ (id) empty
{
	static id kSharedInstance;
	if (nil == kSharedInstance)
		kSharedInstance = [[NSArray alloc] init];
	
	return kSharedInstance;
}
- (BOOL) isEmpty
{
	return (0 == [self count]);
}
- (id) head
{
	return ([self isEmpty]) ? nil : [self objectAtIndex : 0];
}

- (id) deepCopyWithZone : (NSZone *) aZone
{
	NSMutableArray	*copy_;
	NSEnumerator	*iter_;
	id				elem_;
	
	copy_ = [[NSMutableArray allocWithZone : aZone] 
					initWithCapacity : [self count]];
	iter_ = [self objectEnumerator];
	while(elem_ = [iter_ nextObject]){
		id	tmp_;
		
		if([elem_ respondsToSelector:@selector(deepCopyWithZone:)]){
			tmp_ = [elem_ deepCopyWithZone : aZone];
		}else if([elem_ respondsToSelector:@selector(copyWithZone:)]){
			tmp_ = [elem_ copyWithZone : aZone];
		}else{
			tmp_ = [elem_ retain];
		}
		[copy_ addObject : tmp_];
		[tmp_ release];
	}
	return copy_;
}
@end



#if 0
@interface NSArray(CStringArrayExtension)
+ (id) arrayWithUTF8Strings : (const char *) first,...
{
	va_list		vList_;
	id			instance_;
	
	va_start(vList_, first);
	instance_ = [[self alloc] initWithUTF8Strings:first arguments:vList_];
	va_end(vList_);
	
	return [instance_ autorelease];
}
- (id) initWithUTF8Strings : (const char *) first,...
{
	va_list		vList_;
	
	va_start(vList_, first);
	self = [self initWithUTF8Strings:first arguments:vList_];
	va_end(vList_);
	
	return self;
}
- (id) initWithUTF8Strings : (const char *) first
				 arguments : (va_list     ) vList
{
	id			instance_;
	const char	*sval_;
	
	self = [[self init] autorelease];
	self = [self mutableCopyWithZone : [self zone]];
	
	instance_ = self;
	for(sval_ = first; sval_ != NULL; sval_ = va_arg(vList, char *))
		[instance_ addObject : [NSString stringWithUTF8String : sval_]];
	
	return self;
}
@end
#endif