//: SGContainerTableView.h
/**
  * $Id: SGContainerTableView.h,v 1.2 2007/10/29 05:54:46 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Cocoa/Cocoa.h>


@interface SGContainerTableView : NSView
{
	@private
	id				m_dataSource;
	NSBorderType	_borderType;
}
- (id) dataSource;
- (void) setDataSource : (id) aDataSource;
- (NSBorderType) borderType;
- (void) setBorderType : (NSBorderType) aBorderType;

- (void) reloadData;

- (int) numberOfRows;
- (NSView *) containerViewAtRow : (int) rowIndex;

- (NSRect) rectOfRow : (int) rowIndex;
- (void) scrollRowToVisible : (int) rowIndex;
@end




@interface NSObject(SGContainerTableViewDataSource)
- (int) numberOfRowsInContainerTableView : (SGContainerTableView *) tbView;
- (NSView *) containerTableView : (SGContainerTableView *) tbView
                      viewAtRow : (int                   ) rowIndex;
@end