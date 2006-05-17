/**
  * $Id: GeneralPrefController.h,v 1.9 2006/05/17 01:07:53 tsawada2 Exp $
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

- (IBAction) changeAutoscrollMask : (id) sender;

// ShortCircuit Additions - Binding
/*- (int) firstVisible;
- (void) setFirstVisible : (int) tag_;
- (int) lastVisible;
- (void) setLastVisible : (int) tag_;*/

// Vita Additions
- (int) mailFieldOption;
- (void) setMailFieldOption : (int) selectedTag;
@end



@interface GeneralPrefController(View)
// List
- (int) autoscrollMaskForTag : (int) tag;
- (NSMatrix *) autoscrollMaskCheckBox;
@end
