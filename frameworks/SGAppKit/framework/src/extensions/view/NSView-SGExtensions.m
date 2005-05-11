//: NSView-SGExtensions.m
/**
  * $Id: NSView-SGExtensions.m,v 1.1 2005/05/11 17:51:27 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "NSView-SGExtensions_p.h"


@implementation SGViewAnimationScrollInfo
+ (id) infoWithPoint : (NSPoint       ) aPoint
        animateValue : (float         ) animateValue
            interval : (NSTimeInterval) timeInterval
{
	return [[[self alloc] initWithPoint : aPoint
					       animateValue : animateValue
					           interval : timeInterval] autorelease];
}
- (id) initWithPoint : (NSPoint       ) aPoint
        animateValue : (float         ) animateValue
            interval : (NSTimeInterval) timeInterval
{
	if(self = [self init]){
		m_point = aPoint;
		m_animateValue = animateValue;
		m_timeInterval = timeInterval;
	}
	return self;
}
//////////////////////////////////////////////////////////////////////
//////////////////// [ インスタンスメソッド ] ////////////////////////
//////////////////////////////////////////////////////////////////////
/* Accessor for m_point */
- (NSPoint) point
{
	return m_point;
}

/* Accessor for m_animateValue */
- (float) animateValue
{
	return m_animateValue;
}

/* Accessor for m_timeInterval */
- (NSTimeInterval) timeInterval
{
	return m_timeInterval;
}
@end

//------------------------------------------------------------
static NSPoint imp_error_check_prevPoint = {x:1000.0f,y:1000.0f};
//------------------------------------------------------------

static float fAnimateValueWeighted(float current, float goal, float value)
{
	double		distance_;
	float		animate_;
	
	distance_ = fabs(goal - current);
	
	animate_ = value;
	if(distance_ <= ANIMATE_VALUE_MIN){
		animate_ = distance_;
	}else{
		// weight
		float tmp;
		tmp = (float)(distance_/3.0f);
		
		while(animate_ <= tmp){
			animate_ = (float)(animate_*2.0f);
		}
		tmp = (float)(distance_/2.0f);
		while(animate_ >= tmp){
			animate_ = (float)(animate_/2.0f);
		}
	}
	
	return (goal > current) ? animate_ : -(animate_);
}

static NSPoint fCalcPointToMove(NSPoint current, NSPoint goal, float value)
{
	NSPoint		pointToMove_;
	float		animate_;
	
	pointToMove_ = current;
	animate_ = fAnimateValueWeighted(current.y, goal.y, value);
	
	pointToMove_.y += animate_;
	return pointToMove_;
}

@implementation NSView(SGExtensions)
- (NSClipView *) enclosingClipView
{
	return [[self enclosingScrollView] contentView];
}

- (void) animationScrollPointScheduled : (id) info
{
	NSRect		visibleRect_;
	NSPoint		currentOrigin_;
	NSPoint		pointToMove_;
	
	UTILAssertKindOfClass(info, SGViewAnimationScrollInfo);
	visibleRect_ = [[self enclosingScrollView] documentVisibleRect];
	currentOrigin_ = visibleRect_.origin;
	
	pointToMove_ = fCalcPointToMove(currentOrigin_, 
									[info point],
									[info animateValue]);
	
	//------------------------------------------------------------
	// バグ。何度も同じ位置で呼び出されている。
	NSAssert(
		NO == NSEqualPoints(imp_error_check_prevPoint, pointToMove_),
		@"Implementation Error. Infinit Loop...");
	imp_error_check_prevPoint = pointToMove_;
	//------------------------------------------------------------
	
	[self scrollPoint : pointToMove_];
	
	if(NO == NSEqualPoints(pointToMove_, [info point])){
		[self performSelector : @selector(animationScrollPointScheduled:)
				   withObject : info
				   afterDelay : [info timeInterval]];
		return;
	}
	//------------------------------------------------------------
	imp_error_check_prevPoint = NSMakePoint(1000.0f, 1000.0f);
	//------------------------------------------------------------
}

- (void) animationScrollPoint : (NSPoint       ) aPoint
                 animateValue : (float         ) animateValue
                     interval : (NSTimeInterval) timeInterval
{
	SGViewAnimationScrollInfo		*info_;
	NSPoint							constrainScrollPoint_;
	
	constrainScrollPoint_ = [[self enclosingClipView] constrainScrollPoint : aPoint];
	info_ = [SGViewAnimationScrollInfo infoWithPoint : constrainScrollPoint_
										animateValue : animateValue
										    interval : timeInterval];
	[self performSelector : @selector(animationScrollPointScheduled:)
			   withObject : info_
			   afterDelay : timeInterval];
}
@end



@implementation NSView(WorkingWithSubviews)
- (NSView *) subviewAtIndex : (unsigned) anIndex
{
	NSArray		*subviews_;
	
	subviews_ = [self subviews];
	if(nil == subviews_ || anIndex >= [subviews_ count]) return nil;
	return [subviews_ objectAtIndex : anIndex];
}

- (NSView *) firstSubview
{
	return [self subviewAtIndex : 0];
}
- (NSView *) secondSubview
{
	return [self subviewAtIndex : 1];
}
- (NSView *) lastSubview
{
	return [[self subviews] lastObject];
}
@end



@implementation NSView(SGExtension_PrintingOperation)
- (NSImage *) PDFGraphicsImage
{
	return [self PDFGraphicsImageInsideRect : [self bounds]];
}
- (NSImage *) PDFGraphicsImageInsideRect : (NSRect) rect
{
/*
	NSPrintOperation		*op_;
	NSMutableData			*data_;
	NSImage					*image_;
	
	data_ = [NSMutableData data];
	op_ = [NSPrintOperation PDFOperationWithView : self
									  insideRect : rect
										  toData : data_];
	[op_ setShowPanels : NO];
	
	[op_ runOperation];
*/
	NSImage			*image_;
	NSData			*data_;
	
	data_ = [self dataWithPDFInsideRect : rect];
	image_ = [[NSImage alloc] initWithData : data_];
	return [image_ autorelease];
}
@end