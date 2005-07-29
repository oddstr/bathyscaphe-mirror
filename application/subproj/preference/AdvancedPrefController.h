//
//  AdvancedPrefController.h
//  BachyScaphe
//
//  Created by tsawada2 on 05/05/22.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferencesController.h"


@interface AdvancedPrefController : PreferencesController {
	// Proxy
	IBOutlet NSButton		*_usesProxyCheckBox;
	IBOutlet NSButton		*_proxyWhenPOSTCheckBox;
	IBOutlet NSButton		*_usesSystemConfigProxyCheckBox;
	IBOutlet NSTextField	*_proxyURLField;
	IBOutlet NSTextField	*_proxyPortField;
	
	IBOutlet NSButton		*_quietDeletionCheckBox;
	IBOutlet NSButton		*_openLinkInBgCheckBox;

	IBOutlet NSButton		*_chooseAppButton;
	IBOutlet id	_appNameField;
}

// Proxy
- (IBAction) changeProxyURL : (id) sender;
- (IBAction) changeProxyPort : (id) sender;
- (IBAction) enableProxy : (id) sender;
- (IBAction) enableProxyWhenPOST : (id) sender;
- (IBAction) syncSystemConfigProxy : (id) sender;

- (IBAction) changeQuietDeletion : (id) sender;
- (IBAction) changeOpenLinkInBg : (id) sender;

- (IBAction) chooseApplication : (id) sender;

// Proxy
- (NSButton *) usesProxyCheckBox;
- (NSButton *) proxyWhenPOSTCheckBox;
- (NSButton *) usesSystemConfigProxyCheckBox;
- (NSTextField *) proxyURLField;
- (NSTextField *) proxyPortField;

- (NSButton *) quietDeletionCheckBox;
- (NSButton *) openLinkInBgCheckBox;

- (id) appNameField;

- (void) updateProxyUIComponents;
@end
