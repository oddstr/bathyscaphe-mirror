/**
  * $Id: GeneralPrefController.h,v 1.7 2006/01/15 03:28:07 tsawada2 Exp $
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
- (int) firstVisible;
- (void) setFirstVisible : (int) tag_;
- (int) lastVisible;
- (void) setLastVisible : (int) tag_;

// InnocentStarter Additions
- (BOOL) autoReloadListWhenWake;
- (void) setAutoReloadListWhenWake : (BOOL) boxState_;

// Vita Additions
- (int) mailFieldOption;
- (void) setMailFieldOption : (int) selectedTag;

- (int) resAnchorAction;
- (void) setResAnchorAction : (int) tag_;

- (BOOL) collectByNew;
- (void) setCollectByNew : (BOOL) boxState_;
- (BOOL) showsAllFirstTime;
- (void) setShowsAllFirstTime : (BOOL) boxState_;
@end



@interface GeneralPrefController(View)
// List
- (int) autoscrollMaskForTag : (int) tag;
- (NSMatrix *) autoscrollMaskCheckBox;
@end
