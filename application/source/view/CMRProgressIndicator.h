//: CMRProgressIndicator.h
/**
  * $Id: CMRProgressIndicator.h,v 1.2 2005/07/04 17:22:17 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Cocoa/Cocoa.h>
@protocol CMRTask;

/*!
 * @class       CMRProgressIndicator
 * @abstract    CMRProgressIndicator
 * @discussion  

A CMRProgressIndicator object implements custom mouseDown: action.

 */
@interface CMRProgressIndicator : NSProgressIndicator
@end
