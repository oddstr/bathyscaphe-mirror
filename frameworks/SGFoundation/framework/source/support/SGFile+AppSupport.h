/**
  * $Id: SGFile+AppSupport.h,v 1.1.1.1 2005/05/11 17:51:45 tsawada2 Exp $
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
