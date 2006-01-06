//
//  SmartCondition.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/12/27.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "SmartCondition.h"

// static NSString *sNameKey = @"name";
static NSString *sAcceptValueTypeKey = @"acceptValueType";

static NSDictionary *sConditionTypes = nil;

@interface SmartCondition(Private)
- (void) _setValue1 : (id) value1;
- (void) _setValue2 : (id) value2;
@end

@implementation SmartCondition

+ (void)initialize
{
	static BOOL isFirst = YES;
//	@synchronized(self) {
	if(isFirst) {
		id file;
		
		isFirst = NO;
		
		file = [[NSBundle mainBundle] pathForResource:@"ConditionTypes" ofType:@"plist"];
		sConditionTypes = [[NSDictionary alloc] initWithContentsOfFile:file];
		UTILAssertNotNil(sConditionTypes);
	}
//	}
}
+ (BOOL) checkCoordinationTarget : (NSString *)target andOperation : (SCOperation)operation
{
	BOOL result = NO;
	id dict = [sConditionTypes objectForKey : target];
	id valueType;
	
	if(!dict) return NO;
	
	valueType = [dict objectForKey : sAcceptValueTypeKey];
	if(!valueType) return NO;
	if(![valueType isKindOfClass : [NSString class]]) return NO;
	
	switch(operation) {
		case SCBeginsWithOperation:
		case SCEndsWithOperation:
		case SCContaionsOperation:
		case SCExactOperation:
			if([valueType isEqualTo : @"NSString"]) {
				result = YES;
			}
			break;
		case SCLargerOperation:
		case SCEqualOperation:
		case SCSmallerOperation:
		case SCRangeOperation:
			if([valueType isEqualTo : @"NSNumber"]
			   || [valueType isEqualTo : @"NSDate"]) {
				result = YES;
			}
			break;
		default:
			// Do nothing.
			break;
	}
	
	return result;
}
+ (BOOL) checkCoordinationTarget : (NSString *)target andValue : (id)value
{
	id dict = [sConditionTypes objectForKey : target];
	id valueType;
	Class valueTypeClass;
	
	if([value isKindOfClass : [NSNull class]]) return YES;
	
	if(!dict) return NO;
	
	valueType = [dict objectForKey : sAcceptValueTypeKey];
	if(!valueType) return NO;
	if(![valueType isKindOfClass : [NSString class]]) return NO;
	valueTypeClass = NSClassFromString(valueType);
	if(!valueTypeClass) return NO;
	
	if([value isKindOfClass : valueTypeClass]) return YES;
	
	if([valueType isEqualTo : @"NSDate"]
	   && [value isKindOfClass : [NSNumber class]]) return YES;
	
	return NO;
}

+ (id) conditionWithTarget : (NSString *)target operation : (SCOperation)operation value : (id)value
{
	return [[[[self class] alloc] initWithTarget : target operation : operation value : value] autorelease];
}
+ (id) conditionWithTarget : (NSString *)target operation : (SCOperation)operation value : (id)value1 value : (id) value2
{
	return [[[[self class] alloc] initWithTarget : target operation : operation value : value1 value : value2] autorelease];
}

- (id) initWithTarget : (NSString *)target operation : (SCOperation)operation value : (id)value
{
	UTILAssertNotNilArgument(target, @"target");
	
	if( self = [super init] ) {
		if(![[self class] checkCoordinationTarget : target andValue : value]) {
			[self release];
			return nil;
		}
		if(![[self class] checkCoordinationTarget : target andOperation : operation]) {
			[self release];
			return nil;
		}
		mTarget = [target retain];
		mOperation = operation;
		[self _setValue1 : value];
	}
	
	return self;
}
- (id) initWithTarget : (NSString *)target operation : (SCOperation)operation value : (id)value1 value : (id) value2
{
	UTILAssertNotNilArgument(target, @"target");
	
	if( self = [super init] ) {
		if(![[self class] checkCoordinationTarget : target andValue : value1]
		   || ![[self class] checkCoordinationTarget : target andValue : value2]) {
			[self release];
			return nil;
		}
		if(![[self class] checkCoordinationTarget : target andOperation : operation]) {
			[self release];
			return nil;
		}
		mTarget = [target retain];
		mOperation = operation;
		[self _setValue1 : value1];
		[self _setValue2 : value2];
	}
	
	return self;
}

- (NSString *)conditionString
{
	NSString *format = nil;
	BOOL useValue2 = NO;
	
	switch(mOperation) {
		case SCBeginsWithOperation:
			format = @"%@ LIKE '%@%%'";
			break;
		case SCEndsWithOperation:
			format = @"%@ LIKE '%%%@'";
			break;
		case SCContaionsOperation:
			format = @"%@ LIKE '%%%@%%'";
			break;
		case SCExactOperation:
			format = @"%@ LIKE '%@'";
			break;
		case SCLargerOperation:
			format = @"%@ > %@";
			break;
		case SCEqualOperation:
			format = @"%@ = %@";
			break;
		case SCSmallerOperation:
			format = @"%@ < %@";
			break;
		case SCRangeOperation:
			format = @"(%@ < %@ AND %@ > %@)";
			useValue2 = YES;
			break;
		default:
			UTILUnknownCSwitchCase(mOperation);
			break;
	}
	
	if(!mTarget) return nil;
	if(!mValue1) return nil;
	if(useValue2 && !mValue2) return nil;
	
	return (useValue2) ? [NSString stringWithFormat : format, mTarget, mValue1, mTarget, mValue2] :
		[NSString stringWithFormat:format, mTarget, mValue1];
		
}

static inline void setValueToValue( id value, id *toValue )
{
	id temp;
	
	UTILCAssertNotNil(toValue);
	
	if([value isKindOfClass : [NSString class]] ) {
		temp = *toValue;
		*toValue = [SQLiteDB prepareStringForQuery : value];
		[*toValue retain];
		[temp release];
	} else if ([value isKindOfClass : [NSNumber class]]
			   ||[value isKindOfClass : [NSNull class]]) {
		temp = *toValue;
		*toValue = [value copy];
		[temp release];
	} else if([value isKindOfClass : [NSDate class]]) {
		temp = *toValue;
		*toValue = [NSNumber numberWithDouble : [value timeIntervalSince1970]];
		[temp release];
	} else {
		NSLog(@"value must be NSString, NSNumber, NSDate or nil");
	}
}
- (void) _setValue1 : (id) value
{
	setValueToValue(value, &mValue1);
}
- (void) _setValue2 : (id) value
{
	setValueToValue(value, &mValue2);
}
@end
