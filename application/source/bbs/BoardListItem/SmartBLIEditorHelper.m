#import "SmartBLIEditorHelper.h"

//rootHelperを始点とする双方向リンクドリンストを構成する。
//rootHelperは特別扱いされ、ビューを表示しない。
//
//	IBOutlet NSPopUpButton *allOrAnyPopUp;
//	IBOutlet NSScrollView *container;
//	IBOutlet NSButton *includeFallInDATCheck;
//	IBOutlet NSTextField *nameField;
//はrootHelperにのみ存在し、(SmartBoardListItemEditor.nib内で接続）
//	IBOutlet id expressionView;
//	IBOutlet id numberView;
//	IBOutlet id dateView;
//はrootHelper以外にのみ存在する。(SmartBLIEditorComponents.nib内で接続)
//
//rootHelperはSmartBoardListItemEditor.nib内でインスタンス化され、
//nibがロードされると、最初のhelperを生成する。
//
//	containerはNSScrollViewであり、そのdocumentViewは上下がひくり返ったFlippedViewである。
//	FilppedView内にColorBackgroundViewが条件数分配置されている。
//
//	---NSScrollView----------------------
//	| ---FlippedView------------------- |
//	| | ---ColorBackgroundView------- | |
//	| | |                           | | |
//	| | |                           | | |
//	| | ----------------------------- | |
//	| | ---ColorBackgroundView------- | |
//	| | |                           | | |
//	| | |                           | | |
//	| | ----------------------------- | |
//	| --------------------------------| |
//	-------------------------------------
//

typedef enum UIItemTags {
	criterionPopUpTag = 100,
	stringExpressionFieldTag = 200,
	stringQualifierPopUpTag = 300,
	removeCriterionButtonTag = 400,
	addCriterionButtonTag = 500,
	
	dateExpressionFieldTag = 600,
	dateQualifierPopUpTag = 700,
	dateExpression2FieldTag = 800,
	dateExpressionToFieldTag = 801,
	
	numberExpressionFieldTag = 900,
	numberQualifierPopUpTag = 1000,
	numberExpression2FieldTag = 1100,
	numberExpressionToFieldTag = 1101,
} UIItemTags;

typedef enum ExpressionTypes {
	stringExpressionType,
	dateExpressionType,
	dateExpressionRangeType,
	numberExpressionType,
	namberExpressionRangeType,
} ExpressionTypes;

typedef enum CriterionMenuItemTags {
	boardNameItemTag = 1,
	threadNameItemTag,
	numberOfResponseItemTag,
	numberOfReadItemTag,
	numberOfUnreadItemTag,
	dateOfThreadCreateItemTag,
	dateOfModifierItemTag,
	dateOfLastWritenItemTag,
} CriterionMenuItemTags;

typedef enum QualifierMenuItemTags {
	containsQualifierItemTag = 1,
	notContainsQualifierItemTag,
	exactQualifierItemTag,
	notExactQualifierItemTag,
	beginsWithQualifierItemTag,
	endsWithQualifierItemTag,
	isEqualQualifierItemTag = 7,
	notEqualQualifierItemTag,
	largerThanQualifierItemTag,
	smallerThanQualifierItemTag,
	rangeQualifierItemTag,
} QualifierMenuItemTags;

const float kViewPadding = 2.0;

@interface SmartBLIEditorHelper(Private)
- (void)loadComponent;

- (void)insertHelper:(SmartBLIEditorHelper *)newHlper after:(SmartBLIEditorHelper *)helper;
- (void)removeHelper:(SmartBLIEditorHelper *)helper;
- (SmartBLIEditorHelper *)nextHelper;
- (SmartBLIEditorHelper *)previousHelper;
- (SmartBLIEditorHelper *)rootHelper;
- (NSScrollView *)container;
- (ColorBackgroundView *)conditionView;

- (void)relocateConditionView;

- (void)incrementContainerHeight;
- (void)decrementContainerHeight;
- (void)addConditionView;
- (void)removeConditionView;
@end

