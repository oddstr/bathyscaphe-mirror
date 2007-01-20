//
//  BSThreadInfoPanelController.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/01/20.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BSThreadInfoPanelController : NSWindowController {
}

+ (id) sharedInstance;

+ (BOOL) nonActivatingPanel;
+ (void) setNonActivatingPanel: (BOOL) nonActivating;
@end
