//: CMRLocalizableStringsOwner.h
/**
  * $Id: CMRLocalizableStringsOwner.h,v 1.1.1.1 2005/05/11 17:51:19 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>


@interface NSObject(CMRLocalizableStringsOwner)
+ (NSString *) localizableStringsTableName;
- (NSString *) localizedString : (NSString *) aKey;
@end
