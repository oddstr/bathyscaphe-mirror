//
//  BSImagePreviewInspector.h
//  BathyScaphe Preview Inspector 2.7
//
//  Created by Tsutomu Sawada on 05/10/10.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BSImagePreviewerInterface.h"
#import "BSIPIHistoryManager.h"
#import "BSIPIArrayController.h"

@class BSIPIToken;
/*
typedef enum _BSIPIRedirectionBehavior {
	BSIPIAlwaysAsk		= -1,
	BSIPIAlwaysAbort	= 0,
	BSIPIAlwaysPass		= 1,
} BSIPIRedirectionBehavior;
*/
@interface BSImagePreviewInspector : NSWindowController <BSImagePreviewerProtocol> {
	IBOutlet NSTextField			*m_infoField;
	IBOutlet NSPopUpButton			*m_actionBtn;
	IBOutlet NSImageView			*m_imageView;
	IBOutlet NSProgressIndicator	*m_progIndicator;
	IBOutlet NSPanel				*m_settingsPanel;
	IBOutlet NSSegmentedControl		*m_cacheNaviBtn;
	IBOutlet NSTabView				*m_tabView;
	IBOutlet NSSegmentedControl		*m_paneChangeBtn;
	IBOutlet NSTableColumn			*m_nameColumn;
	IBOutlet NSPopUpButton			*m_directoryChooser;
//	IBOutlet NSTextField			*m_versionInfoField;
	IBOutlet NSMenu					*m_cacheNaviMenuFormRep;
	IBOutlet NSSegmentedControl		*m_preferredViewSelector;
	IBOutlet NSMatrix				*m_fullScreenSettingMatrix;
	IBOutlet BSIPIArrayController	*m_tripleGreenCubes;

	@private
	AppDefaults		*_preferences;
	BOOL			m_shouldRestoreKeyWindow;
}

// Content object for BSIPIArrayController.
- (id)historyManager;

// Actions
- (IBAction) openImage : (id) sender;
- (IBAction) openImageWithPreviewApp : (id) sender;
- (IBAction) saveImage : (id) sender;
- (IBAction) saveImageAs: (id) sender;
- (IBAction) copyURL : (id) sender;
- (IBAction) startFullscreen : (id) sender;
- (IBAction)cancelDownload:(id)sender;
- (IBAction)retryDownload:(id)sender;

- (IBAction) historyNavigationPushed: (id) sender;
- (IBAction) changePane: (id) sender;

- (IBAction) forceRunTbCustomizationPalette: (id) sender;
@end

@interface BSImagePreviewInspector(Settings)
- (BOOL) alwaysBecomeKey;
- (void) setAlwaysBecomeKey : (BOOL) alwaysKey;

- (NSString *) saveDirectory;
- (void) setSaveDirectory : (NSString *) aString;

- (float) alphaValue;
- (void) setAlphaValue : (float) newValue;

- (BOOL) opaqueWhenKey;
- (void) setOpaqueWhenKey : (BOOL) opaqueWhenKey;

- (BOOL) resetWhenHide;
- (void) setResetWhenHide: (BOOL) reset;

- (BOOL) floating;
- (void) setFloating: (BOOL) floatOrNot;

- (int) preferredView;
- (void) setPreferredView: (int) aType;

- (int) lastShownViewTag;
- (void) setLastShownViewTag: (int) aTag;

- (BOOL) leaveFailedToken;
- (void) setLeaveFailedToken: (BOOL) leave;

- (float)fullScreenWheelAmount;
- (void)setFullScreenWheelAmount:(float)floatValue;

- (BOOL)useIKSlideShowOnLeopard;
- (void)setUseIKSlideShowOnLeopard:(BOOL)flag;
@end

@interface BSImagePreviewInspector(ToolbarAndUtils)
- (NSString *) localizedStrForKey : (NSString *) key;
- (NSImage *) imageResourceWithName : (NSString *) name;
- (void) setupToolbar;
@end

@interface BSImagePreviewInspector(ViewAccessor)
- (NSTextField *) infoField;
- (NSPopUpButton *) actionBtn;
- (NSImageView *) imageView;
- (NSProgressIndicator *) progIndicator;
- (NSPanel *) settingsPanel;
- (NSSegmentedControl *) cacheNavigationControl;
- (NSTabView *) tabView;
- (NSSegmentedControl *) paneChangeBtn;
- (NSTableColumn *) nameColumn;
- (NSMenu *) cacheNaviMenuFormRep;
- (BSIPIArrayController *) tripleGreenCubes;
@end

@interface BSImagePreviewInspector(Preferences)
- (IBAction) openOpenPanel: (id) sender;

- (NSPopUpButton *) directoryChooser;
//- (NSTextField *) versionInfoField;
- (NSSegmentedControl *) preferredViewSelector;

- (void) updateDirectoryChooser;
@end
