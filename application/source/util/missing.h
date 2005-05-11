//: missing.h
/**
  * $Id: missing.h,v 1.1 2005/05/11 17:51:08 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>


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