@interface SmartBLIEditorHelper(ViewAccessor)
- (ExpressionTypes) currentExpressionType;
- (void)buildForExpressionType:(ExpressionTypes)type;
- (void)validateUIItem;
- (id)uiItemForTag:(UIItemTags)tag;
@end

@interface FlippedView : NSView
@end
@interface ColorBackgroundView : NSView
{
	NSColor *color;
}
- (void)setColor:(NSColor *)color;
- (NSColor *)color;
@end

@implementation SmartBLIEditorHelper

NSColor *nextColor(NSColor *inColor)
{
	if(!inColor || [inColor isEqual:[NSColor whiteColor]]) {
		return  [NSColor colorWithCalibratedRed:238 / 255.0
										  green:246 / 255.0
										   blue:255 / 255.0
										  alpha:1];
	}
	
	return [NSColor whiteColor];
}

- (void)awakeFromNib
{
	// containerが存在するのは rootHelper のみ。
	if(container) {
		FlippedView *d;
		d = [[[FlippedView alloc] initWithFrame:[container documentVisibleRect]] autorelease];
		[container setDocumentView:d];
		[self addCriterion:self];
	}
}

- (IBAction)addCriterion:(id)sender
{
	id newHelper;
	
	newHelper = [[[[self class] alloc] init] autorelease];
	[newHelper loadComponent];
	[self insertHelper:newHelper after:self];
	[newHelper addConditionView];
}
- (IBAction)removeCriterion:(id)sender
{
	[self removeConditionView];
}
- (IBAction)changeCriterionPop:(id)sender
{	
	[self buildForExpressionType:[self currentExpressionType]];
}

@end

@implementation SmartBLIEditorHelper(Private)
- (void)loadComponent
{
	if(!expressionView) {
		[NSBundle loadNibNamed:@"SmartBLIEditorComponents"
						 owner:self];
	}
}

- (void)insertHelper:(SmartBLIEditorHelper *)newHelper after:(SmartBLIEditorHelper *)helper
{
	newHelper->previousHelper = helper;
	newHelper->nextHelper = helper->nextHelper;
	helper->nextHelper = [newHelper retain];
	if(newHelper->nextHelper) {
		newHelper->nextHelper->previousHelper = newHelper;
	}
}
- (void)removeHelper:(SmartBLIEditorHelper *)helper
{
	helper->previousHelper->nextHelper = helper->nextHelper;
	if(helper->nextHelper) {
		helper->nextHelper->previousHelper = helper->previousHelper;
	}
	[helper autorelease];
}
- (SmartBLIEditorHelper *)nextHelper
{
	return nextHelper;
}
- (SmartBLIEditorHelper *)previousHelper
{
	if([previousHelper isEqual:[self rootHelper]]) return nil;
	
	return previousHelper;
}
- (SmartBLIEditorHelper *)rootHelper
{
	SmartBLIEditorHelper *prev, *curr = self;
	
	while(prev = curr->previousHelper) curr = prev;
	
	return curr;
}

- (NSScrollView *)container
{
	id result = [self rootHelper]->container;
	
	if(!result) {
		NSLog(@"HHHHHHHHHHHHHHH");
	}
	
	return result;
}
- (ColorBackgroundView *)conditionView
{
	return expressionView;
}

- (void)relocateConditionView
{
	id prev = [self previousHelper];
	if(!prev) {
		[expressionView setFrameOrigin:NSZeroPoint];
		[expressionView setColor:nextColor(nil)];
		
		[[self nextHelper] relocateConditionView];
		
		return;
	}
	
	id prevView = [prev conditionView];
	NSRect prevViewFrame = [prevView frame];
	NSRect frame;
	NSPoint origin;
	
	frame = [expressionView frame];
	origin = frame.origin;
	origin.y = prevViewFrame.origin.y + frame.size.height;
	[expressionView setFrameOrigin:origin];
	[expressionView setColor:nextColor([prevView color])];
	
	[[self nextHelper] relocateConditionView];
}

