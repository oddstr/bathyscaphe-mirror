//: missing.h
/**
  * $Id: missing.h,v 1.2 2007/09/04 07:45:43 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
@class NSMenu;

@interface NSObject(NotificationExtensions)
- (void) registerToNotificationCenter;
- (void) removeFromNotificationCenter;
- (void) exchangeNotificationObserver : (NSString *) notificationName
					         selector : (SEL       ) notifiedSelector
						  oldDelegate : (id        ) oldDelegate
						  newDelegate : (id        ) newDelegate;
@end



@interface NSException(MissingExtensions)
+ (void) raise : (NSString *) exception
      selector : (SEL       ) aSelector
        object : (id        ) object;
@end

@interface NSObject(CMRAppDelegate)
- (void)showThreadsListForBoard:(NSString *)boardName selectThread:(NSString *)path addToListIfNeeded:(BOOL)addToList;
- (NSMenu *)browserListColumnsMenuTemplate;
@end
