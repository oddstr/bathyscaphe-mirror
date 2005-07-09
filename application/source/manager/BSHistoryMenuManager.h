//
//  BSHistoryMenuManager.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/07/09.
//  Copyright 2005 tsawada2. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CMRHistoryManager.h"

@interface BSHistoryMenuManager : NSObject {

}
+ (id) defaultManager;
+ (void) setupHistoryMenu;
- (void) updateHistoryMenuWithMenu : (NSMenu *) menu;
- (void) updateHistoryMenuWithDefaultMenu;
@end
