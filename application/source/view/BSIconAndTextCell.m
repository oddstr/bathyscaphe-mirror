//
//  BSIconAndTextCell.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/09/19.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import "BSIconAndTextCell.h"

@implementation BSIconAndTextCell
- (void) drawInteriorWithFrame : (NSRect) cellFrame 
						inView : (NSView *) controlView
{
    id			path;
    NSRect		pathRect;
    
    NSImage		*iconImage;
    NSSize		iconSize;
    NSPoint		iconPoint;
    

    iconImage = [self image];
    iconSize = NSZeroSize;
    iconPoint.x = cellFrame.origin.x;
    iconPoint.y = cellFrame.origin.y;
    
    if(iconImage) {
        iconSize = [iconImage size];
        iconPoint.x += 3.0;
		iconPoint.y += ceil((cellFrame.size.height - iconSize.height) /2.0);
        
        if([controlView isFlipped]) {
            iconPoint.y += iconSize.height;
        }
        
        [iconImage compositeToPoint : iconPoint 
                operation : NSCompositeSourceOver];
	}
    

    path = (NSMutableAttributedString *)[self objectValue];
    pathRect.origin.x = cellFrame.origin.x + 3.0;
    if(iconSize.width > 0) {
        pathRect.origin.x += iconSize.width + 3.0;
    }
    pathRect.origin.y = cellFrame.origin.y + ceil((cellFrame.size.height - [path size].height) /2.0);
    pathRect.size.width = cellFrame.size.width - (pathRect.origin.x - cellFrame.origin.x);
    pathRect.size.height = [path size].height;
    
    if(path) {
		if([self isHighlighted]) {
			// Mail のような視覚効果の実現方法を検証、発見してくれた 915@6th に感謝。
			NSMutableAttributedString	*highlightedPath;
			NSDictionary	*highlightedAttr,*backgroundAttr;
			NSRange			pathRange;

			highlightedPath = [[path mutableCopy] autorelease];
			pathRange = NSMakeRange(0, [path length]);

			highlightedAttr = [NSDictionary dictionaryWithObject : [NSColor whiteColor]
														  forKey : NSForegroundColorAttributeName];

			backgroundAttr  = [NSDictionary dictionaryWithObject : [[NSColor grayColor] colorWithAlphaComponent : 0.8]
														  forKey : NSForegroundColorAttributeName];

			// まず、グレーの文字を y軸方向に 1px ずらして描く
			[highlightedPath removeAttribute : NSForegroundColorAttributeName range : pathRange];
			[highlightedPath   addAttributes : backgroundAttr				  range : pathRange];
			[highlightedPath applyFontTraits : NSBoldFontMask				  range : pathRange];

			[highlightedPath drawInRect:NSOffsetRect(pathRect, 0.0,1.0)];

			// そして、白い文字で重ねて描く
			[highlightedPath removeAttribute : NSForegroundColorAttributeName range : pathRange];
			[highlightedPath   addAttributes : highlightedAttr				  range : pathRange];

			[highlightedPath drawInRect:pathRect];

		} else {
			[path drawInRect:pathRect];
		}
    }
}

- (NSColor *) highlightColorWithFrame : (NSRect) cellFrame inView : (NSView *)controlView
{
	return nil;
}
@end
