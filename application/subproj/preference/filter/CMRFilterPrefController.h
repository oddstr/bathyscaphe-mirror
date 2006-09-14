/**
  * $Id: CMRFilterPrefController.h,v 1.4.6.1 2006/09/14 20:37:04 tsawada2 Exp $
  * 
  * CMRFilterPrefController.h
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
#import <Cocoa/Cocoa.h>
#import "PreferencesController.h"



@interface CMRFilterPrefController : PreferencesController
{
	// detail sheet
	IBOutlet NSWindow	*_detailSheet;
	IBOutlet NSTextView	*_spamMessageCorpusTextView;
}

- (NSWindow *) detailSheet;
- (NSTextView *) spamMessageCorpusTextView;

- (IBAction) resetSpamDB : (id) sender;

- (IBAction) openDetailSheet : (id) sender;
- (IBAction) closeDetailSheet : (id) sender;
@end
