//
//  SGContainerTableView.h
//  SGAppKit (BathyScaphe)
//
//  Updated by Tsutomu Sawada on 08/03/08.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>

@interface SGContainerTableView : NSView {
	@private
	id				m_dataSource;
	unsigned int	m_gridStyleMask;
	NSColor			*m_bgColor;
}

- (id)dataSource;
- (void)setDataSource:(id)aDataSource;

- (unsigned int)gridStyleMask;
- (void)setGridStyleMask:(unsigned int)gridType;

- (NSColor *)backgroundColor;
- (void)setBackgroundColor:(NSColor *)aColor;

- (void)reloadData;

- (int)numberOfRows;
- (NSRect)rectOfRow:(int)rowIndex;

- (void)scrollRowToVisible:(int)rowIndex;

- (void)drawBackgroundInClipRect:(NSRect)clipRect;
- (void)drawGridInClipRect:(NSRect)aRect;
@end


@interface NSObject(SGContainerTableViewDataSource)
- (int)numberOfRowsInContainerTableView:(SGContainerTableView *)aContainerTableView;
- (NSView *)containerTableView:(SGContainerTableView *)aContainerTableView viewAtRow:(int)rowIndex;
@end
