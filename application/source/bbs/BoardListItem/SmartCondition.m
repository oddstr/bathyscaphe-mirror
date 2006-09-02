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
+ (BOOL) checkCoordinationTarget : (NSString *)target andOperator : (SCOperator)operator
{
	BOOL result = NO;
	id dict = [sConditionTypes objectForKey : target];
	id valueType;
	
	if(!dict) return NO;
	
	valueType = [dict objectForKey : sAcceptValueTypeKey];
	if(!valueType) return NO;
	if(![valueType isKindOfClass : [NSString class]]) return NO;
	
	switch(operator) {
		case SCBeginsWithOperator:
		case SCEndsWithOperator:
		case SCContaionsOperator:
		case SCNotContainsOperator:
		case SCExactOperator:
		case SCNotExactOperator:
			if([valueType isEqualTo : @"NSString"]) {
				result = YES;
			}
			break;
		case SCLargerOperator:
		case SCEqualOperator:
		case SCNotEqualOperator:
		case SCSmallerOperator:
		case SCRangeOperator:
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
	
	if(value == [NSNull null]) return YES;
	
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

+ (id) conditionWithTarget : (NSString *)target operator : (SCOperator)operator value : (id)value
{
	return [[[[self class] alloc] initWithTarget : target operator : operator value : value] autorelease];
}
+ (id) conditionWithTarget : (NSString *)target operator : (SCOperator)operator value : (id)value1 value : (id) value2
{
	return [[[[self class] alloc] initWithTarget : target operator : operator value : value1 value : value2] autorelease];
}

- (id) initWithTarget : (NSString *)target operator : (SCOperator)operator value : (id)value
{
	UTILAssertNotNilArgument(target, @"target");
	
	if( self = [super init] ) {
		if(![[self class] checkCoordinationTarget : target andValue : value]) {
			[self release];
			return nil;
		}
		if(![[self class] checkCoordinationTarget : target andOperator : operator]) {
			[self release];
			return nil;
		}
		mTarget = [target retain];
		mOperator = operator;
		[self _setValue1 : value];
	}
	
	return self;
}
- (id) initWithTarget : (NSString *)target operator : (SCOperator)operator value : (id)value1 value : (id) value2
{
	UTILAssertNotNilArgument(target, @"target");
	
	if( self = [super init] ) {
		if(![[self class] checkCoordinationTarget : target andValue : value1]
		   || ![[self class] checkCoordinationTarget : target andValue : value2]) {
			[self release];
			return nil;
		}
		if(![[self class] checkCoordinationTarget : target andOperator : operator]) {
			[self release];
			return nil;
		}
		mTarget = [target retain];
		mOperator = operator;
		
		if(mOperator == SCRangeOperator) {
			if([value1 floatValue] > [value2 floatValue]) {
				id t = value1;
				value1 = value2;
				value2 = t;
			}
		}
		[self _setValue1 : value1];
		[self _setValue2 : value2];
	}
	
	return self;
}

- (NSString *)conditionString
{
	NSString *result = nil;
	NSString *format = nil;
	BOOL useValue2 = NO;
	
	switch(mOperator) {
		case SCBeginsWithOperator:
			format = @"%@ LIKE '%@%%'";
			break;
		case SCEndsWithOperator:
			format = @"%@ LIKE '%%%@'";
			break;
		case SCContaionsOperator:
			format = @"%@ LIKE '%%%@%%'";
			break;
		case SCNotContainsOperator:
			format = @"%@ NOT LIKE '%%%@%%'";
			break;
		case SCExactOperator:
			format = @"%@ LIKE '%@'";
			break;
		case SCNotExactOperator:
			format = @"%@ NOT LIKE '%@'";
			break;
		case SCLargerOperator:
			format = @"%@ > %@";
			break;
		case SCEqualOperator:
			format = @"%@ = %@";
			break;
		case SCNotEqualOperator:
			format = @"%@ != %@";
			break;
		case SCSmallerOperator:
			format = @"%@ < %@";
			break;
		case SCRangeOperator:
			format = @"(%@ > %@ AND %@ < %@)";
			useValue2 = YES;
			break;
		default:
			UTILUnknownCSwitchCase(mOperator);
			break;
	}
	
	if(!mTarget) return nil;
	if(!mValue1) return nil;
	if(useValue2 && !mValue2) return nil;
	
	if(useValue2) {
		result = [NSString stringWithFormat : format, 
			[self key], [self value], [self key], [self value2]];
	} else {
		result = [NSString stringWithFormat:format, [self key], [self value]];
	}
	
	return result;
}

- (NSString *)description
{
	return [self conditionString];
}

static inline void setValueToValue( id value, id *toValue )
{
	UTILCAssertNotNil(toValue);
	
	if([value isKindOfClass : [NSString class]] ) {
		*toValue = [SQLiteDB prepareStringForQuery : value];
		[*toValue retain];
	} else if ([value isKindOfClass : [NSNumber class]]
			   ||value == [NSNull null]) {
		*toValue = [value copy];
	} else if([value isKindOfClass : [NSDate class]]) {
		*toValue = [NSNumber numberWithDouble : [value timeIntervalSince1970]];
		[*toValue retain];
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
- (id)key
{
	return mTarget;
}
- (id)value
{
	return mValue1;
}
- (id)value2
{
	return mValue2;
}
- (SCOperator)operator
{
	return mOperator;
}


#pragma mark## NSCoding ##
static NSString *SCTargetCodingKey = @"SCTargetCodingKey";
static NSString *SCOperationCodingKey = @"SCOperationCodingKey";
static NSString *SCValue1CodingKey = @"SCValue1CodingKey";
static NSString *SCValue2CodingKey = @"SCValue2CodingKey";

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	if([aCoder allowsKeyedCoding]) {
		[aCoder encodeObject:mTarget forKey:SCTargetCodingKey];
		[aCoder encodeObject:[NSNumber numberWithInt:mOperator] forKey:SCOperationCodingKey];
		[aCoder encodeObject:mValue1 forKey:SCValue1CodingKey];
		if(mValue2) {
			[aCoder encodeObject:mValue2 forKey:SCValue2CodingKey];
		}
	} else {
		[aCoder encodeObject:mTarget];
		[aCoder encodeObject:[NSNumber numberWithInt:mOperator]];
		[aCoder encodeObject:mValue1];
		if(mValue2) {
			[aCoder encodeObject:mValue2];
		}
	}
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
	id target,value1, value2 = nil;
	int ope;
	
	if([aDecoder allowsKeyedCoding]) {
		target = [aDecoder decodeObjectForKey:SCTargetCodingKey];
		ope = [[aDecoder decodeObjectForKey:SCOperationCodingKey] intValue];
		value1 = [aDecoder decodeObjectForKey:SCValue1CodingKey];
		value2 = [aDecoder decodeObjectForKey:SCValue2CodingKey];
	} else {
		target = [aDecoder decodeObject];
		ope = [[aDecoder decodeObject] intValue];
		value1 = [aDecoder decodeObject];
		if(ope == SCRangeOperator) {
			value2 = [aDecoder decodeObject];
		}
	}
	
	if(value2) {
		self = [self initWithTarget:target operator:ope value:value1 value:value2];
	} else {
		self = [self initWithTarget:target operator:ope value:value1];
	}
	
	return self;
}

@end

@implementation RelativeDateLiveCondition

- (id)value
{
	NSDate *date = [NSDate dateWithTimeIntervalSinceNow:[mValue1 intValue]];
	
	return [NSNumber numberWithInt:[date timeIntervalSince1970]];
}
- (id)value2
{
	NSDate *date = [NSDate dateWithTimeIntervalSinceNow:[mValue2 intValue]];
	
	return [NSNumber numberWithInt:[date timeIntervalSince1970]];
}

@end


@implementation SmartConditionComposit

NSArray *arrayFromValist( id firstCondition, va_list ap )
{
	id cond;
	NSMutableArray *result = [NSMutableArray array];
	
	cond = firstCondition;
	while( cond ) {
		if(![cond conformsToProtocol:@protocol(SmartCondition)]) {
			return nil;
		}
		[result addObject:cond];
//		NSLog(@"add!!");
		cond = va_arg( ap, id );
	}
	
	return result;
}

+ (id)unionCompositWithArray : (NSArray *)conditions
{
	return [[[[self class] alloc] initUnionCompositWithArray:conditions] autorelease];
}
+ (id)intersectionCompositWithArray : (NSArray *)conditions
{
	return [[[[self class] alloc] initIntersectionCompositWithArray:conditions] autorelease];
}
+ (id)unionCompositWithConditions : (id)firstCondition, ...
{
	va_list ap;
	id result;
	
	va_start(ap, firstCondition);
	result = [[[[self class] alloc] initCompositWithOperator:SCCUnionOperator
												   conditions:arrayFromValist(firstCondition, ap)] autorelease];
	va_end(ap);
	
	return result;
}
+ (id)intersectionCompositWithConditions : (id)firstCondition, ...
{
	va_list ap;
	id result;
	
	va_start(ap, firstCondition);
	result = [[[[self class] alloc] initCompositWithOperator:SCCIntersectionOperator
												   conditions:arrayFromValist(firstCondition, ap)] autorelease];
	va_end(ap);
	
	return result;
}

static inline BOOL checkOperator( SCCOperator ope)
{
	return (ope == SCCUnionOperator || ope == SCCIntersectionOperator) ? YES : NO;
}
static inline BOOL checkConditions( NSArray *conditions)
{
	NSEnumerator *condEnum;
	id obj;
	
	if(!conditions || ![conditions isKindOfClass:[NSArray class]]) return NO;
	if([conditions count] == 0) return NO;
	
	condEnum = [conditions objectEnumerator];
	while((obj = [condEnum nextObject])) {
		if(![obj conformsToProtocol:@protocol(SmartCondition)]) return NO;
	}
	
	return YES;
}
// primitive method.
- (id)initCompositWithOperator:(SCCOperator)ope conditions:(NSArray *)conditions
{
	if(self = [super init]) {
		if(!checkOperator(ope)) {
			goto fail;
		}
		if(!checkConditions(conditions)) {
			goto fail;
		}
		
		mOperator = ope;
		mConditions = [[NSArray alloc] initWithArray:conditions];
	}
	
	return self;
	
fail:{
	[self release];
	return nil;
}
}
- (id)initUnionCompositWithArray : (NSArray *)conditions
{
	return [self initCompositWithOperator:SCCUnionOperator
								conditions:conditions];
}
- (id)initIntersectionCompositWithArray : (NSArray *)conditions
{
	return [self initCompositWithOperator:SCCIntersectionOperator
								conditions:conditions];
}
- (id)initUnionCompositWithConditions : (id)firstCondition, ...
{
	id result;
	va_list ap;
	
	va_start(ap, firstCondition);
	result = [self initUnionCompositWithArray:arrayFromValist(firstCondition, ap)];
	va_end(ap);
	
	return result;
}
- (id)initIntersectionCompositWithConditions : (id)firstCondition, ...
{
	id result;
	va_list ap;
	
	va_start(ap, firstCondition);
	result = [self initIntersectionCompositWithArray:arrayFromValist(firstCondition, ap)];
	va_end(ap);
	
	return result;
}

- (NSString *) conditionString
{
	NSMutableString *result;
	NSString *comp = nil;
	
	switch(mOperator) {
		case SCCUnionOperator:
			comp = @") AND (";
			break;
		case SCCIntersectionOperator:
			comp = @") OR (";
			break;
		default:
			UTILUnknownSwitchCase(mOperator);
			break;
	}
	
	result = [NSMutableString stringWithString:@"("];
	
	[result appendString:[mConditions componentsJoinedByString:comp]];
	
	[result appendString:@")"];
	
	return result;
}

- (NSString *)description
{
	return [self conditionString];
}

- (NSArray *)conditions
{
	return mConditions;
}
- (SCCOperator)operator
{
	return mOperator;
}

#pragma mark## NSCoding ##
static NSString *SCCOperationCodingKey = @"SCOperationCodingKey";
static NSString *SCCConditionsCodingKey = @"SCValue1CodingKey";

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	if([aCoder allowsKeyedCoding]) {
		[aCoder encodeObject:[NSNumber numberWithInt:mOperator] forKey:SCCOperationCodingKey];
		[aCoder encodeObject:mConditions forKey:SCCConditionsCodingKey];
	} else {
		[aCoder encodeObject:[NSNumber numberWithInt:mOperator]];
		[aCoder encodeObject:mConditions];
	}
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
	id cond;
	int ope;
	
	if([aDecoder allowsKeyedCoding]) {
		ope = [[aDecoder decodeObjectForKey:SCCOperationCodingKey] intValue];
		cond = [aDecoder decodeObjectForKey:SCCConditionsCodingKey];
	} else {
		ope = [[aDecoder decodeObject] intValue];
		cond = [aDecoder decodeObject];
	}
	
	return [self initCompositWithOperator:ope conditions:cond];
}
@end
