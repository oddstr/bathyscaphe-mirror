//
//  BSIPILeopardSlideshowHelper.h
//  BSIPILeopardSlideshowHelper
//
//  Created by Tsutomu Sawada on 07/11/12.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface BSIPILeopardSlideshowHelper : NSObject<IKSlideshowDataSource> {
	NSArrayController	*m_cube;
}

+ (id)sharedInstance;

// Do not retain/release
- (NSArrayController *)arrayController;
- (void)setArrayController:(id)aController;

- (void)startSlideshow;
@end
