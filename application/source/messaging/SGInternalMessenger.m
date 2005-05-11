//: SGInternalMessaging.m
/**
  * $Id: SGInternalMessenger.m,v 1.1.1.1 2005/05/11 17:51:05 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "SGInternalMessenger_p.h"

#import "SGRunLoopMessenger.h"



NSThread			*CMRMainThread    = nil;
NSRunLoop			*CMRMainRunLoop   = nil;
SGInternalMessenger	*CMRMainMessenger = nil;

NSString *const SGInternalMessengerSendException = @"SGInternalMessengerSendException";


@implementation SGInternalMessenger
+ (id) currentMessenger
{
	return [SGRunLoopMessenger currentMessenger];
}

- (void) invokeMessage : (NSInvocation *) anInvocation
            withResult : (BOOL          ) aResultFlag
{
	UTILAbstractMethodInvoked;
}

- (void)  target : (id ) aTarget
 performSelector : (SEL) aSelector
{
	[self target:aTarget performSelector:aSelector withResult:NO];
}

- (void)  target : (id ) aTarget
 performSelector : (SEL) aSelector
      withObject : (id ) anObject
{
	[self target:aTarget performSelector:aSelector withObject:anObject withResult:NO];
}

- (void)  target : (id ) aTarget
 performSelector : (SEL) aSelector
      withObject : (id ) anObject
      withObject : (id ) anotherObject
{
	[self target:aTarget performSelector:aSelector withObject:anObject withObject:anotherObject withResult:NO];

}

- (id)    target : (id  ) aTarget
 performSelector : (SEL ) aSelector
      withResult : (BOOL) expectResult
{
	return [self target:aTarget performSelector:aSelector withObject:nil withObject:nil withResult:expectResult];
}

- (id)    target : (id  ) aTarget
 performSelector : (SEL ) aSelector
      withObject : (id  ) anObject
      withResult : (BOOL) expectResult
{
	return [self target:aTarget performSelector:aSelector withObject:anObject withObject:nil withResult:expectResult];
}

- (id)    target : (id  ) aTarget
 performSelector : (SEL ) aSelector
      withObject : (id  ) anObject
      withObject : (id  ) anotherObject
      withResult : (BOOL) expectResult
{
    NSMethodSignature *method;
    NSInvocation      *invocation;
    id                 resultValue = nil;
    unsigned           nArgments;
    
    method = [aTarget methodSignatureForSelector : aSelector];
    invocation = [NSInvocation invocationWithMethodSignature : method];

    [invocation setSelector : aSelector];
    [invocation setTarget : aTarget];
    
    // self‚Æ_cmd
    nArgments = [method numberOfArguments];
    NSAssert2(
        nArgments >= 2,
        @"-numberOfArguments was at least %u or more. but was %u.",
        2,
        nArgments);
    if (nArgments >= 3)
        [invocation setArgument:&anObject atIndex:2];
    
    if (nArgments >= 4)
        [invocation setArgument:&anotherObject atIndex:3];
    
    [invocation retain];
    [self invokeMessage:invocation withResult:expectResult];
    
    if (expectResult && [method methodReturnLength]) {
        [invocation getReturnValue : &resultValue];
    }
    [invocation release];
    
    return resultValue;
}


- (void) postNotification : (NSNotification *) aNotification
{
	[self postNotification:aNotification synchronized:NO];
}
- (void) postNotification : (NSNotification *) aNotification
			 synchronized : (BOOL            ) sync;
{
	[self target : [NSNotificationCenter defaultCenter]
 performSelector : @selector(postNotification:)
	  withObject : aNotification
	  withResult : sync];
}
- (void) postNotificationName : (NSString     *) aNotificationName
					   object : (id            ) anObject
{
	[self postNotificationName:aNotificationName object:anObject userInfo:nil];
}
- (void) postNotificationName : (NSString     *) aNotificationName
					   object : (id            ) anObject
					 userInfo : (NSDictionary *) aUserInfo
{
	NSNotification		*notification_;
	
	notification_ = 
		[NSNotification notificationWithName : aNotificationName 
									  object : anObject
									userInfo : aUserInfo];
	[self postNotification : notification_];
}
@end



@implementation SGInternalMessenger(CMXAdditions)
- (void *)    target : (id    ) aTarget
     performSelector : (SEL   ) aSelector
            argument : (void *) param
          withResult : (BOOL  ) aResultFlag
{
	return [self target:aTarget performSelector:aSelector argument:param argument:NULL withResult:aResultFlag];
}

- (void *)    target : (id    ) aTarget
     performSelector : (SEL   ) aSelector
            argument : (void *) param1
            argument : (void *) param2
          withResult : (BOOL  ) expectResult
{
	NSMethodSignature	*method_;
	NSInvocation		*invocation_;
	void				*resultValue_ = nil;
	unsigned			nArgments_;
	
	method_ = [aTarget methodSignatureForSelector : aSelector];
	invocation_ = [NSInvocation invocationWithMethodSignature : method_];

	[invocation_ setSelector : aSelector];
	[invocation_ setTarget : aTarget];
	
	// self‚Æ_cmd
	nArgments_ = [method_ numberOfArguments];
	NSAssert2(
		nArgments_ >= 2,
		@"-numberOfArguments was at least %u or more. but was %u.",
		2,
		nArgments_);
	if (nArgments_ >= 3)
		[invocation_ setArgument:param1 atIndex:2];
	
	if (nArgments_ >= 4)
		[invocation_ setArgument:param2 atIndex:3];
	
	
	
	[invocation_ retain];
	[self invokeMessage:invocation_ withResult:expectResult];
	
	if (expectResult && [method_ methodReturnLength]) {
		
		[invocation_ getReturnValue : &resultValue_];
	}
	[invocation_ release];
	
	return resultValue_;
}

@end


