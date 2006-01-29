//
//  SyncPaneController.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/01/28.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferencesController.h"

@interface SyncPaneController : PreferencesController {
	IBOutlet	*NSButton	_startBtn;
	IBOutlet	*NSTextField	*_statusField;
	IBOutlet	*NSProgressIndicator	*_statusBar;
}

- (NSButton *) startBtn;
- (NSTextField *) statusField;
- (NSProgressIndicator *) statusBar;
@end
