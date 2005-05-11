/**
  * $Id: CMRPullsDownButton.h,v 1.1 2005/05/11 17:51:08 tsawada2 Exp $
  * 
  * CMRPullsDownButton.h
  *
  * Copyright (c) 2004, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Cocoa/Cocoa.h>



/* This class always pulls down its menu. */
@interface CMRPullsDownButton : NSPopUpButton
{
    @private
    BOOL    _isAttached;
}
@end
