//
//  CMRReplyDefaultsController.h
//  BathyScaphe
//
//  Modified by Tsutomu Sawada on 06/09/08.
//  Copyright 2006-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>
#import "PreferencesController.h"


@interface CMRReplyDefaultsController: PreferencesController {
	IBOutlet NSPanel		*m_addKoteHanSheet;
	IBOutlet NSTableView	*m_koteHanListTable;
	NSString				*m_temporaryKoteHan;

	// Panther Support (Huh!)
	IBOutlet NSButton	*gradientPlusButton;
	IBOutlet NSButton	*gradientMinusButton;
}

- (NSPanel *)addKoteHanSheet;

- (NSString *)temporaryKoteHan;
- (void)setTemporaryKoteHan:(NSString *)someText;

- (IBAction)addKoteHan:(id)sender;
- (IBAction)closeKoteHanSheet:(id)sender;
@end
