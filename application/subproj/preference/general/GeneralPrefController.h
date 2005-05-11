/**
  * $Id: GeneralPrefController.h,v 1.1.1.1 2005/05/11 17:51:10 tsawada2 Exp $
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
	// Log
	//IBOutlet NSTextField	*_dataRootPathField;
	
	// List
	IBOutlet NSMatrix		*_autoscrollMaskCheckBox;
	IBOutlet NSMatrix		*_drawerEdgeMaskMatrix;
	IBOutlet NSMatrix		*_collectByNewMatrix;
	IBOutlet NSTextField	*_ignoreCharsField;
	
	// Thread
	IBOutlet NSPopUpButton  *_resAnchorActionPopUp;
	IBOutlet NSButton		*_mailAttachCheckBox;
	IBOutlet NSMatrix		*_isMailShownMatrix;
	IBOutlet NSMatrix		*_showsAllMatrix;
	IBOutlet NSPopUpButton	*_openInBrowserPopUp;
	
	// Proxy
	IBOutlet NSButton		*_usesProxyCheckBox;
	IBOutlet NSButton		*_proxyWhenPOSTCheckBox;
	IBOutlet NSButton		*_usesSystemConfigProxyCheckBox;
	IBOutlet NSTextField	*_proxyURLField;
	IBOutlet NSTextField	*_proxyPortField;
}

// List
- (IBAction) changeAutoscrollMask : (id) sender;
- (IBAction) changeDrawerEdgeMask : (id) sender;
- (IBAction) changeIgnoreCharacters : (id) sender;
- (IBAction) changeCollectByNew : (id) sender;
// Thread
- (IBAction) changeLinkType : (id) sender;
- (IBAction) changeMailAttachShown : (id) sender;
- (IBAction) changeMailAddressShown : (id) sender;
- (IBAction) changeShowsAll : (id) sender;
- (IBAction) changeOpenInBrowserType : (id) sender;
// Proxy
- (IBAction) changeProxyURL : (id) sender;
- (IBAction) changeProxyPort : (id) sender;
- (IBAction) enableProxy : (id) sender;
- (IBAction) enableProxyWhenPOST : (id) sender;
- (IBAction) syncSystemConfigProxy : (id) sender;
@end



@interface GeneralPrefController(View)
// Log
//- (NSTextField *) dataRootPathField;
// List
- (int) autoscrollMaskForTag : (int) tag;
- (NSMatrix *) drawerEdgeMaskMatrix;
- (NSMatrix *) autoscrollMaskCheckBox;
- (NSMatrix *) collectByNewMatrix;
- (NSTextField *) ignoreCharsField;

// Thread
- (NSPopUpButton *) resAnchorActionPopUp;
- (NSMatrix *) isMailShownMatrix;
- (NSMatrix *) showsAllMatrix;
- (NSButton *) mailAttachCheckBox;
- (NSPopUpButton *) openInBrowserPopUp;

// Proxy
- (NSButton *) usesProxyCheckBox;
- (NSButton *) proxyWhenPOSTCheckBox;
- (NSButton *) usesSystemConfigProxyCheckBox;
- (NSTextField *) proxyURLField;
- (NSTextField *) proxyPortField;

- (void) updateProxyUIComponents;

@end
