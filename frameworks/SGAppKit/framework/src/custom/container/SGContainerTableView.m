//
//  SGContainerTableView.m
//  SGAppKit (BathyScaphe)
//
//  Updated by Tsutomu Sawada on 08/03/08.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "SGContainerTableView.h"
#import "UTILKit.h"

@interface SGContainerTableView(Private)
- (NSView *)containerViewAtRow:(int)rowIndex;
- (void)loadSubviews;
- (void)layoutSubviews;
@end


@implementation SGContainerTableView
- (id)initWithFrame:(NSRect)frame
{
    if (self = [super initWithFrame:frame]) {
		[self setGridStyleMask:NSTableViewSolidHorizontalGridLineMask];
		[self setBackgroundColor:[NSColor whiteColor]];
	}
    return self;
}

- (void)dealloc
{
	[self setBackgroundColor:nil];
	[super dealloc];
}

- (BOOL)isOpaque
{
	return YES;
}

- (BOOL)isFlipped
{
	return YES;
}

- (id)dataSource
{
	return m_dataSource;
}

- (void)setDataSource:(id)aDataSource
{
	m_dataSource = aDataSource;
	if (!m_dataSource) return;
	[self reloadData];
}

- (unsigned int)gridStyleMask
{
	return m_gridStyleMask;
}

- (void)setGridStyleMask:(unsigned int)gridType
{
	m_gridStyleMask = gridType;
}

- (NSColor *)backgroundColor
{
	return m_bgColor;
}

- (void)setBackgroundColor:(NSColor *)aColor
{
	[aColor retain];
	[m_bgColor release];
	m_bgColor = aColor;
}

- (void)drawBackgroundInClipRect:(NSRect)clipRect
{
	[[self backgroundColor] set];
	NSRectFill(clipRect);
}

- (void)drawGridInClipRect:(NSRect)aRect
{
	NSRect viewBoundsRect = [self bounds];
	NSRect rowBoundsRect;
	NSRect gridRect;
	NSArray *rows = [self subviews];

	int	i;
	int n = [rows count];

	float amount = -1;
	float height;

	[[NSColor gridColor] set];

	for (i = 0; i < n; i++) {
		rowBoundsRect = [[rows objectAtIndex:i] bounds];
		height = NSHeight(rowBoundsRect);
		amount += height;
		gridRect = NSMakeRect(viewBoundsRect.origin.x, amount, viewBoundsRect.size.width, 1.0);
		gridRect = NSIntersectionRect(gridRect, aRect);
		NSRectFill(gridRect);
	}
}

- (void)drawRect:(NSRect)clipRect
{
	unsigned int mask = [self gridStyleMask];

	[self drawBackgroundInClipRect:clipRect];

	if (mask & NSTableViewSolidHorizontalGridLineMask) {
		[self drawGridInClipRect:clipRect];
	}
}

- (void)reloadData
{
	[self loadSubviews];
	[self layoutSubviews];
}

- (int)numberOfRows
{
	id		dataSource = [self dataSource];

	if (!dataSource || ![dataSource respondsToSelector:@selector(numberOfRowsInContainerTableView:)]) {
		return 0;
	}

	return [dataSource numberOfRowsInContainerTableView:self];
}

- (NSRect)rectOfRow:(int)rowIndex
{
	if (rowIndex >= [self numberOfRows]) return NSZeroRect;
	UTILAssertNotNil([self containerViewAtRow:rowIndex]);
	return [[self containerViewAtRow:rowIndex] frame];
}

- (void)scrollRowToVisible:(int)rowIndex
{
	NSRect		rectOfRow;

	rectOfRow = [self rectOfRow:rowIndex];
	if (NSEqualRects(NSZeroRect, rectOfRow)) return;

	[self scrollRectToVisible:rectOfRow];
}
@end


@implementation SGContainerTableView(Private)
- (NSView *)containerViewAtRow:(int)rowIndex
{
	id		dataSource = [self dataSource];

	if (!dataSource || ![dataSource respondsToSelector:@selector(containerTableView:viewAtRow:)]) {
		return nil;
	}
	return [dataSource containerTableView:self viewAtRow:rowIndex];
}

- (void)layoutSubviews
{
	NSRect	subviewFrame;
	NSRect	vbounds_;
	BOOL	savedFlag;
	NSWindow	*window = [self window];
	
	vbounds_ = [self bounds];
	
	savedFlag = [window isAutodisplay];
	[window setAutodisplay:NO];
	[window disableFlushWindow];

	@try {
		NSEnumerator	*iter_;
		NSView			*subview_;
		
		iter_ = [[self subviews] objectEnumerator];
		while (subview_ = [iter_ nextObject]) {
			float viewHeight;

			subviewFrame = [subview_ frame];
			viewHeight = NSHeight(subviewFrame);
			subviewFrame = NSMakeRect(
								NSMinX(vbounds_),
								NSMaxY(vbounds_) - viewHeight,
								NSWidth(vbounds_),
								viewHeight);
			[subview_ setFrame:subviewFrame];
//			viewHeight = NSHeight(subviewFrame);
			vbounds_.size.height -= viewHeight;
		}
	}
	@catch(NSException *localException) {
		NSLog(@"Exception raised during[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), localException);
//		[localException raise];
		@throw;
	}
	@finally {
		[window enableFlushWindow];
		[window setAutodisplay:savedFlag];
//		[[self window] setViewsNeedDisplay:windowAutoDisplayed_];
//		[[self window] enableFlushWindow];
	}
}

- (void)loadSubviews
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
	[[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperviewWithoutNeedingDisplay)];
	// 最初にDataSourceから返されるViewを順番通りに並び終えれば、
	// 残りはすでに登録されていないView
	for(i = 0; i < cnt; i++){
		subview_ = [self containerViewAtRow:i];
		if (!subview_) continue;
		
		newsize_.height += NSHeight([subview_ frame]);
		[self addSubview:subview_ positioned:NSWindowBelow relativeTo:prev_];
		prev_ = subview_;
	}
/*	for(i = [[self subviews] count] -1; i >= cnt; i--){
		subview_ = [[self subviews] objectAtIndex : i];
		[subview_ removeFromSuperviewWithoutNeedingDisplay];
	}*/
	
	autoresizesSubviews_ = [self autoresizesSubviews];
	[self setAutoresizesSubviews:NO];
	
	newFrame_ = [self frame];
	if (![[self superview] isFlipped]) {
		float		diff;

		diff = NSHeight(newFrame_) - newsize_.height;
		newFrame_.origin.y += diff;
	}
	newFrame_.size = newsize_;
	
	[self setFrame:newFrame_];
	[self setAutoresizesSubviews:autoresizesSubviews_];
}
@end
