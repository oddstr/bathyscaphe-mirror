//
//  CMROpenURLManager.h
//  CocoMonar
//
//  Created by minamie on Sun Jan 25 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CMROpenURLManager : NSObject {

}
+ (id) defaultManager;

- (NSURL *) askUserURL;
- (BOOL) openLocation : (NSURL *) url;

/* Support Service Menu */
- (void)openURL : (NSPasteboard *) pboard
	   userData : (NSString *) data
		  error : (NSString **) error;

@end