- (void)incrementContainerHeight
{
	id w = [[self container] window];
	id d = [[self container] documentView];
	NSRect wFrame = [w frame];
	NSRect dFrame = [d frame];
	
	wFrame.size.height += [expressionView frame].size.height;
	wFrame.origin.y -= [expressionView frame].size.height;
	
	dFrame.size.height += [expressionView frame].size.height;
	[d setFrame:dFrame];
	
	[w setFrame:wFrame display:YES animate:YES];
}
- (void)decrementContainerHeight
{
	id w = [[self container] window];
	id d = [[self container] documentView];
	NSRect wFrame = [w frame];
	NSRect dFrame = [d frame];
	
	wFrame.size.height -= [expressionView frame].size.height;
	wFrame.origin.y += [expressionView frame].size.height;
	
	dFrame.size.height -= [expressionView frame].size.height;
	[d setFrame:dFrame];
	
	[w setFrame:wFrame display:YES animate:YES];
}

- (void)addConditionView
{
	id prev = [self previousHelper];
	
	if(prev) {		
		[[[self container] documentView] addSubview:expressionView];
		[self relocateConditionView];
		
		[self incrementContainerHeight];
	} else {
		[expressionView setColor:nextColor(nil)];
		[[[self container] documentView] addSubview:expressionView];
		[self relocateConditionView];
	}
	
	[[self rootHelper] validateUIItem];
}
- (void)removeConditionView
{
	if(![self previousHelper] && !nextHelper) {
		NSBeep();
		return;
	}
	
	id temp = previousHelper;
	
	[self decrementContainerHeight];
	[expressionView removeFromSuperview];
	
	[self removeHelper:self];
	[temp relocateConditionView];
	
	[[temp rootHelper] validateUIItem];
}
@end

@implementation SmartBLIEditorHelper(ViewAccessor)
- (ExpressionTypes) currentExpressionType
{
	ExpressionTypes type = -1;
	
	CriterionMenuItemTags popupTag = [[[self uiItemForTag:criterionPopUpTag] selectedItem] tag];
	QualifierMenuItemTags qualifierTag;
	BOOL isDateRange = NO;
	BOOL isNumberRange = NO;
	
	if(popupTag == boardNameItemTag || popupTag == threadNameItemTag) return stringExpressionType;
	
	qualifierTag = [[[self uiItemForTag:dateQualifierPopUpTag] selectedItem] tag];
	if(qualifierTag == rangeQualifierItemTag) isDateRange = YES;
	qualifierTag = [[[self uiItemForTag:numberQualifierPopUpTag] selectedItem] tag];
	if(qualifierTag == rangeQualifierItemTag) isNumberRange = YES;
	
	switch(popupTag) {
		case numberOfResponseItemTag:
		case numberOfReadItemTag:
		case numberOfUnreadItemTag:
			if(isNumberRange) {
				type = namberExpressionRangeType;
			} else {
				type = numberExpressionType;
			}
			break;
		case dateOfThreadCreateItemTag:
		case dateOfModifierItemTag:
		case dateOfLastWritenItemTag:
			if(isDateRange) {
				type = dateExpressionRangeType;
			} else {
				type = dateExpressionType;
			}
	}
	return type;
}

void moveSubviewToSuperview(NSView *subview, NSView *superview)
{
	if(!subview || !superview) return;
	
	if([superview isEqual:[subview superview]]) return;
	
	[subview retain];
	[subview removeFromSuperview];
	[superview addSubview:subview];
	[subview release];
}

void moveViewLeftSideViewOnSuperView( NSView *target, NSView *leftSideView, NSView *superview)
{
	NSRect frame;
	NSPoint origin;
	
	[[target superview] setNeedsDisplayInRect:[target frame]];
	
	frame = [leftSideView frame];
	origin.x = NSMaxX(frame) + kViewPadding;
	origin.y = [target frame].origin.y;
	[target setFrameOrigin:origin];
	
	moveSubviewToSuperview(target, superview);
	
	[[target superview] setNeedsDisplayInRect:[target frame]];
}

