#import "SmartBLIEditorHelper.h"

#import "SmartCondition.h"

#import "BSDatePicker.h"

//rootHelperを始点とする双方向リンクドリンストを構成する。
//rootHelperは特別扱いされ、ビューを表示しない。
//
//	IBOutlet NSPopUpButton *allOrAnyPopUp;
//	IBOutlet NSScrollView *container;
//	IBOutlet NSButton *includeFallInDATCheck;
//	IBOutlet NSButton *excludeAdThreadCheck;
//	IBOutlet NSTextField *nameField;
//はrootHelperにのみ存在し、(SmartBoardListItemEditor.nib内で接続）
//	IBOutlet id expressionView;
//	IBOutlet id numberView;
//	IBOutlet id dateView;
//はrootHelper以外にのみ存在する。(SmartBLIEditorComponents.nib内で接続)
//
//rootHelperはSmartBoardListItemEditor.nib内でインスタンス化されると最初のhelperを生成する。
//
//	containerはNSScrollViewであり、そのdocumentViewは上下がひくり返ったFlippedViewである。
//	FlppedView内にColorBackgroundViewが条件数分配置されている。
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
	daysExpressionFieldTag = 900,
	daysUnitPopUpTag = 1000,
	daysExpressionAgoFieldTag = 1100,
	daysExpressionField2Tag = 1200,
	daysExpressionToFieldTag = 1201,
	
	numberExpressionFieldTag = 1300,
	numberQualifierPopUpTag = 1400,
	numberExpression2FieldTag = 1500,
	numberExpressionToFieldTag = 1501,
} UIItemTags;

typedef enum CriterionTypes {
	unkownCriterionType,
	stringCriterionType,
	dateCriterionType,
	namberCriterionType,
} CriterionTypes;

typedef enum ExpressionTypes {
	stringExpressionType,
	dateExpressionType,
	dateExpressionRangeType,
	daysExpressionType,
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
	
	daysDateItemExtension = 1000,
	daysTodayQualifierItemTag = daysDateItemExtension + 0,
	daysYesterdayQualifierItemTag = daysDateItemExtension + 1,
	daysThisWeekQualifierItemTag = daysDateItemExtension + 7,
	daysLastWeekQualifierItemTag = daysDateItemExtension + 14,
	
	daysItemExtension = 2000,
	daysIsEqualQualifierItemTag = daysItemExtension + isEqualQualifierItemTag,
	daysLargerThanQualifierItemTaag = daysItemExtension + largerThanQualifierItemTag,
	daysSmallerThanQualifierItemTag = daysItemExtension + smallerThanQualifierItemTag,
	daysRangeQualifierItemTag = daysItemExtension + rangeQualifierItemTag,
	
	dateItemExtension = 3000,
	dateIsEqualQualifierItemTag = dateItemExtension + isEqualQualifierItemTag,
	dateNotEqualQualifierItemTag = dateItemExtension + notEqualQualifierItemTag,
	dateLargerThanQualifierItemTaag = dateItemExtension + largerThanQualifierItemTag,
	dateSmallerThanQualifierItemTag = dateItemExtension + smallerThanQualifierItemTag,
	dateRangeQualifierItemTag = dateItemExtension + rangeQualifierItemTag,
	
	lastExtensionsLabel = 4000,
} QualifierMenuItemTags;

#pragma mark## Constants ##
const float kViewPadding = 2.0;
const float kMostLeftViewsOriginX = 10.0;

#pragma mark## Static Variables ##
static NSString *SmartBLIEditorComponentsNibName = @"SmartBLIEditorComponents";

static NSString *CriteriaSpecificationsPlist = @"CriteriaSpecifications.plist";
static NSString *CriteriaSpecificationsCriteriaKey = @"criteria";
static NSString		*CriteriaNameKey = @"name";
static NSString		*CriteriaTypeKey = @"type";
static NSString *CriteriaSpecificationsOrdersKey = @"orders";

#pragma mark## Class Variables ##
static NSDictionary *sCriteriaSpecifications = nil;

@interface SmartBLIEditorHelper(Private)
- (void)loadComponent;

- (void)insertHelper:(SmartBLIEditorHelper *)newHlper after:(SmartBLIEditorHelper *)helper;
- (void)addHelper:(SmartBLIEditorHelper *)newHlper;
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
- (void)builExpressionViews;
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

+ (void)initialize
{
	static BOOL isFirst = YES;
	//	@synchronized(self) {
	if(isFirst) {
		isFirst = NO;
		
		if(!sCriteriaSpecifications) {
			NSString *path;
			path = [[NSBundle applicationSpecificBundle] pathForResourceWithName:CriteriaSpecificationsPlist];
			if(!path) {
				path = [[NSBundle mainBundle] pathForResourceWithName:CriteriaSpecificationsPlist];
			}
			if(path) {
				sCriteriaSpecifications = [[NSDictionary dictionaryWithContentsOfFile:path] retain];
			}
			UTILAssertNotNil(sCriteriaSpecifications);
		}
	}
	//	}
}

