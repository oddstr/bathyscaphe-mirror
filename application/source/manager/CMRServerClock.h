//:CMRServerClock.h
/**
  *
  * �R���s���[�^�����̎��v�Ɗe�T�[�o�̎��v�𒲐߂���B
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (2002//)
  *
  */
#import <Foundation/Foundation.h>



@interface CMRServerClock : NSObject
{
	@private
	NSMutableDictionary		*m_mappingTable;
	NSMutableDictionary		*m_lastAccessedTable;
}
+ (id) sharedInstance;

@end



@interface CMRServerClock(Clock)
- (NSTimeInterval) timeIntervalSinceNowForURL : (NSURL *) anURL;
- (NSTimeInterval) timeIntervalSinceNowForHost : (NSString *) aHost;

- (NSDate *) dateFromServerClockForURL : (NSURL *) anURL;

- (void) updateClock : (NSDate *) nowDate
			  forURL : (NSURL  *) anURL;
@end



@interface CMRServerClock(LastAccessedDate)
- (NSDate *) lastAccessedDateForHost : (NSString *) aHost;
- (void) setLastAccessedDate : (NSDate   *) aDate
					 forHost : (NSString *) aHost;
- (NSDate *) lastAccessedDateForURL : (NSURL *) anURL;
- (void) setLastAccessedDate : (NSDate *) aDate
					  forURL : (NSURL  *) anURL;
@end
