//
//  BSIconTextFieldCell.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/06/12.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "BSIconTextFieldCell.h"


@implementation BSIconTextFieldCell
- (void)drawInteriorWithFrame:(NSRect)cellFrame 
                inView:(NSView*)controlView
{
    NSString* path;
    NSRect    pathRect;
    
    NSImage*  iconImage;
    NSSize    iconSize;
    NSPoint   iconPoint;
    

    iconImage = [self image];
    iconSize = NSZeroSize;
    iconPoint.x = cellFrame.origin.x;
    iconPoint.y = cellFrame.origin.y;
    
    if(iconImage) {
        iconSize.width = 16.0;
        iconSize.height = 16.0;
        iconPoint.x += 5.0;
        
        if([controlView isFlipped]) {
            iconPoint.y += iconSize.height;
        }
        
        [iconImage setSize:iconSize];
        [iconImage compositeToPoint:iconPoint 
                operation:NSCompositeSourceOver];
	}
    

    path = [self stringValue];
    pathRect.origin.x = cellFrame.origin.x + 5.0;
    if(iconSize.width > 0) {
        pathRect.origin.x += iconSize.width + 5.0;
    }
    pathRect.origin.y = cellFrame.origin.y;
    pathRect.size.width = cellFrame.size.width 
                - (pathRect.origin.x - cellFrame.origin.x);
    pathRect.size.height = cellFrame.size.height;
    
    if(path) {
        [path drawInRect:pathRect withAttributes:[NSDictionary dictionaryWithObject : [NSFont systemFontOfSize:0] forKey : NSFontAttributeName]];
    }
}
@end
