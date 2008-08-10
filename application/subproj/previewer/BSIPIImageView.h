//
//  BSIPIImageView.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/01/07.
//  Copyright 2006-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>

@interface BSIPIImageCell : NSImageCell {
	@private
	NSColor	*bsIPIImageCell_bgColor;
}

- (void)copyAttributesFromCell:(NSImageCell *)baseCell;

- (NSColor *)backgroundColor;
- (void)setBackgroundColor:(NSColor *)color;
@end


@interface BSIPIImageView : NSImageView {
	@private
	id		bsIPIImageView_delegate;
}

- (id)delegate;
- (void)setDelegate:(id)aDelegate;

- (NSColor *)backgroundColor;
- (void)setBackgroundColor:(NSColor *)color;
@end


@interface NSObject(BSIPIImageViewDraggingSource)
- (BOOL)imageView:(BSIPIImageView *)aImageView writeSomethingToPasteboard:(NSPasteboard *)pboard;
@end 


@interface NSObject(BSIPIImageViewResponderDelegate)
- (BOOL)imageView:(BSIPIImageView *)aImageView shouldPerformKeyEquivalent:(NSEvent *)theEvent;
- (void)imageView:(BSIPIImageView *)aImageView mouseDoubleClicked:(NSEvent *)theEvent;
@end
