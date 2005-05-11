//:CMRServerClock.m
#import "CMRServerClock_p.h"


@implementation CMRServerClock
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(sharedInstance);

- (void) dealloc
{
	[m_mappingTable release];
	[m_lastAccessedTable release];
	[super dealloc];
}
@end



@implementation CMRServerClock(Accessor)
- (NSMutableDictionary *) mappingTable
{
	if(nil == m_mappingTable)
		m_mappingTable = [[NSMutableDictionary alloc] init];
	return m_mappingTable;
}
- (NSMutableDictionary *) lastAccessedTable
{
	if(nil == m_lastAccessedTable)
		m_lastAccessedTable = [[NSMutableDictionary alloc] init];
	return m_lastAccessedTable;
}
- (void) setTimeIntervalSinceNow : (NSTimeInterval) interval
						 forHost : (NSString	 *) aHost
{
	if(nil == aHost) return;
	
	[[self mappingTable] setObject : [NSNumber numberWithDouble : interval]
							forKey : aHost];
}
@end



@implementation CMRServerClock(Clock)
- (NSTimeInterval) timeIntervalSinceNowForURL : (NSURL *) anURL
{
	return [self timeIntervalSinceNowForHost : [anURL host]];
}
- (NSTimeInterval) timeIntervalSinceNowForHost : (NSString *) aHost
{
	NSNumber		*registered_;
	
	UTILRequireCondition(aHost, not_found);
	registered_ = [[self mappingTable] objectForKey : aHost];
	UTILRequireCondition(registered_, not_found);
	
	UTILAssertKindOfClass(registered_, NSNumber);
	return [registered_ doubleValue];
	
	not_found:
		return 0.0;
}

- (NSDate *) dateFromServerClockForURL : (NSURL *) anURL
{
	return [NSDate dateWithTimeIntervalSinceNow : 
						[self timeIntervalSinceNowForURL : anURL]];
}

- (void) updateClock : (NSDate *) nowDate
			  forURL : (NSURL  *) anURL
{
	NSTimeInterval		intervalSinceNow_;
	
	if(nil == nowDate || nil == anURL) return;
	
	intervalSinceNow_ = [nowDate timeIntervalSinceNow];
	[self setTimeIntervalSinceNow : intervalSinceNow_
						  forHost : [anURL host]];
}
@end



@implementation CMRServerClock(LastAccessedDate)
- (NSDate *) lastAccessedDateForHost : (NSString *) aHost
{
	return [[self lastAccessedTable] objectForKey : aHost];

}
- (void) setLastAccessedDate : (NSDate   *) aDate
					 forHost : (NSString *) aHost;
{
	if(nil == aDate || nil == aHost) return;
	[[self lastAccessedTable] setObject:aDate forKey:aHost];
}

- (NSDate *) lastAccessedDateForURL : (NSURL *) anURL
{
	return [self lastAccessedDateForHost : [anURL host]];
}
- (void) setLastAccessedDate : (NSDate *) aDate
					  forURL : (NSURL  *) anURL
{
	[self setLastAccessedDate:aDate forHost:[anURL host]];
}
@end
