/**
  * $Id: CMXPopUpOwner.h,v 1.2 2007/10/23 14:22:52 tsawada2 Exp $
  * 
  * CMXPopUpOwner.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Cocoa/Cocoa.h>



@protocol CMXPopUpOwner
+ (NSMenu *)loadContextualMenuForTextView;
- (NSWindow *)window;
@end

