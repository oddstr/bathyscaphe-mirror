//
//  $Id: SoundsPaneController.h,v 1.1.2.1 2006/01/29 12:58:10 masakih Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/01/27.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferencesController.h"

@interface SoundsPaneController : PreferencesController {
	IBOutlet	NSPopUpButton	*_soundForHEADCheckNewArrivedBtn;
	IBOutlet	NSPopUpButton	*_soundForHEADCheckNoUpdateBtn;
	IBOutlet	NSPopUpButton	*_soundForReplyDidFinishBtn;
	IBOutlet	NSMenu			*_soundsListMenu;
}

- (NSPopUpButton *) soundForHEADCheckNewArrivedBtn;
- (NSPopUpButton *) soundForHEADCheckNoUpdateBtn;
- (NSPopUpButton *) soundForReplyDidFinishBtn;
- (NSMenu *) soundsListMenu;

- (IBAction) soundChosen : (id) sender;
- (IBAction) soundNone : (id) sender;
@end
