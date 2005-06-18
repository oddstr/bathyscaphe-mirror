//
//  CMRPullDownIconBtn.m
//  CocoMonar
//
//  Created by tsawada2 on 05/01/09.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "CMRPullDownIconBtn.h"


@implementation CMRPullDownIconBtn
- (void)drawInteriorWithFrame:(NSRect)cellFrame 
                inView:(NSView*)controlView
{    
    NSImage*  iconImage;
    NSSize    iconSize;
    NSPoint   iconPoint;
    
    // ‰æ‘œ‚ð•`‚­
	// isHighlighted ‚ðŒ©‚ê‚Î‚æ‚¢ ... Thanks to 642@21th
	iconImage = [self isHighlighted]?[NSImage imageAppNamed : @"Action_Pressed"]:[NSImage imageAppNamed : @"Action"];
	
	iconSize = NSZeroSize;
    iconPoint.x = cellFrame.origin.x;
    iconPoint.y = cellFrame.origin.y;
    
    if(iconImage) {
        iconSize.width = 32;
        iconSize.height = 25;
        
        if([controlView isFlipped]) {
            iconPoint.y += iconSize.height;
        }
        
        [iconImage setSize:iconSize];
        [iconImage compositeToPoint:iconPoint 
                operation:NSCompositeSourceOver];
    }
    
}
@end
