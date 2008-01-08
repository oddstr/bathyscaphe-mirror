//
//  CMRThreadMessage-UndoSupport.m
//  BathyScaphe
//
//  Written by Tsutomu Sawada on 08/01/08.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRThreadMessage_p.h"

@implementation CMRThreadMessage(UndoSupport)
- (void)setLocalAboned:(BOOL)flag undoManager:(NSUndoManager *)um
{
	[[um prepareWithInvocationTarget:self] setLocalAboned:!flag undoManager:um];
	[self setLocalAboned:flag];
}

- (void)setInvisibleAboned:(BOOL)flag undoManager:(NSUndoManager *)um
{
	[[um prepareWithInvocationTarget:self] setInvisibleAboned:!flag undoManager:um];
	[self setInvisibleAboned:flag];
}

- (void)setAsciiArt:(BOOL)flag undoManager:(NSUndoManager *)um
{
	[[um prepareWithInvocationTarget:self] setAsciiArt:!flag undoManager:um];
	[self setAsciiArt:flag];
}

- (void)setHasBookmark:(BOOL)flag undoManager:(NSUndoManager *)um
{
	[[um prepareWithInvocationTarget:self] setHasBookmark:!flag undoManager:um];
	[self setHasBookmark:flag];
}

- (void)setSpam:(BOOL)flag undoManager:(NSUndoManager *)um
{
	[[um prepareWithInvocationTarget:self] setSpam:!flag undoManager:um];
	[self setSpam:flag];
}
@end
