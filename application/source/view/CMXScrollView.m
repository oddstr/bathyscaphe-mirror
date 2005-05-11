//: CMXScrollView.m
/**
  * $Id: CMXScrollView.m,v 1.1.1.1 2005/05/11 17:51:08 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "CMXScrollView.h"



@interface CMXScrollView(Private)
- (NSMutableArray *) accessoryViews;	/* 入れ子の配列 */
- (NSMutableArray *) accessoryViewArrayWithAlignment : (int) anAlignment;
@end


@implementation CMXScrollView(Private)
- (NSMutableArray *) accessoryViews
{
	if(nil == _accessoryViews){
		// 最初、各要素にはNSNullを入れ、
		// 必要になった時点で配列に置き換える
		_accessoryViews = [[NSMutableArray alloc] init];
		while([_accessoryViews count] < _CMXScrollViewAlignmentLast)
			[_accessoryViews addObject : [NSNull null]];
	}
	
	return _accessoryViews;
}
- (NSMutableArray *) accessoryViewArrayWithAlignment : (int) anAlignment
{
	NSMutableArray	*views_ = [self accessoryViews];
	id				member_ = nil;
	
	NSAssert2(
		_CMXScrollViewAlignmentLast == [views_ count],
		@"accessoryViewArray expected bounds(%u) but was %u.",
		_CMXScrollViewAlignmentLast,
		[views_ count]);
	NSAssert1(
		0 <= anAlignment && anAlignment < _CMXScrollViewAlignmentLast,
		@"Unknown Alignment TYpe = %d",
		anAlignment);
	
	member_ = [views_ objectAtIndex : anAlignment];
	if([[NSNull null] isEqual : member_]){
		member_ = [[NSMutableArray alloc] init];
		[views_ replaceObjectAtIndex : anAlignment
						  withObject : member_];
		[member_ release];
	}
	UTILAssertKindOfClass(member_, NSMutableArray);
	
	return member_;
}
@end



@implementation CMXScrollView
- (id) initWithFrame : (NSRect) frame
{
	if(self = [super initWithFrame : frame]){
		;
	}
	return self;
}
- (void) dealloc
{
	[_accessoryViews release];
	[_cornerHandleView release];
	[super dealloc];
}

- (void) addAccessoryView : (NSView *) anAccessory
				alignment : (int     ) anAlignment
{
	UTILAssertNotNilArgument(anAccessory, @"Accessory View");
	[[self accessoryViewArrayWithAlignment:anAlignment] addObject:anAccessory];
	[self addSubview : anAccessory];
}
- (void) addHorizontalAccessoryView : (NSView *) anAccessory
{
	[self addAccessoryView:anAccessory alignment:CMXScrollViewHorizontalRight];
}

// Corner View
- (NSView *) cornerHandleView
{
	return _cornerHandleView;
}
- (void) setCornerHandleView : (NSView *) aCornerHandleView
{
	id		tmp;
	
	tmp = _cornerHandleView;
	_cornerHandleView = [aCornerHandleView retain];
	[tmp release];
}

