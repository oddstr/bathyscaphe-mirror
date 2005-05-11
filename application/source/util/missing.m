//: missing.m
/**
  * $Id: missing.m,v 1.1.1.1 2005/05/11 17:51:08 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "missing.h"
#import "CocoMonar_Prefix.h"



@implementation NSObject(MissingExtensions)
- (void) exchangeNotificationObserver : (NSString *) notificationName
					         selector : (SEL       ) notifiedSelector
						  oldDelegate : (id        ) oldDelegate
						  newDelegate : (id        ) newDelegate
{
	NSNotificationCenter	*center_;

	center_ = [NSNotificationCenter defaultCenter];
	if(oldDelegate != nil)
		[center_ removeObserver : self
						   name : notificationName
						 object : oldDelegate];
	if(newDelegate != nil)
		[center_ addObserver : self
					selector : notifiedSelector
						name : notificationName
					  object : newDelegate];
}
- (void) registerToNotificationCenter
{
}
- (void) removeFromNotificationCenter
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end



@implementation NSException(MissingExtensions)
+ (void) raise : (NSString *) exception
      selector : (SEL       ) aSelector
        object : (id        ) object
{
	[NSException raise : exception
				format : @"<Exception %@>\n\t%@ %@.",
			exception,
			NSStringFromClass([object class]),
			NSStringFromSelector(aSelector)];
}
@end
