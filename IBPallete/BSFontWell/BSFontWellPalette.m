//
//  BSFontWellPalette.m
//  BSFontWell
//
//  Created by Tsutomu Sawada on 06/12/12.
//  Copyright BathyScaphe Project 2006 . All rights reserved.
//

#import "BSFontWellPalette.h"

@implementation BSFontWellPalette

- (void)finishInstantiate
{
    /* `finishInstantiate' can be used to associate non-view objects with
     * a view in the palette's nib.  For example:
     *   [self associateObject:aNonUIObject ofType:IBObjectPboardType
     *                withView:aView];
     */
	 [fontWell setFont: [NSFont systemFontOfSize: 12.0]];
	 [fontWell setFontValue: [fontWell font]];
	 [super finishInstantiate];
}
@end

@implementation BSFontWell (BSFontWellPaletteInspector)

- (NSString *)inspectorClassName
{
    return nil;//@"BSFontWellInspector";
}

@end
