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

- (int)operator;
@end

typedef enum _SCOperator
{
	SCUnknownOperator = 0,
	
	SCContaionsOperator,
	SCNotContainsOperator,
	SCExactOperator,
	SCNotExactOperator,
	SCBeginsWithOperator,
	SCEndsWithOperator,
	
	SCEqualOperator,
	SCNotEqualOperator,
	SCLargerOperator,
	SCSmallerOperator,
	SCRangeOperator,
} SCOperator;

@interface SmartCondition : NSObject <SmartCondition>
{
	@protected
	id mTarget;
	SCOperator mOperator;
	id mValue1;
	id mValue2;
}

+ (id) conditionWithTarget : (NSString *)target operator : (SCOperator)operator value : (id)value;
+ (id) conditionWithTarget : (NSString *)target operator : (SCOperator)operator value : (id)value1 value : (id) value2;

- (id) initWithTarget : (NSString *)target operator : (SCOperator)operator value : (id)value;
- (id) initWithTarget : (NSString *)target operator : (SCOperator)operator value : (id)value1 value : (id) value2;

- (id)key;
- (id)value;
- (id)value2;
- (SCOperator)operator;

- (NSString *) conditionString;
@end

@interface RelativeDateLiveCondition : SmartCondition //<SmartCondition>
@end


typedef enum _SCCOperator
{
	SCCUnionOperator,
	SCCIntersectionOperator,
} SCCOperator;

@interface SmartConditionComposit : NSObject <SmartCondition>
{
	SCCOperator mOperator;
	id mConditions;
}

+ (id)unionCompositWithArray : (NSArray *)conditions;
+ (id)unionCompositWithConditions : (id)firstCondition, ...;
+ (id)intersectionCompositWithArray : (NSArray *)conditions;
+ (id)intersectionCompositWithConditions : (id)firstCondition, ...;

	// primitive method.
- (id)initCompositWithOperator:(SCCOperator)ope conditions:(NSArray *)conditions;

- (id)initUnionCompositWithArray : (NSArray *)conditions;
- (id)initUnionCompositWithConditions : (id)firstCondition, ...;
- (id)initIntersectionCompositWithArray : (NSArray *)conditions;
- (id)initIntersectionCompositWithConditions : (id)firstCondition, ...;

- (NSString *) conditionString;

- (NSArray *)conditions;
- (SCCOperator)operator;
@end
