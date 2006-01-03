//
//  SmartCondition.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/12/27.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DatabaseManager.h"

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


@interface SmartCondition : NSObject
{
	@private
	id mTarget;
	SCOperation mOperation;
	id mValue1;
	id mValue2;
}


+ (id) conditionWithTarget : (NSString *)target operation : (SCOperation)operation value : (id)value;
+ (id) conditionWithTarget : (NSString *)target operation : (SCOperation)operation value : (id)value value : (id) value;

- (id) initWithTarget : (NSString *)target operation : (SCOperation)operation value : (id)value;
- (id) initWithTarget : (NSString *)target operation : (SCOperation)operation value : (id)value value : (id) value;

- (NSString *)conditionString;

@end
