//
//  CMRPullDownIconBtn.m
//  CocoMonar & BathyScaphe
//
//  Created by Tsutomu Sawada on 05/01/09, last modified on 06/02/02.
//  Copyright 2005-2006 tsawada2. All rights reserved.
//

#import "CMRPullDownIconBtn.h"
#import <SGAppKit/NSImage-SGExtensions.h>

@implementation CMRPullDownIconBtn
- (NSImage *) btnImg
{
	return _btnImg;
}

- (NSImage *) btnImgPressed
{
	return _btnImgPressed;
}

- (void) setBtnImg : (NSImage *) anImage
{
	[anImage retain];
	[_btnImg release];
	_btnImg = anImage;
}


- (void) setBtnImgPressed : (NSImage *) anImage
{
	[anImage retain];
	[_btnImgPressed release];
	_btnImgPressed = anImage;
}

- (id) initTextCell : (NSString *) stringValue pullsDown : (BOOL) pullDown
{
	if (self = [super initTextCell : stringValue pullsDown : pullDown]) {
		[self setBtnImg : [NSImage imageNamed : @"Action" loadFromBundle : [NSBundle bundleForClass : [self class]]]];
		[self setBtnImgPressed : [NSImage imageNamed : @"Action_Pressed" loadFromBundle : [NSBundle bundleForClass : [self class]]]];
	}
	return self;
}

- (void) drawInteriorWithFrame : (NSRect ) cellFrame 
						inView : (NSView*) controlView
{    
    NSImage*  iconImage;
    NSPoint   iconPoint;
    
    // 画像を描く
	// isHighlighted を見ればよい ... Thanks to 642@21th
	iconImage = [self isHighlighted] ? [self btnImgPressed] : [self btnImg];
	
    iconPoint.x = cellFrame.origin.x;
    iconPoint.y = cellFrame.origin.y;
    
    if(iconImage) {
        
        if([controlView isFlipped]) {
            iconPoint.y += cellFrame.size.height;
        }
        
        [iconImage setSize : cellFrame.size];
        [iconImage compositeToPoint : iconPoint operation : NSCompositeSourceOver];
    }
}

- (void) dealloc
{
	[_btnImg release];
	[_btnImgPressed release];
	[super dealloc];
}
@end
