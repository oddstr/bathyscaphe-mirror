//
//  BSImagePreviewInspector.h
//  BathyScaphe Preview Inspector 2.7
//
//  Created by Tsutomu Sawada on 05/10/10.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>
#import "BSImagePreviewerInterface.h"
#import "BSIPIHistoryManager.h"
#import "BSIPIArrayController.h"

@class BSIPIToken;

@interface BSImagePreviewInspector : NSWindowController <BSImagePreviewerProtocol> {
	IBOutlet NSTextField			*m_infoField;
	IBOutlet NSPopUpButton			*m_actionBtn;
	IBOutlet NSImageView			*m_imageView;
	IBOutlet NSProgressIndicator	*m_progIndicator;
	IBOutlet NSSegmentedControl		*m_cacheNaviBtn;
	IBOutlet NSTabView				*m_tabView;
	IBOutlet NSSegmentedControl		*m_paneChangeBtn;
	IBOutlet NSTableColumn			*m_nameColumn;
	IBOutlet NSMenu					*m_cacheNaviMenuFormRep;
	IBOutlet BSIPIArrayController	*m_tripleGreenCubes;

	@private
	BOOL			m_shouldRestoreKeyWindow;
}

// Content object for BSIPIArrayController.
- (id)historyManager;

// Actions
- (IBAction)openImage:(id)sender;
- (IBAction)openImageWithPreviewApp:(id)sender;
- (IBAction)saveImage:(id)sender;
- (IBAction)saveImageAs:(id)sender;
- (IBAction)copyURL:(id)sender;
- (IBAction)startFullscreen:(id)sender;
- (IBAction)cancelDownload:(id)sender;
- (IBAction)retryDownload:(id)sender;

- (IBAction)historyNavigationPushed:(id)sender;
- (IBAction)changePane:(id)sender;

- (IBAction)forceRunTbCustomizationPalette:(id)sender;
@end


@interface BSImagePreviewInspector(ToolbarAndUtils)
- (NSString *)localizedStrForKey:(NSString *)key;
- (NSImage *)imageResourceWithName:(NSString *)name;
- (void)setupToolbar;
@end


@interface BSImagePreviewInspector(ViewAccessor)
- (NSTextField *)infoField;
- (NSPopUpButton *)actionBtn;
- (NSImageView *)imageView;
- (NSProgressIndicator *)progIndicator;
- (NSSegmentedControl *)cacheNavigationControl;
- (NSTabView *)tabView;
- (NSSegmentedControl *)paneChangeBtn;
- (NSTableColumn *)nameColumn;
- (NSMenu *)cacheNaviMenuFormRep;
- (BSIPIArrayController *)tripleGreenCubes;
@end