- (void) layoutAccessoryViews : (NSArray *) viewArray
				    alignment : (int      ) anAlignment
{
	BOOL			isVertical_;
	BOOL			isRight_;
	NSEnumerator	*iter_;
	
	NSScroller		*scroller_;
	NSView			*accessory_;
	NSRect			scrollerFrame_;
	NSRect			svFrame_;
	NSPoint			origin_;
	NSSize			scrollerSize_;
	
	
	UTILAssertNotNilArgument(viewArray, @"Accessory View Array");
	NSAssert1(
		0 <= anAlignment && anAlignment < _CMXScrollViewAlignmentLast,
		@"Unknown Alignment TYpe = %d",
		anAlignment);
	
	isVertical_ = (CMXScrollViewVerticalTop == anAlignment) || 
				  (CMXScrollViewVerticalBottom == anAlignment);
	isRight_    = (CMXScrollViewHorizontalRight == anAlignment) || 
				  (CMXScrollViewVerticalBottom == anAlignment);
	
	svFrame_ = [self frame];
	
	// スクローラサイズを計算
	scroller_ = isVertical_ 
					? [self verticalScroller]
					: [self horizontalScroller];
	
	scrollerFrame_ = [scroller_ frame];
	scrollerSize_ = scrollerFrame_.size;
	
	
	// アクセサリを配置する開始点を決定。
	origin_ = scrollerFrame_.origin;
	if(isVertical_ && isRight_){
		origin_.y = NSMaxY(scrollerFrame_);
	}
	if(NO == isVertical_ && isRight_){
		origin_.x = NSMaxX(scrollerFrame_);
		//origin_.y -= 1.0;
	}
	
	// 右寄せの場合は逆順に配置していく。
	iter_ = isRight_ ? [viewArray reverseObjectEnumerator]
					 : [viewArray objectEnumerator];
	
	while(accessory_ = [iter_ nextObject]){
		NSRect		acsFrame_;
		float		acsWidth_;
		
		// スクローラの高さに合わせる。
		acsFrame_ = [accessory_ frame];
		if(isVertical_)
			acsFrame_.size.width = scrollerSize_.width;
		else
			acsFrame_.size.height = scrollerSize_.height + 1.0;
		
		if(isRight_){
			if(isVertical_)
				origin_.y -= NSHeight(acsFrame_);
			else
				origin_.x -= NSWidth(acsFrame_);
		}
		acsFrame_.origin = origin_;
		[accessory_ setFrame : acsFrame_];
		acsWidth_ = isVertical_ 
						? NSHeight(acsFrame_)
						: NSWidth(acsFrame_);
		// 原点と水平スクローラのサイズを調節
		acsWidth_--;
		if(NO == isRight_){
			if(isVertical_)
				origin_.y += acsWidth_;
			else
				origin_.x += acsWidth_;
		}
		if(isVertical_)
			scrollerSize_.height -= acsWidth_;
		else
			scrollerSize_.width -= acsWidth_;
	}
	if(NO == isRight_)
		scrollerFrame_.origin = origin_;
	scrollerFrame_.size = scrollerSize_;
	
	[scroller_ setFrame : scrollerFrame_];

}
- (void) layoutAccessoryViews
{
	int		i, cnt;
	
	cnt = [[self accessoryViews] count];
	for(i = 0; i < cnt; i++){
		id			views_ = [[self accessoryViews] objectAtIndex:i];
		
		if([[NSNull null] isEqual : views_])
			continue;
		
		[self layoutAccessoryViews : views_
						 alignment : i];
	}
}
- (void) layoutCornerView
{
	NSView		*cornerView_ = [self cornerHandleView];
	NSRect		vFrame_ = NSZeroRect;
	NSRect		hsFrame_;
	NSRect		vsFrame_;
	
	UTILRequireCondition(cornerView_ != nil, ErrLayoutCornerView);
	UTILRequireCondition([self hasVerticalScroller], ErrLayoutCornerView);
	UTILRequireCondition([self hasHorizontalScroller], ErrLayoutCornerView);
	
	
	hsFrame_ = [[self horizontalScroller] frame];
	vsFrame_ = [[self verticalScroller] frame];
	
	vFrame_.size.height = NSHeight(hsFrame_);
	vFrame_.size.width  = NSWidth(vsFrame_);
	vFrame_.origin.x    = NSWidth([self frame]) - vFrame_.size.width;
	vFrame_.origin.x   -= 1;
	
	if([self isFlipped]){
		vFrame_.origin.y = NSHeight([self frame]);
		vFrame_.origin.y -= vFrame_.size.height;
		vFrame_.origin.y -= 1;
	}else{
		vFrame_.origin.y = 0;
	}
	
	if(NO == NSEqualRects(vFrame_, [cornerView_ frame]))
		[cornerView_ setFrame : vFrame_];
	
	if(NO == [cornerView_ isDescendantOf : self])
		[self addSubview : cornerView_];
	
	return;
	
ErrLayoutCornerView:
	
	if(cornerView_ && [cornerView_ isDescendantOf : self]){
		[cornerView_ removeFromSuperview];
	}
	return;
}

- (void) tile
{
	[super tile];
	[self layoutAccessoryViews];
	[self layoutCornerView];
}
@end
