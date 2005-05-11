//:CMRServerClock_p.h
#import "CMRServerClock.h"
#import "CocoMonar_Prefix.h"



@interface CMRServerClock(Accessor)
- (NSMutableDictionary *) mappingTable;
- (NSMutableDictionary *) lastAccessedTable;

- (void) setTimeIntervalSinceNow : (NSTimeInterval) interval
						 forHost : (NSString	 *) aHost;
@end