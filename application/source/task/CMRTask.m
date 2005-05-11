//: CMRTask.m
/**
  * $Id: CMRTask.m,v 1.1.1.1 2005/05/11 17:51:07 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "CMRTask.h"
#import "CocoMonar_Prefix.h"


// Notification Name.
NSString *const CMRTaskWillStartNotification = @"CMRTaskWillStartNotification";
NSString *const CMRTaskDidFinishNotification = @"CMRTaskDidFinishNotification";
NSString *const CMRTaskWillProgressNotification = @"CMRTaskWillProgressNotification";