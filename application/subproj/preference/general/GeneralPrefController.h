/**
  * $Id: GeneralPrefController.h,v 1.9.2.1 2006/08/03 15:06:32 tsawada2 Exp $
  * 
  * GeneralPrefController.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Cocoa/Cocoa.h>
#import "PreferencesController.h"


@interface GeneralPrefController : PreferencesController
{
	IBOutlet NSMatrix		*_autoscrollMaskCheckBox;
}

- (NSMatrix *) autoscrollMaskCheckBox;

- (IBAction) changeAutoscrollMask : (id) sender;

// Vita Additions
- (int) mailFieldOption;
- (void) setMailFieldOption : (int) selectedTag;

// List
- (int) autoscrollMaskForTag : (int) tag;
@end
