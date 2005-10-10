//
//  BSImagePreviewInspector.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/10/10.
//  Copyright 2005 BathyScaphe. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
    @class       BSImagePreviewInspector
    @abstract    Controller for 'Image Preview' inspector panel.
    @discussion  BSImagePreviewInspector は、画像のプレビューを表示するインスペクタ・パネルのコントローラです。
	             URL を与えることで、Cocoa バインディングの力によって自動的に imageView にイメージが表示され、
				 テキストフィールドには URL が表示されます。私たちは URL のみを与えれば良いのです。
*/

@interface BSImagePreviewInspector : NSWindowController {
	IBOutlet NSButton		*m_openWithBrowserBtn;
	IBOutlet NSImageView	*m_imageView;
	
	@private
	NSURL	*_sourceURL;
}
+ (id) sharedInstance;
// Accessor
- (NSButton *) openWithBrowserBtn;
- (NSImageView *) imageView;

// Binding
- (NSString *) sourceURLAsString;

- (NSURL *) sourceURL;
- (void) setSourceURL : (NSURL *) newURL;

// Actions
- (IBAction) openImage : (id) sender;
- (BOOL) showImageWithURL : (NSURL *) imageURL; // 今のところ、常に YES が返るけど…
@end
