//
//  BSImagePreviewInspector.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/10/10.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BSImagePreviewerInterface.h"
#import "BSIPIHistoryManager.h"

@class TemporaryFolder;
@class BSIPIDownload;

typedef enum _BSIPIRedirectionBehavior {
	BSIPIAlwaysAsk		= -1,
	BSIPIAlwaysAbort	= 0,
	BSIPIAlwaysPass		= 1,
} BSIPIRedirectionBehavior;

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
	IBOutlet NSTextField			*m_versionInfoField;
	IBOutlet NSMenu					*m_cacheNaviMenuFormRep;
	IBOutlet NSSegmentedControl		*m_preferredViewSelector;

	@private
	NSURL			*_sourceURL;
	BSIPIDownload	*_currentDownload;
	TemporaryFolder	*_dlFolder;
	AppDefaults		*_preferences;
	BOOL			m_shouldRestoreKeyWindow;
}

// Binding
- (NSURL *) sourceURL;
- (void) setSourceURL : (NSURL *) newURL;

// Actions
- (IBAction) openImage : (id) sender;
- (IBAction) openImageWithPreviewApp : (id) sender;
- (IBAction) saveImage : (id) sender;
- (IBAction) saveImageAs: (id) sender;
- (IBAction) copyURL : (id) sender;
- (IBAction) beginSettingsSheet : (id) sender;
- (IBAction) endSettingsSheet : (id) sender;
- (IBAction) openOpenPanel : (id) sender;
- (IBAction) startFullscreen : (id) sender;

- (IBAction) togglePreviewPanel : (id) sender;
- (IBAction) historyNavigationPushed: (id) sender;
- (IBAction) changePane: (id) sender;

- (IBAction) showPrevImage: (id) sender;
- (IBAction) showNextImage: (id) sender;

- (IBAction) forceRunTbCustomizationPalette: (id) sender;
- (IBAction) deleteCachedImage: (id) sender;

- (IBAction) resetCache: (id) sender;

- (BOOL) showCachedImageWithPath: (NSString *) path;
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

- (BSIPIRedirectionBehavior) redirectionBehavior;
- (void) setRedirectionBehavior: (BSIPIRedirectionBehavior) aTag;
@end

@interface BSImagePreviewInspector(ToolbarAndUtils)
- (NSString *) localizedStrForKey : (NSString *) key;
- (NSImage *) imageResourceWithName : (NSString *) name;
- (NSString *) calcImageSize : (NSImage *) image_;
- (void) setupToolbar;
- (void) startProgressIndicator;
- (void) stopProgressIndicator;
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
- (NSPopUpButton *) directoryChooser;
- (NSTextField *) versionInfoField;
- (NSMenu *) cacheNaviMenuFormRep;
- (NSSegmentedControl *) preferredViewSelector;

- (BSIPIDownload *) currentDownload;
- (void) setCurrentDownload : (BSIPIDownload *) aDownload;

- (TemporaryFolder *) dlFolder;

- (void) updateDirectoryChooser;

- (void) clearAttributes;
- (void) synchronizeImageAndSelectedRow;
@end