- (void)buildForStringExpression
{
	// 不要な要素を移動。
	moveSubviewToSuperview([self uiItemForTag:dateExpressionFieldTag], dateView);
	moveSubviewToSuperview([self uiItemForTag:dateQualifierPopUpTag], dateView);
	moveSubviewToSuperview([self uiItemForTag:dateExpression2FieldTag], dateView);
	moveSubviewToSuperview([self uiItemForTag:dateExpressionToFieldTag], dateView);
	
	moveSubviewToSuperview([self uiItemForTag:numberExpressionFieldTag], numberView);
	moveSubviewToSuperview([self uiItemForTag:numberQualifierPopUpTag], numberView);
	moveSubviewToSuperview([self uiItemForTag:numberExpression2FieldTag], numberView);
	moveSubviewToSuperview([self uiItemForTag:numberExpressionToFieldTag], numberView);
	
	// 必要な要素を表示。
	[[self uiItemForTag:stringExpressionFieldTag] setHidden:NO];
	[[self uiItemForTag:stringQualifierPopUpTag] setHidden:NO];
}
- (void)buildForDateExpressionIsRange:(BOOL)isRange
{
	// 不要な要素を移動。
	if(!isRange) {
		moveSubviewToSuperview([self uiItemForTag:dateExpression2FieldTag], dateView);
		moveSubviewToSuperview([self uiItemForTag:dateExpressionToFieldTag], dateView);
	}
	
	moveSubviewToSuperview([self uiItemForTag:numberExpressionFieldTag], numberView);
	moveSubviewToSuperview([self uiItemForTag:numberQualifierPopUpTag], numberView);
	moveSubviewToSuperview([self uiItemForTag:numberExpression2FieldTag], numberView);
	moveSubviewToSuperview([self uiItemForTag:numberExpressionToFieldTag], numberView);
	
	// 不要な要素を隠す。
	[[self uiItemForTag:stringExpressionFieldTag] setHidden:YES];
	[[self uiItemForTag:stringQualifierPopUpTag] setHidden:YES];
	
	// 必要な要素を再配置。
	NSView *leftSideView;
	NSView *targetView;
	
	leftSideView = [self uiItemForTag:criterionPopUpTag];
	targetView = [self uiItemForTag:dateExpressionFieldTag];
	moveViewLeftSideViewOnSuperView(targetView, leftSideView, expressionView);
	
	if(isRange) {
		leftSideView = targetView;
		targetView = [self uiItemForTag:dateExpressionToFieldTag];
		moveViewLeftSideViewOnSuperView(targetView, leftSideView, expressionView);
		
		leftSideView = targetView;
		targetView = [self uiItemForTag:dateExpression2FieldTag];
		moveViewLeftSideViewOnSuperView(targetView, leftSideView, expressionView);
	}
	
	leftSideView = targetView;
	targetView = [self uiItemForTag:dateQualifierPopUpTag];
	moveViewLeftSideViewOnSuperView(targetView, leftSideView, expressionView);
	
}
- (void)buildForNumberExpressionIsRange:(BOOL)isRange
{
	// 不要な要素を移動。
	moveSubviewToSuperview([self uiItemForTag:dateExpressionFieldTag], dateView);
	moveSubviewToSuperview([self uiItemForTag:dateQualifierPopUpTag], dateView);
	moveSubviewToSuperview([self uiItemForTag:dateExpression2FieldTag], dateView);
	moveSubviewToSuperview([self uiItemForTag:dateExpressionToFieldTag], dateView);
	
	if(!isRange) {
		moveSubviewToSuperview([self uiItemForTag:numberExpression2FieldTag], numberView);
		moveSubviewToSuperview([self uiItemForTag:numberExpressionToFieldTag], numberView);
	}
	// 不要な要素を隠す。
	[[self uiItemForTag:stringExpressionFieldTag] setHidden:YES];
	[[self uiItemForTag:stringQualifierPopUpTag] setHidden:YES];
	
	// 必要な要素を再配置。
	NSView *leftSideView;
	NSView *targetView;
	
	leftSideView = [self uiItemForTag:criterionPopUpTag];
	targetView = [self uiItemForTag:numberExpressionFieldTag];
	moveViewLeftSideViewOnSuperView(targetView, leftSideView, expressionView);
	
	if(isRange) {
		leftSideView = targetView;
		targetView = [self uiItemForTag:numberExpressionToFieldTag];
		moveViewLeftSideViewOnSuperView(targetView, leftSideView, expressionView);
		
		leftSideView = targetView;
		targetView = [self uiItemForTag:numberExpression2FieldTag];
		moveViewLeftSideViewOnSuperView(targetView, leftSideView, expressionView);
	}
	
	leftSideView = targetView;
	targetView = [self uiItemForTag:numberQualifierPopUpTag];
	moveViewLeftSideViewOnSuperView(targetView, leftSideView, expressionView);
}
- (void)buildForExpressionType:(ExpressionTypes)type
{
	
	switch(type) {
		case stringExpressionType:
			[self buildForStringExpression];
			break;
		case dateExpressionType:
			[self buildForDateExpressionIsRange:NO];
			break;
		case dateExpressionRangeType:
			[self buildForDateExpressionIsRange:YES];
			break;
		case numberExpressionType:
			[self buildForNumberExpressionIsRange:NO];
			break;
		case namberExpressionRangeType:
			[self buildForNumberExpressionIsRange:YES];
			break;
	}
}
- (void)validateUIItem
{
	id item;
	
	if(![self previousHelper] && !nextHelper) {
		item = [self uiItemForTag:removeCriterionButtonTag];
		[item setEnabled:NO];
	} else {
		item = [self uiItemForTag:removeCriterionButtonTag];
		[item setEnabled:YES];
	}
	
	if(nextHelper) {
		[nextHelper validateUIItem];
	}
}
- (id)uiItemForTag:(UIItemTags)tag
{
	id containerView = nil;
	NSEnumerator *subviewsEnum;
	id subview;
	
	switch(tag) {
		case criterionPopUpTag:
		case stringExpressionFieldTag:
		case stringQualifierPopUpTag:
		case removeCriterionButtonTag:
		case addCriterionButtonTag:
			containerView = expressionView;
			break;
		case dateExpressionFieldTag:
		case dateQualifierPopUpTag:
		case dateExpression2FieldTag:
		case dateExpressionToFieldTag:
			containerView = dateView;
			break;
		case numberExpressionFieldTag:
		case numberQualifierPopUpTag:
		case numberExpression2FieldTag:
		case numberExpressionToFieldTag:
			containerView = numberView;
			break;
	}
	
	if(!containerView) return nil;
	
	subviewsEnum = [[containerView subviews] objectEnumerator];
	while((subview = [subviewsEnum nextObject])) {
		if(tag == [subview tag]) return subview;
	}
	// 無ければ移動されている可能性あり
	subviewsEnum = [[expressionView subviews] objectEnumerator];
	while((subview = [subviewsEnum nextObject])) {
		if(tag == [subview tag]) return subview;
	}
	
	return nil;
}
	
@end

@implementation FlippedView
- (BOOL)isFlipped
{
	return YES;
}
@end
@implementation ColorBackgroundView
- (void)dealloc
{
	[color release];
	[super dealloc];
}
- (void)drawRect:(NSRect)rect
{
	if(color) {
		[NSGraphicsContext saveGraphicsState];
		[color set];
		NSRectFill(rect);
		[NSGraphicsContext restoreGraphicsState];
	}
	
	[super drawRect:rect];
}
- (void)setColor:(NSColor *)inColor
{
	id temp = color;
	color = [inColor retain];
	[temp release];
	
	[self setNeedsDisplay:YES];
}
- (NSColor *)color
{
	return color;
}
@end
