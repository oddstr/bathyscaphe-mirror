//
//  BSScriptsMenuManager.h
//  BachyScaphe
//
//  Created by Hori,Masaki on 05/05/29.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//	See http://sourceforge.jp/projects/bathyscaphe/
//  See the file LICENSE for copying permission.

#import <Cocoa/Cocoa.h>

@interface BSScriptsMenuManager : NSObject
+ (id) defaultManager;
+ (void) setupScriptsMenu;

- (void) buldScriptsMenu;
- (IBAction) handleScriptMenuItem : (id) sender;
@end

@interface NSApplication(BSScriptsMenuManager)
- (IBAction) openScriptsDirectory : (id) sender;
@end