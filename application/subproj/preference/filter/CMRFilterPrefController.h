//
//  CMRFilterPrefController.h
//  BachyScaphe
//
//  Updated by Tsutomu Sawada on 07/08/11.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "PreferencesController.h"


@interface CMRFilterPrefController : PreferencesController
{
	IBOutlet NSWindow	*m_detailSheet;
}

- (NSWindow *)detailSheet;

- (IBAction)resetSpamDB:(id)sender;

- (IBAction)openDetailSheet:(id)sender;
- (IBAction)closeDetailSheet:(id)sender;
@end
