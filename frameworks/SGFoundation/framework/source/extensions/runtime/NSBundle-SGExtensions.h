//: NSBundle-SGExtensions.h
/**
  * $Id: NSBundle-SGExtensions.h,v 1.1.1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>



@interface NSBundle(SGExtentions)
+ (NSDictionary *) applicationInfoDictionary;
+ (NSString *) applicationName;
+ (NSString *) applicationVersion;

- (NSString *) pathForResourceWithName : (NSString *) filename;
- (NSString *) pathForResourceWithName : (NSString *) filename
                           inDirectory : (NSString *) dirName;
@end
