//: CMRProgressIndicator.m
/**
  * $Id: CMRProgressIndicator.m,v 1.1 2005/05/11 17:51:08 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "CMRProgressIndicator.h"
#import "CMRTaskManager.h"
#import "UTILKit.h"


@implementation CMRProgressIndicator
- (void) mouseUp : (NSEvent *) theEvent
{
	[super mouseUp : theEvent];
	[[CMRTaskManager defaultManager] showWindow : nil];
	//[[CMRTaskManager defaultManager] scrollLastRowToVisible : nil]; // this method is now included at showWindow:
}
@end
