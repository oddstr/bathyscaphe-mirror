//: CMRLocalizableStringsOwner.m
/**
  * $Id: CMRLocalizableStringsOwner.m,v 1.1.1.1 2005/05/11 17:51:19 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "CMRLocalizableStringsOwner.h"
#import "UTILKit.h"


@implementation NSObject(CMRLocalizableStringsOwner)
+ (NSString *) localizableStringsTableName
{
	UTILAbstractMethodInvoked;
	return nil;
}

- (NSString *) localizedString : (NSString *) aKey
{
	return NSLocalizedStringFromTable(
						aKey,
						[[self class] localizableStringsTableName],
						nil);
}
@end
