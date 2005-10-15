//
//  BSImagePreviewInspector.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/10/10.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BSImagePreviewerInterface.h"

/*!
    @class       BSImagePreviewInspector
    @abstract    Controller for 'Image Preview' inspector panel.
    @discussion  BSImagePreviewInspector は、画像のプレビューを表示するインスペクタ・パネルのコントローラです。
	             URL を与えることで、Cocoa バインディングの力によって自動的に imageView にイメージが表示され、
				 テキストフィールドには URL が表示されます。私たちは URL のみを与えれば良いのです。
*/

@interface BSImagePreviewInspector : NSWindowController <BSImagePreviewerProtocol> {
	IBOutlet NSButton				*m_openWithBrowserBtn;
	IBOutlet NSButton				*m_saveButton;
	IBOutlet NSImageView			*m_imageView;
	IBOutlet NSProgressIndicator	*m_progIndicator;
	
	@private
	NSURL		*_sourceURL;
	AppDefaults	*_preferences;
}

// Accessor
- (NSButton *) openWithBrowserBtn;
- (NSButton *) saveButton;
- (NSImageView *) imageView;
- (NSProgressIndicator *) progIndicator;

// Binding
- (NSString *) sourceURLAsString;

- (NSURL *) sourceURL;
- (void) setSourceURL : (NSURL *) newURL;

// Actions
- (IBAction) openImage : (id) sender;
- (IBAction) saveImage : (id) sender;
@end
