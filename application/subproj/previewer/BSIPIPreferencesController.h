//
//  BSIPIPreferencesController.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/08/31.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>


@interface BSIPIPreferencesController : NSWindowController {
	IBOutlet NSPopUpButton			*m_directoryChooser;
	IBOutlet NSSegmentedControl		*m_preferredViewSelector;
	IBOutlet NSMatrix				*m_fullScreenSettingMatrix;
	IBOutlet NSObjectController		*m_defaultsController;
}

+ (id)sharedPreferencesController;

- (IBAction)openOpenPanel:(id)sender;

- (NSPopUpButton *)directoryChooser;
- (NSSegmentedControl *)preferredViewSelector;
- (NSMatrix *)fullScreenSettingMatrix;

- (void)updateDirectoryChooser;
@end
