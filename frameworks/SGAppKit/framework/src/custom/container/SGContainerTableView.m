//: SGContainerTableView.m
/**
  * $Id: SGContainerTableView.m,v 1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "SGContainerTableView.h"
#import "SGAppKitFrameworkDefines.h"


@interface SGContainerTableView(Private)
- (void) loadSubviews;
- (void) layoutSubviews;
@end



@implementation SGContainerTableView
- (BOOL) isFlipped
{
	return YES;
}

- (id) dataSource
{
	return m_dataSource;
}
- (void) setDataSource : (id) aDataSource
{
	m_dataSource = aDataSource;
	if(nil == m_dataSource) return;
	[self reloadData];
}
- (NSBorderType) borderType
{
	return _borderType;
}
- (void) setBorderType : (NSBorderType) aBorderType
{
	_borderType = aBorderType;
}
- (void) drawRect : (NSRect) clipRect
{
	[super drawRect : clipRect];
	
	if(NSNoBorder == [self borderType])
		return;
	
	[[NSColor grayColor] set];
	NSFrameRect([self bounds]);
}

- (void) reloadData
{
	[self loadSubviews];
	[self layoutSubviews];
}

- (int) numberOfRows
{
	id		dataSource_;
	SEL		sel_ = @selector(numberOfRowsInContainerTableView:);
	
	dataSource_ = [self dataSource];
	if(nil == dataSource_ || NO == [dataSource_ respondsToSelector : sel_])
		return 0;
	return [[self dataSource] numberOfRowsInContainerTableView : self];
}
- (NSView *) containerViewAtRow : (int) rowIndex
{
	id		dataSource_;
	SEL		sel_ = @selector(containerTableView:viewAtRow:);
	
	dataSource_ = [self dataSource];
	if(nil == dataSource_ || NO == [dataSource_ respondsToSelector : sel_])
		return nil;
	return [[self dataSource] containerTableView:self viewAtRow:rowIndex];
}

- (NSRect) rectOfRow : (int) rowIndex
{
	if(rowIndex >= [self numberOfRows]) return NSZeroRect;
	UTILAssertNotNil([self containerViewAtRow : rowIndex]);
	return [[self containerViewAtRow : rowIndex] frame];
}
- (void) scrollRowToVisible : (int) rowIndex
{
	NSRect		rectOfRow_;
	
	rectOfRow_ = [self rectOfRow : rowIndex];
	if(NSEqualRects(NSZeroRect, rectOfRow_)) return;
	
	[self scrollRectToVisible : rectOfRow_];
}

@end



@implementation SGContainerTableView(Private)
- (void) layoutSubviews
{
	NSRect	subviewFrame;
	NSRect	vbounds_;
	BOOL	windowAutoDisplayed_;
	
	vbounds_ = [self bounds];
	
	windowAutoDisplayed_ = [[self window] isAutodisplay];
	[[self window] setAutodisplay : NO];
	[[self window] disableFlushWindow];
	
	NS_DURING
		NSEnumerator	*iter_;
		NSView			*subview_;
		
		iter_ = [[self subviews] objectEnumerator];
		while(subview_ = [iter_ nextObject]){
			float viewHeight;
			
			subviewFrame = [subview_ frame];
			viewHeight = NSHeight(subviewFrame);
			subviewFrame = NSMakeRect(
								NSMinX(vbounds_),
								NSMaxY(vbounds_) - viewHeight,
								NSWidth(vbounds_),
								viewHeight);
			[subview_ setFrame: subviewFrame];
			viewHeight = NSHeight(subviewFrame);
			vbounds_.size.height -= viewHeight;
		}
	NS_HANDLER
		NSLog(@"Exception raised during[%@ %@]: %@",
					NSStringFromClass([self class]),
					NSStringFromSelector(_cmd),
					localException);
		[localException raise];
	NS_ENDHANDLER
	
	[[self window] setAutodisplay : windowAutoDisplayed_];
	[[self window] setViewsNeedDisplay : windowAutoDisplayed_];
	[[self window] enableFlushWindow];
}
- (void) loadSubviews
{
	NSView		*prev_ = nil;
	int			i,cnt;
	NSSize		newsize_;
	NSRect		newFrame_;
	NSView		*subview_;
	BOOL		autoresizesSubviews_;
	
	newsize_ = [self bounds].size;
	newsize_.height = 0.0f;
	
	cnt = [self numberOfRows];
	
	// ç≈èâÇ…DataSourceÇ©ÇÁï‘Ç≥ÇÍÇÈViewÇèáî‘í ÇËÇ…ï¿Ç—èIÇ¶ÇÍÇŒÅA
	// écÇËÇÕÇ∑Ç≈Ç…ìoò^Ç≥ÇÍÇƒÇ¢Ç»Ç¢View
	for(i = 0; i < cnt; i++){
		subview_ = [self containerViewAtRow : i];
		if(nil == subview_) continue;
		
		newsize_.height += NSHeight([subview_ frame]);
		[self addSubview : subview_
			  positioned : NSWindowBelow
			  relativeTo : prev_];
		prev_ = subview_;
	}
	for(i = [[self subviews] count] -1; i >= cnt; i--){
		subview_ = [[self subviews] objectAtIndex : i];
		[subview_ removeFromSuperviewWithoutNeedingDisplay];
	}
	
	autoresizesSubviews_ = [self autoresizesSubviews];
	[self setAutoresizesSubviews : NO];
	
	newFrame_ = [self frame];
	if(NO == [[self superview] isFlipped]){
		float		diff;
		
		diff = NSHeight(newFrame_) - newsize_.height;
		newFrame_.origin.y += diff;
	}
	newFrame_.size = newsize_;
	
	[self setFrame : newFrame_];
	[self setAutoresizesSubviews : autoresizesSubviews_];
}
@end