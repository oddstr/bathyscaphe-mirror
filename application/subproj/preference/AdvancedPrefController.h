//
//  $Id: AdvancedPrefController.h,v 1.7.4.2 2006/12/10 21:10:12 tsawada2 Exp $
//  BachyScaphe
//
//  Created by tsawada2 on 05/05/22.
//  Copyright 2005-2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferencesController.h"


@interface AdvancedPrefController : PreferencesController {
//	IBOutlet NSButton		*m_checkNowBtn;	
	IBOutlet NSPopUpButton	*m_helperAppBtn;
}

//- (IBAction) startCheckingForUpdate: (id) sender;
- (IBAction) chooseApplication: (id) sender;

//- (NSButton *) checkNowBtn;
- (NSPopUpButton *) helperAppBtn;

// Binding
- (int) previewOption;
- (void) setPreviewOption: (int) selectedTag;

- (void) updateHelperAppUI;
@end
