//
//  $Id: AdvancedPrefController.h,v 1.6 2006/01/12 18:00:24 tsawada2 Exp $
//  BachyScaphe
//
//  Created by tsawada2 on 05/05/22.
//  Copyright 2005-2006 BathyScaphe Project. All rights reserved.
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
	
	IBOutlet NSPopUpButton	*_helperAppBtn;
}

// Proxy
- (IBAction) changeProxyURL : (id) sender;
- (IBAction) changeProxyPort : (id) sender;
- (IBAction) enableProxy : (id) sender;
- (IBAction) enableProxyWhenPOST : (id) sender;
- (IBAction) syncSystemConfigProxy : (id) sender;

- (IBAction) chooseApplication : (id) sender;

// Proxy
- (NSButton *) usesProxyCheckBox;
- (NSButton *) proxyWhenPOSTCheckBox;
- (NSButton *) usesSystemConfigProxyCheckBox;
- (NSTextField *) proxyURLField;
- (NSTextField *) proxyPortField;

- (NSPopUpButton *) helperAppBtn;

// ShortCircuit Additions
// 「ブラウザで開くときのレス数：」が、「一般」から「詳細」ペインに移動
- (int) openInBrowserType;
- (void) setOpenInBrowserType : (int) aType;

// InnocentStarter Additions
- (float) mouseDownTrackingTime;
- (void) setMouseDownTrackingTime : (float) sliderValue;

// Vita Additions
- (NSString *) helperAppName;
- (NSImage *) helperAppIcon;

- (BOOL) quietDeletion;
- (void) setQuietDeletion : (BOOL) boxState;
- (BOOL) openLinkInBg;
- (void) setOpenLinkInBg : (BOOL) boxState;

- (void) updateProxyUIComponents;
@end