- (void)dealloc
{
	if(previousHelper == nil && nextHelper != nil) {
		nextHelper->previousHelper = nil;
		[nextHelper release];
		nextHelper = nil;
	}
	
	[expressionView release];
	[numberView release];
	[dateView release];
	
	[super dealloc];
}

- (void)awakeFromNib
{
	// containerが存在するのは rootHelper のみ。
	if(container) {
		FlippedView *d;
		d = [[[FlippedView alloc] initWithFrame:[container documentVisibleRect]] autorelease];
		[container setDocumentView:d];
		[self addCriterion:self];
	} else {
		id item;
		
		item = [self uiItemForTag:criterionPopUpTag];
		item = [item menu];
		[item setDelegate:item];
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
	[self builExpressionViews];
}

@end

@implementation SmartBLIEditorHelper(Private)
static inline NSColor *nextColor(NSColor *inColor)
{
	if(!inColor || [inColor isEqual:[NSColor whiteColor]]) {
		return  [NSColor colorWithCalibratedRed:238 / 255.0
										  green:246 / 255.0
										   blue:255 / 255.0
										  alpha:1];
	}
	
	return [NSColor whiteColor];
}
- (void)loadComponent
{
	if(!expressionView) {
		[NSBundle loadNibNamed:SmartBLIEditorComponentsNibName
						 owner:self];
		
		[[self uiItemForTag:dateExpressionFieldTag] setDate:[NSCalendarDate calendarDate]];
		[[self uiItemForTag:dateExpression2FieldTag] setDate:[NSCalendarDate calendarDate]];
		
		[self builExpressionViews];
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
- (void)addHelper:(SmartBLIEditorHelper *)newHelper
{
	SmartBLIEditorHelper *lastHepler = self;
	
	while(lastHepler->nextHelper) lastHepler = lastHepler->nextHelper;
	
	newHelper->previousHelper = lastHepler;
	newHelper->nextHelper = lastHepler->nextHelper;
	lastHepler->nextHelper = [newHelper retain];
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
	helper->nextHelper = helper->previousHelper = nil;
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
	SmartBLIEditorHelper *root;
	id result = nil;
	
	if(!(root = [self rootHelper])
	   || !(result = root->container) ) {
		NSLog(@"You create SmartBLIeditor in abnormal way.");
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
	NSPoint origin;
	NSColor *color;
	
	if(!prev) {
		origin = NSZeroPoint;
		color = nextColor(nil);
	} else {
		NSRect frame;
		id prevView = [prev conditionView];
		
		frame = [expressionView frame];
		origin = frame.origin;
		origin.y = [prevView frame].origin.y + frame.size.height;
		color = nextColor([prevView color]);
	}
	
	[expressionView setFrameOrigin:origin];
	[expressionView setColor:color];
	
	[[self nextHelper] relocateConditionView];
}

- (void)incrementContainerHeight
{
	NSWindow *w = [[self container] window];
	NSView *d = [[self container] documentView];
	ColorBackgroundView *c = [self conditionView];
	ColorBackgroundView *pv = [[self previousHelper] conditionView];
	NSRect wFrame = [w frame];
	NSRect dFrame = [d frame];
	NSPoint origin;
	float deltaY = 10;
	float incHeight;
	
	if(![self previousHelper]) return;
	
	origin = [pv frame].origin;
	
	incHeight = [c frame].size.height;
	
	origin.y += deltaY;
	[c setFrameOrigin:origin];
	[[self nextHelper] relocateConditionView];
	dFrame.size.height += deltaY;
	[d setFrame:dFrame];
	wFrame.size.height += deltaY;
	wFrame.origin.y -= deltaY;
	[w setFrame:wFrame display:YES];
	
	deltaY = incHeight - deltaY;
	
	origin.y += deltaY;
	[c setFrameOrigin:origin];
	[[self nextHelper] relocateConditionView];
	dFrame.size.height += deltaY;
	[d setFrame:dFrame];
	wFrame.size.height += deltaY;
	wFrame.origin.y -= deltaY;
	[w setFrame:wFrame display:YES];
}
- (void)decrementContainerHeight
{
	NSWindow *w = [[self container] window];
	NSView *d = [[self container] documentView];
	ColorBackgroundView *c = [self conditionView];
	ColorBackgroundView *pv = [[self previousHelper] conditionView];
	NSRect wFrame = [w frame];
	NSRect dFrame = [d frame];
	NSPoint origin;
	float deltaY = -10;
	float incHeight;
	
	incHeight = -[c frame].size.height;
	
	if(pv) {
		origin = [pv frame].origin;
		origin.y -= incHeight;
	} else {
		origin = NSZeroPoint;
	}
	
	origin.y += deltaY;
	[c setFrameOrigin:origin];
	[[self nextHelper] relocateConditionView];
	dFrame.size.height += deltaY;
	[d setFrame:dFrame];
	wFrame.size.height += deltaY;
	wFrame.origin.y -= deltaY;
	[w setFrame:wFrame display:YES];
	
	deltaY = incHeight - deltaY;
	
	origin.y += deltaY;
	[c setFrameOrigin:origin];
	[[self nextHelper] relocateConditionView];
	dFrame.size.height += deltaY;
	[d setFrame:dFrame];
	wFrame.size.height += deltaY;
	wFrame.origin.y -= deltaY;
	[w setFrame:wFrame display:YES];
}

- (void)addConditionView
{
	id prev = [self previousHelper];
	
	if(prev) {
		[expressionView setColor:nextColor([[prev conditionView] color])];
		[[[self container] documentView] addSubview:expressionView
										 positioned:NSWindowBelow
										 relativeTo:[prev conditionView]];
		
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
	SmartBLIEditorHelper* root = [self rootHelper];
	
//	if(!(temp = [self previousHelper]) && !nextHelper) {
//		NSBeep();
//		return;
//	}
//	temp = [self previousHelper];
//	temp = temp ? temp : nextHelper;
	
	[self decrementContainerHeight];
	[expressionView removeFromSuperview];
	
	[self removeHelper:self];
	[root relocateConditionView];
	
	[root validateUIItem];
}
@end

@implementation SmartBLIEditorHelper(ViewAccessor)

static inline void moveSubviewToSuperview(NSView *subview, NSView *superview)
{
	if(!subview || !superview) return;
	
	if([superview isEqual:[subview superview]]) return;
	
	[subview retain];
	[subview removeFromSuperview];
	[superview addSubview:subview];
	[subview release];
}

static inline void moveViewLeftSideViewOnSuperView( NSView *target, NSView *leftSideView, NSView *superview)
{
	NSRect frame;
	NSPoint origin;
		
	if(leftSideView) {
		frame = [leftSideView frame];
		origin.x = NSMaxX(frame) + kViewPadding;
	} else {
		origin.x = kMostLeftViewsOriginX;
	}
	origin.y = [target frame].origin.y;
	[target setFrameOrigin:origin];
	
	moveSubviewToSuperview(target, superview);
	if([target isHidden]) {
		[target setHidden:NO];
	}
}
- (CriterionTypes)currentCriterionType
{
	CriterionTypes result = unkownCriterionType;
	
	int tag = [[[self uiItemForTag:criterionPopUpTag] selectedItem] tag];
	NSString *typesKey = [NSString stringWithFormat:@"%d", tag];
	id criteria;
	NSString *typeString;
	
	criteria = [sCriteriaSpecifications objectForKey:CriteriaSpecificationsCriteriaKey];
	typeString = [[criteria objectForKey:typesKey] objectForKey:CriteriaTypeKey];
	
	if([typeString isEqualTo:@"string type"]) {
		result = stringCriterionType;
	} else if([typeString isEqualTo:@"number type"]) {
		result = namberCriterionType;
	} else if([typeString isEqualTo:@"date type"]) {
		result = dateCriterionType;
	}
	
	if(result == unkownCriterionType) {
		NSLog(@"Broken %@.nib file.", SmartBLIEditorComponentsNibName);
	}
	
	return result;
	
}
- (QualifierMenuItemTags)currentQualifierItemTag
{
	int qulifierPopupTag = -1;
	id popup;
	
	switch([self currentCriterionType]) {
		case stringCriterionType:
			qulifierPopupTag = stringQualifierPopUpTag;
			break;
		case dateCriterionType:
			qulifierPopupTag = dateQualifierPopUpTag;
			break;
		case namberCriterionType:
			qulifierPopupTag = numberQualifierPopUpTag;
			break;
		case unkownCriterionType:
			qulifierPopupTag = -1;
			break;
	}
	
	popup = [self uiItemForTag:qulifierPopupTag];
	if(!popup) {
		return -1;
	}
	
	return [[popup selectedItem] tag];
}	

- (NSView *)uiItemFromName:(NSString *)string
{
	int itemTag = -1;
	CriterionTypes currentCriterionType = [self currentCriterionType];
	
	if(!string || ![string length]) return nil;
	if(currentCriterionType  == unkownCriterionType) return nil;
	
	if([string hasSuffix:@"popup"]) {
		if([string hasPrefix:@"criterion"]) {
			itemTag = criterionPopUpTag;
		} else if([string hasPrefix:@"qualifier"]) {
			if(currentCriterionType == stringCriterionType) {
				itemTag = stringQualifierPopUpTag;
			} else if(currentCriterionType == dateCriterionType) {
				itemTag = dateQualifierPopUpTag;
			} else if(currentCriterionType == namberCriterionType) {
				itemTag = numberQualifierPopUpTag;
			}
		} else if([string hasPrefix:@"units"]) {
			itemTag = daysUnitPopUpTag;
		}
	} else if([string hasSuffix:@"field"]) {
		if([string hasPrefix:@"expression"]) {
			itemTag = stringExpressionFieldTag;
		} else if([string hasPrefix:@"date"]) {
			itemTag = dateExpressionFieldTag;
		} else if([string hasPrefix:@"beginning date"]) {
			itemTag = dateExpressionFieldTag;
		} else if([string hasPrefix:@"ending date"]) {
			itemTag = dateExpression2FieldTag;
		} else if([string hasPrefix:@"days"]) {
			itemTag = daysExpressionFieldTag;
		} else if([string hasPrefix:@"beginning days"]) {
			itemTag = daysExpressionFieldTag;
		} else if([string hasPrefix:@"ending days"]) {
			itemTag = daysExpressionField2Tag;
		} else if([string hasPrefix:@"number"]) {
			itemTag = numberExpressionFieldTag;
		} else if([string hasPrefix:@"beginning number"]) {
			itemTag = numberExpressionFieldTag;
		} else if([string hasPrefix:@"ending number"]) {
			itemTag = numberExpression2FieldTag;
		}
	} else if([string hasSuffix:@"string"]) {
		if([string hasPrefix:@"to"]) {
			itemTag = dateExpressionToFieldTag;
		} else if([string hasPrefix:@"and"]) {
			if(currentCriterionType == dateCriterionType) {
				itemTag = daysExpressionToFieldTag;
			} else if(currentCriterionType == namberCriterionType) {
				itemTag = numberExpressionToFieldTag;
			}
		}else if([string hasPrefix:@"ago"]) {
			itemTag = daysExpressionAgoFieldTag;
		}
	}
	
	return [self uiItemForTag:itemTag];
}
- (void)hideAllItems
{
	[[self uiItemForTag:criterionPopUpTag] setHidden:YES];
	[[self uiItemForTag:stringExpressionFieldTag] setHidden:YES];
	[[self uiItemForTag:stringQualifierPopUpTag] setHidden:YES];
	
	moveSubviewToSuperview([self uiItemForTag:dateExpressionFieldTag], dateView);
	moveSubviewToSuperview([self uiItemForTag:dateQualifierPopUpTag], dateView);
	moveSubviewToSuperview([self uiItemForTag:dateExpression2FieldTag], dateView);
	moveSubviewToSuperview([self uiItemForTag:dateExpressionToFieldTag], dateView);
	
	moveSubviewToSuperview([self uiItemForTag:daysExpressionFieldTag], dateView);
	moveSubviewToSuperview([self uiItemForTag:daysUnitPopUpTag], dateView);
	moveSubviewToSuperview([self uiItemForTag:daysExpressionAgoFieldTag], dateView);
	moveSubviewToSuperview([self uiItemForTag:daysExpressionField2Tag], dateView);
	moveSubviewToSuperview([self uiItemForTag:daysExpressionToFieldTag], dateView);
	
	moveSubviewToSuperview([self uiItemForTag:numberExpressionFieldTag], numberView);
	moveSubviewToSuperview([self uiItemForTag:numberQualifierPopUpTag], numberView);
	moveSubviewToSuperview([self uiItemForTag:numberExpression2FieldTag], numberView);
	moveSubviewToSuperview([self uiItemForTag:numberExpressionToFieldTag], numberView);
}
- (void)builExpressionViews
{
	QualifierMenuItemTags tag = [self currentQualifierItemTag];
	NSString *typesKey = [NSString stringWithFormat:@"%d", tag];
	id orderDict;
	NSArray *order;
	NSEnumerator *orderEnum;
	NSString *itemName;
	
	NSView *leftSideView = nil;
	NSView *targetView = nil;
	
	orderDict = [sCriteriaSpecifications objectForKey:CriteriaSpecificationsOrdersKey];
	UTILAssertNotNil(orderDict);
	order = [orderDict objectForKey:typesKey];
	UTILAssertNotNil(order);
	
	[self hideAllItems];
	
	orderEnum = [order objectEnumerator];
	while(itemName = [orderEnum nextObject]) {
		targetView = [self uiItemFromName:itemName];
		moveViewLeftSideViewOnSuperView(targetView, leftSideView, expressionView);
		leftSideView = targetView;
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
		case daysExpressionFieldTag:
		case daysUnitPopUpTag:
		case daysExpressionAgoFieldTag:
		case daysExpressionField2Tag:
		case daysExpressionToFieldTag:
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
	if( containerView != expressionView) {
		subviewsEnum = [[expressionView subviews] objectEnumerator];
		while((subview = [subviewsEnum nextObject])) {
			if(tag == [subview tag]) return subview;
		}
	}
	
	return nil;
}

- (BOOL)validateMenuItem:(id <NSMenuItem>)menuItem
{
//	int tag = [menuItem tag];
//	if(tag == dateOfLastWritenItemTag) {
//		id view = [self uiItemForTag:criterionPopUpTag];
//		if( [view indexOfItem:menuItem] != -1) {
//			return NO;
//		}
//	}
	
	return YES;
}
	

@end

@implementation SmartBLIEditorHelper(SmartConditionAccesor)

- (id)value1
{
	id value1 = [NSNull null];
	QualifierMenuItemTags qualifier = [self currentQualifierItemTag];
	id field;
	id strValue;
	
	{
		if(qualifier < isEqualQualifierItemTag) {	// 文字列
			field = [self uiItemForTag:stringExpressionFieldTag];
			strValue = [field stringValue];
			if([strValue length] != 0) {
				value1 = strValue;
			}
		} else if(qualifier < daysItemExtension) {	// 数字
			field = [self uiItemForTag:numberExpressionFieldTag];
			strValue = [field stringValue];
			if([strValue length] != 0) {
				int v = [field intValue];
				value1 = [NSNumber numberWithInt:v];
			}
		} else if(qualifier < dateItemExtension) {	// 相対日付
			field = [self uiItemForTag:daysExpressionFieldTag];
			strValue = [field stringValue];
			if([strValue length] != 0) {
				int v = [field intValue];
				v *= [[[self uiItemForTag:daysUnitPopUpTag] selectedItem] tag];
				value1 = [NSNumber numberWithInt:-1 * v];
			}
		} else if(qualifier < lastExtensionsLabel) { // 絶対日付
			field = [self uiItemForTag:dateExpressionFieldTag];
			strValue = [field stringValue];
			if([strValue length] != 0) {
				NSTimeInterval t = [field epoch];
				value1 = [NSNumber numberWithInt:t];
			}
		} else {
			//
			//
		}
	}
	
	return value1;
}
- (id)value2
{
	id value2 = nil;
	QualifierMenuItemTags qualifier = [self currentQualifierItemTag];
	id field;
	id strValue;
	
	{
		if(qualifier < isEqualQualifierItemTag) {	// 文字列
			//
		}else if(qualifier < daysItemExtension) {	// 数字
			if(qualifier == rangeQualifierItemTag) {
				field = [self uiItemForTag:numberExpression2FieldTag];
				strValue = [field stringValue];
				if([strValue length] != 0) {
					int v = [field intValue];
					value2 = [NSNumber numberWithInt:v];
				} else {
					value2 = [NSNull null];
				}
			}
		} else if(qualifier < dateItemExtension) {	// 相対日付
			if(qualifier == daysRangeQualifierItemTag) {
				field = [self uiItemForTag:daysExpressionField2Tag];
				strValue = [field stringValue];
				if([strValue length] != 0) {
					int v = [field intValue];
					v *= [[[self uiItemForTag:daysUnitPopUpTag] selectedItem] tag];
					value2 = [NSNumber numberWithInt:-1 * v];
				} else {
					value2 = [NSNull null];
				}
			}
		} else if(qualifier < lastExtensionsLabel) { // 絶対日付
			if(qualifier == dateRangeQualifierItemTag) {
				field = [self uiItemForTag:dateExpression2FieldTag];
				strValue = [field stringValue];
				if([strValue length] != 0) {
					NSTimeInterval t = [field epoch];
					value2 = [NSNumber numberWithInt:t];
				} else {
					value2 = [NSNull null];
				}
			}
		} else {
			//
			//
		}
	}
	
	return value2;
}
- (BOOL)isValidAItem
{
	if([self value1] == [NSNull null] || [self value2] == [NSNull null]) {
		return NO;
	}
	
	return YES;
}
- (BOOL)isValid
{
	SmartBLIEditorHelper *helper = [self rootHelper];
	
	while(helper = [helper nextHelper]) {
		if(![helper isValidAItem]) {
			return NO;
		}
	}
	
	return YES;
}
- (SmartCondition *)aCondition
{
	SmartCondition *result;
	
	NSString *criterion;
	id value1, value2 = nil;
	
	SCOperator operator = SCUnknownOperator;
	QualifierMenuItemTags qualifier = [self currentQualifierItemTag];
	
	int tag;
	NSString *typesKey;
	id criteria;
	
	if(self == [self rootHelper]) return nil;
	
	{
		switch(qualifier) {
			case containsQualifierItemTag:
				operator = SCContaionsOperator;
				break;
			case notContainsQualifierItemTag:
				operator = SCNotContainsOperator;
				break;
			case exactQualifierItemTag:
				operator = SCExactOperator;
				break;
			case notExactQualifierItemTag:
				operator = SCNotExactOperator;
				break;
			case beginsWithQualifierItemTag:
				operator = SCBeginsWithOperator;
				break;
			case endsWithQualifierItemTag:
				operator = SCEndsWithOperator;
				break;
			case isEqualQualifierItemTag:
				operator = SCEqualOperator;
				break;
			case notEqualQualifierItemTag:
				operator = SCNotEqualOperator;
				break;
			case largerThanQualifierItemTag:
				operator = SCLargerOperator;
				break;
			case smallerThanQualifierItemTag:
				operator = SCSmallerOperator;
				break;
			case rangeQualifierItemTag:
				operator = SCRangeOperator;
				break;
			case daysTodayQualifierItemTag:
				operator = SCDaysTodayOperator;
				break;
			case daysYesterdayQualifierItemTag:
				operator = SCDaysYesterdayOperator;
				break;
			case daysThisWeekQualifierItemTag:
				operator = SCDaysThisWeekOperator;
				break;
			case daysLastWeekQualifierItemTag:
				operator = SCDaysLastWeekOperator;
				break;
			case daysIsEqualQualifierItemTag:
				operator = SCDaysEqualOperator;
				break;
			case daysLargerThanQualifierItemTaag:
				operator = SCDaysLargerOperator;
				break;
			case daysSmallerThanQualifierItemTag:
				operator = SCDaysSmallerOperator;
				break;
			case daysRangeQualifierItemTag:
				operator = SCDaysRangeOperator;
				break;
			case dateIsEqualQualifierItemTag:
				operator = SCDateEqualOperator;
				break;
			case dateNotEqualQualifierItemTag:
				operator = SCDateNotEqualOperator;
				break;
			case dateLargerThanQualifierItemTaag:
				operator = SCDateLargerOperator;
				break;
			case dateSmallerThanQualifierItemTag:
				operator = SCDateSmallerOperator;
				break;
			case dateRangeQualifierItemTag:
				operator = SCDateRangeOperator;
				break;
			default:
				operator = -1;
				break;
		}
		
		if(operator == -1) {
			return nil;
		}
	}
	
	tag = [[[self uiItemForTag:criterionPopUpTag] selectedItem] tag];
	typesKey = [NSString stringWithFormat:@"%d", tag];
	criteria = [sCriteriaSpecifications objectForKey:CriteriaSpecificationsCriteriaKey];
	criterion = [[criteria objectForKey:typesKey] objectForKey:CriteriaNameKey];
	
	value1 = [self value1];
	value2 = [self value2];
	if(value1 == [NSNull null] || value2 == [NSNull null]) {
		return nil;
	}
	
	{
		//
		if(value2) {
			result = [SmartCondition conditionWithTarget:criterion
												operator:operator
												   value:value1
												   value:value2];
		} else {
			result = [SmartCondition conditionWithTarget:criterion
												operator:operator
												   value:value1];
		}
	}
	
	return result;
}

- (SmartConditionComposit *)compositCondition
{
	NSMutableArray *array;
	SmartBLIEditorHelper *helper;
	SCCOperator ope;
	
	if(self != [self rootHelper]) return nil;
	
	array = [NSMutableArray array];
	helper = self;
	while((helper = [helper nextHelper])) {
		id cond = [helper aCondition];
		if(cond) {
			[array addObject:cond];
		}
	}
	
	ope = [[allOrAnyPopUp selectedItem] tag];
	
	return [[[SmartConditionComposit alloc] initCompositWithOperator:ope
														   conditions:array] autorelease];
}

- (id<SmartCondition>)condition
{
	// TODO ダット落ちと広告スレの条件付加
	
	return [[self rootHelper] compositCondition];
}


#pragma mark-
#pragma mark Edit SmartItem
- (CriterionMenuItemTags)tagFromConditionKey:(NSString *)key
{
	if(!key || ![key isKindOfClass:[NSString class]]) return -1;
	
	if([key isEqualTo:@"boardName"]) {
		return boardNameItemTag;
	} else if([key isEqualTo:@"threadName"]) {
		return threadNameItemTag;
	} else if([key isEqualTo:@"numberOfAll"]) {
		return numberOfResponseItemTag;
	} else if([key isEqualTo:@"numberOfRead"]) {
		return numberOfReadItemTag;
	} else if([key isEqualTo:@"numberOfDifference"]) {
		return numberOfUnreadItemTag;
	} else if([key isEqualTo:@"threadID"]) {
		return dateOfThreadCreateItemTag;
	} else if([key isEqualTo:@"modifiedDate"]) {
		return dateOfModifierItemTag;
	} else if([key isEqualTo:@"LastWrittenDate"]) {
		return dateOfLastWritenItemTag;
	}
	
	return -1;
}
- (UIItemTags)valueFieldTagFromCondition:(SmartCondition *)condition
{		
	if([condition isKindOfClass:[StringCondition class]]) {
		return stringExpressionFieldTag;
	} else if([condition isKindOfClass:[NumberCondition class]]) {
		return numberExpressionFieldTag;
	} else if([condition isKindOfClass:[RelativeDateLiveCondition class]]) {
		return daysExpressionFieldTag;
	} else if([condition isKindOfClass:[AbsoluteDateLiveCondition class]]) {
		return dateExpressionFieldTag;
	} else if([condition isKindOfClass:[DaysCondition class]]) {
		return dateQualifierPopUpTag;
	}
	
	return -1;
}
- (UIItemTags)value2FieldTagFromCondition:(SmartCondition *)condition
{
	if([condition isKindOfClass:[StringCondition class]]) {
		return -1;
	} else if([condition isKindOfClass:[NumberCondition class]]) {
		return numberExpression2FieldTag;
	} else if([condition isKindOfClass:[RelativeDateLiveCondition class]]) {
		return daysExpressionField2Tag;
	} else if([condition isKindOfClass:[AbsoluteDateLiveCondition class]]) {
		return dateExpression2FieldTag;
	} else if([condition isKindOfClass:[DaysCondition class]]) {
		return -1;
	}
	
	return -1;
}
- (QualifierMenuItemTags)qualifierMenuItemTagFromCondition:(SmartCondition *)condition
{
	int result = -1;
	
	switch([condition operator]) {
		case SCContaionsOperator:
			result = containsQualifierItemTag;
			break;
		case SCNotContainsOperator:
			result = notContainsQualifierItemTag;
			break;
		case SCExactOperator:
			result = exactQualifierItemTag;
			break;
		case SCNotExactOperator:
			result = notExactQualifierItemTag;
			break;
		case SCBeginsWithOperator:
			result = beginsWithQualifierItemTag;
			break;
		case SCEndsWithOperator:
			result = endsWithQualifierItemTag;
			break;
		case SCEqualOperator:
			result = isEqualQualifierItemTag;
			break;
		case SCNotEqualOperator:
			result = notEqualQualifierItemTag;
			break;
		case SCLargerOperator:
			result = largerThanQualifierItemTag;
			break;
		case SCSmallerOperator:
			result = smallerThanQualifierItemTag;
			break;
		case SCRangeOperator:
			result = rangeQualifierItemTag;
			break;
		case SCDaysTodayOperator:
			result = daysTodayQualifierItemTag;
			break;
		case SCDaysYesterdayOperator:
			result = daysYesterdayQualifierItemTag;
			break;
		case SCDaysThisWeekOperator:
			result = daysThisWeekQualifierItemTag;
			break;
		case SCDaysLastWeekOperator:
			result = daysLastWeekQualifierItemTag;
			break;
		case SCDaysEqualOperator:
			result = daysIsEqualQualifierItemTag;
			break;
		case SCDaysNotEqualOperator:
			//
			break;
		case SCDaysLargerOperator:
			result = daysLargerThanQualifierItemTaag;
			break;
		case SCDaysSmallerOperator:
			result = daysSmallerThanQualifierItemTag;
			break;
		case SCDaysRangeOperator:
			result = daysRangeQualifierItemTag;
			break;
		case SCDateEqualOperator:
			result = dateIsEqualQualifierItemTag;
			break;
		case SCDateNotEqualOperator:
			result = dateNotEqualQualifierItemTag;
			break;
		case SCDateLargerOperator:
			result = dateLargerThanQualifierItemTaag;
			break;
		case SCDateSmallerOperator:
			result = dateSmallerThanQualifierItemTag;
			break;
		case SCDateRangeOperator:
			result = dateRangeQualifierItemTag;
			break;
		default:
			//
			break;
	}
	
	return result;
}
- (UIItemTags)qualifierPopupTagFromCondition:(SmartCondition *)condition
{
	int result = -1;
	
	switch([condition operator]) {
		case SCContaionsOperator:
		case SCNotContainsOperator:
		case SCExactOperator:
		case SCNotExactOperator:
		case SCBeginsWithOperator:
		case SCEndsWithOperator:
			result = stringQualifierPopUpTag;
			break;
		case SCEqualOperator:
		case SCNotEqualOperator:
		case SCLargerOperator:
		case SCSmallerOperator:
		case SCRangeOperator:
			result = numberQualifierPopUpTag;
			break;
		case SCDaysTodayOperator:
		case SCDaysYesterdayOperator:
		case SCDaysThisWeekOperator:
		case SCDaysLastWeekOperator:
		case SCDaysEqualOperator:
		case SCDaysNotEqualOperator:
		case SCDaysLargerOperator:
		case SCDaysSmallerOperator:
		case SCDaysRangeOperator:
		case SCDateEqualOperator:
		case SCDateNotEqualOperator:
		case SCDateLargerOperator:
		case SCDateSmallerOperator:
		case SCDateRangeOperator:
			result = dateQualifierPopUpTag;
			break;
		default:
			//
			break;
	}
	
	return result;
}
- (BOOL)setRelaviceDateValueFromCondition:(SmartCondition *)condition
{
	NSNumber *v1 = [condition value];
	NSNumber *v2 = [condition value2];
	long value1 = [v1 longValue] * -1;
	long value2 = [v2 longValue] * -1;
	int tag = -1;
	
	const long hourUnit = 3600;
	const long dayUnit = 86400;
	const long weekUnit = 604800;
	const long monthUnit = 2592000;
	
	if(value1 % monthUnit == 0) {
		if(!v2 || value2 % monthUnit == 0) {
			tag = monthUnit;
		}
	} else if(value1 % weekUnit == 0) {
		if(!v2 || value2 % weekUnit) {
			tag = weekUnit;
		}
	} else if(value1 % dayUnit == 0) {
		if(!v2 || value2 % dayUnit == 0) {
			tag = dayUnit;
		}
	} else if(value1 % hourUnit == 0) {
		if(!v2 || value2 % hourUnit == 0) {
			tag = hourUnit;
		}
	}
	
	if(tag == -1) return NO;
	
	id unitPopUp = [self uiItemForTag:daysUnitPopUpTag];
	int index = [unitPopUp indexOfItemWithTag:tag];
	[unitPopUp selectItemAtIndex:index];
	
	id valueCtrl = [self uiItemForTag:daysExpressionFieldTag];
	[valueCtrl setIntValue:value1 / tag];
	
	if(v2) {
		valueCtrl = [self uiItemForTag:daysExpressionField2Tag];
		[valueCtrl setIntValue:value2 / tag];
	}
	
	return YES;
}

- (BOOL)buildAHelperFromSmartCondition:(SmartCondition *)condition
{
	id key, v1, v2 = nil;
	
	if(self == [self rootHelper]) return NO;
	
	if([condition isKindOfClass:[IncludeDatOtiCondition class]]) {
		[[self rootHelper]->includeFallInDATCheck setState:NSOnState];
		return YES;
	}
	if([condition isKindOfClass:[ExcludeAdThreadCondition class]]) {
		[[self rootHelper]->excludeAdThreadCheck setState:NSOnState];
		return YES;
	}
	
	key = [condition key];
	v1 = [condition value];
	if(SCRangeOperator == [condition operator]) {
		v2 = [condition value2];
	}
	
	// key から　CriterionMenu　を選択
	int tag = [self tagFromConditionKey:key];
	if(tag == -1) return NO;
	
	int index = [[self uiItemForTag:criterionPopUpTag] indexOfItemWithTag:tag];
	[[self uiItemForTag:criterionPopUpTag] selectItemAtIndex:index];
	// QualifierMenuItemTags をセット
	tag = [self qualifierMenuItemTagFromCondition:condition];
	if(tag == -1) return NO;
	int popupTag = [self qualifierPopupTagFromCondition:condition];
	if(popupTag == -1) return NO;
	index = [[self uiItemForTag:popupTag] indexOfItemWithTag:tag];
	[[self uiItemForTag:popupTag] selectItemAtIndex:index];
	[self builExpressionViews];
	
	// 値をセット
	int valueCtrlTag;
	id valueCtrl;
	
	if([condition isKindOfClass:[RelativeDateLiveCondition class]]) {
		return [self setRelaviceDateValueFromCondition:condition];
	}
	
	valueCtrlTag = [self valueFieldTagFromCondition:condition];
	if(valueCtrlTag == dateQualifierPopUpTag) {
		return YES;
	}
	valueCtrl = [self uiItemForTag:valueCtrlTag];
	[valueCtrl setObjectValue:v1];
	
	if(!v2) return YES;
	
	valueCtrlTag = [self value2FieldTagFromCondition:condition];
	valueCtrl = [self uiItemForTag:valueCtrlTag];
	[valueCtrl setObjectValue:v2];
	
	return YES;
}

- (BOOL)buildHelpers:(id<SmartCondition>)condition
{
	if([condition isKindOfClass:[SmartCondition class]]) {
		id newHelper;
		
		newHelper = [[[[self class] alloc] init] autorelease];
		[newHelper loadComponent];
		[self addHelper:newHelper];
		[newHelper addConditionView];
		
		return [newHelper buildAHelperFromSmartCondition:condition];
	}
	
	if(![condition isKindOfClass:[SmartConditionComposit class]]) {
		return NO;
	}
	
	NSEnumerator *condsEnum = [[condition conditions] objectEnumerator];
	id cond;
	while(cond = [condsEnum nextObject]) {
		BOOL res = [self buildHelpers:cond];
		if(!res) return NO;
	}
	
	return YES;
}
- (BOOL)buildHelperFromCondition:(id<SmartCondition>)condition
{
	if(self != [self rootHelper]) return NO;
	
	// SmartConditionComposit でなければならない。
	if(![condition isKindOfClass:[SmartConditionComposit class]]) return NO;
	
	// すべて もしくは または
	int tag = [condition operator];
	[allOrAnyPopUp selectItemAtIndex:[allOrAnyPopUp indexOfItemWithTag:tag]];
	
	[includeFallInDATCheck setState:NSOffState];
	[excludeAdThreadCheck setState:NSOffState];
	
	if(![self buildHelpers:condition]) {
		return NO;
	}
	
	[[self nextHelper] removeConditionView];
	
	return YES;
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
