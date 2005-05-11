//:CMRThreadLinkProcessor.h
/**
  *
  * ÉäÉìÉNèàóù
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (03/01/17  2:32:54 AM)
  *
  */
#import <Cocoa/Cocoa.h>
#import "CMRMessageAttributesStyling.h"

@class SGBaseRangeArray;



@interface CMRThreadLinkProcessor : NSObject
+ (BOOL) parseThreadLink : (id         ) aLink
               boardName : (NSString **) pBoardName
                boardURL : (NSURL    **) pBoardURL
                filepath : (NSString **) pFilepath;
+ (BOOL) isMessageLinkUsingLocalScheme : (id                ) aLink
							rangeArray : (SGBaseRangeArray *) rangeBuffer;

+ (BOOL) isBeProfileLinkUsingLocalScheme : (id		   ) aLink
							   linkParam : (NSString **) aParam;
@end
