#import <ObjcUnit/ObjcUnit.h>
#import <SGFoundation/SGFoundation.h>
#import "UTILTestCase.h"



#define CLOCK_TIMER_BEGIN(loop_time)		\
	{NSDate				*prevClock;\
	int					prevIndex;\
	NSTimeInterval		prevTimeInterval;\
	prevClock = [NSDate date];\
	for(prevIndex = 0; prevIndex < loop_time; prevIndex++){ fprintf(stderr, "."); 


#define CLOCK_TIMER_END_NAME(case_name, loop_time)	}\
	prevTimeInterval = [[NSDate date] timeIntervalSinceDate : prevClock];\
	NSLog(@"\n%-35s%.3f/%d(%.3f)",\
		[(case_name ? case_name : NSStringFromSelector(_cmd)) UTF8String],\
		(prevTimeInterval/loop_time),\
		loop_time,\
		prevTimeInterval); fprintf(stderr, "\n");}

#define CLOCK_TIMER_END_CLASS(class_obj, loop_time)	\
	CLOCK_TIMER_END_NAME(\
	([NSString stringWithFormat : @"%@%@",NSStringFromSelector(_cmd),NSStringFromClass(class_obj)]),		\
		loop_time)


#define CLOCK_TIMER_END(loop_time)	CLOCK_TIMER_END_NAME(nil, loop_time)
