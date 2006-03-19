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
	IBOutlet NSTextField			*m_infoField;
	IBOutlet NSPopUpButton			*m_actionBtn;
	IBOutlet NSImageView			*m_imageView;
	IBOutlet NSProgressIndicator	*m_progIndicator;
	IBOutlet NSPanel				*m_settingsPanel;

	long long  lExLength;  // コンテンツの総容量
	long long  lDlLength;  // ダウンロードした量	

	@private
	NSURL			*_sourceURL;
	NSURLDownload	*_currentDownload;
	NSString		*_downloadedFileDestination;
	TemporaryFolder	*_dlFolder;
	AppDefaults		*_preferences;
}

// Accessor
- (NSTextField *) infoField;
- (NSPopUpButton *) actionBtn;
- (NSImageView *) imageView;
- (NSProgressIndicator *) progIndicator;
- (NSPanel *) settingsPanel;

- (NSURLDownload *) currentDownload;
- (void) setCurrentDownload : (NSURLDownload *) aDownload;

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

- (float) alphaValue;
- (void) setAlphaValue : (float) newValue;

- (BOOL) opaqueWhenKey;
- (void) setOpaqueWhenKey : (BOOL) opaqueWhenKey;

// Actions
- (IBAction) openImage : (id) sender;
- (IBAction) openImageWithPreviewApp : (id) sender;
- (IBAction) copyURL : (id) sender;
- (IBAction) beginSettingsSheet : (id) sender;
- (IBAction) endSettingsSheet : (id) sender;
- (IBAction) openOpenPanel : (id) sender;
- (IBAction) startFullscreen : (id) sender;

//- (IBAction) togglePreviewPanel : (id) sender;
@end

@interface BSImagePreviewInspector(ToolbarAndUtils)
- (NSString *) localizedStrForKey : (NSString *) key;
- (NSImage *) imageResourceWithName : (NSString *) name;
- (NSString *) calcImageSize : (NSImage *) image_;
- (void) setupToolbar;
- (void) startProgressIndicator : (NSProgressIndicator *) indicator indeterminately : (BOOL) indeterminately;
- (void) stopProgressIndicator : (NSProgressIndicator *) indicator;
@end
