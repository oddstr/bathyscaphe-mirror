//
//  $Id: AdvancedPrefController.h,v 1.7.4.1 2006/08/31 10:18:41 tsawada2 Exp $
//  BachyScaphe
//
//  Created by tsawada2 on 05/05/22.
//  Copyright 2005-2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferencesController.h"


@interface AdvancedPrefController : PreferencesController {
	// Proxy
	//IBOutlet NSWindow		*_proxySheet;
	//IBOutlet NSButton		*_usesProxyCheckBox;
	//IBOutlet NSButton		*_proxyWhenPOSTCheckBox;
	//IBOutlet NSButton		*_usesSystemConfigProxyCheckBox;
	//IBOutlet NSTextField	*_proxyURLField;
	//IBOutlet NSTextField	*_proxyPortField;
	
	IBOutlet NSButton		*_openNetworkPaneBtn;
	//IBOutlet NSButton		*_closeSheetBtn;
	
	IBOutlet NSPopUpButton	*_helperAppBtn;
}

// Proxy
//- (IBAction) changeProxyURL : (id) sender;
//- (IBAction) changeProxyPort : (id) sender;
//- (IBAction) enableProxy : (id) sender;
//- (IBAction) enableProxyWhenPOST : (id) sender;
//- (IBAction) syncSystemConfigProxy : (id) sender;

- (IBAction) chooseApplication : (id) sender;

- (IBAction) openNetworkPrefsPane : (id) sender;
//- (IBAction) closeSheet : (id) sender;

// Proxy
//- (NSButton *) usesProxyCheckBox;
//- (NSButton *) proxyWhenPOSTCheckBox;
//- (NSButton *) usesSystemConfigProxyCheckBox;
//- (NSTextField *) proxyURLField;
//- (NSTextField *) proxyPortField;

- (NSPopUpButton *) helperAppBtn;

//- (NSWindow *) proxySheet;

- (NSButton *) openNetworkPaneBtn;
//- (NSButton *) closeSheetBtn;

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

- (int) previewOption;
- (void) setPreviewOption : (int) selectedTag;

- (BOOL) quietDeletion;
- (void) setQuietDeletion : (BOOL) boxState;
- (BOOL) openLinkInBg;
- (void) setOpenLinkInBg : (BOOL) boxState;

//- (void) updateProxyUIComponents;
@end
