//
//  SmartCondition.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/12/27.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DatabaseManager.h"


@protocol SmartCondition <NSCoding>
- (NSString *) conditionString;

// description method must be return same as conditionString method's returns.
- (NSString *)description;
@end

typedef enum _SCOperation
{
	SCUnknownOperation = 0,
	
	SCContaionsOperation,
	SCNotContainsOperation,
	SCExactOperation,
	SCNotExactOperation,
	SCBeginsWithOperation,
	SCEndsWithOperation,
	
	SCEqualOperation,
	SCNotEqualOperation,
	SCLargerOperation,
	SCSmallerOperation,
	SCRangeOperation,
} SCOperation;

@interface SmartCondition : NSObject <SmartCondition>
{
	@protected
	id mTarget;
	SCOperation mOperation;
	id mValue1;
	id mValue2;
}

+ (id) conditionWithTarget : (NSString *)target operation : (SCOperation)operation value : (id)value;
+ (id) conditionWithTarget : (NSString *)target operation : (SCOperation)operation value : (id)value1 value : (id) value2;

- (id) initWithTarget : (NSString *)target operation : (SCOperation)operation value : (id)value;
- (id) initWithTarget : (NSString *)target operation : (SCOperation)operation value : (id)value1 value : (id) value2;

- (NSString *) conditionString;
@end

@interface RelativeDateLiveCondition : SmartCondition <SmartCondition>
{
	id mAbsoluteDate1;
	id mAbsoluteDate2;
}
- (void)update;
@end


typedef enum _SCCOperation
{
	SCCUnionOperation,
	SCCIntersectionOperation,
} SCCOperation;

@interface SmartConditionComposit : NSObject <SmartCondition>
{
	SCCOperation mOperation;
	id mConditions;
}

+ (id)unionCompositWithArray : (NSArray *)conditions;
+ (id)unionCompositWithConditions : (id)firstCondition, ...;
+ (id)intersectionCompositWithArray : (NSArray *)conditions;
+ (id)intersectionCompositWithConditions : (id)firstCondition, ...;

	// primitive method.
- (id)initCompositWithOperation:(SCCOperation)ope conditions:(NSArray *)conditions;

- (id)initUnionCompositWithArray : (NSArray *)conditions;
- (id)initUnionCompositWithConditions : (id)firstCondition, ...;
- (id)initIntersectionCompositWithArray : (NSArray *)conditions;
- (id)initIntersectionCompositWithConditions : (id)firstCondition, ...;

- (NSString *) conditionString;

- (NSArray *)conditions;
- (SCCOperation)operation;
@end
