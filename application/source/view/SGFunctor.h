//:SGFunctor.h
/**
  *
  * 
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (02/11/12  8:23:14 PM)
  *
  */
#import <Foundation/Foundation.h>



@protocol SGFunctor<NSObject>
- (void) execute : (id) sender;
@end



@interface SGFunctor : NSObject<SGFunctor>
{
	id		m_objectValue;
}
+ (id) functorWithObject : (id) obj;
- (id) initWithObject : (id) obj;
- (id) objectValue;
- (void) setObjectValue : (id) anObjectValue;
@end
