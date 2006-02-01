/**
  * $Id: SGFile+AppSupport.h,v 1.2 2006/02/01 17:39:08 tsawada2 Exp $
  * 
  * SGFile+AppSupport.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import <SGFoundation/SGFileRef.h>


@interface SGFileRef(SGApplicationSupport)
// ~/Library/Application Support
+ (SGFileRef *) applicationSupportFolderRef;
// ~/Library/Application Support/(ExecutableName)
+ (SGFileRef *) applicationSpecificFolderRef;
@end
