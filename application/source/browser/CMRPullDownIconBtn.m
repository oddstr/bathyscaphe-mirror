//
//  CMRPullDownIconBtn.m
//  CocoMonar & BathyScaphe
//
//  Created by Tsutomu Sawada on 05/01/09, last modified on 05/10/11.
//  Copyright 2005 tsawada2. All rights reserved.
//

#import "CMRPullDownIconBtn.h"


@implementation CMRPullDownIconBtn
- (void) drawInteriorWithFrame : (NSRect ) cellFrame 
						inView : (NSView*) controlView
{    
    NSImage*  iconImage;
    NSPoint   iconPoint;
    
    // �摜��`��
	// isHighlighted ������΂悢 ... Thanks to 642@21th
	// 2005-10-11 �ǉ��F���������J�X�^�}�C�Y�\�ł��Ӗ����Ȃ��̂ŁA������ imageAppNamed �� imageNamed �ɕύX�B
	iconImage = [self isHighlighted] ? [NSImage imageNamed : @"Action_Pressed"] : [NSImage imageNamed : @"Action"];
	
    iconPoint.x = cellFrame.origin.x;
    iconPoint.y = cellFrame.origin.y;
    
    if(iconImage) {
        
        if([controlView isFlipped]) {
            iconPoint.y += 25;
        }
        
        [iconImage setSize : NSMakeSize(32,25)];
        [iconImage compositeToPoint : iconPoint operation : NSCompositeSourceOver];
    }    
}
@end
