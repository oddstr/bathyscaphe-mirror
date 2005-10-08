/**
  * $Id: GeneralPrefController.h,v 1.5 2005/10/08 02:46:39 tsawada2 Exp $
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
	// List
	IBOutlet NSMatrix		*_autoscrollMaskCheckBox;
	IBOutlet NSButton		*_collectByNewCheckBox;
	IBOutlet NSTextField	*_ignoreCharsField;
	
	// Thread
	IBOutlet NSPopUpButton  *_resAnchorActionPopUp;
	IBOutlet NSButton		*_mailAttachCheckBox;
	IBOutlet NSButton		*_isMailShownCheckBox;
	IBOutlet NSButton		*_showsAllCheckBox;
}

// List
- (IBAction) changeAutoscrollMask : (id) sender;
- (IBAction) changeIgnoreCharacters : (id) sender;
- (IBAction) changeCollectByNew : (id) sender;
// Thread
- (IBAction) changeLinkType : (id) sender;
- (IBAction) changeMailAttachShown : (id) sender;
- (IBAction) changeMailAddressShown : (id) sender;
- (IBAction) changeShowsAll : (id) sender;

// ShortCircuit Additions - Binding
- (int) firstVisible;
- (void) setFirstVisible : (int) tag_;
- (int) lastVisible;
- (void) setLastVisible : (int) tag_;
@end



@interface GeneralPrefController(View)
// List
- (int) autoscrollMaskForTag : (int) tag;
- (NSMatrix *) autoscrollMaskCheckBox;
- (NSButton *) collectByNewCheckBox;
- (NSTextField *) ignoreCharsField;

// Thread
- (NSPopUpButton *) resAnchorActionPopUp;
- (NSButton *) isMailShownCheckBox;
- (NSButton *) showsAllCheckBox;
- (NSButton *) mailAttachCheckBox;
@end
