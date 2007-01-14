//
//  BSFontWellPalette.h
//  BSFontWell
//
//  Created by Tsutomu Sawada on 06/12/12.
//  Copyright BathyScaphe Project 2006 . All rights reserved.
//

#import <InterfaceBuilder/InterfaceBuilder.h>
#import "BSFontWell.h"

@interface BSFontWellPalette : IBPalette
{
	IBOutlet BSFontWell	*fontWell;
}
@end

@interface BSFontWell (BSFontWellPaletteInspector)
- (NSString *)inspectorClassName;
@end
