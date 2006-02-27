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
		case SCNotContainsOperation:
		case SCExactOperation:
		case SCNotExactOperation:
			if([valueType isEqualTo : @"NSString"]) {
				result = YES;
			}
			break;
		case SCLargerOperation:
		case SCEqualOperation:
		case SCNotEqualOperation:
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
		case SCNotContainsOperation:
			format = @"%@ NOT LIKE '%%%@%%'";
			break;
		case SCExactOperation:
			format = @"%@ LIKE '%@'";
			break;
		case SCNotExactOperation:
			format = @"%@ NOT LIKE '%@'";
			break;
		case SCLargerOperation:
			format = @"%@ > %@";
			break;
		case SCEqualOperation:
			format = @"%@ = %@";
			break;
		case SCNotEqualOperation:
			format = @"%@ != %@";
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
			   ||[value isKindOfClass : [NSNull class]]) {
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


#pragma mark## NSCoding ##
static NSString *SCTargetCodingKey = @"SCTargetCodingKey";
static NSString *SCOperationCodingKey = @"SCOperationCodingKey";
static NSString *SCValue1CodingKey = @"SCValue1CodingKey";
static NSString *SCValue2CodingKey = @"SCValue2CodingKey";

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	if([aCoder allowsKeyedCoding]) {
		[aCoder encodeObject:mTarget forKey:SCTargetCodingKey];
		[aCoder encodeObject:[NSNumber numberWithInt:mOperation] forKey:SCOperationCodingKey];
		[aCoder encodeObject:mValue1 forKey:SCValue1CodingKey];
		if(mValue2) {
			[aCoder encodeObject:mValue2 forKey:SCValue2CodingKey];
		}
	} else {
		[aCoder encodeObject:mTarget];
		[aCoder encodeObject:[NSNumber numberWithInt:mOperation]];
		[aCoder encodeObject:mValue1];
		if(mValue2) {
			[aCoder encodeObject:mValue2];
		}
	}
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
	id target,value1, value2;
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
		value2 = [aDecoder decodeObject];
	}
	
	if(value2) {
		self = [self initWithTarget:target operation:ope value:value1 value:value2];
	} else {
		self = [self initWithTarget:target operation:ope value:value1];
	}
	
	return self;
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
	result = [[[[self class] alloc] initCompositWithOperation:SCCUnionOperation
												   conditions:arrayFromValist(firstCondition, ap)] autorelease];
	va_end(ap);
	
	return result;
}
+ (id)intersectionCompositWithConditions : (id)firstCondition, ...
{
	va_list ap;
	id result;
	
	va_start(ap, firstCondition);
	result = [[[[self class] alloc] initCompositWithOperation:SCCIntersectionOperation
												   conditions:arrayFromValist(firstCondition, ap)] autorelease];
	va_end(ap);
	
	return result;
}

static inline BOOL checkOperation( SCCOperation ope)
{
	return (ope == SCCUnionOperation || ope == SCCIntersectionOperation) ? YES : NO;
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
- (id)initCompositWithOperation:(SCCOperation)ope conditions:(NSArray *)conditions
{
	if(self = [super init]) {
		if(!checkOperation(ope)) {
			goto fail;
		}
		if(!checkConditions(conditions)) {
			goto fail;
		}
		
		mOperation = ope;
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
	return [self initCompositWithOperation:SCCUnionOperation
								conditions:conditions];
}
- (id)initIntersectionCompositWithArray : (NSArray *)conditions
{
	return [self initCompositWithOperation:SCCIntersectionOperation
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
	
	switch(mOperation) {
		case SCCUnionOperation:
			comp = @") AND (";
			break;
		case SCCIntersectionOperation:
			comp = @") OR (";
			break;
		default:
			UTILUnknownSwitchCase(mOperation);
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
- (SCCOperation)operation
{
	return mOperation;
}

#pragma mark## NSCoding ##
static NSString *SCCOperationCodingKey = @"SCOperationCodingKey";
static NSString *SCCConditionsCodingKey = @"SCValue1CodingKey";

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	if([aCoder allowsKeyedCoding]) {
		[aCoder encodeObject:[NSNumber numberWithInt:mOperation] forKey:SCCOperationCodingKey];
		[aCoder encodeObject:mConditions forKey:SCCConditionsCodingKey];
	} else {
		[aCoder encodeObject:[NSNumber numberWithInt:mOperation]];
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
	
	return [self initCompositWithOperation:ope conditions:cond];
}
@end
