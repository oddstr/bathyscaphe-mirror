/**
  * $Id: NSBundle+AppSupport.h,v 1.1.1.1 2005/05/11 17:51:45 tsawada2 Exp $
  * 
  * NSBundle+AppSupport.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>



@interface NSBundle(SGApplicationSupport)
// ~/Library/Application Support/(ExecutableName)
+ (NSBundle *) applicationSpecificBundle;
@end
