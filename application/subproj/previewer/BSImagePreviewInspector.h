//
//  BSImagePreviewInspector.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/10/10.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BSImagePreviewerInterface.h"
@class TemporaryFolder;
/*!
    @class       BSImagePreviewInspector
    @abstract    Controller for 'Image Preview' inspector panel.
    @discussion  BSImagePreviewInspector は、画像のプレビューを表示するインスペクタ・パネルのコントローラです。
*/

@interface BSImagePreviewInspector : NSWindowController <BSImagePreviewerProtocol> {
	IBOutlet NSPopUpButton			*m_actionBtn;
	IBOutlet NSButton				*m_saveButton;
	IBOutlet NSImageView			*m_imageView;
	IBOutlet NSProgressIndicator	*m_progIndicator;
	IBOutlet NSPanel				*m_settingsPanel;
	
	@private
	NSURL			*_sourceURL;
	NSURLDownload	*_currentDownload;
	NSString		*_downloadedFileDestination;
	TemporaryFolder	*_dlFolder;
	AppDefaults		*_preferences;
}

// Accessor
- (NSPopUpButton *) actionBtn;
- (NSButton *) saveButton;
- (NSImageView *) imageView;
- (NSProgressIndicator *) progIndicator;
- (NSPanel *) settingsPanel;

- (NSString *) downloadedFileDestination;
- (void) setDownloadedFileDestination : (NSString *) aPath;

- (TemporaryFolder *) dlFolder;

// Binding
- (NSString *) sourceURLAsString;

- (NSURL *) sourceURL;
- (void) setSourceURL : (NSURL *) newURL;

- (BOOL) alwaysBecomeKey;
- (void) setAlwaysBecomeKey : (BOOL) alwaysKey;

- (NSString *) saveDirectory;
- (void) setSaveDirectory : (NSString *) aString;

// Actions
- (IBAction) openImage : (id) sender;
- (IBAction) openImageWithPreviewApp : (id) sender;
- (IBAction) copyURL : (id) sender;
- (IBAction) beginSettingsSheet : (id) sender;
- (IBAction) openOpenPanel : (id) sender;
@end
